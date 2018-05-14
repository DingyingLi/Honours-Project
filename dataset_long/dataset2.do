clear all
cd /Users/Caroline/Desktop/dataset_long2
//import excel "/Users/Caroline/Desktop/dataset_long/dataset.xlsx", sheet("WRDS") firstrow clear

import delimited dataset_long.csv
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
replace sectorname = "Others" if gicsectors == . 


generate comp = intangibleassetstotal / assetstotal
generate extfin= (capitalexpenditures - operatingactivitiesnetcashflow) / ///
capitalexpenditures

generate size = ln(assetstotal)
replace size = ln(assetstotal * 1.10960956175298 ) if isocurrencycode == "EUR" & datayearfiscal == 2015
replace size = ln(assetstotal * 1.528396812749 ) if isocurrencycode == "GBP" & datayearfiscal == 2015
replace size = ln(assetstotal * 0.727851136614596) if isocurrencycode == "SGD" & datayearfiscal == 2015
replace size = ln(assetstotal * 0.078819198 ) if isocurrencycode == "ZAR" & datayearfiscal == 2015


generate roa= netincomelossconsolidated / assetstotal
replace longtermdebttotal = 0 if longtermdebttotal == .
replace debtincurrentliabilitiestotal = 0 if  debtincurrentliabilitiestotal == .
generate lev = ( longtermdebttotal + debtincurrentliabilitiestotal) / assetstotal
replace cashdividendscashflow = 0 if cashdividendscashflow == .
replace dividendscommonordinary = 0 if dividendscommonordinary == .
replace dividendspreferredpreference = 0 if dividendspreferredpreference == .
generate dividend = cashdividendscashflow + dividendscommonordinary + dividendspreferredpreference


generate currency_change = 1 if globalcompanykey[_n] == globalcompanykey[_n-1] & isocurrencycode[_n] != isocurrencycode[_n-1]
list globalcompanykey isocurrencycode if currency_change == 1
by globalcompanykey: generate valid = 0 if (datayearfiscal[_n-1] != datayearfiscal[_n]-1) & (isocurrencycode[_n] != isocurrencycode[_n-1])
//by globalcompanykey: generate roa_1 = netincomelossconsolidated[_n+1] / assetstotal[_n+1]



destring pricecloselastday, ignore("#N/A") replace 
//generate market_value_of_equity = pricecloselastday * comsharesoutstandingissue

//generate tobins_q = (liabilitiestotal + market_value_of_equity) / assetstotal
//by globalcompanykey: generate tobins_q1 = tobins_q[_n+1] 
//by globalcompanykey: generate growth_1 = ((salesturnovernet- salesturnovernet[_n-1])/salesturnovernet[_n-1])



//by globalcompanykey: generate growth =((revenuetotal - revenuetotal[_n-1])/ revenuetotal[_n-1] )

by globalcompanykey: generate growth =((assetstotal- assetstotal[_n-1])/ assetstotal[_n-1])

//drop if datayearfiscal!= 2015




//list globalcompanykey sectorname  if extfin == . 

count if gicsectors == 40
count if gicsectors == 60
//list  companylegalname globalcompanykey sectorname datayearfiscal if comparabilitystatus != ""
//drop if comparabilitystatus != ""
//list  companylegalname globalcompanykey sectorname datayearfiscal if  extfin == . 
count if extfin == .
count if extfin == . & gicsectors == 40
count if extfin == . & gicsectors == 60
count if extfin == . & gicsectors == 20
count if extfin == . & gicsectors == 15
count if extfin == . & gicsectors == 30
count if extfin == . & gicsectors == .
count if extfin == . & gicsectors == 45
count if extfin == . & gicsectors == 25
count if extfin == . & gicsectors == 35
count if extfin == . & gicsectors == 10

//drop if extfin == . 
//list globalcompanykey if comp == .
//drop if comp == .
//list globalcompanykey if size == .
//drop if size == .
//list companylegalname globalcompanykey sectorname datayearfiscal fiscalyearendmonth if roa_1 == .

//list globalcompanykey if growth_1 == .


//list globalcompanykey if growth == .
count if growth == .
//drop if growth == .
//drop if comp == .
//list globalcompanykey if tobins_q == .

//drop if tobins_q == .




//drop if lev == .




merge m:1 globalcompanykey datayearfiscal primaryissuetagrestofworld isocurrencycode using stockprice_average_dataset2_0905


sort globalcompanykey datayearfiscal

generate me = average_price *comsharesoutstandingissue
//generate me = price_last_day*comsharesoutstandingissue

generate tobins_q = (liabilitiestotal + me )/assetstotal

drop if _merge == 2

drop if datayearfiscal != 2015

//by globalcompanykey: generate tobins_q1 = tobins_q[_n+1] 



eststo clear
quietly estpost tabulate sectorname
esttab using tex/gicsector_dataset_2_1.tex, cells("b pct") nostar label replace
esttab using tex/gicsector_dataset_2_1.rtf, cells("b pct") nostar label replace





drop if comparabilitystatus != ""
drop if valid == 0
drop if currency_change == 1

drop if extfin == .
drop if growth == .
drop if roa == .
drop if lev == .
drop if comp == .
drop if size == .
drop if tobins_q == .






replace comp = 0 if comp == .
egen median_comp = median(comp)
generate indcomp = 1 if comp >= median_comp
replace indcom = 0 if comp < median_comp

replace extfin = 0 if extfin == .
egen median_extfin = median(extfin)
generate indextfin = 1 if extfin >= median_extfin
replace indextfin = 0 if extfin < median_extfin

replace dividend = 0 if dividend == .
generate inddividend = 1
replace inddividend = 0 if dividend == 0

//summ complexity external_financing size profitability risk growth dividend

// this is not sure. 
disp "Drop abnormal year"
//summ complexity external_financing size profitability risk growth dividend


keep gicsectors companylegalname globalcompanykey industryformat sectorname datayearfiscal isocurrencycode ///
fiscalyearendmonth yearcheck comp extfin size roa lev ///
growth dividend  tobins_q indcomp ///
indextfin inddividend stockexchangecode  ///
intangibleassetstotal assetstotal capitalexpenditures operatingactivitiesnetcashflow netincomelossconsolidated ///
longtermdebttotal cashdividendscashflow dividendscommonordinary dividendspreferredpreference liabilitiestotal comparabilitystatus





merge 1:1 globalcompanykey using coding.dta

drop if _merge == 2
drop if irscoretotal == .



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


drop if tobins_q > 5
list globalcompanykey companylegalname datayearfiscal growth if growth > 2.5
drop if growth > 2.5




disp "Discriptive statistics"
summ tobins_q roa size lev growth ///
inddividend indcomp indextfin

eststo clear
quietly estpost tabulate sectorname
esttab using tex/gicsector_dataset_2_2.tex, cells("b pct") nostar label replace
esttab using tex/gicsector_dataset_2_2.rtf, cells("b pct") nostar label replace

eststo clear
quietly estpost summ tobins_q roa size lev growth ///
inddividend indcomp indextfin, detail 
esttab using tex/summ_dataset_2.tex, cells("count mean p50 sd min max") label nostar replace
esttab using tex/summ_dataset_2.rtf, cells("count mean p50 sd min max") label nostar replace


eststo clear
quietly estpost corr tobins_q irscoretotal irscoretotal1 irscoretotal2 irscoretotal3 roa size lev growth ///
inddividend indcomp indextfin , matrix listwise
esttab . using tex/corr_dataset_2.tex, p unstack not noobs compress label replace star(* 0.10 ** 0.05 *** 0.01)
esttab . using tex/corr_dataset_2.rtf, p unstack not noobs compress label replace star(* 0.10 ** 0.05 *** 0.01)

/*
eststo clear
quietly estpost spearman tobins_q profitability profitability_1 size risk risk_1 growth growth_1 ///
indicator_dividend indicator_complexity indicator_external_financing , matrix listwise
esttab . using tex/corr_dataset_spearman_2.tex, p unstack not noobs compress label replace star(* 0.10 ** 0.05 *** 0.01)
*/

//log using "logs/spearman_dataset2.log", text replace
spearman tobins_q roa size lev growth ///
inddividend indcomp indextfin , matrix stats(rho p) star(.05)
//log off

corr tobins_q roa lev growth ///
inddividend indcomp indextfin

//eststo: quietly summ tobins_q ranking profitability dummy_complexity dummy_external_financing size risk dummy_dividend
//esttab using tex/corr.tex, label nostar, replace

xtset globalcompanykey datayearfiscal

xtreg tobins_q roa size lev growth ///
inddividend indcomp indextfin, fe



reg tobins_q irscoretotal size lev growth indextfin inddividend indcomp ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate


reg tobins_q irscoretotal1 size lev growth indextfin inddividend indcomp ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate



reg tobins_q irscoretotal2 size lev growth indextfin inddividend indcomp ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate

reg tobins_q irscoretotal3 size lev growth indextfin inddividend indcomp ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate





export excel using "dataset_2_processed.xlsx", firstrow(variables) replace
//export delimited using "dataset_processed_4.csv", replace
