import csv
import pandas as pd
import tqdm
import pickle
import os

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


def f2c(year, month):
    '''input fyear, fyear end month; return calendar start date + end date'''
    if month <= 5:
        start_date = str(year) + str(month+1).zfill(2) + '01'
        end_date = str(year+1) + str(month+1).zfill(2) + '01'
    elif month == 12:
        start_date = str(year) + '0101'
        end_date = str(year+1) + '0101'
    else:
        start_date = str(year-1) + str(month+1).zfill(2) + '01'
        end_date = str(year) + str(month+1).zfill(2) + '01'
    assert len(start_date) == 8
    assert len(end_date) == 8
    assert end_date > start_date
    return start_date, end_date

cs_path = 'compustat_merged_0313_new.csv'
stockprice_path = 'stockprice_0319.csv'

cs = pd.read_csv(cs_path, low_memory=False, encoding='latin-1')
cs = cs[['gvkey', 'fyear', 'fyrc', 'curcd', 'prirow']]

# Get dictionary to record start_calendar_day amd emd_calendar_day
pre_load = True

if pre_load and os.path.exists('fyear_end_month.pkl'):
    with open('fyear_end_month.pkl', 'rb') as f:
        month_dict = pickle.load(f)

else:
    with open(stockprice_path, 'r') as f:
        reader = csv.reader(f, delimiter=',')
        month_dict = {}
        for i, j in tqdm.tqdm(enumerate(reader)):
            if i == 0: print(j); continue
            if j[1] != j[-1]: continue
            gvkey = int(j[0])
            try:
                data = cs[cs.gvkey==gvkey][['fyear', 'fyrc', 'curcd']]
                if gvkey not in month_dict.keys():
                    month_dict[gvkey] = {}
                for idx, row in data.iterrows():
                    if row['fyear'] in month_dict[gvkey].keys(): continue
                    start, end = f2c(row['fyear'], row['fyrc'])
                    curr = row['curcd']
                    if curr != 'ZAR': print(gvkey, start, end, curr)
                    month_dict[gvkey][row['fyear']] = {'f_month_end': row['fyrc'],
                                                       'start_date': start,
                                                       'end_date': end,
                                                       'curr': curr,
                                                       'meter': AverageMeter()}
            except KeyError:
                continue

if not pre_load:
    with open('fyear_end_month.pkl', 'wb') as f:
        pickle.dump(month_dict, f)

import ipdb; ipdb.set_trace()

with open('currency_transfer.pkl', 'rb') as f:
    curr_transfer = pickle.load(f)

# iterate again, compute average using AverageMeter
jump = False

if not jump:
    print('Computing Average ... ')
    reader = pd.read_csv(stockprice_path, iterator=True, chunksize=1)
    for i, row in tqdm.tqdm(enumerate(reader)):
        if row['iid'].iloc[0] != row['prirow'].iloc[0]: continue
        gvkey = row['gvkey'].iloc[0]
        if gvkey not in month_dict.keys(): continue
        datadate = row['datadate'].iloc[0]
        year = int(datadate.astype(str)[0:4])
        price = row['prccd'].iloc[0]
        curr = row['curcdd'].iloc[0]
        for y_i, value in month_dict[gvkey].items():
            if str(datadate) >= value['start_date'] and str(datadate) < value['end_date']:
                cs_curr = month_dict[gvkey][y_i]['curr'] # compustat currency
                if curr != cs_curr:
                    if curr != 'ZAR': print(gvkey, datadate, curr, '-->', cs_curr, 'discard!'); continue
                    print(gvkey, datadate, price, curr, '-->', cs_curr)
                    if y_i not in curr_transfer[cs_curr].keys(): continue
                    price /= curr_transfer[cs_curr][y_i]
                    month_dict[gvkey][y_i]['meter'].update(price, cs_curr)
                    month_dict[gvkey][y_i]['curr'] = cs_curr
                else:
                    month_dict[gvkey][y_i]['meter'].update(price, cs_curr)
                month_dict[gvkey][y_i]['prirow'] = row['prirow'].iloc[0]
                break
            else:
                continue
    # with open('stockprice_process_0319.pkl', 'wb') as f:
    #     pickle.dump(month_dict, f)
else:
    # with open('stockprice_process_0319.pkl', 'rb') as f:
    #     month_dict = pickle.load(f)
    pass

# save month_dict

output_list = []
output_list.append(['gvkey', 'prirow', 'fyear', 'curcd', 'average_price', 'price_last_day'])
for gvkey, value in month_dict.items():
    for year, v in value.items():
        output_list.append([gvkey, v.get('prirow','None'), year, v['curr'], v['meter'].average(), v['meter'].val])

assert output_list.__len__() > 10
with open('stockprice_average_0319.csv', 'w') as f:
    writer = csv.writer(f, delimiter=',')
    for i, row in enumerate(output_list):
        writer.writerow(row)

import ipdb; ipdb.set_trace()
