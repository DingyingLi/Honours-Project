clear all
cd /Users/Caroline/Desktop/dataset_long2
//import excel "/Users/Caroline/Desktop/dataset_long/dataset.xlsx", sheet("WRDS") firstrow clear

import delimited dataset2_completed.csv


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
//generate extfin= (capitalexpenditures - operatingactivitiesnetcashflow) / ///
//capitalexpenditures

generate size = ln(assetstotal)
replace size = ln(assetstotal * 1.10960956175298 ) if isocurrencycode == "EUR" & datayearfiscal == 2015
replace size = ln(assetstotal * 1.528396812749 ) if isocurrencycode == "GBP" & datayearfiscal == 2015
replace size = ln(assetstotal * 0.727851136614596) if isocurrencycode == "SGD" & datayearfiscal == 2015
replace size = ln(assetstotal * 0.078819198 ) if isocurrencycode == "ZAR" & datayearfiscal == 2015
replace size = ln(assetstotal * 1.10719442231075 ) if isocurrencycode == "EUR" & datayearfiscal == 2016
replace size = ln(assetstotal * 1.35551752988047 ) if isocurrencycode == "GBP" & datayearfiscal == 2016
replace size = ln(assetstotal * 0.725028387108148) if isocurrencycode == "SGD" & datayearfiscal == 2016
replace size = ln(assetstotal * 0.068308114 ) if isocurrencycode == "ZAR" & datayearfiscal == 2016



generate roa= netincomelossconsolidated / assetstotal
replace longtermdebttotal = 0 if longtermdebttotal == .
replace debtincurrentliabilitiestotal = 0 if  debtincurrentliabilitiestotal == .
generate lev = ( longtermdebttotal + debtincurrentliabilitiestotal) / assetstotal
replace cashdividendscashflow = 0 if cashdividendscashflow == .
replace dividendscommonordinary = 0 if dividendscommonordinary == .
replace dividendspreferredpreference = 0 if dividendspreferredpreference == .
generate dividend = cashdividendscashflow + dividendscommonordinary + dividendspreferredpreference
by globalcompanykey: generate roa_1 = netincomelossconsolidated[_n+1] / assetstotal[_n+1]
by globalcompanykey: generate valid = 0 if (datayearfiscal[_n-1] != datayearfiscal[_n]-1) & (isocurrencycode[_n] != isocurrencycode[_n-1])
by globalcompanykey: generate currency_change = 1 if (globalcompanykey[_n] == globalcompanykey[_n-1]) & (isocurrencycode[_n] != isocurrencycode[_n-1])
list globalcompanykey isocurrencycode if currency_change == 1



by globalcompanykey: generate growth =((assetstotal- assetstotal[_n-1])/ assetstotal[_n-1])

//drop if datayearfiscal!= 2015



count if gicsectors == 40
count if gicsectors == 60
list  companylegalname globalcompanykey sectorname datayearfiscal if comparabilitystatus != ""



merge m:1 globalcompanykey datayearfiscal primaryissuetagrestofworld isocurrencycode using stockprice_average_dataset2_0911


sort globalcompanykey datayearfiscal

generate me = average_price *comsharesoutstandingissue
//generate me = price_last_day*comsharesoutstandingissue

generate tobins_q = (liabilitiestotal + me )/assetstotal
by globalcompanykey: generate tobins_q1 = tobins_q[_n+1] 

//by globalcompanykey: generate tobins_q1 = tobins_q[_n+1] 

drop if datayearfiscal != 2015 & datayearfiscal != 2016
drop if _merge == 2



eststo clear
quietly estpost tabulate sectorname
esttab using tex5/gicsector_dataset_2_1.tex, cells("b pct") nostar label replace
esttab using tex5/gicsector_dataset_2_1.rtf, cells("b pct") nostar label replace


drop if comparabilitystatus != ""
drop if valid == 0
drop if currency_change == 1

list globalcompanykey sectorname datayearfiscal companylegalname if growth == .
drop if growth == .
list globalcompanykey sectorname datayearfiscal companylegalname netincomelossconsolidated assetstotal if roa == .
list globalcompanykey sectorname datayearfiscal intangibleassetstotal companylegalname if comp == .
drop if comp == .
drop if roa_1 == .
list globalcompanykey sectorname datayearfiscal companylegalname if lev == .
drop if lev == .
list globalcompanykey sectorname datayearfiscal companylegalname if size == .
drop if size == .
list globalcompanykey sectorname datayearfiscal companylegalname if tobins_q == .
drop if tobins_q1 == .





replace comp = 0 if comp == .
egen median_comp = median(comp)
generate indcomp = 1 if comp >= median_comp
replace indcom = 0 if comp < median_comp

/*replace extfin = 0 if extfin == .
egen median_extfin = median(extfin)
generate indextfin = 1 if extfin >= median_extfin
replace indextfin = 0 if extfin < median_extfin
*/
replace dividend = 0 if dividend == .
generate inddividend = 1
replace inddividend = 0 if dividend == 0

//summ complexity external_financing size profitability risk growth dividend

// this is not sure. 
disp "Drop abnormal year"
//summ complexity external_financing size profitability risk growth dividend


keep gicsectors companylegalname globalcompanykey industryformat sectorname datayearfiscal isocurrencycode ///
fiscalyearendmonth comp size roa lev ///
growth dividend tobins_q indcomp tobins_q1 roa_1 ///
inddividend stockexchangecode   comsharesoutstandingissue  ///
intangibleassetstotal assetstotal capitalexpenditures operatingactivitiesnetcashflow netincomelossconsolidated  ///
longtermdebttotal cashdividendscashflow dividendscommonordinary dividendspreferredpreference liabilitiestotal comparabilitystatus me average_price





merge 1:1 globalcompanykey datayearfiscal using coding2.dta

drop if _merge == 2
drop if irscoretotal == .
//drop if globalcompanykey == 211175

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


list globalcompanykey datayearfiscal companylegalname tobins_q if tobins_q > 5
//drop if tobins_q > 5

list globalcompanykey companylegalname datayearfiscal sector growth if growth > 2.5
//drop if growth > 2.5


disp "Discriptive statistics"
summ tobins_q1 roa_1 roa size lev growth ///
inddividend indcomp 

corr tobins_q1 roa_1 roa  irscoretotal irscoretotal1 irscoretotal2 irscoretotal3 size lev growth ///
inddividend indcomp 


reg tobins_q1 irscoretotal roa size lev growth  inddividend indcomp ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate


reg tobins_q1 irscoretotal1 roa size lev growth  inddividend indcomp ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate



reg tobins_q1 irscoretotal2 roa size lev growth  inddividend indcomp ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate

reg tobins_q1 irscoretotal3 roa size lev growth  inddividend indcomp ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate




reg roa_1 irscoretotal roa size lev growth  inddividend indcomp ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate


reg roa_1 irscoretotal1 roa size lev growth  inddividend indcomp ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate


reg roa_1 irscoretotal2 roa size lev growth  inddividend indcomp ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate

reg roa_1 irscoretotal3 roa size lev growth  inddividend indcomp ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate


winsor tobins_q1, gen(wtobins_q1) p(0.01)
winsor growth, gen(wgrowth) p(0.01)
winsor lev, gen(wlev) p(0.01)
winsor roa_1, gen(wroa1) p (0.01) 
winsor roa, gen(wroa) p (0.01) 





corr wtobins_q1 wroa1 wroa irscoretotal irscoretotal1 irscoretotal2 irscoretotal3 size wlev wgrowth ///
inddividend indcomp 

reg wroa1 irscoretotal1 wroa size wlev wgrowth  inddividend indcomp ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate




reg wroa irscoretotal1 size wlev wgrowth  inddividend indcomp ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate


reg wtobins_q1 irscoretotal1 wroa size wlev wgrowth  inddividend indcomp ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate

spearman wtobins_q1 irscoretotal1 wroa size wlev wgrowth ///
inddividend indcomp, matrix stats(rho p) star(.05)

/*reg roa irscoretotal size lev growth  inddividend indcomp ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate


reg roa irscoretotal1  size lev growth  inddividend indcomp ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate



reg roa irscoretotal2  size lev growth  inddividend indcomp ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate

reg roa irscoretotal3 size lev growth  inddividend indcomp ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate
