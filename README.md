# Quality of Financial Disclosure in Integrated Reporting vs Firm Values
Research project of Dingying Li following Honours project.
## Instruction
* `python future_price_with_currecy.py`
  - read daily stockprice, based on current fiscal year end, compute future stock price.
* `python merge2dataset.py`
  - read number of analysts from `Analyst following.csv`, compute company age from `age.csv`, merge them to compustat.

## Files
* compustat2008-2018.csv - Downloaded from compustat
* stockprice\_0313.csv - Downloaded from compustat - security daily
* currency\_transfer.pkl - python pickle file, for currency transfer to ZAR
* search\_dict.pkl - python pickle file, store the AverageMeter read from daily stockprice
* Analyst_following.csv - Downloaded from compustat, number of analysts
* Plan to add a crawler for collecting companies' integrated report.

## Directories
* dataset_long - Backup of Stata do files and small datasets for Honours project
