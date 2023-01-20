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

        EXPORT(cnt,com)$(sum(sec, XDDZ(cnt,sec,com)) and not sameas(com,"pH2") )                    ! Export activity
        EXPORT(cnt,com)$(sameas(com,"pH2"))


        XD(cnt,sec)$(XDZ(cnt,sec) and not sameas(sec,"iH2S") and not sameas(sec,"iH2C")  and not sameas(sec,"iH2E"))                       ! Domestic production
        XD(cnt,sec)$(sameas(sec,"iH2S") or sameas(sec,"iH2E") or sameas(sec,"iH2C"))

$COMMODITIES:
        PU(cnt)                                          ! Private consumption price index
        PUGL(cnt)                                         ! Local Govenrmental consumption price index
        PUINVB(cnt)                                       ! Fixed capital local invesment price index
        PD(cnt,sec,com)$(XDDZ(cnt,sec,com) or (sameas(sec,"iH2S") and sameas(com,"pH2")) or (sameas(sec,"iH2C") and sameas(com,"pH2")) or (sameas(sec,"iH2E") and sameas(com,"pH2")))
        PDD(cnt,com)$(XXDZ(cnt, com)>1e-6  and not sameas(com,"pH2"))       ! Price of domestic goods provided to domestic market
        PDD(cnt,com)$(sameas(com,"pH2"))

        P(cnt,com)$(XZ(cnt,com) and not sameas(com,"pH2"))                  ! Composite consumer price
        P(cnt,com)$(sameas(com,"pH2") and sum(sec,Pathway_adj(cnt, sec, "pH2")))
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
$PROD:XD(cnt,sec)$(XDZ(cnt,sec) and P_S > 0 and not sameas(sec,"iH2S") and not sameas(sec,"iH2C") and not sameas(sec,"iH2E") and not sameas(sec,"iELC") and not ressecs(sec))
+ t:0 s:ELAS(sec, "KLEM") sM(s):0 skle(s):ELAS(sec, "KLE")  sE(sKLE):0.1$(ES0 eq 1)  sE(sKLE):5$(ES0 eq 0) skl(skle):ELAS(sec, "KL") sk(skl):10 com.tl(sE):0  sEl(sE):0
O:PD(cnt,sec,com)$(XDDZ(cnt,sec,com))       Q:(XDDZ(cnt,sec,com))
+        P:(1-taxpz(cnt,sec))
+        A:GOVTL(cnt)   T:taxp(cnt,sec)

* Materials and services
I:P(cnt,com)$(PID(com) eq 0 or PID(com) eq 3)            Q:(IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))
+        P:(1+taxcz(cnt,com))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        sM:

* Non-fossil fuels
I:P(cnt,com)$(PID(com) = 1 and (IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)) and FF(com)=0 )
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))*(eint(cnt)$(not ensecs(sec))+1$(ensecs(sec))))       P:((1+taxcz(cnt,com))/(eint(cnt)$(not ensecs(sec))+1$(ensecs(sec))))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        sE:

* Fossil fuels
I:P(cnt,com)$(PID(com) = 1 and (IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)) and FF(com)=1)
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))*(eint(cnt)$(not ensecs(sec))+1$(ensecs(sec))))     P:((1+taxcz(cnt,com))/(eint(cnt)$(not ensecs(sec))+1$(ensecs(sec))))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        com.tl:

* CO2 allowances
I:PCO2(cnt)#(com)$(PID(com) = 1 and CO2P(cnt,com,sec) and FF(com)=1 and CO2B(cnt))
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))*CO2r(cnt,com,sec)*cint(cnt,sec)*(eint(cnt)$(not ensecs(sec))+1$(ensecs(sec))))     P:(1e-6)
+        com.tl:

* Hydrogen
I:P(cnt,"pH2")$(Pathway_adj(cnt, sec, "pH2"))
+        Q:(Pathway_adj(cnt, sec, "pH2")*(eint(cnt)$(not ensecs(sec))+1$(ensecs(sec))))     P:(1/(eint(cnt)$(not ensecs(sec))+1$(ensecs(sec))))
+        sE:


* energy generation
I:P(cnt,com)$(PID(com) = 2 and (IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)))
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))*(eint(cnt)$(not ensecs(sec))+1$(ensecs(sec))))       P:((1+taxcz(cnt,com))/(eint(cnt)$(not ensecs(sec))+1$(ensecs(sec))))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        sEl:

* energy transmission
I:P(cnt,com)$(PID(com)=4 and (IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)))
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))*(eint(cnt)$(not ensecs(sec))+1$(ensecs(sec))))       P:((1+taxcz(cnt,com))/(eint(cnt)$(not ensecs(sec))+1$(ensecs(sec))))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        sEl:


* Labour, Capital & Savings
I:PL(cnt)               Q:(LZ(cnt,sec)/(PRC(cnt)*(1+CPD(cnt)$GWsec(sec)))) P:(PRC(cnt)*(1+CPD(cnt)$GWsec(sec)))     skl:
I:RKC(cnt)$(Pathway_adj_cap(cnt, sec))        Q:(Pathway_adj_cap(cnt, sec))    sk:
I:PS(cnt)               Q:INVZ(cnt,sec)  sk:


*Domestic Production
$PROD:XD(cnt,sec)$(XDZ(cnt,sec) and P_S > 0 and ressecs(sec) )
+ t:0  s:0.5 sR(s):0 s1(s):ELAS(sec, "KLEM") sM(s1):0 skle(s1):1  com.tl(skle):0  sEl(skle):0
O:PD(cnt,sec,com)$(XDDZ(cnt,sec,com))       Q:(XDDZ(cnt,sec,com))
+        P:(1-taxpz(cnt,sec))
+        A:GOVTL(cnt)   T:taxp(cnt,sec)

* Materials and services
I:P(cnt,com)$(PID(com) eq 0 or PID(com) eq 3)            Q:(IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))
+        P:(1+taxcz(cnt,com))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        sM:

* Non-fossil fuels
I:P(cnt,com)$(PID(com) = 1 and (IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)) and FF(com)=0 )
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))*(eint(cnt)$(not ensecs(sec))+1$(ensecs(sec))))       P:((1+taxcz(cnt,com))/(eint(cnt)$(not ensecs(sec))+1$(ensecs(sec))))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        skle:

* Fossil fuels
I:P(cnt,com)$(PID(com) = 1 and (IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)) and FF(com)=1)
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))*(eint(cnt)$(not ensecs(sec))+1$(ensecs(sec))))       P:((1+taxcz(cnt,com))/(eint(cnt)$(not ensecs(sec))+1$(ensecs(sec))))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        com.tl:

* CO2 allowances
I:PCO2(cnt)#(com)$(PID(com) = 1 and CO2P(cnt,com,sec) and FF(com)=1 and CO2B(cnt))
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))*CO2r(cnt,com,sec)*(eint(cnt)$(not ensecs(sec))+1$(ensecs(sec)))*cint(cnt,sec))     P:(1e-6)
+        com.tl:


* Hydrogen
I:P(cnt,"pH2")$(Pathway_adj(cnt, sec, "pH2"))
+        Q:(Pathway_adj(cnt, sec, "pH2")*(eint(cnt)$(not ensecs(sec))+1$(ensecs(sec))))      P:(1/(eint(cnt)$(not ensecs(sec))+1$(ensecs(sec))))
+        skle:


* Energy generation
I:P(cnt,com)$(PID(com) = 2 and (IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)))
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))*(eint(cnt)$(not ensecs(sec))+1$(ensecs(sec))))       P:((1+taxcz(cnt,com))/(eint(cnt)$(not ensecs(sec))+1$(ensecs(sec))))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        sEl:

* Energy transmission
I:P(cnt,com)$(PID(com)=4 and (IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)))
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))*(eint(cnt)$(not ensecs(sec))+1$(ensecs(sec))))       P:((1+taxcz(cnt,com))/(eint(cnt)$(not ensecs(sec))+1$(ensecs(sec))))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        sEl:

* Labour, Capital & Resources
I:PL(cnt)               Q:(LZ(cnt,sec)/(PRC(cnt)*(1+CPD(cnt)$GWsec(sec)))) P:(PRC(cnt)*(1+CPD(cnt)$GWsec(sec)))                                     skle:
I:RKC(cnt)$(Pathway_adj_cap(cnt, sec))        Q:(Pathway_adj_cap(cnt, sec))         skle:
I:POG(cnt)$(sameas(sec,"iCOI"))               Q:OGR(cnt)                       sR:
I:PCL(cnt)$(sameas(sec,"iCOA"))               Q:CR(cnt)                        sR:
I:PNG(cnt)$(sameas(sec,"iNG"))                Q:NGR(cnt)                       sR:

*write old structure. Forget increase in land.
*Domestic Production
$PROD:XD(cnt,sec)$(XDZ(cnt,sec) and P_S > 0 and sameas(sec,"iELC") )
+ t:0 s:ELAS(sec, "KLEM") sM(s):0 skle(s):ELAS(sec, "KLE")  sE(sKLE):0.1$(ES0 eq 1)  sE(sKLE):5$(ES0 eq 0)  skl(skle):ELAS(sec, "KL")  com.tl(sE):0  sEl(sE):0
O:PD(cnt,sec,com)$(XDDZ(cnt,sec,com) > 1e-6)       Q:(XDDZ(cnt,sec,com)*Rp(cnt))
+        P:((1-taxpz(cnt,sec))/Rp(cnt))
+        A:GOVTL(cnt)   T:taxp(cnt,sec)

*Materials and services
I:P(cnt,com)$(PID(com) eq 0 or PID(com) eq 3)            Q:(IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))
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
+        Q:(IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))       P:(1+taxcz(cnt,com))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        com.tl:

* CO2 allowances
I:PCO2(cnt)#(com)$(PID(com) = 1 and CO2P(cnt,com,sec) and FF(com)=1 and CO2B(cnt))
+        Q:((IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))*CO2r(cnt,com,sec)*cint(cnt,sec))     P:(1e-6)
+        com.tl:

* Hydrogen
I:P(cnt,"pH2")$(Pathway_adj(cnt, sec, "pH2"))
+        Q:(Pathway_adj(cnt, sec, "pH2"))      P:1
+        sE:


* Energy generation
I:P(cnt,com)$(PID(com) = 2 and (IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)))
+        Q:(IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))       P:(1+taxcz(cnt,com))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        sEl:

* Energy transmission
I:P(cnt,com)$(PID(com)=4 and (IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)))
+        Q:(IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))       P:(1+taxcz(cnt,com))
+        A:GOVTL(cnt)                 T:taxc(cnt,com)
+        sEl:

* Labour, Capital & Resources
I:PL(cnt)               Q:(LZ(cnt,sec)/(PRC(cnt)*(1+CPD(cnt)$GWsec(sec)))) P:(PRC(cnt)*(1+CPD(cnt)$GWsec(sec)))                                   skl:
I:RKC(cnt)$(Pathway_adj_cap(cnt, sec))        Q:(Pathway_adj_cap(cnt, sec))       skl:



*Hydrogen Production
$PROD:XD(cnt,"iH2S") t:0 s:ELAS("iH2S", "KLEM") sM(s):0 skle(s):ELAS("iH2S", "KLE")  sE(sKLE):1 skl(skle):ELAS("iH2S", "KL") com.tl(sE):0 sEl(sE):0
O:PD(cnt,"iH2S","pH2")$(sum(sec,XDDZ(cnt,sec,"pNG")))      Q:(3*open(cnt,"iH2S")*Rp(cnt))   P:(1/Rp(cnt))

* Materials and services
I:P(cnt,com)$((PID(com) eq 0 or PID(com) eq 3) and InputCom("iH2S",com)    )   Q:InputCom("iH2S",com)
+        A:GOVTL(cnt)   T:taxc(cnt,com)        sM:

* Fuels
I:P(cnt,com)$(PID(com) = 1 and InputCom("iH2S",com)    )                       Q:(InputCom("iH2S",com))   P:(1)
+        A:GOVTL(cnt)   T:taxc(cnt,com)    com.tl:

* CO2 allowances
I:PCO2(cnt)#(com)$(PID(com) = 1 and FF(com)=1 and CO2B(cnt) and InputCom("iH2S",com))
+        Q:(InputCom("iH2S",com)*CO2r(cnt,com,"iNG")*cint(cnt,"iH2S"))     P:(1e-6)
+        com.tl:

* Energy generation
I:P(cnt,com)$(PID(com) = 2  and InputCom("iH2S",com)    )                      Q:(InputCom("iH2S",com))  P:(1)
+        A:GOVTL(cnt)   T:taxc(cnt,com)          sEl:

* Energy transmission
I:P(cnt,com)$(PID(com) = 4  and InputCom("iH2S",com)    )                      Q:(InputCom("iH2S",com))  P:(1)
+        A:GOVTL(cnt)   T:taxc(cnt,com)           sEl:

* Labour, Capital & Savings
I:PL(cnt)                                                        Q:(0.21/(PRC(cnt)*(1+CPD(cnt)$GWsec("iH2S"))))    P:(PRC(cnt)*(1+CPD(cnt)$GWsec("iH2S")))       skl:
I:RKC(cnt)                                                       Q:(1.34)            skl:




*$PROD:XD(cnt,"iH2C") t:0 s:ELAS("iH2C", "KLME") sM(sKLM):0 sklm(s):ELAS("iH2C", "KLM")  sE(s):0.1 skl(sklm):ELAS("iH2C", "KL") com.tl(sE):0
$PROD:XD(cnt,"iH2C") t:0 s:ELAS("iH2C", "KLEM") sM(s):0 skle(s):ELAS("iH2C", "KLE")  sE(sKLE):1 skl(skle):ELAS("iH2C", "KL") com.tl(sE):0  sEl(sE):0
O:PD(cnt,"iH2C","pH2")$(sum(sec,XDDZ(cnt,sec,"pNG")))      Q:(3*open(cnt,"iH2C")*Rp(cnt))        P:(1/Rp(cnt))

* Materials and services
I:P(cnt,com)$((PID(com) eq 0 or PID(com) eq 3) and InputCom("iH2C",com))   Q:InputCom("iH2C",com)
+        A:GOVTL(cnt)   T:taxc(cnt,com)        sM:

* Fuels
I:P(cnt,com)$(PID(com) = 1 and InputCom("iH2C",com))                       Q:(InputCom("iH2C",com))      P:(1)
+        A:GOVTL(cnt)   T:taxc(cnt,com)    sE:


* Energy generation
I:P(cnt,com)$(PID(com) = 2  and InputCom("iH2C",com))                      Q:(InputCom("iH2C",com))      P:(1)
+        A:GOVTL(cnt)   T:taxc(cnt,com)          sEl:

* Energy transmission
I:P(cnt,com)$(PID(com) = 4  and InputCom("iH2C",com))                      Q:(InputCom("iH2C",com))      P:(1)
+        A:GOVTL(cnt)   T:taxc(cnt,com)           sEl:

* Labour, Capital & Savings
I:PL(cnt)                                                        Q:(0.21*1.02/(PRC(cnt)*(1+CPD(cnt)$GWsec("iH2C")))) P:(PRC(cnt)*(1+CPD(cnt)$GWsec("iH2C")))          skl:
I:RKC(cnt)                                                       Q:(1.34*1.1)                  skl:


*Hydrogen Production
$PROD:XD(cnt,"iH2E") t:0 s:ELAS("iH2E", "KLEM") sM(s):0 skle(s):ELAS("iH2E", "KLE")  sE(sKLE):1 skl(skle):ELAS("iH2E", "KL") com.tl(sE):0  sEl(sE):0
O:PD(cnt,"iH2E","pH2")$(sum(sec,XDDZ(cnt,sec,"pNG")))      Q:(3*open(cnt,"iH2E")*Rp(cnt))               P:(1/Rp(cnt))

* Materials and services
I:P(cnt,com)$((PID(com) eq 0 or PID(com) eq 3) and InputCom("iH2E",com))   Q:InputCom("iH2E",com)
+        A:GOVTL(cnt)   T:taxc(cnt,com)        sM:

* Fuels
I:P(cnt,com)$(PID(com) = 1 and InputCom("iH2E",com))                       Q:(InputCom("iH2E",com))          P:(1)
+        A:GOVTL(cnt)   T:taxc(cnt,com)    com.tl:

* CO2 allowances
I:PCO2(cnt)#(com)$(PID(com) = 1 and FF(com)=1 and CO2B(cnt) and InputCom("iH2E",com))
+        Q:(InputCom("iH2E",com)*CO2r(cnt,com,"iNG")*cint(cnt,"iH2E"))     P:(1e-6)
+        com.tl:

* Energy generation
I:P(cnt,com)$(PID(com) = 2  and InputCom("iH2E",com))                      Q:(InputCom("iH2E",com))    P:(1)
+        A:GOVTL(cnt)   T:taxc(cnt,com)          sEl:

* Energy transmission
I:P(cnt,com)$(PID(com) = 4  and InputCom("iH2E",com))                      Q:(InputCom("iH2E",com))    P:(1)
+        A:GOVTL(cnt)   T:taxc(cnt,com)           sEl:

* Labour, Capital & Savings
I:PL(cnt)                                                        Q:(0.1/(PRC(cnt)*(1+CPD(cnt)$GWsec("iH2E"))))   P:(PRC(cnt)*(1+CPD(cnt)$GWsec("iH2E")))        skl:
I:RKC(cnt)                                                       Q:(0.53)                             skl:


*===================================================================
*=======================    UTILITY BLOCKS    ======================
*===================================================================



*Households Utility/Welfare
$PROD:U(cnt)$(P_S > 0)      s:1 com.tl(s):0 sEl(s):0
O:PU(cnt)      Q:(CBUDZ(cnt) + Pathway_total(cnt, "Hous")$(Pathway_total(cnt, "Hous")<0))
I:P(cnt,com)$(P_S > 0 and FF(com) = 0 and PID(com) ne 1 and PID(com) ne 2 and PID(com) ne 4)   Q:(CZ(cnt,com) + Pathway_adj(cnt, "HOUS", com) )
+        P:(1+taxcz(cnt, com))        A:GOVTL(cnt)       T:taxc(cnt,com)
I:P(cnt,com)$(P_S > 0 and FF(com) = 0 and (PID(com) eq 1))   Q:((CZ(cnt,com) + Pathway_adj(cnt, "HOUS", com))*eintFC(cnt))
+        P:((1+taxcz(cnt,com))/eintFC(cnt))       A:GOVTL(cnt)       T:taxc(cnt,com)
I:P(cnt,com)$(P_S > 0 and FF(com) = 0 and (PID(com) eq 2))   Q:((CZ(cnt,com) + Pathway_adj(cnt, "HOUS", com))*eintFC(cnt))
+        P:((1+taxcz(cnt,com))/eintFC(cnt))       A:GOVTL(cnt)       T:taxc(cnt,com)
+ sEl:
I:P(cnt,com)$(P_S > 0 and FF(com) = 0 and (PID(com) eq 4))   Q:((CZ(cnt,com) + Pathway_adj(cnt, "HOUS", com))*eintFC(cnt))
+        P:((1+taxcz(cnt,com))/eintFC(cnt))       A:GOVTL(cnt)       T:taxc(cnt,com)
+ sEl:
I:P(cnt,com)$(P_S > 0 and FF(com)=1)   Q:((CZ(cnt,com) + Pathway_adj(cnt, "HOUS", com))*eintFC(cnt))
+        P:((1+taxcz(cnt,com))/eintFC(cnt))        A:GOVTL(cnt)       T:taxc(cnt,com)
+        com.tl:
I:PCO2(cnt)#(com)$(CO2H(cnt,com) and FF(com)=1 and CO2B(cnt))    Q:((CZ(cnt,com) + Pathway_adj(cnt, "HOUS", com))*CO2r(cnt,com,"HOUS")*cint(cnt,"iSER")*eintFC(cnt))
+  P:(1e-6)       com.tl:


*Local Government Utility
$PROD:UGL(cnt)$(P_S > 0)    s:1 com.tl(s):0 sEl(s):0
O:PUGL(cnt)                 Q:(CBUDGLZ(cnt) + Pathway_total(cnt, "Govt")$(Pathway_total(cnt, "Govt")<0) )
I:P(cnt,com)$(P_S > 0 and FF(com) = 0 and PID(com) ne 1 and PID(com) ne 2 and PID(com) ne 4)  Q:(CGLZ(cnt,com) + Pathway_adj(cnt, "GOVT", com))
+        P:(1+taxcz(cnt,com) )
+        A:GOVTL(cnt)      T:taxc(cnt,com)
I:P(cnt,com)$(P_S > 0 and FF(com) = 0 and (PID(com) eq 1))  Q:((CGLZ(cnt,com) + Pathway_adj(cnt, "GOVT", com))*eintFC(cnt))
+        P:((1+taxcz(cnt,com))/eintFC(cnt))
+        A:GOVTL(cnt)      T:taxc(cnt,com)
I:P(cnt,com)$(P_S > 0 and FF(com) = 0 and (PID(com) eq 2))  Q:((CGLZ(cnt,com) + Pathway_adj(cnt, "GOVT", com))*eintFC(cnt))
+        P:((1+taxcz(cnt,com))/eintFC(cnt))
+        A:GOVTL(cnt)      T:taxc(cnt,com)
+ sEl:
I:P(cnt,com)$(P_S > 0 and FF(com) = 0 and (PID(com) eq 4))  Q:((CGLZ(cnt,com) + Pathway_adj(cnt, "GOVT", com))*eintFC(cnt))
+        P:((1+taxcz(cnt,com))/eintFC(cnt))
+        A:GOVTL(cnt)      T:taxc(cnt,com)
+ sEl:
I:P(cnt,com)$(P_S > 0 and FF(com)=1)   Q:((CGLZ(cnt,com) + Pathway_adj(cnt, "GOVT", com))*eintFC(cnt))
+        P:((1+taxcz(cnt,com))/eintFC(cnt))    A:GOVTL(cnt)       T:taxc(cnt,com)
+        com.tl:
I:PCO2(cnt)#(com)$(CO2G(cnt,com) and FF(com)=1 and CO2B(cnt))    Q:((CGLZ(cnt,com) + Pathway_adj(cnt, "GOVT", com) )*CO2r(cnt,com,"GOVT")*cint(cnt,"iSER")*eintFC(cnt))
+  P:(1e-6)       com.tl:

*Investment Sector Utility
$PROD:UINVB(cnt)  s:1 com.tl(s):0 sEl(s):0
O:PUINVB(cnt) Q:ITZ(cnt)
I:P(cnt,com)$(FF(com)=0 and PID(com) ne 1 and PID(com) ne 2 and PID(com) ne 4)  Q:(IZ(cnt,com)) P:(1+taxcz(cnt,com))
+        A:GOVTL(cnt)        T:taxc(cnt,com)
I:P(cnt,com)$(FF(com)=0 and (PID(com) eq 1))  Q:(IZ(cnt,com)) P:(1+taxcz(cnt,com))
+        A:GOVTL(cnt)        T:taxc(cnt,com)
I:P(cnt,com)$(FF(com)=0 and (PID(com) eq 2))  Q:(IZ(cnt,com)) P:(1+taxcz(cnt,com))
+        A:GOVTL(cnt)        T:taxc(cnt,com)
+ sEl:
I:P(cnt,com)$(FF(com)=0 and (PID(com) eq 4))  Q:(IZ(cnt,com)) P:(1+taxcz(cnt,com))
+        A:GOVTL(cnt)        T:taxc(cnt,com)
+ sEl:
I:P(cnt,com)$(FF(com)=1)   Q:(IZ(cnt,com)*eintFC(cnt))
+        P:((1+taxcz(cnt,com))/eintFC(cnt))        A:GOVTL(cnt)       T:taxc(cnt,com)
+        com.tl:
I:PCO2(cnt)#(com)$(CO2I(cnt,com) and FF(com)=1 and CO2B(cnt))    Q:((IZ(cnt,com))*CO2r(cnt,com,"INV")*cint(cnt,"iSER")*eintFC(cnt))
+  P:(1e-6)      com.tl:

*=====================================================================
*========================   TRADE BLOCKS    ==========================
*=====================================================================

*Domestic/Regional/International production split
$PROD:EXPORT(cnt,com)$( sum(sec, XDDZ(cnt,sec,com) ) and not sameas(com,"pH2")) t:1.4$(worldcom(com)=0) t:5$(worldcom(com)=1) s:1.2
O:ERint#(cntt)                                                           Q:(TRADEZ(com,cnt,cntt))
O:PDD(cnt,com)$(XXDZ(cnt,com)>1e-6)                                      Q:XXDZ(cnt,com)
O:ERext                                                                  Q:(EROWZ(cnt,com)*ROWgt*(1+ROWc$sameas(com,'pCOA')))   P:(1/(1+ROWc$sameas(com,'pCOA')))
I:PD(cnt,sec,com)$(XDDZ(cnt,sec,com))                                    Q:(XDDZ(cnt,sec,com))


*Domestic/Regional/International production split
$PROD:EXPORT(cnt,"pH2") t:1.2 s:5
O:ERint#(cntt)                                                           Q:(TRADEZ("pNG",cnt,cntt))
O:PDD(cnt,"pH2")                                                         Q:XXDZ(cnt,"pNG")
O:ERext                                                                  Q:(EROWZ(cnt,"pNG")*ROWgt)
I:PD(cnt,"iH2C","pH2")$(sum(sec,XDDZ(cnt,sec,"pNG")))                    Q:(0.34*sum(sec,XDDZ(cnt,sec,"pNG")))
I:PD(cnt,"iH2S","pH2")$(sum(sec,XDDZ(cnt,sec,"pNG")))                    Q:(0.33*sum(sec,XDDZ(cnt,sec,"pNG")))
I:PD(cnt,"iH2E","pH2")$(sum(sec,XDDZ(cnt,sec,"pNG")))                    Q:(0.33*sum(sec,XDDZ(cnt,sec,"pNG")))

*Armington Composite Good
$PROD:X(cnt,com)$(XZ(cnt,com) and not sameas(com,"pH2")) s:elasM(com)$(worldcom(com)=0)   s:5$(worldcom(com)=1)   s2:0 s3:0
O:P(cnt,com)                                                             Q:(XZ(cnt,com) )
I:PDD(cnt,com)$(XXDZ(cnt, com)>1e-6)                                     Q:XXDZ(cnt,com)   s2:
I:PTM(cnt, cntt)$(ord(cnt) eq ord(cntt))                                 Q:(trademargins(com, cntt, cnt) )     s2:
I:ERext                                                                  Q:MROWZ(cnt,com)
I:ERint#(cntt)                                                           Q:TRADEZ(com,cntt,cnt)    A:GOVTL(cnt) T:tfp(cntt)   s3:
I:PTM(cnt, cntt)$(ord(cnt) ne ord(cntt))                                 Q:trademargins(com, cntt, cnt)        s3:

*Armington Composite Good
* For H2 Put the same structure as Natural Gas.
$PROD:X(cnt,"pH2")  s:5  s2:0 s3:0
O:P(cnt,"pH2")$(sum(sec,Pathway_adj(cnt, sec,"pH2")))                    Q:(XZ(cnt,"pNG"))
I:PDD(cnt,"pH2")                                                         Q:XXDZ(cnt,"pNG")                   s2:
I:PTM(cnt, cntt)$(ord(cnt) eq ord(cntt))                                 Q:(trademargins("pNG", cntt, cnt) ) s2:
I:ERext                                                                  Q:MROWZ(cnt,"pNG")
I:ERint#(cntt)                                                           Q:TRADEZ("pNG",cntt,cnt)            s3:
I:PTM(cnt, cntt)$(ord(cnt) ne ord(cntt))                                 Q:trademargins("pNG", cntt, cnt)    s3:

*Transport transforms the bulk "TTM" product purchsed by the traders into
*payments to the transport industries.
$PROD:TRANSP(cnt)  s:1  com.tl(s):0  t:0
O:PTM(cnt, cntt)#(com)                           Q:(trademargins(com, cntt,cnt) )
I:P(cnt,com)$(FF(com) eq 0)                      Q:(TMXZ(cnt,com))
I:P(cnt,com)$(FF(com) eq 1)                      Q:(TMXZ(cnt,com)*eintFC(cnt))        P:(1/eintFC(cnt))                       com.tl:
I:PCO2(cnt)#(com)$(FF(com)=1 and CO2B(cnt))      Q:(TMXZ(cnt,com)*CO2r(cnt,com,"tmarg")*cint(cnt,"iSER")*eintFC(cnt)) P:(1e-6)  com.tl:

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
*E:PLR(cnt)$ALR(cnt)                                             Q:(ALR(cnt))
E:PTR(cnt)                                                       Q:(TRANSFZ(cnt)*gdp_p(cnt))     R:PCINDEX(cnt)
E:PS(cnt)                                                        Q:(-SHZ(cnt)*gdp_p(cnt))        R:R_SH(cnt)
E:ERext                                                          Q:(TRHROWZ(cnt)*gdp_p(cnt))
D:PU(cnt)                                                        Q:(CBUDZ(cnt))


*Local Government Demand
$DEMAND:GOVTL(cnt)
E:PCO2(cnt)$(CO2B(cnt))                                                                                  Q:CO2B(cnt)
E:RKC(cnt)$(sum(sec,pathway_adj_cap(cnt, sec)) and (sum(sec,pathway_total(cnt, sec))<0 and P_S>0))       Q:(-sum(sec,pathway_total(cnt, sec))*gdp_p(cnt))
E:PS(cnt)                                                                                                Q:(-SGZ(cnt)*gdp_p(cnt))              R:PIINDEX(cnt)
E:ERext                                                                                                  Q:(TRROWZ(cnt)*gdp_p(cnt))
E:PTR(cnt)                                                                                               Q:(-TRANSFZ(cnt)*gdp_p(cnt))           R:PCINDEX(cnt)
D:PUGL(cnt)                                                                                              Q:(CBUDGLZ(cnt)-sum(sec, pathway_total(cnt, sec)))


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


*$CONSTRAINT:UR(cnt)
*   PL(cnt)=g=pu(cnt)*bin;


$CONSTRAINT:UR(cnt)$urate(cnt)
 PL(cnt)/pu(cnt)=g=(UR(cnt)**(-0.1))/(urate(cnt)**(-0.1));

*========================================================================
*=========================    REPORT BLOCKS    ==========================
*========================================================================
$REPORT:
V:II(cnt)                        O:PUINVB(cnt)           PROD:UINVB(cnt)
V:R_PD_XD(cnt, sec, com)         O:PD(cnt, sec, com)     PROD:XD(cnt, sec)
V:REP_Welfare(cnt)               O:PU(cnt)               PROD:U(cnt)
V:REP_Welfare_B(cnt)$(P_S>1)     O:PU(cnt)               PROD:U_B(cnt)
V:REP_Labour(cnt, sec)           I:PL(cnt)               PROD:XD(cnt, sec)
V:REP_Capital(cnt, sec)          I:RKC(cnt)              PROD:XD(cnt, sec)
V:REP_Production(cnt, sec, com)  O:PD(cnt, sec, com)     PROD:XD(cnt, sec)
V:REP_Income(cnt)                W:HOUS(cnt)
V:REP_HOUS_CONS(cnt)             O:PU(cnt)               PROD:U(cnt)
V:REP_GOV_CONS(cnt)              O:PUGL(cnt)             PROD:UGL(cnt)

V:REP_EXP_EU(cnt, com)      O:ERint            PROD:EXPORT(cnt, com)
V:REP_EXPout(cnt,com)            O:ERext                 PROD:EXPORT(cnt,com)

V:REP_IMPout(cnt, com)           I:ERext                 PROD:X(cnt, com)
V:REP_IMP_EU(cnt,com)        I:ERint            PROD:X(cnt,com)
V:DPDM(cnt,com)                I:PDD(cnt,com)          PROD:X(cnt,com)

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
V:CO2T_dem(cnt)                  I:PCO2(cnt)             PROD:TRANSP(cnt)

$OFFTEXT


* ============                               ===================
* ============ INCLUDE THE MPSGE FILES ABOVE ===================
* ============                               ===================

$SYSINCLUDE mpsgeset Arrow_Debreu
