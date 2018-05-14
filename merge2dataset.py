import pandas as pd
import argparse
import pickle

parser = argparse.ArgumentParser()
parser.add_argument('--cs', default='compustat2008-2018.csv', type=str)
parser.add_argument('--ibes', default='Analyst following.csv', type=str)
parser.add_argument('--age', default='age.csv', type=str)
parser.add_argument('--rolling', default=5, type=int)
parser.add_argument('--out', default='compustat_merged.csv', type=str)

args = parser.parse_args()

cs_path = args.cs
ibes_path = args.ibes
age_path = args.age

cs = pd.read_csv(cs_path, low_memory=False, encoding='latin-1')
ibes = pd.read_csv(ibes_path, low_memory=False)
age = pd.read_csv(age_path, low_memory=False)

# merge ibes dataset
cs['sedol_6'] = cs['sedol'].str[0:6] # first 6 digits
ibes['sedol_6'] = ibes['CUSIP'].str[2::] # last 6 digits
# convert calendar date to fyear - June-Dec=current; Jan-May=last.
ibes['fyear'] = ibes['FPEDATS'].astype(str).str[0:4].astype(int)
ibes.loc[ibes['FPEDATS'].astype(str).str[4:6].astype(int)<=5, 'fyear'] -= 1
# calculate rolling average
ibes_small = ibes.groupby(['sedol_6','fyear'], as_index=False)['NUMEST'].mean()
import ipdb; ipdb.set_trace()
new_cs = cs.merge(ibes_small, how='left', left_on=['sedol_6','fyear'] ,right_on=['sedol_6','fyear'])
# calculating coefficient of variant
new_cs['nicon_zar'] = new_cs['nicon']

with open('currency_transfer_0320.pkl', 'rb') as f:
    curr_transfer = pickle.load(f)

for i, row in new_cs.iterrows():
    if (row['curcd'] != 'ZAR') and (row['fyear']>2008):
        curr = row['curcd']
        year = row['fyear']
        new_cs['nicon_zar'][i] *= curr_transfer[curr][year]

import ipdb; ipdb.set_trace()
new_cs['nicon_coef_var'] = (new_cs.groupby('gvkey')['nicon_zar'].rolling(args.rolling).std() / \
      new_cs.groupby('gvkey')['nicon_zar'].rolling(args.rolling).mean()).reset_index(level=0, drop=True)
# merge age dataset
getage = lambda df: df - df.min() + 1
age['age'] = age.groupby('gvkey')['fyear'].transform(getage)
age_small = pd.concat([age['gvkey'], age['fyear'], age['fyr'], age['age']], axis=1, keys=['gvkey','fyear', 'fyr', 'comp_age'])
new_cs = new_cs.merge(age_small, how='left', left_on=['gvkey','fyear','fyr'] ,right_on=['gvkey','fyear','fyr'])
# drop compst != ''
# new_cs = new_cs.drop(new_cs[new_cs['compst'].notnull()].index)
# drop duplicated records (diff fyr)
# new_cs = new_cs.drop(new_cs.duplicated(subset=['gvkey','fyear']).index)
new_cs.to_csv(args.out, index=False)
print('file saved to %s' % args.out)
