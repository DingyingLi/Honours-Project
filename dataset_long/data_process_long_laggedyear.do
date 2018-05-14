clear all
cd /Users/Caroline/Desktop/dataset_long2

import delimited dataset_long_2.csv
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


generate complexity = intangibleassetstotal[_n-1] / assetstotal[_n-1]
generate external_financing = (capitalexpenditures[_n-1] - operatingactivitiesnetcashflow[_n-1]) / ///
capitalexpenditures[_n-1]
generate size = ln(assetstotal[_n-1])
generate profitability = netincomelossconsolidated[_n-1] / assetstotal[_n-1]
generate risk = longtermdebttotal[_n-1] / assetstotal[_n-1]
replace cashdividendscashflow = 0 if cashdividendscashflow == .
replace dividendscommonordinary = 0 if dividendscommonordinary == .
replace dividendspreferredpreference = 0 if dividendspreferredpreference == .
generate dividend = cashdividendscashflow[_n-1] + dividendscommonordinary[_n-1] + dividendspreferredpreference[_n-1]
generate profitability_1 = netincomelossconsolidated[_n+1] / assetstotal
destring pricecloselastday ranking2010 ranking2011 ranking2012 ranking2013 ///
ranking2014 ranking2015, ignore("#N/A") replace 
generate market_value_of_equity = pricecloselastday * comsharesoutstandingissue

generate tobins_q = (liabilitiestotal + market_value_of_equity) / assetstotal
by globalcompanykey: generate growth = ((salesturnovernet[_n-1]- salesturnovernet[_n-2])/salesturnovernet[_n-2])
foreach y of numlist 2010 2011 2012 2013 2014 2015{
	replace ranking`y' = 0 if ranking`y' == .
}
generate ranking = ranking2010 + ranking2011 + ranking2012 + ranking2013 + ranking2014 + ranking2015

replace complexity = 0 if complexity == .
egen median_complexity = median(complexity)
generate dummy_complexity = 1 if complexity >= median_complexity
replace dummy_complexity = 0 if complexity < median_complexity

replace external_financing = 0 if external_financing == .
egen median_external_financing = median(external_financing)
generate dummy_external_financing = 1 if external_financing >= median_external_financing
replace dummy_external_financing = 0 if external_financing < median_external_financing

replace dividend = 0 if dividend == .
generate dummy_dividend = 1
replace dummy_dividend = 0 if dividend == 0


//summ complexity external_financing size profitability risk growth dividend
drop if yearcheck == 0
// this is not sure. 
disp "Drop abnormal year"
//summ complexity external_financing size profitability risk growth dividend

/*
drop if ranking2010==. & ranking2011==. & ranking2012==. & ranking2013==. & ///
ranking2014==. & ranking2015==. 
count if ranking2010 != .
count if ranking2011 != .
count if ranking2012 != .
count if ranking2013 != .
count if ranking2014 != .
count if ranking2015 != .
*/
gen ranking_last = ranking[_n-1]
drop if ranking_last == 0

count if complexity == . 
count if external_financing == . 
count if size == .
count if profitability == .
count if risk == .
count if tobins_q == .
count if growth == .
count if salesturnovernet == .
keep gicsectors companylegalname globalcompanykey industryformat sectorname datayearfiscal ///
fiscalyearendmonth yearcheck complexity external_financing size profitability risk ///
growth dividend market_value_of_equity tobins_q ranking ranking_last profitability_1 dummy_complexity ///
dummy_external_financing ///
intangibleassetstotal assetstotal capitalexpenditures operatingactivitiesnetcashflow netincomelossconsolidated ///
longtermdebttotal cashdividendscashflow dividendscommonordinary dividendspreferredpreference liabilitiestotal

drop if tobins_q > 40 // 135 naspers ltd 2015

drop if complexity == . 
drop if external_financing == . 
drop if size == .
drop if profitability == .
drop if risk == .
drop if tobins_q == .
drop if growth == .
drop if profitability_1 == .

disp "Discriptive statistics"
summ *
/*
xtset gicsectors
xtreg tobins_q ranking profitability dummy_complexity dummy_external_financing risk dividend i.datayearfiscal, fe
*/

xtset gicsectors
xtreg tobins_q ranking_last profitability dummy_complexity dummy_external_financing risk dividend i.datayearfiscal, fe 

//export excel using "dataset_processed_4.xlsx", firstrow(variables) replace
//export delimited using "dataset_processed_4.csv", replace
