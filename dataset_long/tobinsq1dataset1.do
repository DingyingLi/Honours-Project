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

generate comp = intangibleassetstotal / assetstotal
generate extfin = (capitalexpenditures - operatingactivitiesnetcashflow) / ///
capitalexpenditures

generate size = ln(assetstotal)
replace size = ln(assetstotal * 1.2685 ) if isocurrencycode == "EUR"
replace size = ln(assetstotal * 1.5477 ) if isocurrencycode == "GBP"
replace size = ln(assetstotal * 0.772895014) if isocurrencycode == "SGD"
replace size = ln(assetstotal * 0.105559006 ) if isocurrencycode == "ZAR"



generate roa= netincomelossconsolidated / assetstotal
generate lev = ( longtermdebttotal + debtincurrentliabilitiestotal) / assetstotal
replace cashdividendscashflow = 0 if cashdividendscashflow == .
replace dividendscommonordinary = 0 if dividendscommonordinary == .
replace dividendspreferredpreference = 0 if dividendspreferredpreference == .
generate dividend = cashdividendscashflow + dividendscommonordinary + dividendspreferredpreference
by globalcompanykey: generate roa_1 = netincomelossconsolidated[_n+1] / assetstotal[_n+1]
destring pricecloselastday ranking2010 ranking2011 ranking2012 ranking2013 ///
ranking2014 ranking2015, ignore("#N/A") replace 
generate market_value_of_equity = pricecloselastday * comsharesoutstandingissue
generate prime = stockexchangecode

generate tobins_q = (liabilitiestotal + market_value_of_equity) / assetstotal
by globalcompanykey: generate tobins_q1 = tobins_q[_n+1] 
by globalcompanykey: generate growth_1 = ((salesturnovernet- salesturnovernet[_n-1])/salesturnovernet[_n-1])
by globalcompanykey: generate growth =((assetstotal- assetstotal[_n-1])/ assetstotal[_n-1])


foreach y of numlist 2010 2011 2012 2013 2014 2015{
	replace ranking`y' = 0 if ranking`y' == .
}

replace ranking2010 = 0

generate ranking = ranking2010 + ranking2011 + ranking2012 + ranking2013 + ranking2014 + ranking2015


drop if ranking == 0

eststo clear
estpost tabulate sectorname
esttab using tex2/gicsector_dataset_1_1.tex, cells("b pct") label nostar replace
esttab using tex2/gicsector_dataset_1_1.rtf, cells("b pct") label nostar replace


list companylegalname globalcompanykey sectorname datayearfiscal if extfin == . 

count if extfin == .
list companylegalname globalcompanykey datayearfiscal sectorname if extfin == .

drop if extfin == . 



list companylegalname globalcompanykey sectorname datayearfiscal fiscalyearendmonth if roa_1 == .
//drop if roa_1 == .
drop if growth == .
drop if tobins_q == .
list companylegalname globalcompanykey if yearcheck == 0
drop if comparabilitystatus != ""
//count if tobins_q1 == .
//list companylegalname datayearfiscal if tobins_q1 == .


count if comp == .
list companylegalname globalcompanykey datayearfiscal sectorname if comp == .

count if roa == .
list companylegalname globalcompanykey datayearfiscal sectorname if roa == .
//count if roa_1 == .
//list companylegalname globalcompanykey datayearfiscal sectorname if roa_1 == .


count if lev == .
 
count if growth == .
list companylegalname datayearfiscal netincomelossconsolidated if growth == .
count if growth_1 == .
list companylegalname datayearfiscal netincomelossconsolidated if growth_1 == .

count if dividend == .

count if liabilitiestotal == .
count if pricecloselastday == .
list companylegalname datayearfiscal if pricecloselastday == .

count if comsharesoutstandingissue == .
list companylegalname datayearfiscal if comsharesoutstandingissue == .

count if salesturnovernet == .
list companylegalname datayearfiscal sectorname if salesturnovernet == .
count if tobins_q == .

keep  gicsectors companylegalname globalcompanykey industryformat sectorname datayearfiscal isocurrencycode ///
fiscalyearendmonth comparabilitystatus  comp extfin size roa roa_1  lev ///
growth growth_1 dividend market_value_of_equity tobins_q ranking intangibleassetstotal assetstotal ///
capitalexpenditures operatingactivitiesnetcashflow netincomelossconsolidated ///
longtermdebttotal debtincurrentliabilitiestotal cashdividendscashflow dividendscommonordinary dividendspreferredpreference ///
liabilitiestotal pricecloselastday comsharesoutstandingissue salesturnovernet prime stockexchangecode tobins_q1 gicindustries



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








//summ complexity external_financing size profitability risk growth dividend
//drop if yearcheck == 0
// this is not sure. 
disp "Drop abnormal year"
//summ complexity external_financing size profitability risk growth dividend


 


/* 
keep indicator_complexity prime ///
indicator_external_financing indicator_dividend stockexchangecode indicator_prime	///
*/





//drop if tobins_q1 == .
disp "Discriptive statistics"
summ tobins_q ranking roa roa_1 lev growth growth_1 ///
inddividend indcomp indextfin indprime

eststo clear
estpost summ tobins_q ranking roa roa_1 size lev growth growth_1 ///
inddividend indcomp indextfin indprime
esttab using tex/disc_dataset_1_1.rtf, cells("count mean p50 sd min max") label nostar replace
esttab using tex/disc_dataset_1_1.tex, cells("count mean p50 sd min max") label nostar replace

drop if tobins_q1 > 48

disp "Discriptive statistics"
summ tobins_q ranking roa roa_1 size lev growth growth_1 ///
inddividend indcomp indextfin indprime

eststo clear
estpost summ tobins_q ranking roa roa_1 size lev growth growth_1 ///
inddividend indcomp indextfin indprime, detail
esttab using tex/disc_dataset_1_2.rtf, cells("count mean p50 sd min max") label nostar replace
esttab using tex/disc_dataset_1_2.tex, cells("count mean p50 sd min max") label nostar replace

eststo clear
estpost tabulate sectorname
esttab using tex/gicsector_dataset_1_2.tex, cells("b pct") label nostar replace

eststo clear
estpost corr tobins_q ranking roa roa_1 size lev growth growth_1 ///
inddividend indcomp indextfin indprime, matrix listwise
esttab . using tex/corr_dataset_1.tex, p unstack not noobs compress label replace star(* 0.10 ** 0.05 *** 0.01)

collin ranking roa roa_1 size lev growth growth_1 ///
inddividend indcomp indextfin indprime

//pwcorr tobins_q ranking profitability profitability_1 size risk risk_1 growth growth_1 ///
//indicator_dividend indicator_complexity indicator_external_financing indicator_prime, sig star(.05)

corr tobins_q ranking roa roa_1 size lev growth growth_1 ///
inddividend indcomp indextfin indprime


log using "logs/spearman_dataset1.log", text replace
spearman tobins_q ranking roa roa_1 size lev growth growth_1 ///
inddividend indcomp indextfin indprime, matrix stats(rho p) star(.05)
log close

xtset globalcompanykey datayearfiscal
xtreg tobins_q ranking roa roa_1 size lev growth growth_1 ///
inddividend indcomp indextfin indprime,  fe

//xtreg roa_1  ranking roa size lev growth growth_1 inddividend indcomp indextfin indprime, fe

//export excel using "dataset_1_processed.xlsx", firstrow(variables) replace
//export delimited using "dataset_processed_4.csv", replace


reg tobins_q1 ranking roa size lev growth growth_1 inddividend indcomp indextfin indprime ///
indictor_2011 indictor_2012 indictor_2013 indictor_2014 indictor_2015 ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate



predict MYRESIDUALS if e(sample), residuals
predict MYFITTED if e(sample), xb
hist MYRESIDUALS

winsor tobins_q1, gen(wtobins_q1) p(0.01)
winsor roa, gen(wroa) p(0.01)
winsor size, gen(wsize) p(0.01)
winsor lev, gen(wlev) p(0.01)
winsor growth, gen(wgrowth) p(0.01)
winsor growth_1, gen(wgrowth_1) p(0.01)

disp "Discriptive statistics"
summ wtobins_q1 ranking wroa  wlev wgrowth wgrowth_1 ///
inddividend indcomp indextfin indprime


spearman wtobins_q1 ranking wroa roa_1 wsize wlev wgrowth wgrowth_1 ///
inddividend indcomp indextfin indprime, matrix stats(rho p) star(.05)

reg wtobins_q1 ranking wroa wsize wlev wgrowth wgrowth_1 inddividend indcomp indextfin indprime ///
indictor_2011 indictor_2012 indictor_2013 indictor_2014 indictor_2015 ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate

predict wMYRESIDUALS if e(sample), residuals
predict wMYFITTED if e(sample), xb
hist wMYRESIDUALS


reg roa_1 ranking size lev growth growth_1 inddividend indcomp indextfin indprime ///
indictor_2011 indictor_2012 indictor_2013 indictor_2014 indictor_2015 ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate



