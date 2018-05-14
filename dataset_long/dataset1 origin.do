clear all
cd /Users/Caroline/Desktop/dataset_long2
//import excel "/Users/Caroline/Desktop/dataset_long/dataset.xlsx", sheet("WRDS") firstrow clear

import delimited dataset_long_2.csv
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

destring pricecloselastday ranking2010 ranking2011 ranking2012 ranking2013 ///
ranking2014 ranking2015, ignore("#N/A") replace 

generate comp = intangibleassetstotal / assetstotal
generate extfin = (capitalexpenditures - operatingactivitiesnetcashflow) / ///
capitalexpenditures

generate size = ln(assetstotal)
replace size = ln(assetstotal * 1.39313346613545 ) if isocurrencycode == "EUR" & datayearfiscal == 2011
replace size = ln(assetstotal * 1.28587410358565) if isocurrencycode == "EUR" & datayearfiscal == 2012
replace size = ln(assetstotal * 1.32813944223107) if isocurrencycode == "EUR" & datayearfiscal == 2013
replace size = ln(assetstotal * 1.3296708 ) if isocurrencycode == "EUR" & datayearfiscal == 2014
replace size = ln(assetstotal * 1.10960956175298 ) if isocurrencycode == "EUR" & datayearfiscal == 2015



replace size = ln(assetstotal * 1.60430199203187 ) if isocurrencycode == "GBP" & datayearfiscal == 2011
replace size = ln(assetstotal * 1.58532430278884) if isocurrencycode == "GBP" & datayearfiscal == 2012
replace size = ln(assetstotal * 1.56416852589641) if isocurrencycode == "GBP" & datayearfiscal == 2013
replace size = ln(assetstotal * 1.6484352 ) if isocurrencycode == "GBP" & datayearfiscal == 2014
replace size = ln(assetstotal * 1.528396812749 ) if isocurrencycode == "GBP" & datayearfiscal == 2015

replace size = ln(assetstotal * 0.79633682874858) if isocurrencycode == "SGD" & datayearfiscal == 2011
replace size = ln(assetstotal * 0.800756986899521) if isocurrencycode == "SGD" & datayearfiscal == 2012
replace size = ln(assetstotal * 0.799431395246667) if isocurrencycode == "SGD" & datayearfiscal == 2013
replace size = ln(assetstotal * 0.789755681602004) if isocurrencycode == "SGD" & datayearfiscal == 2014
replace size = ln(assetstotal * 0.727851136614596) if isocurrencycode == "SGD" & datayearfiscal == 2015


replace size = ln(assetstotal * 0.138544357099999 ) if isocurrencycode == "ZAR" & datayearfiscal == 2011
replace size = ln(assetstotal * 0.122106019482758 ) if isocurrencycode == "ZAR" & datayearfiscal == 2012
replace size = ln(assetstotal * 0.104017156176245 ) if isocurrencycode == "ZAR" & datayearfiscal == 2013
replace size = ln(assetstotal * 0.0922700653141762 ) if isocurrencycode == "ZAR" & datayearfiscal == 2014
replace size = ln(assetstotal * 0.078819198 ) if isocurrencycode == "ZAR" & datayearfiscal == 2015

by globalcompanykey: generate valid = 0 if (datayearfiscal[_n-1] != datayearfiscal[_n]-1) & (isocurrencycode[_n] != isocurrencycode[_n-1])

by globalcompanykey: generate currency_change = 1 if globalcompanykey[_n] == globalcompanykey[_n-1] & isocurrencycode[_n] != isocurrencycode[_n-1]
list globalcompanykey isocurrencycode if currency_change == 1


generate roa= netincomelossconsolidated / assetstotal
//by globalcompanykey: generate roa_1 = netincomelossconsolidated[_n+1] / assetstotal[_n+1]

replace longtermdebttotal = 0 if longtermdebttotal == .
replace debtincurrentliabilitiestotal = 0 if debtincurrentliabilitiestotal == .
generate lev = (longtermdebttotal + debtincurrentliabilitiestotal) / assetstotal

replace cashdividendscashflow = 0 if cashdividendscashflow == .
replace dividendscommonordinary = 0 if dividendscommonordinary == .
replace dividendspreferredpreference = 0 if dividendspreferredpreference == .
generate dividend = cashdividendscashflow + dividendscommonordinary + dividendspreferredpreference


generate prime = stockexchangecode


//by globalcompanykey: generate growth_1 = ((salesturnovernet- salesturnovernet[_n-1])/salesturnovernet[_n-1])


//by globalcompanykey: generate growth =((revenuetotal - revenuetotal[_n-1])/ revenuetotal[_n-1] ) 
by globalcompanykey: generate growth =((assetstotal- assetstotal[_n-1])/ assetstotal[_n-1])





foreach y of numlist 2010 2011 2012 2013 2014 2015{
	replace ranking`y' = 0 if ranking`y' == .
}

replace ranking2010 = 0

generate ranking = ranking2010 + ranking2011 + ranking2012 + ranking2013 + ranking2014 + ranking2015






count if gicsectors == 40
count if gicsectors == 60

//drop if comparabilitystatus != ""
count if extfin == .
count if extfin == . & gicsectors == 40
count if extfin == . & gicsectors == 60
count if extfin == . & gicsectors == 20
//list companylegalname globalcompanykey datayearfiscal sectorname if extfin == .
//drop if extfin == . 


count if comp == .
//list companylegalname globalcompanykey datayearfiscal sectorname if comp == .
//drop if comp == .

count if roa == .
//list companylegalname globalcompanykey datayearfiscal sectorname if roa == .
//drop if roa == .


count if lev == .
//drop if lev == .
 
count if growth == .
//list companylegalname datayearfiscal netincomelossconsolidated if growth == .
//drop if growth == .

merge m:1 globalcompanykey datayearfiscal primaryissuetagrestofworld isocurrencycode using stockprice_average_0924


sort globalcompanykey datayearfiscal

generate me = average_price *comsharesoutstandingissue
//generate me = price_last_day*comsharesoutstandingissue

generate tobins_q = (liabilitiestotal + me )/assetstotal

// by globalcompanykey: generate tobins_q1 = tobins_q[_n+1] 

drop if datayearfiscal != 2011 & datayearfiscal !=2012 & datayearfiscal != 2013 & datayearfiscal != 2014 & datayearfiscal != 2015
drop if _merge == 2
drop if ranking == 0





drop if comparabilitystatus != ""
drop if valid == 0
drop if currency_change == 1
list companylegalname globalcompanykey datayearfiscal sectorname if extfin == .
drop if extfin == .
drop if growth == .
drop if roa == .
drop if lev == .
drop if comp == .
drop if size == .
drop if tobins_q == .


eststo clear
estpost tabulate sectorname
esttab using tex/gicsector_dataset_1_1.tex, cells("b pct") label nostar replace
esttab using tex/gicsector_dataset_1_1.rtf, cells("b pct") label nostar replace


//sort globalcompanykey datayearfiscal
//generate tobins_q = (liabilitiestotal + (average_value/1000000) ) / assetstotal
//by globalcompanykey: generate tobins_q1 = tobins_q[_n+1] 

//drop if tobins_q == .
//drop if ranking == .



keep  gicsectors companylegalname globalcompanykey industryformat sectorname datayearfiscal isocurrencycode ///
fiscalyearendmonth comparabilitystatus comsharesoutstandingissue tobins_q comp extfin size roa lev ///
growth dividend ranking intangibleassetstotal assetstotal revenuetotal ///
capitalexpenditures operatingactivitiesnetcashflow netincomelossconsolidated ///
longtermdebttotal debtincurrentliabilitiestotal cashdividendscashflow dividendscommonordinary dividendspreferredpreference ///
liabilitiestotal salesturnovernet prime stockexchangecode gicindustries



//replace complexity = 0 if complexity == . //not sure 
egen median_comp = median(comp)
generate indcomp = 1 if comp >= median_comp
replace indcomp = 0 if comp < median_comp

generate indprime = 1
replace indprime = 0 if prime != 177

//replace external_financing = 0 if external_financing == . // not sure 
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


drop if tobins_q > 6
drop if growth > 2


disp "Discriptive statistics"
summ tobins_q ranking lev growth ///
inddividend indcomp indextfin indprime


disp "Discriptive statistics"
summ tobins_q ranking roa size lev growth ///
inddividend indcomp indextfin indprime


eststo clear
estpost tabulate ranking if datayearfiscal == 2011
esttab using tex/ranking20112.rtf, cells("b pct") nostar label replace

eststo clear
estpost tabulate ranking if datayearfiscal == 2012
esttab using tex/ranking20122.rtf, cells("b pct") nostar label replace

eststo clear
estpost tabulate ranking if datayearfiscal == 2013
esttab using tex/ranking20132.rtf, cells("b pct") nostar label replace

eststo clear
estpost tabulate ranking if datayearfiscal == 2014
esttab using tex/ranking20142.rtf, cells("b pct") nostar label replace

eststo clear
estpost tabulate ranking if datayearfiscal == 2015
esttab using tex/ranking20152.rtf, cells("b pct") nostar label replace




eststo clear
estpost summ tobins_q ranking roa size lev growth ///
inddividend indcomp indextfin indprime, detail
esttab using tex/disc_dataset_1_2.rtf, cells("count mean p50 sd min max") label nostar replace
esttab using tex/disc_dataset_1_2.tex, cells("count mean p50 sd min max") label nostar replace

eststo clear
estpost tabulate sectorname
esttab using tex/gicsector_dataset_1_2.tex, cells("b pct") label nostar replace
esttab using tex/gicsector_dataset_1_2.rtf, cells("b pct") label nostar replace

eststo clear
estpost corr tobins_q ranking roa size lev growth ///
inddividend indcomp indextfin indprime, matrix listwise
esttab . using tex/corr_dataset_1.tex, p unstack not noobs compress label replace star(* 0.10 ** 0.05 *** 0.01)
esttab . using tex/corr_dataset_1.rtf, p unstack not noobs compress label replace star(* 0.10 ** 0.05 *** 0.01)

collin ranking roa size lev growth ///
inddividend indcomp indextfin indprime

pwcorr tobins_q ranking roa size lev growth  ///
inddividend indcomp indextfin indprime, sig star(.05)

corr tobins_q ranking roa  size lev growth ///
inddividend indcomp indextfin indprime


log using "logs/spearman_dataset1.log", text replace
spearman tobins_q ranking roa size lev growth  ///
inddividend indcomp indextfin indprime, matrix stats(rho p) star(.05)
log close

xtset globalcompanykey datayearfiscal
xtreg tobins_q ranking roa size lev growth  ///
inddividend indcomp indextfin indprime,  fe

//xtreg roa_1  ranking roa size lev growth growth_1 inddividend indcomp indextfin indprime, fe

//export excel using "dataset_1_processed.xlsx", firstrow(variables) replace
//export delimited using "dataset_processed_4.csv", replace


reg tobins_q ranking roa size lev growth inddividend indcomp indextfin indprime ///
indictor_2011 indictor_2012 indictor_2013 indictor_2014 indictor_2015 ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate

predict MYRESIDUALS if e(sample), residuals
predict MYFITTED if e(sample), xb
hist MYRESIDUALS

winsor tobins_q, gen(wtobins_q) p(0.01)
winsor roa, gen(wroa) p(0.01)
winsor size, gen(wsize) p(0.01)
winsor lev, gen(wlev) p(0.01)
winsor growth, gen(wgrowth) p(0.01)

eststo clear
estpost summ wtobins_q ranking wroa wsize wlev wgrowth ///
inddividend indcomp indextfin indprime, detail
esttab using tex/disc_dataset_1_2w.tex, cells("count mean p50 sd min max") label nostar replace
esttab using tex/disc_dataset_1_2w.rtf, cells("count mean p50 sd min max") label nostar replace

disp "Discriptive statistics"
summ wtobins_q ranking wroa  wlev wgrowth ///
inddividend indcomp indextfin indprime

eststo clear
estpost corr wtobins_q ranking wroa wsize wlev wgrowth ///
inddividend indcomp indextfin indprime, matrix listwise
esttab . using tex/corr_dataset_1w.tex, p unstack not noobs compress label replace star(* 0.10 ** 0.05 *** 0.01)
esttab . using tex/corr_dataset_1w.rtf, p unstack not noobs compress label replace star(* 0.10 ** 0.05 *** 0.01)

log using "logs/spearman_dataset1wsor", text replace
spearman wtobins_q ranking wroa wsize wlev wgrowth ///
inddividend indcomp indextfin indprime, matrix stats(rho p) star(.05)
log close

reg wtobins_q ranking wroa wsize wlev wgrowth inddividend indcomp indextfin indprime ///
indictor_2011 indictor_2012 indictor_2013 indictor_2014 indictor_2015 ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate

predict wMYRESIDUALS if e(sample), residuals
predict wMYFITTED if e(sample), xb
hist wMYRESIDUALS


/*reg roa_1 ranking size lev growth inddividend indcomp indextfin indprime ///
indictor_2011 indictor_2012 indictor_2013 indictor_2014 indictor_2015 ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate


