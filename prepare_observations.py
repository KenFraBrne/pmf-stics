#!/usr/bin/python3

import re
import os
import unidecode
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

def generate_obs(file):

    # df
    df = pd.read_csv(file)

    # remove index column
    df = df.iloc[:,1:]

    # change headers
    mapper = lambda header: str.lower(unidecode.unidecode(header))
    df = df.rename(mapper, axis='columns')

    # choose columns
    columns = {
        'berba': 'year',
        'pupanje_doy': 'ilevs',
        'cvatnja_doy': 'iflos',
        'berba_doy': 'irecs',
    }

    # if data not complete - exit
    keys = columns.keys()
    is_complete = [ key in df.columns for key in keys ]
    if not all(is_complete):
        # print('data not complete in %s' % file)
        return

    # rename
    df = df[list(columns.keys())]
    df = df.rename(columns=columns)
    df = df.set_index('year')

    # create obs dfs
    df_years = pd.DataFrame()
    for year, row in df.iterrows():
        datetime = np.datetime64('%i-01-01' % year)
        columns = ['ian', 'mo', 'jo', 'jul'] + list(df.columns)
        df_year = pd.DataFrame(columns=columns)
        for var in row.index:
            doy = row[var].astype(int)
            datetime_pheno = datetime + np.timedelta64(doy, 'D')
            if np.isnat(datetime_pheno) == False:
                dyear = datetime_pheno.astype(object).year
                dmonth = datetime_pheno.astype(object).month
                dday = datetime_pheno.astype(object).day
                data = {
                    'ian': dyear,
                    'mo': dmonth,
                    'jo': dday,
                    'jul': doy,
                    var: doy+365,
                }
                df_year = df_year.append(data, ignore_index=True)
        df_year = df_year.ffill()
        df_year = df_year.fillna(-999.99)
        df_years = df_years.append(df_year, ignore_index=True)
    df_years = df_years.astype({
        'ian': 'int32',
        'mo': 'int32',
        'jo': 'int32',
        'jul': 'int32',
    })

    # print
    city, usm = re.findall('[a-zA-Z]{1,}_[a-zA-Zš]{1,}_TOT', file)[0][:-4].split('_')
    usm = unidecode.unidecode(usm)
    workspace = 'simulate/%s' % usm
    os.makedirs(workspace, exist_ok=True)
    path = workspace + '/%s.obs' % city
    df_years.to_csv(path, sep=';', index=False)

def main():
    # files
    path = 'data/phenology'
    files = os.listdir(path)
    files = [ path + '/' + file for file in files if 'csv_no' not in file ]
    files.sort()

    # generate
    for file in files:
        generate_obs(file)

if __name__ == '__main__':
    main()
