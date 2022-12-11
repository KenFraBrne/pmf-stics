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
    mapper = lambda header: str.lower(unidecode.unidecode(header)).replace('...oe.','')
    df = df.rename(mapper, axis='columns')

    # if 'secer' range (or object) average it
    if 'secer' in df.dtypes.index.values:
        if df.dtypes.loc['secer'] == 'object':
            df['secer'] = [ np.mean(list(map(int, string.split('-')))) for string in df['secer'] ]

    # choose columns
    columns = {
        'berba': 'year',
        'pupanje_doy': 'ilevs',
        'cvatnja_doy': 'iflos',
        'berba_doy': 'irecs',
        'secer': 'H2Orec_percent' # ali Oechsle
    }

    # column intersection
    intersect = [ x for x in columns.keys() if x in df.columns ]
    df = df[intersect]
    df = df.rename(columns=columns)

    # add nans for missing columns
    for column in columns.values():
        if column not in df.columns:
            df[column] = np.NaN
    df = df[columns.values()]

    # change Oechsle() to H2O in percent
    # - sg = 1 + Oe/1000
    # - Be = 145 * ( 1 - 1/sg )
    # - Br = 1.905*Be - 1.6 ( Ball, 2006 )
    # - WC = -0.82 * Br + 94.40 ( Garcia de Cortazar, 2009 )
    if 'secer' in intersect:
        Oe = df['H2Orec_percent']
        sg = 1+Oe/1000
        Be = 145*(1-1/sg)
        Br = 1.905*Be-1.6
        WC = -0.82*Br+94.40
        df['H2Orec_percent'] = WC

    # dropna
    ind = df.irecs.isna()
    df = df[~ind]

    # df to obs
    ian = df['year']
    irecs = df['irecs']
    datetimes = [ np.datetime64('%i-01-01' % year) + np.timedelta64(int(doy), 'D') for year, doy in zip(ian,irecs)]
    mo = [ datetime.astype(object).month for datetime in datetimes ]
    jo = [ datetime.astype(object).day for datetime in datetimes ]
    jul = irecs
    df.insert(0, 'jul', jul)
    df.insert(0, 'jo', jo)
    df.insert(0, 'mo', mo)
    df.insert(0, 'ian', ian)

    # dates + 365
    df['ilevs']+=365
    df['iflos']+=365
    df['irecs']+=365

    # remove year
    df = df.drop('year', axis=1)

    # fillna
    df = df.fillna(-999)

    # astype(int)
    for column in ['jul', 'ilevs', 'iflos', 'irecs']:
        if column in df.columns:
            df[column] = df[column].astype(int)

    # print
    city, usm = re.findall('[a-zA-Z]{1,}_[a-zA-Zš]{1,}_TOT', file)[0][:-4].split('_')
    usm = unidecode.unidecode(usm)
    workspace = 'simulate/%s' % usm
    os.makedirs(workspace, exist_ok=True)
    path = workspace + '/%s.obs' % city
    df.to_csv(path, sep=';', index=False)

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
