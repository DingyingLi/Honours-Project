clear all
cd C:\Users\mike\Desktop\dataset_long2
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

generate complexity = intangibleassetstotal / assetstotal
generate external_financing = (capitalexpenditures - operatingactivitiesnetcashflow) / ///
capitalexpenditures
generate size = ln(assetstotal)
generate profitability = netincomelossconsolidated / assetstotal
generate risk = longtermdebttotal / assetstotal // levergae
generate risk_1 = ( longtermdebttotal + debtincurrentliabilitiestotal) / assetstotal
replace cashdividendscashflow = 0 if cashdividendscashflow == .
replace dividendscommonordinary = 0 if dividendscommonordinary == .
replace dividendspreferredpreference = 0 if dividendspreferredpreference == .
generate dividend = cashdividendscashflow + dividendscommonordinary + dividendspreferredpreference
by globalcompanykey: generate profitability_1 = netincomelossconsolidated[_n+1] / assetstotal[_n+1]
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
esttab using tex/gicsector_dataset_1_1.tex, cells("b pct") label nostar replace

list companylegalname globalcompanykey sectorname datayearfiscal if external_financing == . 

count if capitalexpenditures == .
count if operatingactivitiesnetcashflow == .
drop if external_financing == . 
list companylegalname globalcompanykey sectorname datayearfiscal fiscalyearendmonth if profitability_1 == .
drop if profitability_1 == .
drop if growth == .
drop if tobins_q == .
list companylegalname globalcompanykey if yearcheck == 0
drop if yearcheck == 0
count if tobins_q1 == .
list companylegalname datayearfiscal if tobins_q1 == .



count if yearcheck == 0
list companylegalname globalcompanykey datayearfiscal sectorname if yearcheck == 0
count if intangibleassetstotal ==.
count if assetstotal == .
count if complexity == .
list companylegalname globalcompanykey datayearfiscal sectorname if complexity == .
count if netincomelossconsolidated ==. 
count if profitability == .
list companylegalname globalcompanykey datayearfiscal sectorname if profitability == .
count if profitability_1 == .
list companylegalname globalcompanykey datayearfiscal sectorname if profitability_1 == .
count if capitalexpenditures == .
count if operatingactivitiesnetcashflow == .
count if external_financing == .
list companylegalname globalcompanykey datayearfiscal sectorname if external_financing == .
count if longtermdebttotal == .
count if debtincurrentliabilitiestotal == .
count if risk == .
count if risk_1 ==. 
count if growth == .
list companylegalname datayearfiscal netincomelossconsolidated if growth == .
count if growth_1 == .
list companylegalname datayearfiscal netincomelossconsolidated if growth_1 == .
count if cashdividendscashflow == .
count if dividendscommonordinary == .
count if dividendspreferredpreference == .
count if dividend == .
count if liabilitiestotal == .
count if pricecloselastday == .
list companylegalname datayearfiscal if pricecloselastday == .
count if comsharesoutstandingissue == .
list companylegalname datayearfiscal if comsharesoutstandingissue == .
count if salesturnovernet == .
list companylegalname datayearfiscal if salesturnovernet == .
count if tobins_q == .





keep  gicsectors companylegalname globalcompanykey industryformat sectorname datayearfiscal ///
fiscalyearendmonth yearcheck complexity external_financing size profitability risk risk_1 ///
growth growth_1 dividend market_value_of_equity tobins_q ranking profitability_1  intangibleassetstotal assetstotal ///
capitalexpenditures operatingactivitiesnetcashflow netincomelossconsolidated ///
longtermdebttotal debtincurrentliabilitiestotal cashdividendscashflow dividendscommonordinary dividendspreferredpreference ///
liabilitiestotal pricecloselastday comsharesoutstandingissue salesturnovernet prime stockexchangecode tobins_q1



//replace complexity = 0 if complexity == . //not sure 
egen median_complexity = median(complexity)
generate indicator_complexity = 1 if complexity >= median_complexity
replace indicator_complexity = 0 if complexity < median_complexity

generate indicator_prime = 1
replace indicator_prime = 0 if prime != 177

//replace external_financing = 0 if external_financing == . // not sure 
egen median_external_financing = median(external_financing)
generate indicator_external_financing = 1 if external_financing >= median_external_financing
replace indicator_external_financing = 0 if external_financing < median_external_financing

replace dividend = 0 if dividend == .
generate indicator_dividend = 1
replace indicator_dividend = 0 if dividend == 0

//summ complexity external_financing size profitability risk growth dividend
//drop if yearcheck == 0
// this is not sure. 
disp "Drop abnormal year"
//summ complexity external_financing size profitability risk growth dividend


 


/* 
keep indicator_complexity prime ///
indicator_external_financing indicator_dividend stockexchangecode indicator_prime	///
*/




drop if tobins_q > 48 // 135 naspers ltd 2015
//drop if tobins_q1 == .
disp "Discriptive statistics"
summ tobins_q tobins_q1 ranking profitability profitability_1 indicator_complexity indicator_external_financing ///
indicator_prime size risk indicator_dividend


eststo clear
estpost summ tobins_q ranking profitability profitability_1 size risk risk_1 growth growth_1 ///
indicator_dividend indicator_complexity indicator_external_financing indicator_prime
esttab using tex/summ_dataset_1.tex, cells("count mean sd min max") label nostar replace

eststo clear
estpost tabulate sectorname
esttab using tex/gicsector_dataset_1_2.tex, cells("b pct") label nostar replace

eststo clear
estpost corr tobins_q ranking profitability profitability_1 size risk risk_1 growth growth_1 ///
indicator_dividend indicator_complexity indicator_external_financing indicator_prime, matrix listwise
esttab . using tex/corr_dataset_1.tex, p unstack not noobs compress label replace star(* 0.10 ** 0.05 *** 0.01)

/*
collin ranking profitability profitability_1 size risk risk_1 growth growth_1 ///
indicator_dividend indicator_complexity indicator_external_financing indicator_prime
*/

pwcorr tobins_q ranking profitability profitability_1 size risk risk_1 growth growth_1 ///
indicator_dividend indicator_complexity indicator_external_financing indicator_prime, sig star(.05)

local varlist tobins_q ranking profitability profitability_1 size risk risk_1 growth growth_1 ///
indicator_dividend indicator_complexity indicator_external_financing indicator_prime

/*
foreach i in `varlist'{
	egen "r`i'" = rank (`i'), unique
}

eststo clear
estpost corr `varlist', matrix listwise
esttab . using tex/corr_spearman_dataset_1.tex, p unstack not noobs compress label replace star(* 0.10 ** 0.05 *** 0.01)
*/

xtset globalcompanykey datayearfiscal
xtreg tobins_q ranking profitability profitability_1 size risk risk_1 growth growth_1 ///
indicator_dividend indicator_complexity indicator_external_financing indicator_prime, fe


xtreg profitability_1 ranking size risk risk_1 growth growth_1 indicator_dividend indicator_complexity ///
indicator_external_financing indicator_prime i.datayearfiscal, fe

//export excel using "dataset_1_processed.xlsx", firstrow(variables) replace
//export delimited using "dataset_processed_4.csv", replace

/*
scatter tobins_q profitability
scatter tobins_q profitability_1
scatter tobins_q risk
scatter tobins_q risk_1
*/
