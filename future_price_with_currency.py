import pandas as pd
import numpy as np
import tqdm
import argparse
import datetime
from monthdelta import monthdelta
import sys
import pickle
import os
import csv

class AverageMeter():
    def __init__(self):
        self.sum = 0
        self.count = 0
        self.val = None
        self.currency = set()
    def update(self, val, currency=None):
        self.sum += val
        self.count += 1
        self.val = val
        if currency:
            self.currency.add(currency)
    def average(self):
        if self.count == 0: return None
        return self.sum / self.count

parser = argparse.ArgumentParser()
parser.add_argument('--cs', default='compustat2008-2018.csv', type=str)
parser.add_argument('-c', '--calculate', action='store_true', help='recalculate search_dict')
parser.add_argument('--out', default='compustat2008-2018_new_0320.csv', type=str)

args = parser.parse_args()

cs_path = args.cs

cs = pd.read_csv(cs_path, low_memory=False, encoding='latin-1')
# cs = cs[['gvkey','fyear','fyr','curcd']] # TODO: remember to uncomment!!
cs = cs.assign(year = lambda x: x.fyear)
cs = cs.assign(month = lambda x: x.fyr)
cs.loc[cs['fyr'].astype(int)<=5, 'year'] += 1

# plus 3 month
cs = cs.assign(yfuture = lambda x: x.year)
cs = cs.assign(mfuture = lambda x: x.fyr)
cs.loc[cs['fyr'].astype(int)>=10, 'yfuture'] += 1
cs.loc[cs['fyr'].astype(int)<10, 'mfuture'] += 3
cs.loc[cs['fyr'].astype(int)>=10, 'mfuture'] -= 9


def iter_chunk(file, search_dict):
    '''iterate over stockprice data, compute average for corresponding day and month'''
    csv_reader = pd.read_csv(file, iterator=True, chunksize=1, header=None)
    global header
    header = csv_reader.get_chunk()
    first_chunk = csv_reader.get_chunk()
    gvkey = int(first_chunk.iloc[0,0])
    keep = False; counter = 1 # 'keep' means gvkey is correct
    if gvkey in search_dict.keys():
        date = first_chunk.iloc[0,2].astype(str)
        if (first_chunk.iloc[0,1] == first_chunk.iloc[0,8]) and ((int(date[0:4]), int(date[4:6])) in search_dict[gvkey].keys()):
            search_dict[gvkey][(int(date[0:4]), int(date[4:6]))][0].update(first_chunk.iloc[0,5], first_chunk.iloc[0,3])
            search_dict[gvkey][(int(date[0:4]), int(date[4:6]))][1] = first_chunk.iloc[0,4]
        keep = True

    for i, row in enumerate(csv_reader):
        sys.stdout.write('Processing: %d, gvkey: %d  \r' % (i, gvkey))
        sys.stdout.flush()
        if gvkey == int(row.iloc[0,0]):
            if not keep: continue
            # if gvkey == 101933: import ipdb; ipdb.set_trace() # 21497
            if row.iloc[0,1] != row.iloc[0,8]: continue
            date = row.iloc[0,2].astype(str)
            if (int(date[0:4]), int(date[4:6])) in search_dict[gvkey].keys():
                search_dict[gvkey][(int(date[0:4]), int(date[4:6]))][0].update(row.iloc[0,5], row.iloc[0,3])
                search_dict[gvkey][(int(date[0:4]), int(date[4:6]))][1] = row.iloc[0,4]
                sys.stdout.write('gvkey: %d, (%d, %d) \r' % (gvkey, int(date[0:4]), int(date[4:6])))
                sys.stdout.flush()
            continue
        gvkey = int(row.iloc[0,0])
        keep = False
        if gvkey in search_dict.keys():
            keep = True
            date = row.iloc[0,2].astype(str)
            if row.iloc[0,1] != row.iloc[0,8]: continue
            if (int(date[0:4]), int(date[4:6])) in search_dict[gvkey].keys():
                # TODO: all ZAR, so no need to convert currency
                search_dict[gvkey][(int(date[0:4]), int(date[4:6]))][0].update(row.iloc[0,5], row.iloc[0,3])
                search_dict[gvkey][(int(date[0:4]), int(date[4:6]))][1] = row.iloc[0,4]
    return search_dict

# transfer currency dictionary
comp_curr = False
if comp_curr:
    currency_transfer = {}
    with open('currency/annual_average.csv', 'r') as f:
        reader = csv.reader(f, delimiter=',')
        for i, row in enumerate(reader):
            code = row[0]
            if code == 'AL': code = 'AUD'
            if code == 'EU': code = 'EUR'
            if code == 'UK': code = 'GBP'
            if code == 'SI': code = 'SGD'
            year = int(row[1])
            price = float(row[2])
            if code not in currency_transfer.keys():
                currency_transfer[code] = {year: price}
            else:
                currency_transfer[code][year] = price

    currency_transfer['USD'] = currency_transfer['SF'].copy() # shallow
    for year in range(2009, 2017):
        currency_transfer['AUD'][year] /= currency_transfer['SF'][year]
        currency_transfer['EUR'][year] /= currency_transfer['SF'][year]
        currency_transfer['GBP'][year] /= currency_transfer['SF'][year]
        currency_transfer['SGD'][year] /= currency_transfer['SF'][year]
        currency_transfer['USD'][year] = 1 / currency_transfer['SF'][year]

    with open('currency_transfer_0320.pkl', 'wb') as f:
        pickle.dump(currency_transfer, f)
else:
    with open('currency_transfer_0320.pkl', 'rb') as f:
        currency_transfer = pickle.load(f)

# search from stock price
global search_dict
if os.path.exists('search_dict_0320.pkl') and not args.calculate:
    with open('search_dict_0320.pkl', 'rb') as f:
        search_dict = pickle.load(f)
    dict_loaded = True
else:
    dict_loaded = False
    search_dict = {}
    for i, row in tqdm.tqdm(cs.iterrows()):
        gvkey = row['gvkey']
        if gvkey not in search_dict.keys():
            search_dict[gvkey] = {(row['yfuture'], row['mfuture']) : [AverageMeter(), None]}
        else:
            search_dict[gvkey][(row['yfuture'], row['mfuture'])] = [AverageMeter(). None]

    stockprice_path = 'stockprice_0319.csv' # stockprice_full_currency, stockprice_0921
    search_dict = iter_chunk(stockprice_path, search_dict)

if not dict_loaded:
    with open('search_dict_0321.pkl', 'wb') as f:
        pickle.dump(search_dict, f)
    print('search_dict_0321.pkl saved')

# compute average, adjust currency
cs['pday_future'] = pd.Series()
cs['pmonth_future'] = pd.Series()
cs['cshocday_future'] = pd.Series()
for i, row in tqdm.tqdm(cs.iterrows()):
    gvkey = row['gvkey']
    avgmeter = search_dict[gvkey][(row['yfuture'], row['mfuture'])][0]
    cshoc = search_dict[gvkey][(row['yfuture'], row['mfuture'])][1]
    pavg = avgmeter.average()
    curr = avgmeter.currency
    if not pavg:
        print(gvkey, (row['yfuture'], row['mfuture']), curr, 'no observation')
        continue
    if len(curr) != 1:
        print(gvkey, (row['yfuture'], row['mfuture']), curr, 'multiple currency')
        continue
    print(gvkey, (row['yfuture'], row['mfuture']), curr)
    # else:
        # print(gvkey, (row['yfuture'], row['mfuture']), curr)
    pval = avgmeter.val
    # if row['curcd'] != list(curr)[0]: import ipdb; ipdb.set_trace()
    if list(curr)[0] == 'ZAR':
        cs.loc[i, 'pday_future'] = pval
        cs.loc[i, 'pmonth_future'] = pavg
        cs.loc[i, 'cshocday_future'] = cshoc
    # print(list(curr)[0])
import ipdb; ipdb.set_trace()
cs.to_csv(args.out, index=False)
print('file saved to %s' % args.out)
    # import ipdb; ipdb.set_trace()

