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

    # city
    city = re.findall('\/\D{1,10}_TOT', file)[0][1:-4]

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

    # find simulate dirs for the city
    path = 'simulate/%s_*/' % city
    paths = glob.glob(path)
    if len(paths) == 0:
        return

    # print per year
    for path in paths:
        years = df_stics.iloc[:,1]
        for year in years:
            file = path + '%s.%i' % ( city, year )
            ind = years == year
            df_stics[ind].to_csv(file, sep=' ', header=False, index=False)

if __name__ == '__main__':

    # files
    path = 'data/climate/'
    files = os.listdir(path)
    files = [ path + file for file in files ]

    # generate
    for file in files:
        generate_climate(file)
