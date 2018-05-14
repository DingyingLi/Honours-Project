clear all
cd /Users/Caroline/Desktop/dataset_long2
import delimited stockprice.csv

gen year = 2011
replace year = 2012 if datadatedailyprices >= 20120000 & datadatedailyprices < 20130000
replace year = 2013 if datadatedailyprices >= 20130000 & datadatedailyprices < 20140000
replace year = 2014 if datadatedailyprices >= 20140000 & datadatedailyprices < 20150000
replace year = 2015 if datadatedailyprices >= 20150000 & datadatedailyprices < 20160000
replace year = 2016 if datadatedailyprices >= 20160000 & datadatedailyprices < 20170000

generate marketvalueofequity = 


sort  globalcompanykeydailyprices year datadatedailyprices
by globalcompanykeydailyprices year: egen average = mean(priceclosedaily)


