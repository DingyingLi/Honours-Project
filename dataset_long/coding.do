clear all
cd /Users/Caroline/Desktop/dataset_long2
import  delimited  Dataset2coding2.csv

drop if globalcompanykey == .	
drop if irscoretotal == 0
sort sector globalcompanykey

destring  financialcapitalcontains,replace

generate ftotal = financialcapitalcontains + financialinput + financialoutput + financialnumericalnumbers + ///
financialtimeseries + financialconsistent + businessmodelfinancial

generate mtotal =  manufacturingcapitalcontains + manufacturinginput + ///
manufacturingoutput + manufacturingnumericalnumbers + manufacturingtimeseries + manufacturingconsistent + businessmodelmanufacturing

generate itotal = intellectualcapitalcontains + intellectualinput + intellectualoutput+ ///
intellectualnumericalnumbers + intellectualtimeseries + intellectualconsistent + businessmodelintellectual

generate htotal = humancapitalcontains + humaninput + humanoutput + humannumericalnumbers + humantimeseries + ///
humanconsistent + businessmodelhuman

generate stotal = socialandrelationshipcapitalcont + socialandrelationshipinput + socialandrelationshipoutput + socialandrelationshipnumericalnu ///
+ socialandrelationshiptimeseries + socialandrelationshipconsistent + businessmodelsocialandrelationsh

generate ntotal = naturalcapitalcontains + naturalinput + naturaloutput + naturalnumericalnumbers + naturaltimeseries + naturalconsistent + businessmodelnatural





eststo clear
estpost tabstat ftotal mtotal itotal htotal stotal ntotal irscoretotal, by(sector) stat(mean sd min med max)
esttab using tex6/summ_irscoretotal.rtf, cells("ftotal mtotal itotal stotal ntotal irscoretotal") label nostar replace


//tab ftotal mtotal itotal htotal stotal ntotal irscoretotal




generate ftotal1 = financialcapitalcontains + financialinput + financialoutput + financialnumericalnumbers + ///
financialtimeseries + businessmodelfinancial

generate mtotal1=  manufacturingcapitalcontains + manufacturinginput + ///
manufacturingoutput + manufacturingnumericalnumbers + manufacturingtimeseries + businessmodelmanufacturing

generate itotal1 = intellectualcapitalcontains + intellectualinput + intellectualoutput+ ///
intellectualnumericalnumbers + intellectualtimeseries + businessmodelintellectual

generate htotal1 = humancapitalcontains + humaninput + humanoutput + humannumericalnumbers + humantimeseries + ///
businessmodelhuman

generate stotal1 = socialandrelationshipcapitalcont + socialandrelationshipinput + socialandrelationshipoutput + socialandrelationshipnumericalnu ///
+ socialandrelationshiptimeseries + businessmodelsocialandrelationsh

generate ntotal1 = naturalcapitalcontains + naturalinput + naturaloutput + naturalnumericalnumbers + naturaltimeseries +  businessmodelnatural



generate irscoretotal1 =ftotal1 + mtotal1+itotal1 + htotal1 + stotal1 + ntotal1



eststo clear
estpost tabstat ftotal1 mtotal1 itotal1 htotal1 stotal1 ntotal1 irscoretotal1, by(sector) stat(mean sd min med max)
esttab using tex6/summ_irscoretotal1.rtf, cells("ftotal1 mtotal1 itotal1 stotal1 ntotal1 irscoretotal1") label nostar replace


//tab ftotal1 mtotal1 itotal1 htotal1 stotal1 ntotal1 irscoretotal1


generate ftotal2 =  financialcapitalcontains + financialinput + financialoutput + businessmodelfinancial

generate mtotal2 =   manufacturingcapitalcontains + manufacturinginput + manufacturingoutput + businessmodelmanufacturing

generate itotal2 = intellectualcapitalcontains + intellectualinput + intellectualoutput + businessmodelintellectual

generate htotal2 =   humancapitalcontains + humaninput + humanoutput + businessmodelhuman

generate stotal2 =  socialandrelationshipcapitalcont +  socialandrelationshipinput + socialandrelationshipoutput + businessmodelsocialandrelationsh

generate ntotal2 =  naturalcapitalcontains +naturalinput + naturaloutput +  businessmodelnatural


generate irscoretotal2 = ftotal2 + mtotal2 + itotal2 + htotal2 + stotal2 + ntotal2


eststo clear
estpost tabstat ftotal2 mtotal2 itotal2 htotal2 stotal2 ntotal2 irscoretotal2, by(sector) stat(mean sd min med max)
esttab using tex6/summ_irscoretotal2.rtf, cells("ftotal2 mtotal2 itotal2 stotal2 ntotal2 irscoretotal2") label nostar replace


//tab ftotal2 mtotal2 itotal2 htotal2 stotal2 ntotal2 irscoretotal2 




generate ftotal3 = financialinput + financialoutput + financialnumericalnumbers + ///
 businessmodelfinancial

generate mtotal3 =  manufacturinginput + ///
manufacturingoutput + manufacturingnumericalnumbers +  businessmodelmanufacturing

generate itotal3 = intellectualinput + intellectualoutput+ ///
intellectualnumericalnumbers +  businessmodelintellectual

generate htotal3 = humaninput + humanoutput + humannumericalnumbers + businessmodelhuman

generate stotal3 = socialandrelationshipinput + socialandrelationshipoutput + socialandrelationshipnumericalnu ///
 + businessmodelsocialandrelationsh

generate ntotal3 = naturalinput + naturaloutput + naturalnumericalnumbers  +  businessmodelnatural

generate irscoretotal3 =ftotal3 + mtotal3+itotal3 + htotal3 + stotal3 + ntotal3



generate ftotal4 = financialinput + financialoutput + businessmodelfinancial

generate mtotal4 = manufacturinginput + manufacturingoutput + businessmodelmanufacturing

generate itotal4 =  intellectualinput + intellectualoutput + businessmodelintellectual

generate htotal4 =   humaninput + humanoutput + businessmodelhuman

generate stotal4 =   socialandrelationshipinput + socialandrelationshipoutput + businessmodelsocialandrelationsh

generate ntotal4 =  naturalinput + naturaloutput +  businessmodelnatural


generate irscoretotal4 = ftotal4 + mtotal4 + itotal4 + htotal4 + stotal4 + ntotal4









save "coding2.dta", replace

/*egen avefcontains = mean(financialcapitalcontains)
egen avefinput = mean(financialinput)
egen avefoutput = mean(financialoutput)
egen avefnum = mean(financialnumericalnumbers)
egen aveftime = mean(financialtimeseries )
egen avefconsist = mean(financialconsistent)
egen avefbus = mean(businessmodelfinancial)
egen aveftotal = mean(ftotal)
egen aveftotal1 = mean(ftotal1)
egen aveftotal2 = mean(ftotal2)

eststo clear
estpost tabstat avefcontains avefinput avefoutput avefnum aveftime avefconsist avefbus aveftotal aveftotal1 aveftotal2, by(sector) stat(mean sd min med max)
esttab using tex6/summ_irscoretotal3.rtf, cells("avefcontains avefinput avefoutput avefnum aveftime avefconsist avefbus aveftotal aveftotal1 aveftotal2") label nostar replace

//sum avefcontains avefinput avefoutput avefnum aveftime avefconsist avefbus aveftotal aveftotal1 aveftotal2, detail

egen avemcontains = mean(manufacturingcapitalcontains)
egen aveminput = mean(manufacturinginput)
egen avemoutput = mean(manufacturingoutput)
egen avemnum = mean(manufacturingnumericalnumbers)
egen avemtime = mean(manufacturingtimeseries )
egen avemconsist = mean(manufacturingconsistent)
egen avembus = mean(businessmodelmanufacturing)
egen avemtotal = mean(mtotal)
egen avemtotal1 = mean(mtotal1)
egen avemtotal2 = mean(mtotal2)

eststo clear
estpost tabstat avemcontains aveminput avemoutput avemnum avemtime avemconsist avembus avemtotal avemtotal1 avemtotal2, by(sector) stat(mean sd min med max)
esttab using tex6/summ_irscoretotal3.rtf, cells("avemcontains aveminput avemoutput avemnum avemtime avemconsist avembus avemtotal avemtotal1 avemtotal2") label nostar replace

//sum avemcontains aveminput avemoutput avemnum avemtime avemconsist avembus avemtotal avemtotal1 avemtotal2, detail 

egen aveicontains = mean(intellectualcapitalcontains)
egen aveiinput = mean(intellectualinput)
egen aveioutput = mean(intellectualoutput)
egen aveinum = mean(intellectualnumericalnumbers)
egen aveitime = mean(intellectualtimeseries )
egen aveiconsist = mean(intellectualconsistent)
egen aveibus = mean( businessmodelintellectual)
egen aveitotal = mean(itotal)
egen aveitotal1 = mean(itotal1)
egen aveitotal2 = mean(itotal2)


eststo clear
estpost tabstat aveicontains aveiinput aveioutput aveinum aveitime aveiconsist aveibus aveitotal aveitotal1 aveitotal2, by(sector) stat(mean sd min med max)
esttab using tex6/summ_irscoretotal4.rtf, cells(" aveicontains aveiinput aveioutput aveinum aveitime aveiconsist aveibus aveitotal aveitotal1 aveitotal2") label nostar replace

//sum aveicontains aveiinput aveioutput aveinum aveitime aveiconsist aveibus aveitotal aveitotal1 aveitotal2, detail

egen avehcontains = mean(humancapitalcontains)
egen avehinput = mean(humaninput)
egen avehoutput = mean(humanoutput)
egen avehnum = mean(humannumericalnumbers)
egen avehtime = mean(humantimeseries )
egen avehconsist = mean(humanconsistent)
egen avehbus = mean( businessmodelhuman)
egen avehtotal = mean(htotal)
egen avehtotal1 = mean(htotal1)
egen avehtotal2 = mean(htotal2)

eststo clear
estpost tabstat avehcontains avehinput avehoutput avehnum avehtime avehconsist avehbus avehtotal avehtotal1 avehtotal2, by(sector) stat(mean sd min med max)
esttab using tex6/summ_irscoretotal4.rtf, cells(" avehcontains avehinput avehoutput avehnum avehtime avehconsist avehbus avehtotal avehtotal1 avehtotal2") label nostar replace


//sum avehcontains avehinput avehoutput avehnum avehtime avehconsist avehbus avehtotal avehtotal1 avehtotal2, detail

egen avescontains = mean(socialandrelationshipcapitalcont)
egen avesinput = mean(socialandrelationshipinput)
egen avesoutput = mean(socialandrelationshipoutput)
egen avesnum = mean(socialandrelationshipnumericalnu)
egen avestime = mean(socialandrelationshiptimeseries )
egen avesconsist = mean(socialandrelationshipconsistent)
egen avesbus = mean( businessmodelsocialandrelationsh)
egen avestotal = mean(stotal)
egen avestotal1 = mean(stotal1)
egen avestotal2 = mean(stotal2)

eststo clear
estpost tabstat avehcontains avehinput avehoutput avehnum avehtime avehconsist avehbus avehtotal avehtotal1 avehtotal2, by(sector) stat(mean sd min med max)
esttab using tex6/summ_irscoretotal5.rtf, cells(" avehcontains avehinput avehoutput avehnum avehtime avehconsist avehbus avehtotal avehtotal1 avehtotal2") label nostar replace

//sum avescontains avesinput avesoutput avesnum avestime avesconsist avesbus avestotal avestotal1 avestotal2, detail

egen avencontains = mean(naturalcapitalcontains)
egen aveninput = mean(naturalinput)
egen avenoutput = mean(naturaloutput)
egen avennum = mean(naturalnumericalnumbers)
egen aventime = mean(naturaltimeseries )
egen avenconsist = mean(naturalconsistent)
egen avenbus = mean( businessmodelnatural)
egen aventotal = mean(ntotal)
egen aventotal1 = mean(ntotal1)
egen aventotal2 = mean(ntotal2)

eststo clear
estpost tabstat avencontains aveninput avenoutput avennum aventime avenconsist avenbus aventotal aventotal1 aventotal2, by(sector) stat(mean sd min med max)
esttab using tex6/summ_irscoretotal6.rtf, cells(" avencontains aveninput avenoutput avennum aventime avenconsist avenbus aventotal aventotal1 aventotal22") label nostar replace

//sum avencontains aveninput avenoutput avennum aventime avenconsist avenbus aventotal aventotal1 aventotal2, detail

/*egen aveirscoretotal = mean(irscoretotal)
egen aveirscoretotal1 = mean(irscoretotal1)
egen aveirscoretotal2 = mean(irscoretotal2)

eststo clear
estpost summ aveirscoretotal aveirscoretotal1 aveirscore, detail
esttab using tex6/summ_irscoretotal7.rtf, cells("mean sd min p50 max") nostar label replace

//sum aveirscoretotal aveirscoretotal1 aveirscore, detail



/*by sector: egen avefcontains1 = mean(financialcapitalcontains)
by sector: egen avefinput1 = mean(financialinput)
by sector:egen avefoutput1 = mean(financialoutput)
by sector: egen avefnum1 = mean(financialnumericalnumbers)
by sector: egen aveftime1 = mean(financialtimeseries )
by sector: egen avefconsist1 = mean(financialconsistent)
by sector: egen avefbus1 = mean(businessmodelfinancial)
by sector: egen aveftotal01 = mean(ftotal)
by sector: egen aveftotal101 = mean(ftotal1)
by sector: egen aveftotal201 = mean(ftotal2)

sum avefcontains1 avefinput1 avefoutput1 avefnum1 aveftime1 avefconsist1 avefbus1 aveftotal01 aveftotal101 aveftotal201, detail


by sector: egen avemcontains1 = mean(manufacturingcapitalcontains)
by sector: egen aveminput1 = mean(manufacturinginput)
by sector: egen avemoutput1 = mean(manufacturingoutput)
by sector: egen avemnum1 = mean(manufacturingnumericalnumbers)
by sector: egen avemtime1 = mean(manufacturingtimeseries )
by sector: egen avemconsist1 = mean(manufacturingconsistent)
by sector: egen avembus1 = mean(businessmodelmanufacturing)
by sector: egen avemtotal01 = mean(mtotal)
by sector: egen avemtotal101 = mean(mtotal1)
by sector: egen avemtotal201 = mean(mtotal2)

sum avemcontains1 aveminput1 avemoutput1 avemnum1 avemtime1 avemconsist1 avembus1 avemtotal01 avemtotal101 avemtotal201, detail



by sector: egen aveicontains1 = mean(intellectualcapitalcontains)
by sector: egen aveiinput1 = mean(intellectualinput)
by sector: egen aveioutput1 = mean(intellectualoutput)
by sector: egen aveinum1 = mean(intellectualnumericalnumbers)
by sector: egen aveitime1 = mean(intellectualtimeseries )
by sector: egen aveiconsist1 = mean(intellectualconsistent)
by sector: egen aveibus1 = mean( businessmodelintellectual)
by sector: egen aveitotal01 = mean(itotal)
by sector: egen aveitotal101 = mean(itotal1)
by sector: egen aveitotal201 = mean(itotal2)

sum aveicontains1 aveiinput1 aveioutput1 aveinum1 aveitime1 aveiconsist1 aveibus1 aveitotal01 aveitotal101 aveitotal201, detail


by sector: egen avehcontains1 = mean(humancapitalcontains)
by sector: egen avehinput1 = mean(humaninput)
by sector: egen avehoutput1 = mean(humanoutput)
by sector: egen avehnum1 = mean(humannumericalnumbers)
by sector: egen avehtime1 = mean(humantimeseries )
by sector: egen avehconsist1 = mean(humanconsistent)
by sector: egen avehbus1 = mean( businessmodelhuman)
by sector: egen avehtotal01 = mean(htotal)
by sector: egen avehtotal101 = mean(htotal1)
by sector: egen avehtotal201 = mean(htotal2)

sum avehcontains1 avehinput1 avehoutput1 avehnum1 avehtime1 avehconsist1 avehbus1 avehtotal01 avehtotal101 avehtotal201, detail



by sector: egen avescontains1 = mean(socialandrelationshipcapitalcont)
by sector: egen avesinput1 = mean(socialandrelationshipinput)
by sector: egen avesoutput1 = mean(socialandrelationshipoutput)
by sector: egen avesnum1 = mean(socialandrelationshipnumericalnu)
by sector: egen avestime1 = mean(socialandrelationshiptimeseries )
by sector: egen avesconsist1 = mean(socialandrelationshipconsistent)
by sector: egen avesbus1 = mean( businessmodelsocialandrelationsh)
by sector: egen avestotal01 = mean(stotal)
by sector: egen avestotal101 = mean(stotal1)
by sector: egen avestotal201 = mean(stotal2)

sum avescontains1 avesinput1 avesoutput1 avesnum1 avestime1 avesconsist1 avesbus1 avestotal01 avestotal101 avestotal201, detail


by sector: egen avencontains1 = mean(naturalcapitalcontains)
by sector: egen aveninput1 = mean(naturalinput)
by sector: egen avenoutput1 = mean(naturaloutput)
by sector: egen avennum1 = mean(naturalnumericalnumbers)
by sector: egen aventime1 = mean(naturaltimeseries )
by sector: egen avenconsist1 = mean(naturalconsistent)
by sector: egen avenbus1 = mean( businessmodelnatural)
by sector: egen aventotal01 = mean(ntotal)
by sector: egen aventotal101 = mean(ntotal1)
by sector: egen aventotal201 = mean(ntotal2)

sum avencontains1 aveninput1 avenoutput1 avennum1 aventime1 avenconsist1 avenbus1 aventotal01 aventotal101 aventotal201, detail



by sector: egen aveirscoretotal01 = mean(irscoretotal)
by sector: egen aveirscoretotal101 = mean(irscoretotal1)
by sector: egen aveirscore01 = mean(irscore)

sum aveirscoretotal01 aveirscoretotal101 aveirscore01, detail
