clear all
//cd /Users/Caroline/Desktop/dataset_long2
cd C:\Users\mike\Desktop\dataset_long2
//import excel "/Users/Caroline/Desktop/dataset_long/dataset.xlsx", sheet("WRDS") firstrow clear

import delimited dataset1_complete_0925.csv
//import delimited company_name.csv
//summ capitalexpenditures operatingactivitiesnetcashflow

sort globalcompanykey datayearfiscal

generate sectorname = "Energy" if gicsectors == 10
replace sectorname = "Materials" if gicsectors == 15
replace sectorname = "Industrials" if gicsectors == 20
replace sectorname = "Consumer Discretionary" if gicsectors == 25
replace sectorname = "Consumer Staples" if gicsectors == 30
replace sectorname = "Health Care" if gicsectors == 35
replace sectorname = "Financials" if gicsectors == 40
replace sectorname = "Information Technology" if gicsectors == 45
replace sectorname = "Telecommunication Services" if gicsectors == 50
replace sectorname = "Utilities" if gicsectors == 55
replace sectorname = "Real Estate" if gicsectors == 60

destring ranking2011 ranking2012 ranking2013 ///
ranking2014 ranking2015 ranking2016, ignore("#N/A") replace 

destring rankingtop2012 rankingtop2013 ///
rankingtop2014 rankingtop2015 rankingtop2016, ignore("#N/A") replace 


generate comp = intangibleassetstotal / assetstotal
generate extfin = (capitalexpenditures - operatingactivitiesnetcashflow) / ///
capitalexpenditures

generate size = ln(assetstotal)
replace size = ln(assetstotal * 1.39313346613545 ) if isocurrencycode == "EUR" & datayearfiscal == 2011
replace size = ln(assetstotal * 1.28587410358565) if isocurrencycode == "EUR" & datayearfiscal == 2012
replace size = ln(assetstotal * 1.32813944223107) if isocurrencycode == "EUR" & datayearfiscal == 2013
replace size = ln(assetstotal * 1.3296708 ) if isocurrencycode == "EUR" & datayearfiscal == 2014
replace size = ln(assetstotal * 1.10960956175298 ) if isocurrencycode == "EUR" & datayearfiscal == 2015
replace size = ln(assetstotal * 1.10719442231075 ) if isocurrencycode == "EUR" & datayearfiscal == 2016


replace size = ln(assetstotal * 1.60430199203187 ) if isocurrencycode == "GBP" & datayearfiscal == 2011
replace size = ln(assetstotal * 1.58532430278884) if isocurrencycode == "GBP" & datayearfiscal == 2012
replace size = ln(assetstotal * 1.56416852589641) if isocurrencycode == "GBP" & datayearfiscal == 2013
replace size = ln(assetstotal * 1.6484352 ) if isocurrencycode == "GBP" & datayearfiscal == 2014
replace size = ln(assetstotal * 1.528396812749 ) if isocurrencycode == "GBP" & datayearfiscal == 2015
replace size = ln(assetstotal * 1.35551752988047 ) if isocurrencycode == "GBP" & datayearfiscal == 2016



replace size = ln(assetstotal * 0.79633682874858) if isocurrencycode == "SGD" & datayearfiscal == 2011
replace size = ln(assetstotal * 0.800756986899521) if isocurrencycode == "SGD" & datayearfiscal == 2012
replace size = ln(assetstotal * 0.799431395246667) if isocurrencycode == "SGD" & datayearfiscal == 2013
replace size = ln(assetstotal * 0.789755681602004) if isocurrencycode == "SGD" & datayearfiscal == 2014
replace size = ln(assetstotal * 0.727851136614596) if isocurrencycode == "SGD" & datayearfiscal == 2015
replace size = ln(assetstotal * 0.725028387108148) if isocurrencycode == "SGD" & datayearfiscal == 2016



replace size = ln(assetstotal * 0.138544357099999 ) if isocurrencycode == "ZAR" & datayearfiscal == 2011
replace size = ln(assetstotal * 0.122106019482758 ) if isocurrencycode == "ZAR" & datayearfiscal == 2012
replace size = ln(assetstotal * 0.104017156176245 ) if isocurrencycode == "ZAR" & datayearfiscal == 2013
replace size = ln(assetstotal * 0.0922700653141762 ) if isocurrencycode == "ZAR" & datayearfiscal == 2014
replace size = ln(assetstotal * 0.078819198 ) if isocurrencycode == "ZAR" & datayearfiscal == 2015
replace size = ln(assetstotal * 0.068308114 ) if isocurrencycode == "ZAR" & datayearfiscal == 2016


generate currency_change = 1 if globalcompanykey[_n] == globalcompanykey[_n-1] & isocurrencycode[_n] != isocurrencycode[_n-1]
list globalcompanykey isocurrencycode if currency_change == 1


generate roa= netincomelossconsolidated / assetstotal

replace longtermdebttotal = 0 if longtermdebttotal == .
replace debtincurrentliabilitiestotal = 0 if  debtincurrentliabilitiestotal == .
generate lev = (longtermdebttotal + debtincurrentliabilitiestotal) / assetstotal
replace cashdividendscashflow = 0 if cashdividendscashflow == .
replace dividendscommonordinary = 0 if dividendscommonordinary == .
replace dividendspreferredpreference = 0 if dividendspreferredpreference == .
generate dividend = cashdividendscashflow + dividendscommonordinary + dividendspreferredpreference

generate prime = stockexchangecode
by globalcompanykey: generate valid = 0 if (datayearfiscal[_n-1] != datayearfiscal[_n]-1) | (isocurrencycode[_n] != isocurrencycode[_n-1])
//by globalcompanykey: generate growth1 =((revenuetotal - revenuetotal[_n-1])/ revenuetotal[_n-1] )
//by globalcompanykey: generate growth2 =((operatingincomebeforedepreciatio- operatingincomebeforedepreciatio[_n-1])/ operatingincomebeforedepreciatio[_n-1] )
by globalcompanykey: generate growth = ((assetstotal- assetstotal[_n-1])/assetstotal[_n-1])


foreach y of numlist 2011 2012 2013 2014 2015 2016{
	replace ranking`y' = 0 if ranking`y' == . 
}

foreach y of numlist 2012 2013 2014 2015 2016{
	replace rankingtop`y' = 0 if rankingtop`y' == . 
}



generate ranking = ranking2011 + ranking2012 + ranking2013 + ranking2014 + ranking2015 +ranking2016
generate rankingtop = rankingtop2012 + rankingtop2013 + rankingtop2014 + rankingtop2015 +rankingtop2016

drop if ranking == 0




sort globalcompanykey datayearfiscal


replace comsharesoutstandingissue =  537117864/1000000 if globalcompany == 102422 & datayearfiscal == 2011
replace comsharesoutstandingissue =  539970269.1647509/1000000 if globalcompany == 102422 & datayearfiscal == 2012
replace comsharesoutstandingissue =  541446223.0/1000000 if globalcompany == 102422 & datayearfiscal == 2013
replace comsharesoutstandingissue =  541446223.0/1000000 if globalcompany == 102422 & datayearfiscal == 2014
replace comsharesoutstandingissue =  541446223.0/1000000 if globalcompany == 102422 & datayearfiscal == 2015
replace comsharesoutstandingissue =  542698482.3869731/1000000 if globalcompany == 102422 & datayearfiscal == 2016

merge m:1 globalcompanykey datayearfiscal primaryissuetagrestofworld isocurrencycode using stockprice_average_0924
drop if _merge == 2




generate me = average_price *comsharesoutstandingissue
//generate me = price_last_day * comsharesoutstandingissue


generate tobins_q = (liabilitiestotal + me)/assetstotal

//by globalcompanykey: generate tobins_q1 = tobins_q[_n+1] 

drop if datayearfiscal != 2011 & datayearfiscal !=2012 & datayearfiscal != 2013 & datayearfiscal != 2014 & datayearfiscal != 2015 & datayearfiscal != 2016


eststo clear
estpost tabulate sectorname
esttab using dataset1/gicsector.rtf, cells("b pct") label nostar replace






drop if comparabilitystatus != ""
drop if valid == 0
drop if currency_change == 1
list globalcompanykey sectorname datayearfiscal companylegalname if growth == .
drop if growth == .
list globalcompanykey sectorname datayearfiscal companylegalname netincomelossconsolidated assetstotal if roa == .
drop if roa == .
list globalcompanykey sectorname datayearfiscal companylegalname if lev == .
drop if lev == .
list globalcompanykey sectorname datayearfiscal intangibleassetstotal companylegalname if comp == .
drop if comp == .
list globalcompanykey sectorname datayearfiscal companylegalname if size == .
drop if size == .
list globalcompanykey sectorname datayearfiscal companylegalname if tobins_q == .
drop if tobins_q == .


eststo clear
estpost tabulate sectorname
esttab using dataset1/gicsector.rtf, cells("b pct") label nostar append



keep  gicsectors companylegalname globalcompanykey industryformat sectorname datayearfiscal isocurrencycode me ///
fiscalyearendmonth comparabilitystatus comsharesoutstandingissue  comp extfin size roa  lev  _merge ///
growth dividend tobins_q ranking rankingtop intangibleassetstotal assetstotal ///
capitalexpenditures operatingactivitiesnetcashflow netincomelossconsolidated  ///
longtermdebttotal debtincurrentliabilitiestotal cashdividendscashflow dividendscommonordinary dividendspreferredpreference ///
liabilitiestotal prime stockexchangecode gicindustries average_price price_last_day revenuetotal  ///


/*gen ranking_p = 0
foreach y of numlist 2011 2012 2013 2014 2015 2016{
	quietly count if datayearfiscal == `y'
	gen year_total = r(N)
	gen dum = 0
	foreach i of numlist 1 2 3 4 5{
		quietly count if datayearfiscal == `y' & ranking == `i'
		replace dum = r(N) if datayearfiscal == `y' & ranking == `i'
		quietly count if datayearfiscal == `y' & ranking < `i'
		replace ranking_p = (r(N) + (dum / 2)) / year_total if datayearfiscal == `y' & ranking == `i'
		replace ranking_p = rankingtop / year_total if datayearfiscal == `y' & ranking == 1 &`y' != 2011
	}
    drop year_total
	drop dum
}
*/

generate ranking_new = 1
//replace ranking_new= 2 if ranking == 3
//replace ranking_new = 3 if ranking == 4 
//replace ranking_new = 4 if ranking == 5
replace ranking_new= 2 if ranking == 3 | ranking ==4 | ranking == 5



gen ranking_p = 0
foreach y of numlist 2011 2012 2013 2014 2015 2016{
	quietly count if datayearfiscal == `y'
	gen year_total = r(N)
	gen dum = 0
	foreach i of numlist 1 2  {
		quietly count if datayearfiscal == `y' & ranking_new == `i'
		replace dum = r(N) if datayearfiscal == `y' & ranking_new == `i'
		quietly count if datayearfiscal == `y' & ranking_new < `i'
		replace ranking_p = (r(N) + (dum / 2)) / year_total if datayearfiscal == `y' & ranking_new == `i'
		replace ranking_p = rankingtop / year_total if datayearfiscal == `y' & ranking == 1 &`y' != 2011
	}
    drop year_total
	drop dum
}








//replace ranking_p = 1 if ranking_p > = 0.5
//replace ranking_p = 0 if ranking_p <0.5


egen median_comp = median(comp)
generate indcomp = 1 if comp >= median_comp
replace indcomp = 0 if comp < median_comp

generate indprime = 1
replace indprime = 0 if prime != 177

egen median_extfin = median(extfin)
generate indextfin = 1 if extf >= median_extfin
replace indextfin = 0 if extfin < median_extfin


replace dividend = 0 if dividend == .
generate inddividend = 1
replace inddividend = 0 if dividend == 0

generate indictor_2011 = 1
replace indictor_2011 = 0 if datayearfiscal!= 2011

generate indictor_2012 = 1
replace indictor_2012 = 0 if datayearfiscal!= 2012

generate indictor_2013 = 1
replace indictor_2013 = 0 if datayearfiscal!= 2013

generate indictor_2014 = 1
replace indictor_2014 = 0 if datayearfiscal!= 2014

generate indictor_2015 = 1
replace indictor_2015 = 0 if datayearfiscal!= 2015


generate indictor_enegry =1
replace indictor_enegry = 0 if gicsector ! = 10

generate indictor_materials =1
replace indictor_materials = 0 if gicsector ! = 15

generate indictor_industrials =1
replace indictor_industrials = 0 if gicsector ! = 20

generate indictor_consumerdiscretionary =1
replace indictor_consumerdiscretionary = 0 if gicsector ! = 25

generate indictor_consumerstaples =1
replace indictor_consumerstaples = 0 if gicsector ! = 30

generate indictor_healthcare =1
replace indictor_healthcare = 0 if gicsector ! = 35

generate indictor_financials =1
replace indictor_financials = 0 if gicsector ! = 40

generate indictor_informationtechnology =1
replace indictor_informationtechnology = 0 if gicsector ! = 45

generate indictor_telecomm =1
replace indictor_telecomm = 0 if gicsector ! = 50

generate indictor_utilities =1
replace indictor_utilities = 0 if gicsector ! = 55

generate indictor_realestate =1
replace indictor_realestate = 0 if gicsector ! = 60


sum tobins_q ranking_p roa growth lev size indcomp indprime inddividend 

disp "Discriptive statistics"
summ tobins_q ranking_p roa lev growth ///
inddividend indcomp indextfin indprime

eststo clear
estpost summ tobins_q ranking_p roa size lev growth ///
inddividend indcomp indextfin indprime, detail
esttab using dataset1/summdataset1.rtf, cells("count mean p50 sd min max") label nostar replace


eststo clear
estpost tabulate ranking if datayearfiscal == 2011
esttab using dataset1/ranking.rtf, cells("b pct") nostar label replace

eststo clear
estpost tabulate ranking if datayearfiscal == 2012
esttab using dataset1/ranking.rtf, cells("b pct") nostar label append

eststo clear
estpost tabulate ranking if datayearfiscal == 2013
esttab using dataset1/ranking.rtf, cells("b pct") nostar label append

eststo clear
estpost tabulate ranking if datayearfiscal == 2014
esttab using dataset1/ranking.rtf, cells("b pct") nostar label append

eststo clear
estpost tabulate ranking if datayearfiscal == 2015
esttab using dataset1/ranking.rtf, cells("b pct") nostar label append

eststo clear
estpost tabulate ranking if datayearfiscal == 2016
esttab using dataset1/ranking.rtf, cells("b pct") nostar label append

disp "Discriptive statistics"
summ tobins_q ranking_p roa size lev growth ///
inddividend indcomp  indprime

eststo clear
estpost summ tobins_q ranking_p roa size lev growth ///
inddividend indcomp indprime, detail
esttab using dataset1/summdataset1.rtf, cells("count mean p50 sd min max") label nostar append


eststo clear
estpost tabulate sectorname
esttab using dataset1/gicsector.rtf, cells("b pct") label nostar append

eststo clear
estpost corr tobins_q ranking_p roa size lev growth  ///
inddividend indcomp  indprime, matrix listwise
esttab . using dataset1/corr_dataset_1.rtf, p unstack not noobs compress label replace star(* 0.10 ** 0.05 *** 0.01)


collin ranking_p roa size lev growth ///
inddividend indcomp indextfin indprime

pwcorr tobins_q ranking_p roa size lev growth  ///
inddividend indcomp  indprime

corr tobins_q ranking_p roa  size lev growth ///
inddividend indcomp  indprime


log using "logs/spearman_dataset1withoutextfin.log", text replace
spearman tobins_q ranking_p roa size lev growth  ///
inddividend indcomp indprime, matrix stats(rho p) star(.05)
log close



xtset globalcompanykey datayearfiscal
xtreg tobins_q ranking_p roa size lev growth  ///
inddividend indcomp indprime , fe




//xtreg roa_1  ranking roa size lev growth growth_1 inddividend indcomp indextfin indprime, fe


//export excel using "dataset_1_processed.xlsx", firstrow(variables) replace
//export delimited using "dataset_processed_4.csv", replace


reg tobins_q ranking_p roa size lev growth  inddividend indcomp indprime ///
indictor_2011 indictor_2012 indictor_2013 indictor_2014 indictor_2015 ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm 


eststo clear
eststo: quietly reg tobins_q ranking_p roa size lev growth  inddividend indcomp indprime ///
indictor_2011 indictor_2012 indictor_2013 indictor_2014 ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm 
esttab using dataset1/myreg.rtf, p(4) r2(4) ar2(4) scalars(F df_m df_r) star(* 0.10 ** 0.05 *** 0.01) replace

predict MYRESIDUALS if e(sample), residuals
predict MYFITTED if e(sample), xb
hist MYRESIDUALS

winsor tobins_q, gen(wtobins_q) p(0.01)
winsor growth, gen(wgrowth) p(0.01)



disp "Discriptive statistics"
summ wtobins_q ranking_p roa size lev wgrowth ///
inddividend indcomp indextfin indprime, detail


eststo clear
estpost summ wtobins_q ranking_p roa size lev wgrowth ///
inddividend indcomp indextfin indprime, detail
esttab using dataset1/summdataset1.rtf, cells("count mean p50 sd min max") label nostar append



eststo clear
estpost corr wtobins_q ranking_p roa size lev wgrowth  ///
inddividend indcomp  indprime, matrix listwise
esttab . using dataset1/corr_dataset_1.rtf, p unstack not noobs compress label append star(* 0.10 ** 0.05 *** 0.01)

spearman wtobins_q ranking_p roa size lev wgrowth ///
inddividend indcomp indextfin indprime, matrix stats(rho p) star(.05)

log using "logs/spearman_dataset1withoutextfinw.log", text replace
spearman wtobins_q ranking_p roa size lev wgrowth  ///
inddividend indcomp indprime, matrix stats(rho p) star(.05)
log close


reg wtobins_q ranking_p roa size lev wgrowth inddividend indcomp indprime ///
indictor_2011 indictor_2012 indictor_2013 indictor_2014 indictor_2015 ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm 


reg roa ranking_p  size lev wgrowth inddividend indcomp indprime ///
indictor_2011 indictor_2012 indictor_2013 indictor_2014 indictor_2015 ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm 

xtset globalcompanykey datayearfiscal
xtreg wtobins_q ranking_p roa size lev wgrowth inddividend indcomp indprime, fe


eststo clear
eststo: quietly reg wtobins_q ranking_p roa size lev wgrowth inddividend indcomp indprime ///
indictor_2011 indictor_2012 indictor_2013 indictor_2014 indictor_2015 ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities 
esttab using dataset1/myreg.rtf, p(4) r2(4) ar2(4) scalars(F df_m df_r) star(* 0.10 ** 0.05 *** 0.01) append


predict wMYRESIDUALS if e(sample), residuals
predict wMYFITTED if e(sample), xb
hist wMYRESIDUALS

egen industryyear = group(datayearfiscal gicsector),label
regress wtobins_q ranking_p roa size lev wgrowth inddividend indcomp indprime i.industryyear

/*reg roa_1 ranking size lev growth growth_1 inddividend indcomp  indprime ///
indictor_2011 indictor_2012 indictor_2013 indictor_2014 indictor_2015 ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate





reg ranking roa lev growth size 
predict ranking_hat
reg wtobins_q ranking_hat roa size lev wgrowth inddividend indcomp indprime ///
indictor_2011 indictor_2012 indictor_2013 indictor_2014 indictor_2015 ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm 



