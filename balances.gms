$ontext
test balances
$offtext

parameter balanceU(cnt),balanceUGL(cnt),balanceINVB(cnt),balanceX(cnt,com),balanceEXP(cnt,com),balanceXD(cnt,sec),balanceTRANSP(cnt);
parameter balanceHOUS(cnt),balanceGOVTL(cnt),balanceINV(cnt);

balanceU(cnt)=CBUDZ(cnt) + Pathway_total(cnt, "Hous")$(Pathway_total(cnt, "Hous")<0)
- sum(com$(P_S > 0 and FF(com) = 0),(CZ(cnt,com) + Pathway_adj(cnt, "HOUS", com))*(1+taxcz(cnt, com)))
- sum(com$(P_S > 0 and FF(com)=1),(CZ(cnt,com) + Pathway_adj(cnt, "HOUS", com))*(1+taxcz(cnt, com)))
- sum(com$(FF(com) = 1),1e-6*CO2H(cnt,com));


*         sum(com$(FF(com) ne  1),(1+taxcz(cnt, com))*(CZ(cnt,com) + Pathway_adj(cnt, "HOUS", com)))-
*         sum(com$(FF(com) = 1),(CZ(cnt,com) + Pathway_adj(cnt, "HOUS", com)))-
*         sum(com$(FF(com) = 1),CO2H(cnt,com));



*CBUDZ(cnt) + Pathway_total(cnt, "Hous")$(Pathway_total(cnt, "Hous")<0)-
*         sum(com,(1+taxcz(cnt, com))*(CZ(cnt,com) + Pathway_adj(cnt, "HOUS", com)));

balanceUGL(cnt)=CBUDGLZ(cnt) + Pathway_total(cnt, "Govt")$(Pathway_total(cnt, "Govt")<0)
         -sum(com$(FF(com) ne  1),(1+taxcz(cnt,com))*(CGLZ(cnt,com) + Pathway_adj(cnt, "GOVT", com)))-
         sum(com$(FF(com) = 1),(CGLZ(cnt,com) + Pathway_adj(cnt, "HOUS", com)))-
         sum(com$(FF(com) = 1),CO2G(cnt,com));

balanceINVB(cnt)=ITZ(cnt)-sum(com$(FF(com) ne  1),(1+taxcz(cnt,com))*IZ(cnt,com))-
         sum(com$(FF(com) = 1),IZ(cnt,com))-
         sum(com$(FF(com) = 1),CO2I(cnt,com));



balanceXD(cnt,sec)=sum(com,(1-taxpz(cnt,sec))*XDDZ(cnt,sec,com)) - sum(com$(PID(com) eq 0 or PID(com) eq 3),(1+taxcz(cnt,com))*IOZ(cnt,com,sec)) -
         sum(com$(PID(com) = 1 or PID(com)=2),(1+taxcz(cnt,com))*(IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))) -
         LZ(cnt,sec) - Pathway_adj_cap(cnt, sec) - INVZ(cnt,sec);

*balanceXD(cnt,sec)=sum(com,(1-taxpz(cnt,sec))*XDDZ(cnt,sec,com)) - sum(com$(PID(com) eq 0 or PID(com) eq 3),(1+taxcz(cnt,com))*IOZ(cnt,com,sec)) -
*         sum(com$(PID(com) = 1 or PID(com)=2),(1+taxcz(cnt,com))*(IOZ(cnt,com,sec))) -
*         LZ(cnt,sec) - KZ(cnt, sec) - INVZ(cnt,sec);


balanceEXP(cnt,com)=sum(cntt,tradez(com,cnt,cntt))+XXDZ(cnt,com)$(XXDZ(cnt,com)>1e-6)+EROWZ(cnt,com)-sum(sec,XDDZ(cnt,sec,com)$(XDDZ(cnt,sec,com) > 1e-6));


balanceX(cnt,com)=XZ(cnt,com)-XXDZ(cnt,com)-sum(cntt,trademargins(com, cntt, cnt))-MROWZ(cnt,com)
         -sum(cntt$( ord(cnt) ne ord(cntt)),TRADEZ(com,cntt,cnt));

balanceTRANSP(cnt)= sum((com,cntt),trademargins(com, cntt,cnt))-sum(com,TMXZ(cnt,com));

balanceHOUS(cnt)=CBUDZ(cnt)-TRHROWZ(cnt)+SHZ(cnt)-TRANSFZ(cnt)-sum(sec$(KZ(cnt,sec) and pathway_adj_cap(cnt, sec)),KZ(cnt,sec)*(1-ty(cnt))*gdp_p(cnt))-LSZ(cnt)*(1-ty(cnt))*gdp_p(cnt);

balanceGOVTL(cnt)=(CBUDGLZ(cnt)-sum(sec, pathway_total(cnt, sec)))+TRANSFZ(cnt)-TRROWZ(cnt)+SGZ(cnt)
                  +sum(sec$(pathway_adj_cap(cnt, sec) and pathway_total(cnt, sec)<0 and P_S>0),pathway_total(cnt, sec))
                  -sum((com,sec)$(PID(com) eq 0 or PID(com) eq 3),taxcz(cnt,com)*IOZ(cnt,com,sec))
* tax revenue
                  -sum((sec,com),taxpz(cnt,sec)*XDDZ(cnt,sec,com))
                  -sum((com,sec)$((PID(com) = 1 or PID(com)=2) and FF(com) ne 1 ),taxcz(cnt,com)*(IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)))
                  -sum(com$(FF(com) ne 1),taxcz(cnt,com)*(CZ(cnt,com) + Pathway_adj(cnt, "HOUS", com)))
                  -sum(com$(FF(com) ne 1),taxcz(cnt,com)*(CGLZ(cnt,com) + Pathway_adj(cnt, "GOVT", com)))
                  -sum(com$(FF(com) ne 1),taxcz(cnt,com)*IZ(cnt,com))
* CO2 allowance revenue
                  -CO2B(cnt);


balanceINV(cnt)=ITZ(cnt)-sum(sec,INVZ(cnt,sec))+sum(com,SVZ(cnt,com))-SROWZ(cnt)-SGZ(cnt)-SHZ(cnt);


display balanceU, balanceUGL, balanceINVB, balanceXD,balanceEXP,balanceX,balanceTRANSP,balanceHOUS,balanceGOVTL,balanceINV;


parameter balancePCO2(cnt), balancePUGL(cnt);

balancePCO2(cnt)=CO2B(cnt)-sum((com,sec)$(FF(com)=1),CO2P(cnt,com,sec))-sum(com$(FF(com)=1),CO2H(cnt,com)+CO2I(cnt,com)+CO2G(cnt,com));

*balancePUGL(cnt)=(CBUDGLZ(cnt) + Pathway_total(cnt, "Govt")$(Pathway_total(cnt, "Govt")<0) )
*                 -(CBUDGLZ(cnt)-sum(sec, pathway_total(cnt, sec)));

balancePUGL(cnt)=sum(com$(FF(com)=0),(CGLZ(cnt,com) + Pathway_adj(cnt, "GOVT", com))*(1+taxcz(cnt, com)))+
sum(com$(FF(com)=1),(CGLZ(cnt,com) + Pathway_adj(cnt, "HOUS", com) ))+
sum(com$(FF(com)=1),CO2G(cnt,com))-(CBUDGLZ(cnt)-sum(sec, pathway_total(cnt, sec)));


*(CBUDGLZ(cnt) + Pathway_total(cnt, "Govt")$(Pathway_total(cnt, "Govt")<0) )
*                 -(CBUDGLZ(cnt)-sum(sec, pathway_total(cnt, sec)));


display balancePCO2,balancePUGL;

execute_unload "balance" balanceU, balanceUGL, balanceINVB, balanceXD,balanceEXP,balanceX,balanceTRANSP,balanceHOUS,balanceGOVTL,balanceINV;


parameter balanceER(CRR),bER(CRR,cnt);
balanceER(CRR)=sum(cnt$(used_currency(cnt, CRR)),TRHROWZ(cnt)+TRROWZ(cnt)+SROWZ(cnt))+
sum((com,cnt,cntt)$(used_currency(cnt, CRR)),TRADEZ(com,cnt,cntt))+sum((com,cnt)$(used_currency(cnt, CRR)),EROWZ(cnt,com))
-sum((com,cnt)$(used_currency(cnt, CRR)),MROWZ(cnt,com))-sum((com,cnt,cntt)$(used_currency(cnt, CRR)),TRADEZ(com,cntt,cnt));

bER(CRR,cnt)$used_currency(cnt, CRR)= TRHROWZ(cnt)+TRROWZ(cnt)+SROWZ(cnt)+
sum((com,cntt)$(ord(cnt) ne ord(cntt)),TRADEZ(com,cnt,cntt))+sum(com,EROWZ(cnt,com))
-sum(com,MROWZ(cnt,com))-sum((com,cntt)$(ord(cnt) ne ord(cntt)),TRADEZ(com,cntt,cnt));


display balanceER,bER;

parameter balanceERext;
balanceERext=
 sum((cnt,com)$sameas(com,"pELE"),EROWZ(cnt,com))+sum((cnt,com)$(not sameas(com,"pELE") and not sameas(com,"pH2")),EROWZ(cnt,com))
         -sum((cnt,com)$(not sameas(com,"pH2")),MROWZ(cnt,com))+sum(cnt,TRHROWZ(cnt)+TRROWZ(cnt)+SROWZ(cnt));

display balanceERext, gdp_p;
* the SAM is unbalanced.
* It can be balanced by subtracting the unbalance from the tax_com fields
