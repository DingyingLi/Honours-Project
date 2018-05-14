clear all
cd /Users/Caroline/Desktop/dataset_long2

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
generate cash1 = cash/assetstotal
generate pm = netincomelossconsolidated / revenuetotal
generate roe = netincomelossconsolidated / commonordinaryequitytotal


by globalcompanykey: generate valid = 0 if (datayearfiscal[_n-1] != datayearfiscal[_n]-1) & (isocurrencycode[_n] != isocurrencycode[_n-1])
by globalcompanykey: generate currency_change = 1 if (globalcompanykey[_n] == globalcompanykey[_n-1]) & (isocurrencycode[_n] != isocurrencycode[_n-1])
list globalcompanykey isocurrencycode if currency_change == 1


by globalcompanykey: generate growth =((assetstotal- assetstotal[_n-1])/ assetstotal[_n-1])

merge m:1 globalcompanykey datayearfiscal primaryissuetagrestofworld isocurrencycode using stockprice_average_dataset2_0924


sort globalcompanykey datayearfiscal


replace comsharesoutstandingissue =  541446223.0/1000000 if globalcompany == 102422 & datayearfiscal == 2015
replace comsharesoutstandingissue = 381.927359 if globalcompany == 102572 & datayearfiscal == 2016

generate me = average_price *comsharesoutstandingissue
//generate me = price_last_day*comsharesoutstandingissue
generate tobins_q = (liabilitiestotal + me )/assetstotal


drop if datayearfiscal != 2015 & datayearfiscal != 2016
drop if _merge == 2

eststo clear
quietly estpost tabulate sectorname
esttab using dataset2/gicsector.rtf, cells("b pct") nostar label replace



drop if comparabilitystatus != ""
drop if valid == 0
drop if currency_change == 1

list globalcompanykey sectorname datayearfiscal companylegalname if growth == .
drop if growth == .
list globalcompanykey sectorname datayearfiscal companylegalname netincomelossconsolidated assetstotal if roa == .
list globalcompanykey sectorname datayearfiscal intangibleassetstotal companylegalname if comp == .
drop if comp == .
drop if roa == .
list globalcompanykey sectorname datayearfiscal companylegalname if lev == .
drop if lev == .
list globalcompanykey sectorname datayearfiscal companylegalname if size == .
drop if size == .
list globalcompanykey sectorname datayearfiscal companylegalname if tobins_q == .
drop if tobins_q == .


replace comp = 0 if comp == .
egen median_comp = median(comp)
generate indcomp = 1 if comp >= median_comp
replace indcom = 0 if comp < median_comp


replace dividend = 0 if dividend == .
generate inddividend = 1
replace inddividend = 0 if dividend == 0


keep gicsectors companylegalname globalcompanykey industryformat sectorname datayearfiscal isocurrencycode ///
fiscalyearendmonth comp size roa lev cash1 pm roe ///
growth dividend tobins_q indcomp ///
inddividend stockexchangecode   comsharesoutstandingissue  ///
intangibleassetstotal assetstotal capitalexpenditures operatingactivitiesnetcashflow netincomelossconsolidated ///
longtermdebttotal cashdividendscashflow dividendscommonordinary dividendspreferredpreference liabilitiestotal comparabilitystatus me average_price



merge 1:1 globalcompanykey datayearfiscal using coding2

drop if irscoretotal == .
drop if _merge == 2

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

disp "Discriptive statistics"
summ tobins_q roa size lev growth ///
inddividend indcomp 




eststo clear
quietly estpost tabulate sectorname
esttab using dataset2/gicsector.rtf, cells("b pct") nostar label append

eststo clear
quietly estpost summ tobins_q irscoretotal1 roa size lev growth ///
inddividend indcomp, detail 
esttab using dataset2/summ_dataset_2.rtf, cells("count mean p50 sd min max") label nostar replace


eststo clear
quietly estpost corr tobins_q  irscoretotal1  roa size lev growth ///
inddividend indcomp , matrix listwise
esttab . using dataset2/corr_dataset_2.rtf, p unstack not noobs compress label replace star(* 0.10 ** 0.05 *** 0.01)



spearman tobins_q irscoretotal irscoretotal1 irscoretotal2 irscoretotal3 roa size lev growth ///
inddividend indcomp,matrix stats(rho p) star(.05)

corr tobins_q irscoretotal irscoretotal1 irscoretotal2 irscoretotal3  roa  lev growth ///
inddividend indcomp 

sort sector globalcompanykey
by sector: egen irscore_ave = mean(irscoretotal)
by sector: egen irscore_ave1 = mean(irscoretotal1)
by sector: egen irscore_ave2 = mean(irscoretotal2)
by sector: egen irscore_ave3 = mean(irscoretotal3)


rename financialcapitalcontains  fcontains
rename financialinput  finput
rename financialoutput  foutput
rename financialnumericalnumbers fnum
rename financialtimeseries ftime
rename financialconsistent fconsist
rename businessmodelfinancial  fbus

rename manufacturingcapitalcontains mcontains
rename manufacturinginput minput
rename manufacturingoutput moutput
rename manufacturingnumericalnumbers mnum
rename manufacturingtimeseries mtime
rename manufacturingconsistent mconsist
rename businessmodelmanufacturing mbus

rename intellectualcapitalcontains icontains
rename intellectualinput iinput
rename intellectualoutput ioutput
rename intellectualnumericalnumbers inum 
rename intellectualtimeseries itime
rename intellectualconsistent  iconsist 
rename businessmodelintellectual ibus


rename humancapitalcontains hcontains
rename humaninput hinput
rename humanoutput houtput
rename humannumericalnumbers hnum
rename humantimeseries htime
rename humanconsistent hconsist 
rename businessmodelhuman hbus


rename socialandrelationshipcapitalcont scontains
rename socialandrelationshipinput sinput
rename socialandrelationshipoutput soutput
rename socialandrelationshipnumericalnu snum
rename socialandrelationshiptimeseries stime
rename socialandrelationshipconsistent sconsist
rename businessmodelsocialandrelationsh sbus


rename naturalcapitalcontains ncontains
rename naturalinput ninput
rename naturaloutput  noutput
rename naturalnumericalnumbers nnum
rename naturaltimeseries  ntime 
rename naturalconsistent nconsist
rename  businessmodelnatural nbus



eststo clear
estpost tabstat irscoretotal1, by(sector) stat(mean sd min med max)
esttab using dataset2/irscore1.rtf, cells("mean sd min p50 max") label nostar replace

eststo clear
estpost tabstat ftotal1 mtotal1 itotal1 htotal1 stotal1 ntotal1, by(sector) stat(mean min max)
esttab using dataset2/irscore1.rtf, cells("ftotal1 mtotal1 itotal1 htotal1 stotal1 ntotal1 ") label nostar append

eststo clear
estpost tabstat ftotal1 mtotal1 itotal1 htotal1 stotal1 ntotal1 if datayearfiscal==2015, by(sector) stat(mean)
esttab using dataset2/irscore1.rtf, cells("ftotal1 mtotal1 itotal1 htotal1 stotal1 ntotal1 ") label nostar append

eststo clear
estpost tabstat ftotal1 mtotal1 itotal1 htotal1 stotal1 ntotal1 if datayearfiscal==2016, by(sector) stat(mean)
esttab using dataset2/irscore1.rtf, cells("ftotal1 mtotal1 itotal1 htotal1 stotal1 ntotal1 ") label nostar append


eststo clear
estpost summ fcontains finput foutput fnum ftime fbus mcontains minput moutput mnum mtime mbus ///
icontains iinput ioutput inum itime  ibus hcontains hinput houtput hnum htime  hbus ///
scontains sinput soutput snum stime  sbus ncontains ninput noutput nnum ntime nbus, detail
esttab using dataset2/irscore1.rtf, cells("mean sd min max") label nostar append



reg tobins_q irscoretotal1 roa size lev growth  inddividend indcomp indictor_2015 ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate


eststo clear
eststo: quietly reg tobins_q irscoretotal1  roa size lev growth  inddividend indcomp ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate
esttab using dataset2/myreg.rtf, p(4) r2(4) ar2(4) scalars(F df_m df_r) star(* 0.10 ** 0.05 *** 0.01) replace



reg tobins_q irscoretotal2 roa size lev growth  inddividend indcomp ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate

reg tobins_q irscoretotal3 size roa lev growth  inddividend indcomp ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm  indictor_realestate


winsor tobins_q, gen(wtobins_q) p(0.01)
winsor growth, gen(wgrowth) p(0.01)
//winsor roa, gen(wroa) p(0.01)
//winsor size, gen(wsize) p (0.01)
//winsor lev, gen(wlev) p(0.01) 

disp "Discriptive statistics"
summ wtobins_q irscoretotal1 roa size lev wgrowth ///
inddividend indcomp 

eststo clear
quietly estpost summ wtobins_q irscoretotal1 roa size lev wgrowth ///
inddividend indcomp, detail 
esttab using dataset2/summ_dataset_2.rtf, cells("count mean p50 sd min max") label nostar append


spearman wtobins_q irscoretotal irscoretotal1 irscoretotal2 irscoretotal3 roa size lev wgrowth ///
inddividend indcomp,matrix stats(rho p) star(.05)


eststo clear
quietly estpost corr wtobins_q  irscoretotal1 irscoretotal roa size lev wgrowth ///
inddividend indcomp , matrix listwise
esttab . using dataset2/corr_dataset_2.rtf, p unstack not noobs compress label append star(* 0.10 ** 0.05 *** 0.01)

eststo clear
quietly estpost summ wtobins_q irscoretotal1 wgrowth lev roa size inddividend indcomp, detail
esttab using dataset2/summ_dataset_2.rtf, cells("count mean p50 sd min max") label nostar append



reg wtobins_q irscoretotal roa size lev wgrowth  inddividend indcomp indictor_2015 ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate

reg wtobins_q irscoretotal1 roa size lev wgrowth  inddividend indcomp indictor_2015 ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate

reg roa irscoretotal size lev wgrowth  inddividend indcomp indictor_2015 ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate

reg roa irscoretotal1 size lev wgrowth  inddividend indcomp indictor_2015 ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate


/*
reg wtobins_q irscoretotal2  roa size lev wgrowth  inddividend indcomp indictor_2015 ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate


reg wtobins_q irscoretotal3  roa size lev wgrowth  inddividend indcomp indictor_2015 ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate


reg wtobins_q irscoretotal  roa size lev wgrowth  inddividend indcomp indictor_2015 ///
indictor_enegry indictor_materials indictor_industrials indictor_consumerdiscretionary ///
indictor_consumerstaples indictor_healthcare indictor_financials indictor_informationtechnology ///
indictor_telecomm indictor_utilities indictor_realestate


