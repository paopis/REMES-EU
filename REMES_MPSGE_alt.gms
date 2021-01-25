* ============                             ===================
* ============ DEFINITION OF THE CGE MODEL ===================
* ============                             ===================


$ONTEXT
$MODEL: Arrow_Debreu

$SECTORS:
        U(cnt)                                             ! Consumption of households
        UGL(cnt)                                         ! Consumption of the local governments
        UINVB(cnt)                                        ! Fixed capital investments - local

        X(cnt,com)                                        ! Armington composite

        TRANSP(cnt)                                      ! Transport services

        EXPORT(cnt,com)$(sum(sec, XDDZ(cnt,sec,com)) and not sameas(com,"gH2") )                    ! Export activity
        EXPORT(cnt,com)$(sameas(com,"gH2"))
        EXPORTN(cnt,com)$(sum(sec, XDDZ(cnt,sec,com)))


        XD(cnt,sec)$(XDZ(cnt,sec) and not sameas(sec,"i-H2S") and not sameas(sec,"i-H2CCS")  and not sameas(sec,"i-H2E") and not sameas(sec,"i-PCCS"))                       ! Domestic production
        XD(cnt,sec)$(sameas(sec,"i-H2S") or sameas(sec,"i-H2E") or sameas(sec,"i-H2CCS") or sameas(sec,"i-PCCS"))

$COMMODITIES:
        PU(cnt)                                          ! Private consumption price index
        PUGL(cnt)                                         ! Local Govenrmental consumption price index
        PUINVB(cnt)                                       ! Fixed capital local invesment price index
        PD(cnt,sec,com)$(XDDZ(cnt,sec,com) or (sameas(sec,"i-H2S") and sameas(com,"gH2")) or (sameas(sec,"i-H2CCS") and sameas(com,"gH2")) or (sameas(sec,"i-H2E") and sameas(com,"gH2")) or (sameas(sec,"i-PCCS") and XDDZ(cnt,"i-POW",com)))
        PDD(cnt,com)$(XXDZ(cnt, com)>1e-6  and not sameas(com,"gH2"))       ! Price of domestic goods provided to domestic market
        PDD(cnt,com)$(sameas(com,"gH2"))

        P(cnt,com)$(XZ(cnt,com) and not sameas(com,"gH2"))                  ! Composite consumer price
        P(cnt,com)$(sameas(com,"gH2") and sum(sec,Pathway_adj(cnt, sec, "gH2")))
        PCO2(cnt)$(CO2B(cnt))
        PL(cnt)                                           ! Price of (locally traded)labour

        RKC(cnt)$(P_S =0)                                     ! Price of (locally traded) capital
        RKC(cnt)       ! Price of (locally traded) capital

        ERint                                     ! Terms of trade
        ERext                                          ! Terms of trade
        PTM(cnt, cntt)$(sum(com,trademargins(com, cntt,cnt)) ne 0    )           ! Transport and trade margins
        PTR(cnt)$(TRANSF.L(cnt) )                         ! Price of governmental transfers
        PS(cnt)                                          !Price of (local) savings (artificial)
        POG(cnt)$(OGR(cnt))                              ! price of local oil and gas resource
        PCL(cnt)$(CR(cnt))                               ! price of coal resources
        PNG(cnt)$(NGR(cnt))                              ! price of natural gas resources
*        PLR(cnt)$(LR(cnt))                               ! price of land

$CONSUMERS:
        HOUS(cnt)                                        ! Representative household

        GOVTL(cnt)                                       ! Local Governments

        INVB(cnt)                                        ! Local Investment agents

$AUXILIARY:
        LS(cnt)                                          ! Labour endowment
        KS(cnt)                                          ! Capital endowment
        TRANSF(cnt)                                      ! Govermental transfers to households
        TRROW(cnt)                                       ! Net transfers to government (closing trade balance)
        TRHROW(cnt)                                      ! Net transfers to households (closing trade balance)
        PCINDEX(cnt)                                     ! Consumer price index
        PIINDEX(cnt)                                     ! Local Investment index
        SH(cnt)                                          ! Households savings
        SGL(cnt)                                         ! Local Governmental savings
        SROW(cnt)                                        ! Savings from RoW
        SV(cnt,com)                                      ! Changes in stocks
        INV(cnt,sec)                                     ! Sectoral investments
        R_SV(cnt,com)                                    ! Multiplier for changes in stocks
        R_SH(cnt)                                        ! Multiplier for households savings
        UR(cnt)                                          ! Unemployment multiplier

*====================================================================================
*=======================     Production Blocks    ===================================
*====================================================================================


*Domestic Production
$PROD:XD(cnt,sec)$(XDZ(cnt,sec) and P_S > 0 and not sameas(sec,"i-H2S") and not sameas(sec,"i-H2CCS") and not sameas(sec,"i-H2E") and not sameas(sec,"i-POW") and not sameas(sec,"i-PCCS") and not ressecs(sec))
+ t:0 s:ELAS(sec, "KLEM") sM(s):0 skle(s):ELAS(sec, "KLE")  sE(sKLE):1 skl(skle):ELAS(sec, "KL") sk(skl):10 com.tl(sE):0
O:PD(cnt,sec,com)$(XDDZ(cnt,sec,com))       Q:(XDDZ(cnt,sec,com))
+        P:(1-taxpz(cnt,sec))
+        A:GOVTL(cnt)   T:taxp(cnt,sec)

* Materials and services
I:P(cnt,com)$(PID(com) eq 0 or PID(com) eq 3)            Q:(IOZ(cnt,com,sec))
+        P:(1+taxcz(cnt,com))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        sM:

* Non-fossil fuels
I:P(cnt,com)$(PID(com) = 1 and (IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)) and FF(com)=0 )
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))*eint(cnt))       P:((1+taxcz(cnt,com))/eint(cnt))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        sE:

* Fossil fuels
I:P(cnt,com)$(PID(com) = 1 and (IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)) and FF(com)=1)
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))*eint(cnt))     P:((1+taxcz(cnt,com))/eint(cnt))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        com.tl:

* CO2 allowances
I:PCO2(cnt)#(com)$(PID(com) = 1 and CO2P(cnt,com,sec) and FF(com)=1 and CO2B(cnt))
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))*CO2r(cnt,com,sec)*cint(cnt)*eint(cnt))     P:(1e-6/eint(cnt))
+        com.tl:

* Hydrogen
I:P(cnt,"gH2")$(Pathway_adj(cnt, sec, "gH2"))
+        Q:(Pathway_adj(cnt, sec, "gH2")*eint(cnt))     P:(1/eint(cnt))
+        sE:


* energy generation
I:P(cnt,com)$(PID(com) = 2 and (IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)))
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))*eint(cnt))       P:((1+taxcz(cnt,com))/eint(cnt))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        sE:

* energy transmission
I:P(cnt,com)$(PID(com)=4 and (IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)))
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))*eint(cnt))       P:((1+taxcz(cnt,com))/eint(cnt))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        sE:


* Labour, Capital & Savings
I:PL(cnt)               Q:(LZ(cnt,sec)/PRC(cnt))    skl:
I:RKC(cnt)$(Pathway_adj_cap(cnt, sec))        Q:(Pathway_adj_cap(cnt, sec)/PRC(cnt))    sk:
I:PS(cnt)               Q:INVZ(cnt,sec)  sk:


*Domestic Production
$PROD:XD(cnt,sec)$(XDZ(cnt,sec) and P_S > 0 and ressecs(sec) )
+ t:0  s:0.5 sR(s):0 s1(s):ELAS(sec, "KLEM") sM(s1):0 skle(s1):1  com.tl(skle):0
O:PD(cnt,sec,com)$(XDDZ(cnt,sec,com))       Q:(XDDZ(cnt,sec,com))
+        P:(1-taxpz(cnt,sec))
+        A:GOVTL(cnt)   T:taxp(cnt,sec)

* Materials and services
I:P(cnt,com)$(PID(com) eq 0 or PID(com) eq 3)            Q:(IOZ(cnt,com,sec))
+        P:(1+taxcz(cnt,com))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        sM:

* Non-fossil fuels
I:P(cnt,com)$(PID(com) = 1 and (IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)) and FF(com)=0 )
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)))       P:(1+taxcz(cnt,com))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        skle:

* Fossil fuels
I:P(cnt,com)$(PID(com) = 1 and (IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)) and FF(com)=1)
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)))       P:(1+taxcz(cnt,com))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        com.tl:

* CO2 allowances
I:PCO2(cnt)#(com)$(PID(com) = 1 and CO2P(cnt,com,sec) and FF(com)=1 and CO2B(cnt))
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))*CO2r(cnt,com,sec))     P:1e-6
+        com.tl:

* Hydrogen
I:P(cnt,"gH2")$(Pathway_adj(cnt, sec, "gH2"))
+        Q:(Pathway_adj(cnt, sec, "gH2"))        P:1
+        skle:


* Energy generation
I:P(cnt,com)$(PID(com) = 2 and (IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)))
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)))       P:(1+taxcz(cnt,com))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        skle:

* Energy transmission
I:P(cnt,com)$(PID(com)=4 and (IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)))
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)))       P:(1+taxcz(cnt,com))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        skle:

* Labour, Capital & Resources
I:PL(cnt)               Q:(LZ(cnt,sec)/PRC(cnt))                                            skle:
I:RKC(cnt)$(Pathway_adj_cap(cnt, sec))        Q:(Pathway_adj_cap(cnt, sec)/PRC(cnt))        skle:
I:POG(cnt)$(sameas(sec,"i-COIL"))               Q:OGR(cnt)                       sR:
I:PCL(cnt)$(sameas(sec,"i-COAL"))               Q:CR(cnt)                        sR:
I:PNG(cnt)$(sameas(sec,"i-NG"))                 Q:NGR(cnt)                       sR:

*write old structure. Forget increase in land.
*Domestic Production
$PROD:XD(cnt,sec)$(XDZ(cnt,sec) and P_S > 0 and sameas(sec,"i-POW") )
+ t:0 s:ELAS(sec, "KLEM") sM(s):0 skle(s):ELAS(sec, "KLE")  sE(sKLE):0.1 skl(skle):ELAS(sec, "KL")  com.tl(sE):0
O:PD(cnt,sec,com)$(XDDZ(cnt,sec,com) > 1e-6)       Q:(XDDZ(cnt,sec,com)*Rp(cnt))
+        P:(1-taxpz(cnt,sec))
+        A:GOVTL(cnt)   T:taxp(cnt,sec)

*Materials and services
I:P(cnt,com)$(PID(com) eq 0 or PID(com) eq 3)            Q:(IOZ(cnt,com,sec))
+        P:(1+taxcz(cnt,com))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        sM:

* non-fossil fuels
I:P(cnt,com)$(PID(com) = 1 and (IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)) and FF(com)=0 )
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)))       P:(1+taxcz(cnt,com))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        sE:

* fossil fuels
I:P(cnt,com)$(PID(com) = 1 and (IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)) and FF(com)=1)
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)))       P:(1+taxcz(cnt,com))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        com.tl:

* CO2 allowances
I:PCO2(cnt)#(com)$(PID(com) = 1 and CO2P(cnt,com,sec) and FF(com)=1 and CO2B(cnt))
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))*CO2r(cnt,com,sec))     P:1e-6
+        com.tl:

* Hydrogen
I:P(cnt,"gH2")$(Pathway_adj(cnt, sec, "gH2"))
+        Q:(Pathway_adj(cnt, sec, "gH2"))       P:1
+        sE:


* Energy generation
I:P(cnt,com)$(PID(com) = 2 and (IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)))
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)))       P:(1+taxcz(cnt,com))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        sE:

* Energy transmission
I:P(cnt,com)$(PID(com)=4 and (IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)))
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)))       P:(1+taxcz(cnt,com))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        sE:

* Labour, Capital & Resources
I:PL(cnt)               Q:(LZ(cnt,sec)/PRC(cnt))                                            skl:
I:RKC(cnt)$(Pathway_adj_cap(cnt, sec))        Q:(Pathway_adj_cap(cnt, sec)/PRC(cnt))        skl:



*Hydrogen Production
*$PROD:XD(cnt,"i-H2S") t:0 s:ELAS("i-H2S", "KLME") sM(sKLM):0 sklm(s):ELAS("i-H2S", "KLM")  sE(s):0.1 skl(sklm):ELAS("i-H2S", "KL") com.tl(sE):0
$PROD:XD(cnt,"i-H2S") t:0 s:ELAS("i-H2S", "KLEM") sM(s):0 skle(s):ELAS("i-H2S", "KLE")  sE(sKLE):1 skl(skle):ELAS("i-H2S", "KL") com.tl(sE):0
O:PD(cnt,"i-H2S","gH2")$(sum(sec,XDDZ(cnt,sec,"gNG")))      Q:(3)

* Materials and services
I:P(cnt,com)$((PID(com) eq 0 or PID(com) eq 3) and InputCom("i-H2S",com)    )   Q:InputCom("i-H2S",com)
+        A:GOVTL(cnt)   T:taxc(cnt,com)        sM:

* Fuels
I:P(cnt,com)$(PID(com) = 1 and InputCom("i-H2S",com)    )                       Q:(InputCom("i-H2S",com)*eint(cnt))   P:(1/eint(cnt))
+        A:GOVTL(cnt)   T:taxc(cnt,com)    com.tl:

* CO2 allowances
I:PCO2(cnt)#(com)$(PID(com) = 1 and FF(com)=1 and CO2B(cnt) and InputCom("i-H2S",com))
+        Q:(InputCom("i-H2S",com)*CO2r(cnt,com,"i-NG")*cint(cnt)*eint(cnt))     P:(1e-6/eint(cnt))
+        com.tl:

* Energy generation
I:P(cnt,com)$(PID(com) = 2  and InputCom("i-H2S",com)    )                      Q:(InputCom("i-H2S",com)*eint(cnt))  P:(1/eint(cnt))
+        A:GOVTL(cnt)   T:taxc(cnt,com)          sE:

* Energy transmission
I:P(cnt,com)$(PID(com) = 4  and InputCom("i-H2S",com)    )                      Q:(InputCom("i-H2S",com)*eint(cnt))  P:(1/eint(cnt))
+        A:GOVTL(cnt)   T:taxc(cnt,com)           sE:

* Labour, Capital & Savings
I:PL(cnt)                                                        Q:(0.21/PRC(cnt))           skl:
I:RKC(cnt)                                                       Q:(1.34/PRC(cnt))           skl:




*$PROD:XD(cnt,"i-H2CCS") t:0 s:ELAS("i-H2CCS", "KLME") sM(sKLM):0 sklm(s):ELAS("i-H2CCS", "KLM")  sE(s):0.1 skl(sklm):ELAS("i-H2CCS", "KL") com.tl(sE):0
$PROD:XD(cnt,"i-H2CCS") t:0 s:ELAS("i-H2CCS", "KLEM") sM(s):0 skle(s):ELAS("i-H2CCS", "KLE")  sE(sKLE):1 skl(skle):ELAS("i-H2CCS", "KL") com.tl(sE):0
O:PD(cnt,"i-H2CCS","gH2")$(sum(sec,XDDZ(cnt,sec,"gNG")))      Q:(3)

* Materials and services
I:P(cnt,com)$((PID(com) eq 0 or PID(com) eq 3) and InputCom("i-H2CCS",com))   Q:InputCom("i-H2CCS",com)
+        A:GOVTL(cnt)   T:taxc(cnt,com)        sM:

* Fuels
I:P(cnt,com)$(PID(com) = 1 and InputCom("i-H2CCS",com))                       Q:(InputCom("i-H2CCS",com)*eint(cnt))      P:(1/eint(cnt))
+        A:GOVTL(cnt)   T:taxc(cnt,com)    sE:


* Energy generation
I:P(cnt,com)$(PID(com) = 2  and InputCom("i-H2CCS",com))                      Q:(InputCom("i-H2CCS",com)*eint(cnt))      P:(1/eint(cnt))
+        A:GOVTL(cnt)   T:taxc(cnt,com)          sE:

* Energy transmission
I:P(cnt,com)$(PID(com) = 4  and InputCom("i-H2CCS",com))                      Q:(InputCom("i-H2CCS",com)*eint(cnt))      P:(1/eint(cnt))
+        A:GOVTL(cnt)   T:taxc(cnt,com)           sE:

* Labour, Capital & Savings
I:PL(cnt)                                                        Q:(0.21*1.02/PRC(cnt))           skl:
I:RKC(cnt)                                                       Q:(1.34*1.1/PRC(cnt))           skl:


*Hydrogen Production
$PROD:XD(cnt,"i-H2E") t:0 s:ELAS("i-H2E", "KLEM") sM(s):0 skle(s):ELAS("i-H2E", "KLE")  sE(sKLE):1 skl(skle):ELAS("i-H2E", "KL") com.tl(sE):0
O:PD(cnt,"i-H2E","gH2")$(sum(sec,XDDZ(cnt,sec,"gNG")))      Q:(3)

* Materials and services
I:P(cnt,com)$((PID(com) eq 0 or PID(com) eq 3) and InputCom("i-H2E",com))   Q:InputCom("i-H2E",com)
+        A:GOVTL(cnt)   T:taxc(cnt,com)        sM:

* Fuels
I:P(cnt,com)$(PID(com) = 1 and InputCom("i-H2E",com))                       Q:(InputCom("i-H2E",com)*eint(cnt))          P:(1/eint(cnt))
+        A:GOVTL(cnt)   T:taxc(cnt,com)    com.tl:

* CO2 allowances
I:PCO2(cnt)#(com)$(PID(com) = 1 and FF(com)=1 and CO2B(cnt) and InputCom("i-H2E",com))
+        Q:(InputCom("i-H2E",com)*CO2r(cnt,com,"i-NG")*cint(cnt)*eint(cnt))     P:(1e-6/eint(cnt))
+        com.tl:

* Energy generation
I:P(cnt,com)$(PID(com) = 2  and InputCom("i-H2E",com))                      Q:(InputCom("i-H2E",com)*eint(cnt))    P:(1/eint(cnt))
+        A:GOVTL(cnt)   T:taxc(cnt,com)          sE:

* Energy transmission
I:P(cnt,com)$(PID(com) = 4  and InputCom("i-H2E",com))                      Q:(InputCom("i-H2E",com)*eint(cnt))    P:(1/eint(cnt))
+        A:GOVTL(cnt)   T:taxc(cnt,com)           sE:

* Labour, Capital & Savings
I:PL(cnt)                                                        Q:(0.1/PRC(cnt))           skl:
I:RKC(cnt)                                                       Q:(0.53/PRC(cnt))           skl:



*Domestic Production
$PROD:XD(cnt,"i-PCCS")
+ t:0 s:ELAS("i-POW", "KLEM") sM(s):0 skle(s):ELAS("i-POW", "KLE")  sE(sKLE):5 skl(skle):ELAS("i-POW", "KL") sk(skl):10 com.tl(sE):0
O:PD(cnt,"i-PCCS",com)$(XDDZ(cnt,"i-POW",com))       Q:(XDDZ(cnt,"i-POW",com))
+        P:(1-taxpz(cnt,"i-POW"))
+        A:GOVTL(cnt)   T:taxp(cnt,"i-PCCS")

* Materials and services
I:P(cnt,com)$(PID(com) eq 0 or PID(com) eq 3)            Q:(IOZ(cnt,com,"i-POW"))
+        P:(1+taxcz(cnt,com))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        sM:

* Non-fossil fuels
I:P(cnt,com)$(PID(com) = 1 and (IOZ(cnt,com,"i-POW")+Pathway_adj(cnt, "i-POW", com)) and FF(com)=0 )
+        Q:((IOZ(cnt,com,"i-POW")+Pathway_adj(cnt, "i-POW", com))*eint(cnt))       P:((1+taxcz(cnt,com))/eint(cnt))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        sE:

* Fossil fuels
I:P(cnt,com)$(PID(com) = 1 and (IOZ(cnt,com,"i-POW")+Pathway_adj(cnt, "i-POW", com)) and FF(com)=1)
+        Q:((IOZ(cnt,com,"i-POW")+Pathway_adj(cnt, "i-POW", com))*eint(cnt))     P:((1+taxcz(cnt,com))/eint(cnt))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        sE:

* Hydrogen
I:P(cnt,"gH2")$(Pathway_adj(cnt, "i-POW", "gH2"))
+        Q:(Pathway_adj(cnt, "i-POW", "gH2")*eint(cnt))       P:(1/eint(cnt))
+        sE:


* energy generation
I:P(cnt,com)$(PID(com) = 2 and (IOZ(cnt,com,"i-POW")+Pathway_adj(cnt, "i-POW", com)))
+        Q:((IOZ(cnt,com,"i-POW")+Pathway_adj(cnt, "i-POW", com))*eint(cnt))       P:((1+taxcz(cnt,com))/eint(cnt))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        sE:

* energy transmission
I:P(cnt,com)$(PID(com)=4 and (IOZ(cnt,com,"i-POW")+Pathway_adj(cnt, "i-POW", com)))
+        Q:((IOZ(cnt,com,"i-POW")+Pathway_adj(cnt, "i-POW", com))*eint(cnt))       P:((1+taxcz(cnt,com))/eint(cnt))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        sE:


* Labour, Capital & Savings
* Capital requirement has increased by 10% and labour requirement has increased by 2%
I:PL(cnt)               Q:(LZ(cnt,"i-POW")*1.02/PRC(cnt))    skl:
I:RKC(cnt)$(Pathway_adj_cap(cnt, "i-POW"))        Q:(Pathway_adj_cap(cnt, "i-POW")*1.1/PRC(cnt))    sk:
I:PS(cnt)               Q:INVZ(cnt,"i-POW")  sk:

*===================================================================
*=======================    UTILITY BLOCKS    ======================
*===================================================================



*Households Utility/Welfare
$PROD:U(cnt)$(P_S > 0)      s:1 com.tl(s):0
O:PU(cnt)      Q:(CBUDZ(cnt) + Pathway_total(cnt, "Hous")$(Pathway_total(cnt, "Hous")<0))
I:P(cnt,com)$(P_S > 0 and FF(com) = 0 and PID(com) ne 2)   Q:(CZ(cnt,com) + Pathway_adj(cnt, "HOUS", com) )
+        P:(1+taxcz(cnt, com))        A:GOVTL(cnt)       T:taxc(cnt,com)
I:P(cnt,com)$(P_S > 0 and FF(com) = 0 and PID(com) eq 2)   Q:((CZ(cnt,com) + Pathway_adj(cnt, "HOUS", com))*eint(cnt))
+        P:((1+taxcz(cnt,com))/eint(cnt))       A:GOVTL(cnt)       T:taxc(cnt,com)

I:P(cnt,com)$(P_S > 0 and FF(com)=1)   Q:((CZ(cnt,com) + Pathway_adj(cnt, "HOUS", com))*eint(cnt))
+        P:((1+taxcz(cnt,com))/eint(cnt))        A:GOVTL(cnt)       T:taxc(cnt,com)
+        com.tl:
I:PCO2(cnt)#(com)$(CO2H(cnt,com) and FF(com)=1 and CO2B(cnt))    Q:((CZ(cnt,com) + Pathway_adj(cnt, "HOUS", com))*CO2r(cnt,com,"HOUS")*cint(cnt)*eint(cnt))
+  P:(1e-6/eint(cnt))       com.tl:


*Local Government Utility
$PROD:UGL(cnt)$(P_S > 0)    s:1 com.tl(s):0
O:PUGL(cnt)                 Q:(CBUDGLZ(cnt) + Pathway_total(cnt, "Govt")$(Pathway_total(cnt, "Govt")<0) )
I:P(cnt,com)$(P_S > 0 and FF(com) = 0 and PID(com) ne 2)  Q:(CGLZ(cnt,com) + Pathway_adj(cnt, "GOVT", com))
+        P:(1+taxcz(cnt,com) )
+        A:GOVTL(cnt)      T:taxc(cnt,com)
I:P(cnt,com)$(P_S > 0 and FF(com) = 0 and PID(com) eq 2)  Q:((CGLZ(cnt,com) + Pathway_adj(cnt, "GOVT", com))*eint(cnt))
+        P:((1+taxcz(cnt,com))/eint(cnt))
+        A:GOVTL(cnt)      T:taxc(cnt,com)
I:P(cnt,com)$(P_S > 0 and FF(com)=1)   Q:((CGLZ(cnt,com) + Pathway_adj(cnt, "GOVT", com))*eint(cnt))
+        P:((1+taxcz(cnt,com))/eint(cnt))    A:GOVTL(cnt)       T:taxc(cnt,com)
+        com.tl:
I:PCO2(cnt)#(com)$(CO2G(cnt,com) and FF(com)=1 and CO2B(cnt))    Q:((CGLZ(cnt,com) + Pathway_adj(cnt, "GOVT", com) )*CO2r(cnt,com,"GOVT")*cint(cnt)*eint(cnt))
+  P:(1e-6/eint(cnt))       com.tl:

*Investment Sector Utility
$PROD:UINVB(cnt)  s:1 com.tl(s):0
O:PUINVB(cnt) Q:ITZ(cnt)
I:P(cnt,com)$(FF(com)=0 and PID(com) ne 2)  Q:(IZ(cnt,com)) P:(1+taxcz(cnt,com))
+        A:GOVTL(cnt)        T:taxc(cnt,com)
I:P(cnt,com)$(FF(com)=0 and PID(com) eq 2)  Q:(IZ(cnt,com)) P:(1+taxcz(cnt,com))
+        A:GOVTL(cnt)        T:taxc(cnt,com)
I:P(cnt,com)$(FF(com)=1)   Q:(IZ(cnt,com))
+        P:(1+taxcz(cnt, com))        A:GOVTL(cnt)       T:taxc(cnt,com)
+        com.tl:
I:PCO2(cnt)#(com)$(CO2I(cnt,com) and FF(com)=1 and CO2B(cnt))    Q:((IZ(cnt,com))*CO2r(cnt,com,"INV")*cint(cnt))
+  P:1e-6       com.tl:

*=====================================================================
*========================   TRADE BLOCKS    ==========================
*=====================================================================

*Domestic/Regional/International production split
$PROD:EXPORT(cnt,com)$( sum(sec, XDDZ(cnt,sec,com)) and sameas(com,"gPOW")) t:5 s:5
O:ERint#(cntt)                                                           Q:(TRADEZ(com,cnt,cntt))
O:PDD(cnt,com)$(XXDZ(cnt,com)>1e-6)                                      Q:XXDZ(cnt,com)
O:ERext                                                                  Q:EROWZ(cnt,com)
I:PD(cnt,sec,com)$(XDDZ(cnt,sec,com) and not sameas(sec,"i-PCCS"))       Q:(XDDZ(cnt,sec,com)*(t**xdsp))

$PROD:EXPORTN(cnt,com)$( sum(sec, XDDZ(cnt,sec,com)) and sameas(com,"gPOW")) t:5 s:5
O:ERint#(cntt)                                                                             Q:(TRADEZ(com,cnt,cntt))
O:PDD(cnt,com)$(XXDZ(cnt,com)>1e-6)                                                              Q:XXDZ(cnt,com)
O:ERext                                                                                         Q:(EROWZ(cnt,com)*0.95)
I:PD(cnt,sec,com)$(XDDZ(cnt,sec,com) and not sameas(sec,"i-PCCS") and not sameas(sec,"i-POW"))  Q:XDDZ(cnt,sec,com)
I:PD(cnt,"i-POW",com)$(XDDZ(cnt,"i-POW",com))                                                  Q:(XDDZ(cnt,"i-POW",com)*0.5)
I:PD(cnt,"i-PCCS",com)$(XDDZ(cnt,"i-POW",com))                                                  Q:(XDDZ(cnt,"i-POW",com)*0.5)

*Domestic/Regional/International production split
$PROD:EXPORT(cnt,com)$( sum(sec, XDDZ(cnt,sec,com) ) and not sameas(com,"gH2") and not sameas(com,"gPOW")) t:1.4$(worldcom(com)=0) t:5$(worldcom(com)=1) s:1.2
O:ERint#(cntt)                               Q:(TRADEZ(com,cnt,cntt))
O:PDD(cnt,com)$(XXDZ(cnt,com)>1e-6)                                      Q:XXDZ(cnt,com)
O:ERext                                                                Q:EROWZ(cnt,com)
I:PD(cnt,sec,com)$(XDDZ(cnt,sec,com))                                    Q:(XDDZ(cnt,sec,com)*(t**xdsp))

*Domestic/Regional/International production split
$PROD:EXPORTN(cnt,com)$( sum(sec, XDDZ(cnt,sec,com) ) and not sameas(com,"gH2") and not sameas(com,"gPOW")) t:1.4$(worldcom(com)=0) t:5$(worldcom(com)=1) s:1.2
O:ERint#(cntt)                                                       Q:(TRADEZ(com,cnt,cntt))
O:PDD(cnt,com)$(XXDZ(cnt,com)>1e-6)                                                              Q:(XXDZ(cnt,com))
O:ERext                                                                                        Q:(EROWZ(cnt,com)*0.95)
I:PD(cnt,sec,com)$(XDDZ(cnt,sec,com) and not sameas(sec,"i-PCCS") and not sameas(sec,"i-POW"))  Q:XDDZ(cnt,sec,com)
I:PD(cnt,"i-POW",com)$(XDDZ(cnt,"i-POW",com))                                                  Q:(XDDZ(cnt,"i-POW",com)*0.5)
I:PD(cnt,"i-PCCS",com)$(XDDZ(cnt,"i-POW",com))                                                  Q:(XDDZ(cnt,"i-POW",com)*0.5)

*Domestic/Regional/International production split
$PROD:EXPORT(cnt,"gH2") t:5 s:5
O:ERint#(cntt)                           Q:(TRADEZ("gNG",cnt,cntt))
O:PDD(cnt,"gH2")                                                        Q:XXDZ(cnt,"gNG")
O:ERext                                                                 Q:EROWZ(cnt,"gNG")
I:PD(cnt,"i-H2CCS","gH2")$(sum(sec,XDDZ(cnt,sec,"gNG")))                Q:(0.34*sum(sec,XDDZ(cnt,sec,"gNG")))
I:PD(cnt,"i-H2S","gH2")$(sum(sec,XDDZ(cnt,sec,"gNG")))                  Q:(0.33*sum(sec,XDDZ(cnt,sec,"gNG")))
I:PD(cnt,"i-H2E","gH2")$(sum(sec,XDDZ(cnt,sec,"gNG")))                  Q:(0.33*sum(sec,XDDZ(cnt,sec,"gNG")))

*Armington Composite Good
$PROD:X(cnt,com)$(XZ(cnt,com) and not sameas(com,"gH2")) s:elasM(com)    s2:0 s3:0
O:P(cnt,com)                                                     Q:(XZ(cnt,com) )
I:PDD(cnt,com)$(XXDZ(cnt, com)>1e-6)                             Q:XXDZ(cnt,com)   s2:
I:PTM(cnt, cntt)$(ord(cnt) eq ord(cntt))                   Q:(trademargins(com, cntt, cnt) )     s2:
I:ERext                                                    Q:MROWZ(cnt,com)
I:ERint#(cntt)              Q:TRADEZ(com,cntt,cnt)    A:GOVTL(cnt) T:tfp(cntt)   s3:
I:PTM(cnt, cntt)$(ord(cnt) ne ord(cntt))                   Q:trademargins(com, cntt, cnt)        s3:

*Armington Composite Good
* For H2 Put the same structure as Natural Gas.
$PROD:X(cnt,"gH2")  s:elasM("gH2")  s2:0 s3:0
O:P(cnt,"gH2")$(sum(sec,Pathway_adj(cnt, sec,"gH2")))             Q:(XZ(cnt,"gNG") )
I:PDD(cnt,"gH2")                                                   Q:XXDZ(cnt,"gNG")                   s2:
I:PTM(cnt, cntt)$(ord(cnt) eq ord(cntt))                   Q:(trademargins("gNG", cntt, cnt) ) s2:
I:ERext                                                   Q:MROWZ(cnt,"gNG")
I:ERint#(cntt)                     Q:TRADEZ("gNG",cntt,cnt)            s3:
I:PTM(cnt, cntt)$(ord(cnt) ne ord(cntt))                   Q:trademargins("gNG", cntt, cnt)    s3:

*Transport transforms the bulk "TTM" product purchsed by the traders into
*payments to the transport industries.
$PROD:TRANSP(cnt)  s:0   t:0
O:PTM(cnt, cntt)#(com)        Q:(trademargins(com, cntt,cnt) )
I:P(cnt,com)                  Q:(TMXZ(cnt,com))


*========================================================================
*========================    DEMAND BLOCKS    ===========================
*========================================================================


*Household Demand
$DEMAND:HOUS(cnt)
E:PL(cnt)                                                        Q:(LSZ(cnt)*(1-ty(cnt))*gdp_p(cnt)/(1-urate(cnt)))
E:PL(cnt)                                                        Q:(-(LSZ(cnt)*(1-ty(cnt))*gdp_p(cnt))/(1-urate(cnt))) R:UR(cnt)
E:RKC(cnt)                                                       Q:(KSZ0(cnt)*(1-ty(cnt))*gdp_p(cnt))
E:POG(cnt)$AOGR(cnt)                                             Q:(AOGR(cnt))
E:PCL(cnt)$ACR(cnt)                                              Q:(ACR(cnt))
E:PNG(cnt)$ANGR(cnt)                                             Q:(ANGR(cnt))
*E:PLR(cnt)$ALR(cnt)                                              Q:(ALR(cnt))
E:PTR(cnt)                                                       Q:(TRANSFZ(cnt)*gdp_p(cnt))     R:PCINDEX(cnt)
E:PS(cnt)                                                        Q:(-SHZ(cnt)*gdp_p(cnt))        R:R_SH(cnt)
E:ERext                                                          Q:(TRHROWZ(cnt)*gdp_p(cnt))
D:PU(cnt)                                                        Q:(CBUDZ(cnt))


*Local Government Demand
$DEMAND:GOVTL(cnt)
E:PCO2(cnt)$(CO2B(cnt))                                                                  Q:CO2B(cnt)
E:RKC(cnt)$(sum(sec,pathway_adj_cap(cnt, sec)) and (sum(sec,pathway_total(cnt, sec))<0 and P_S>0))    Q:(-sum(sec,pathway_total(cnt, sec))*gdp_p(cnt))
E:PS(cnt)                                                                                Q:(-SGZ(cnt)*gdp_p(cnt))              R:PIINDEX(cnt)
E:ERext                                                                                  Q:(TRROWZ(cnt)*gdp_p(cnt))
E:PTR(cnt)                                                                               Q:(-TRANSFZ(cnt)*gdp_p(cnt))           R:PCINDEX(cnt)
D:PUGL(cnt)                                                                              Q:(CBUDGLZ(cnt)-sum(sec, pathway_total(cnt, sec)))


*Local Investment Sector
$DEMAND:INVB(cnt)
E:PS(cnt)                                Q:(SHZ(cnt)*gdp_p(cnt))           R:R_SH(cnt)
E:PS(cnt)                                Q:(SGZ(cnt)*gdp_p(cnt))           R:PIINDEX(cnt)
E:ERext                                  Q:(SROWZ(cnt)*gdp_p(cnt))
E:P(cnt,com)                             Q:(-SVZ(cnt,com)*gdp_p(cnt))      R:R_SV(cnt,com)
E:PS(cnt)                                Q:(sum(sec,INVZ(cnt,sec)*XD.L(cnt,sec))*gdp_p(cnt))
D:PUINVB(cnt)                            Q:(ITZ(cnt))





*============================================================================
*========================    ENDOGENOUS ADJUSTMENTS    ======================
*============================================================================



*Definition of consumer price index
$CONSTRAINT:PCINDEX(cnt)
         PCINDEX(cnt) =e= sum(com, (1+taxc(cnt,com))*P(cnt,com) *CZ(cnt,com) ) /
                sum(com, (1+taxcz(cnt,com))*CZ(cnt,com) )  ;


*Definition of local inverstment index
$CONSTRAINT:PIINDEX(cnt)
         PIINDEX(cnt) =e= sum(com, (1+taxc(cnt,com))*P(cnt,com) *IZ(cnt,com) ) /
                sum(com, (1+taxcz(cnt,com))*IZ(cnt,com) )  ;


$CONSTRAINT:R_SV(cnt,com)
    R_SV(cnt,com) =e= X(cnt,com) ;


$CONSTRAINT:R_SH(cnt)
   R_SH(cnt) =e=  HOUS(cnt)/(CBUDZ(cnt));


$CONSTRAINT:UR(cnt)
   PL(cnt)=g=1-bin+pu(cnt)*bin;



*========================================================================
*=========================    REPORT BLOCKS    ==========================
*========================================================================
$REPORT:
V:II(cnt)                        O:PUINVB(cnt)           PROD:UINVB(cnt)
V:R_PD_XD(cnt, sec, com)         O:PD(cnt, sec, com)     PROD:XD(cnt, sec)
V:REP_Welfare(cnt)               O:PU(cnt)               PROD:U(cnt)
V:REP_Welfare_B(cnt)$(P_S)       O:PU(cnt)               PROD:U_B(cnt)
V:REP_Labour(cnt, sec)           I:PL(cnt)               PROD:XD(cnt, sec)
V:REP_Capital(cnt, sec)          I:RKC(cnt)              PROD:XD(cnt, sec)
V:REP_Production(cnt, sec, com)  O:PD(cnt, sec, com)     PROD:XD(cnt, sec)
V:REP_Income(cnt)                W:HOUS(cnt)
V:REP_HOUS_CONS(cnt)             O:PU(cnt)               PROD:U(cnt)
V:REP_GOV_CONS(cnt)              O:PUGL(cnt)             PROD:UGL(cnt)

V:REP_EXP_EU(cnt, com)      O:ERint            PROD:EXPORT(cnt, com)
V:REP_EXP_EUN(cnt, com)     O:ERint            PROD:EXPORTN(cnt, com)
V:REP_EXPout(cnt,com)            O:ERext                 PROD:EXPORT(cnt,com)
V:REP_EXPoutN(cnt,com)           O:ERext                 PROD:EXPORTN(cnt,com)

V:REP_IMPout(cnt, com)           I:ERext                 PROD:X(cnt, com)
V:REP_IMP_EU(cnt,com)        I:ERint            PROD:X(cnt,com)

V:REP_IMP_PTM(cnt, com, cntt)$(ord(cnt) ne ord(cntt))    I:PTM(cnt, cntt)        PROD:X(cnt, com)
V:REP_SEC_OUT(cnt, sec, com)     O:PD(cnt, sec, com)     PROD:XD(cnt, sec)
V:REP_SEC_IN(cnt, sec, com)      I:P(cnt, com)           PROD:XD(cnt, sec)


V:TMout(com,cnt)                 I:P(cnt,com)            PROD:TRANSP(cnt)
V:TMin(com,cnt,cntt)             I:PTM(cnt,cntt)         PROD:X(cnt,com)
V:DCO2(cnt,sec,com)              I:PCO2(cnt)             PROD:XD(cnt,sec)

V:R_P_XD(cnt, sec, com)          I:P(cnt, com)           PROD:XD(cnt,sec)
V:HOUS_DEM(cnt,com)              I:P(cnt,com)            PROD:U(cnt)
V:GOVT_DEM(cnt,com)              I:P(cnt,com)            PROD:UGL(cnt)
V:INVB_DEM(cnt,com)              I:P(cnt,com)            PROD:UINVB(cnt)

V:CO2S_dem(cnt,sec)              I:PCO2(cnt)             PROD:XD(cnt,sec)
V:CO2H_dem(cnt)                  I:PCO2(cnt)             PROD:U(cnt)
V:CO2G_dem(cnt)                  I:PCO2(cnt)             PROD:UGL(cnt)
V:CO2I_dem(cnt)                  I:PCO2(cnt)             PROD:UINVB(cnt)

$OFFTEXT


* ============                               ===================
* ============ INCLUDE THE MPSGE FILES ABOVE ===================
* ============                               ===================

$SYSINCLUDE mpsgeset Arrow_Debreu
