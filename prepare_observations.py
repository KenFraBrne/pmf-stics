#!/usr/bin/python3

import re
import os
import unidecode
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.model_selection import KFold

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
        'sara_doy': 'ilaxs',
        'berba_doy': 'irecs',
        'secer': 'H2Orec_percent' # ali Oechsle
    }

    # column intersection
    intersect = [ x for x in columns.keys() if x in df.columns ]
    df = df[intersect]
    df = df.rename(columns=columns)

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

    # drop NaN rows
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
    for column in df.columns:
        if column in ['ilevs', 'iflos', 'ilaxs', 'irecs']:
            df[column]+=365

    # remove year
    df = df.drop('year', axis=1)

    # fillna
    df = df.fillna(-999)

    # astype(int)
    for column in ['jul', 'ilevs', 'iflos', 'ilaxs', 'irecs']:
        if column in df.columns:
            df[column] = df[column].astype(int)

    # print
    kfolds = KFold().split(df)
    for split, (train, test) in enumerate(kfolds):
        city, usm = re.findall('[a-zA-Z]{1,}_[a-zA-Zš]{1,}_TOT', file)[0][:-4].split('_')
        usm = unidecode.unidecode(usm)
        workspace = 'simulate/%s' % usm
        os.makedirs(workspace, exist_ok=True)
        path_train = workspace + '/%s_train_%d.obs' % (city, split)
        path_test = workspace + '/%s_test_%d.obs' % (city, split)
        df.iloc[train].to_csv(path_train, sep=';', index=False)
        df.iloc[test].to_csv(path_test, sep=';', index=False)

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
