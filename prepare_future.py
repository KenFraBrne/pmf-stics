#!/usr/bin/python3

import re
import os
import glob
import numpy as np
import pandas as pd

def e0(T):
    return 0.6108*np.exp(17.27*T/(273.15+T))

def generate_climate(file):

    # read_csv
    df = pd.read_csv(file)

    # interpolate missing
    df = df.interpolate()

    # df_stics
    df_stics = pd.DataFrame(
        index = range(df.shape[0]),
        columns = range(13),
    )

    # city, model, scenario
    city = re.findall('\/\D{1,10}_[0-9]{4}', file)[0][1:-5]
    model = re.findall('\d{4}_\d{4}.*csv', file)[0][0:-4]
    scenario = file.split('/')[3]

    # fill columns
    df_stics[0] = [ '%s_%i' % (city, year) for year in df.Year ]
    df_stics[1] = df.Year
    df_stics[2] = df.Month
    df_stics[3] = df.Day
    df_stics[4] = df.DOY
    df_stics[5] = df.Tmin
    df_stics[6] = df.Tmax
    df_stics[7] = df.Rs
    df_stics[8] = df.ET0
    df_stics[9] = df.ob
    df_stics[10] = df.vj_ms
    df_stics[11] = 10*e0((df.Tmin+df.Tmax)/2)*df.RH/100
    df_stics[12] = 320 + (420-320)*(df.Year-1960)/(2020-1960)

    # print per year
    years = df_stics.iloc[:,1]
    observations = glob.glob('simulate/*/%s.obs' % city)
    for observation in observations:
        if city in observation:
            for year in years.unique():
                file = os.path.dirname(observation) + '/%s_%s_%s.%i' % ( city, model, scenario, year )
                print(file)
                df_stics[ years == year ].to_csv(file, sep=' ', header=False, index=False)

def main():

    # files
    path = 'data/climate/Klimatski_modeli_dio?/*/*.csv'
    files = glob.glob(path)
    files.sort()

    # generate
    for file in files:
        generate_climate(file)

if __name__ == '__main__':
    main()
