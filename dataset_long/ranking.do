clear all
cd /Users/Caroline/Desktop/dataset_long2
//import excel "/Users/Caroline/Desktop/dataset_long/dataset.xlsx", sheet("WRDS") firstrow clear
import delimited ranking20112016.csv 

drop if ranking_2011 == 0
drop if ranking_2012 == 0
drop if ranking_2013 == 0
drop if ranking_2014 == 0
drop if ranking_2015 == 0
drop if ranking_2016 == 0


eststo clear
estpost tabulate ranking_2011 
esttab using dataset1/ranking1.rtf, cells("b pct") nostar label replace

eststo clear
estpost tabulate ranking_2012 
esttab using dataset1/ranking1.rtf, cells("b pct") nostar label append

eststo clear
estpost tabulate ranking_2013 
esttab using dataset1/ranking1.rtf, cells("b pct") nostar label append

eststo clear
estpost tabulate ranking_2014 
esttab using dataset1/ranking1.rtf, cells("b pct") nostar label append

eststo clear
estpost tabulate ranking_2015 
esttab using dataset1/ranking1.rtf, cells("b pct") nostar label append

eststo clear
estpost tabulate ranking_2016 
esttab using dataset1/ranking1.rtf, cells("b pct") nostar label append
