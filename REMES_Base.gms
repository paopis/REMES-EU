$Ontext
openENTRANCE version of REMES EUROPA
$Offtext

*===========Options===========
*a.        Choice of the user case and definition of main parameters for user case
* Define the CaseStudy
$set CaseStudy 3
*3

*================= openENTRANCE scenarios ===============
$ifthen %CaseStudy%==1
*P_S is doing nothing. Could be deleted but it is featured in the model, but it does nothing. Needs to be deleted as it is useless.
scalar P_S /1/;
scalar carbonbudget By default is low (reduce 90% but it can be left at reducing by 40% by multiplying by 4) high=4 low=1 /0/;
scalar GHGred if 1 we control the emissions if 0 we do not use a cap /0/;
scalar tariff This works on tariffs on energy import from Visegrad countries /0/;
scalar coop this works on the CO2 budget for Visegrad countries /1/;
scalar rescut not used here - but needs to be defined /0/;
scalar xdsp export decrease speed to make room for the new exports /0/;
scalar GDPt if set to 1 then we test a case with no GDP growth /1/;
scalar CE   if set to 1 circular economy is enforced /1/;
scalar CUT  if set to 1 we cut resources by rescut otherwise we do not /0/;
scalar EF   if set to 1 we consider energy intensity effects /0/;
$endif

$ifthen %CaseStudy%==2
scalar P_S /1/;
scalar carbonbudget By default is low (reduce 90% but it can be left at reducing by 40% by multiplying by 4) high=4 low=1 /0/;
scalar GHGred if 1 we control the emissions if 0 we do not use a cap /0/;
scalar tariff This works on tariffs on energy import from Visegrad countries /0/;
scalar coop this works on the CO2 budget for Visegrad countries /1/;
scalar rescut not used here - but needs to be defined /0/;
scalar xdsp export decrease speed to make room for the new exports /0/;
scalar GDPt if set to 1 then we test a case with no GDP growth /0/;
scalar CE   if set to 1 circular economy is enforced /0/;
scalar CUT  if set to 1 we cut resources by rescut otherwise we do not /0/;
scalar EF   if set to 1 we consider energy intensity effects /1/;
$endif

$ifthen %CaseStudy%==3
scalar P_S /3/;
scalar carbonbudget By default is low (reduce 90% but it can be left at reducing by 40% by multiplying by 4) high=4 low=1 /1/;
scalar GHGred if 1 we control the emissions if 0 we do not use a cap /1/;
scalar tariff This works on tariffs on energy import from Visegrad countries /0/;
scalar coop this works on the CO2 budget for Visegrad countries /1/;
scalar rescut cut of fossil resources per period (1 in BAU - 0.5 in Dec) /0.5/;
scalar xdsp export decrease speed to make room for the new exports /0.1/;
scalar GDPt if set to 1 then we test a case with no GDP growth /0/;
scalar CE   if set to 1 circular economy is enforced /0/;
scalar CUT  if set to 1 we cut resources by rescut otherwise we do not /0/;
scalar EF   if set to 1 we consider energy intensity effects /1/;
$endif


$ifthen %CaseStudy%==4
scalar P_S /4/;
scalar carbonbudget By default is low (reduce 90% but it can be left at reducing by 40% by multiplying by 4) high=4 low=1 /1/;
scalar GHGred if 1 we control the emissions if 0 we do not use a cap /1/;
scalar tariff This works on tariffs on energy import from Visegrad countries /0/;
scalar coop this works on the CO2 budget for Visegrad countries /1/;
scalar rescut cut of fossil resources per period (1 in BAU - 0.5 in Dec) /0.5/;
scalar xdsp export decrease speed to make room for the new exports /0.1/;
scalar GDPt if set to 1 then we test a case with no GDP growth /0/;
scalar CE   if set to 1 circular economy is enforced /0/;
scalar CUT  if set to 1 we cut resources by rescut otherwise we do not /0/;
scalar EF   if set to 1 we consider energy intensity effects /1/;
$endif



*================= openENTRANCE scenarios ===============


$setglobal SW_start "No";
$setglobal Period "10";

*Choose the numeraire value for the model
scalar num /1/;
* to stop the model at only 'STEPS' iterations
scalar STEPS /10/;
scalar IterLim 0 1 1e9 /0/;

display STEPS, P_S;

*===========================================================
*====================== Model Starts =======================
*===========================================================

*PP 5) DATA HANDLING

set
samr(*)  rows and columns of sam (dynamic)
/
HOUS
GOVT
INV
STOCKS
Labour
Capital
tax_com
tax_sec
tdirect
tmarg
Trade
/

set
samd(*)  rows and columns of sam (dynamic)
/
HOUS
GOVT
INV
STOCKS
Labour
Capital
tax_com
tax_sec
tdirect
tmarg
Trade
/


cnt(*) regions in the model
com0(*) commodities and services
sec0(*) industries or sectors

com(*)
sec(*);

alias(samd,samh);

* ========== load the file to read ==========
$gdxin EuroSAM15

* ========== Load the indices for the main sets ==========
$load cnt
$load com0=com
$load sec0=sec

* ========== add the goods and indices to the samr matrix ==========
samr(com0)=yes;
samr(sec0)=yes;



Alias
(samr,samrr)
(sec,secc)
(cnt,cntt)
(com,comm)
;

*read the three main data tables
Parameter
SAMt(cnt,*,*)
TradeDatat(com0,*,*)
TradeMarginst(com0,*,*)
distrgood_share_public(*,*)
;

*FOR GDX INPUT
$load SAMt = SAM
$load TradeDatat = Trade
$load TradeMarginst = TTM


$gdxin


* this value is updated at every step and enters the model
parameter eint(cnt) emission intensity over time in countries
cint(cnt)  carbon intensity over time in countries;

* initialize it to one
eint(cnt)=1;
cint(cnt)=1;


parameter yS0(cnt,sec0,com0) detailed sectoral outputs;
parameter XD0(cnt,sec0) sectoral output;
parameter PD0(cnt,com0) good output;
yS0(cnt,sec0,com0)=SAMt(cnt,sec0,com0)   ;
XD0(cnt,sec0)         = sum(com0,yS0(cnt,sec0,com0)) ;
PD0(cnt,com0)         = sum(sec0,yS0(cnt,sec0,com0)) ;

parameter IOZ0(cnt,com0,sec0),CZ0(cnt,com0),CGZ0(cnt,com0),IZ0(cnt,com0);

IOZ0(cnt,com0,sec0)     = SAMt(cnt, com0, sec0) ;
CZ0(cnt, com0)             =  SAMt(cnt, com0, "HOUS");
CGZ0(cnt, com0)            = SAMt(cnt, com0, "GOVT");
IZ0(cnt, com0)             = SAMt(cnt, com0, "INV");

*b.        Definition of parameters to use in the model
Parameter
XDZ(cnt,sec)      sectoral outputs
XDDZ(cnt,sec,com) detailed sectoral outputs
IOZ(cnt,com,sec)  intermediate inputs
LZ(cnt,sec)       labour inputs
KZ(cnt,sec)       capital inputs

CZ(cnt,com)       households consumption
CGZ(cnt,com)      governmental consumption
CGLZ(cnt, com)     local governemnt consumption

IZ(cnt,com)       investments
SVZ(cnt,com)      changes in stocks

EROWZ(cnt,com)    exports
MROWZ(cnt,com)    imports
TRADEZ(com,cnt,cntt) trade flows
TMCRZ(com,cnt,cntt)  trade and transportmargins
EZ(cnt,com)       total exports

TMCZ(cnt,com)     transport and trade margins
TMXZ(cnt,com)     production of transport and trade margins

TTYZ(cnt)         income taxes
TRANSFZ(cnt)      government to households transfers
TRANSFGZ(cnt)     national to local government transfers

SHZ(cnt)          households savings
SGZ(cnt)         local governmental savings

CBUDGLZ(cnt)       local governmental consumption budget

SROWZ(cnt)        savings from RoW
INVZ(cnt,sec)     sectoral investments

TRROWZ(cnt)       net transfers to government (closing trade balance)
TRHROWZ(cnt)      net transfers to households (closing trade balance)

TAXCZ(cnt,com)    net taxes on products
TAXPZ(cnt,sec)    net taxes on production

LSZ(cnt)          initial labour endowment
KSZ(cnt)          initial capital endowment

CBUDZ(cnt)        households consumption budget
CBUDGZ(cnt)       governmental consumption budget

XZ(cnt,com)       total sales
XXDZ(cnt,com)     domestic products supply to domestic market

ITZ(cnt)          total investments
OGR(cnt)          oil and gas resources
CR(cnt)           coal resources
NGR(cnt)          natural gas resources
LR(cnt)           land resources;



*c.        Data reading
$include "InputParameters.gms"


Alias(samd,samdd);

*d.        Reaggregation of commodities and sectors.
parameter SAM1(cnt,*,*),SAM(cnt,*,*);
* Populating the SAM only using the initial elements (no sectors, no commodities)
SAM1(cnt,samdd,samr)=SAMt(cnt,samdd,samr);
SAM(cnt,samdd,samd)=SAM1(cnt,samdd,samd);

* including commodities and sectors in the index
samd(com)=yes;
samd(sec)=yes;

alias
(cnt,r)
(sec,s)
(com,g);

display samd,samr;


* Create aggregated SAM, trade data and trade margins data
SAM1(cnt,sec,samr)=sum(sec0$maps(sec0,sec),SAMt(cnt,sec0,samr));
SAM1(cnt,com,samr)=sum(com0$mapc(com0,com),SAMt(cnt,com0,samr));

SAM(cnt,samd,samdd)=SAM1(cnt,samd,samdd);
SAM(cnt,samd,sec)=sum(sec0$maps(sec0,sec),SAM1(cnt,samd,sec0));
SAM(cnt,samd,com)=sum(com0$mapc(com0,com),SAM1(cnt,samd,com0));

parameter tradeData(com,*,*);
tradeData(com,cnt,cntt)=sum(com0$mapc(com0,com),tradeDatat(com0,cnt,cntt));
tradeData(com,cnt,"ROW")=sum(com0$mapc(com0,com),tradeDatat(com0,cnt,"ROW"));
tradeData(com,"ROW",cntt)=sum(com0$mapc(com0,com),tradeDatat(com0,"ROW",cntt));

parameter TradeMargins(com,cnt,cntt);
TradeMargins(com,cnt,cntt)=sum(com0$mapc(com0,com),TradeMarginst(com0,cnt,cntt));


* ===================== check if SAM is balanced ===============================
Parameter SAM_balance(cnt,*) ;
SAM_balance(cnt,samd) =  sum(samdd,SAM(cnt,samd,samdd))
       -  sum(samdd,SAM(cnt,samdd,samd)) ;
display SAM_balance;
*execute_unload "sambalance.gdx" SAM_balance;
*execute_unload "newSAM.gdx" SAM1,SAM,tradeData,TradeMargins,SAM_balance;

* ===== Calculate initial levels of variables for calibration ==================


*e.        Assignment of parameters
XDDZ(cnt,sec,com)    = SAM(cnt,sec,com)   ;

XDZ(cnt,sec)         = sum(com,XDDZ(cnt,sec,com)) ;
IOZ(cnt,com,sec)     = SAM(cnt, com, sec) ;
CZ(cnt, com)             =  SAM(cnt, com, "HOUS");
CGZ(cnt, com)            = SAM(cnt, com, "GOVT");
IZ(cnt, com)             = SAM(cnt, com, "INV");
LZ(cnt,sec)          = SAM(cnt,'Labour',sec);
KZ(cnt,sec)          = SAM(cnt,'Capital',sec);

* split the capital remuneration of oil and gas from the general capital
parameter AOGR(cnt), ACR(cnt),ANGR(cnt),ALR(cnt) available resources (oil and gas coil natural gas and land);

OGR(cnt)             = 0.5*KZ(cnt,"i-COIL");
KZ(cnt,"i-COIL")     = 0.5*KZ(cnt,"i-COIL");
NGR(cnt)             = 0.5*KZ(cnt,"i-NG");
KZ(cnt,"i-NG")       = 0.5*KZ(cnt,"i-NG");
CR(cnt)              = 0.5*KZ(cnt,"i-COAL");
KZ(cnt,"i-COAL")     = 0.5*KZ(cnt,"i-COAL");

* initialize the available resources with the values featured in the sectors (resources used = resources available)
AOGR(cnt)=OGR(cnt);
ACR(cnt)=CR(cnt);
ANGR(cnt)=NGR(cnt);
*ALR(cnt)=LR(cnt);
parameter AOGR0(cnt),ACR0(cnt),ANGR0(cnt),ALR0(cnt);
AOGR0(cnt)=OGR(cnt);
ACR0(cnt)=CR(cnt);
ANGR0(cnt)=NGR(cnt);
*ALR0(cnt)=LR(cnt);


parameter Rp(cnt) Renewable sector productivity;
* set to 1 for benchmarking
Rp(cnt)=1;

display CZ;
* Identify sectors with negative capital returns
Parameter negcap(cnt,sec) ;
negcap(cnt,sec)$(KZ(cnt,sec) lt 0) = 1 ;

* Generate positive returns to capital
Parameter KZ_old(cnt,sec) ;
KZ_old(cnt,sec) = KZ(cnt,sec) ;
KZ(cnt,sec)$negcap(cnt,sec) = sum(secc$(KZ(cnt,secc) gt 0),KZ(cnt,secc) )
                     /sum(secc$(KZ(cnt,secc) gt 0),XDZ(cnt,secc) )
                     *XDZ(cnt,sec) ;

SVZ(cnt,com)         = SAM(cnt,com,'STOCKS') ;

display LZ,KZ;

*Read initial consumption figures from SAM
ITZ(cnt)             = sum(com, SAM(cnt,com, "INV"));
CBUDZ(cnt)           = sum(com, SAM(cnt,com, "HOUS"))  ;


*Define the local governments budget
CBUDGLZ(cnt)  = sum(com, SAM(cnt,com, "GOVT"))  ;


*Define Local Government Consumption
CGLZ(cnt, com) = CGZ(cnt, com);
CGLZ(cnt, "gH2") = 0 ;

EROWZ(cnt,com)       = TradeData(com,cnt,'ROW') ;
MROWZ(cnt,com)       = TradeData(com,'ROW',cnt) ;
EROWZ(cnt, "gH2") = 0 ;
MROWZ(cnt, "gH2") = 0 ;

TRADEZ(com,cnt,cntt) = TradeData(com,cnt,cntt) ;
TMCRZ(com,cnt,cntt)  = TradeMargins(com,cnt,cntt) ;
TRADEZ("gH2",cnt,cntt) = 0 ;
TMCRZ("gH2",cnt,cntt) = 0;

* Compute domestic Supply to Domestic Market (XXDZ)
XXDZ(cnt,com)        = sum(sec,XDDZ(cnt,sec,com))- EROWZ(cnt,com) - sum(cntt,TRADEZ(com,cnt,cntt));

loop ((com,cnt), TRADEZ(com, cnt, cnt) = 0);

TMCZ(cnt,com)        = SAM(cnt,'tmarg',com) ;
TMXZ(cnt,com)        = SAM(cnt,com,'tmarg') ;
TMCZ(cnt,"gH2")        = 0 ;
TMXZ(cnt,"gH2")        = 0 ;

TTYZ(cnt)            = SAM(cnt,'tdirect','HOUS') ;
TRANSFZ(cnt)         = SAM(cnt,'HOUS','GOVT') - SAM(cnt, 'GOVT', 'HOUS') ;

TRROWZ(cnt)          = SAM(cnt,'GOVT','Trade') - SAM(cnt,'Trade','GOVT') ;
TRHROWZ(cnt)         = SAM(cnt,'HOUS','Trade') - SAM(cnt,'Trade','HOUS') ;

SHZ(cnt)             = SAM(cnt,'INV','HOUS') ;
SGZ(cnt)             = SAM(cnt,'INV','GOVT') ;

SROWZ(cnt)           = SAM(cnt,'INV','Trade') - SAM(cnt,'Trade','INV') ;

TAXCZ(cnt,com)       = SAM(cnt,'tax_com',com) ;
TAXPZ(cnt,sec)       = SAM(cnt,'tax_sec',sec) ;

INVZ(cnt,sec)        = SAM(cnt,'INV',sec) ;

LSZ(cnt)             = sum(sec,LZ(cnt,sec)) ;
KSZ(cnt)             = sum(sec,KZ(cnt,sec)) ;

* Save the initial value for capital and labour
parameter KSZ0(cnt), LSZ0(cnt);
KSZ0(cnt)=KSZ(cnt);
LSZ0(cnt)=LSZ(cnt);

* Compute initial sectoral value added both in value and percentage.
parameter sVA(cnt,sec),sVAperc(cnt,sec);
sVA(cnt,sec)=(LZ(cnt,sec)+LZ(cnt,sec)+TAXPZ(cnt,sec));
sVAperc(cnt,sec)=(LZ(cnt,sec)+LZ(cnt,sec)+TAXPZ(cnt,sec))/sum(secc,LZ(cnt,secc)+LZ(cnt,secc)+TAXPZ(cnt,secc));
*execute_unload "InitialVA.gdx", sVA,sVAperc;



*Define the Fix for potential Trade Margins' Imbalance in the SAM
Parameter
TMFIX(cnt)
TMFIXC(cnt, com);

TMFIX(cnt) = -sum(com, TMCZ(cnt, com)) + sum(com, TMXZ(cnt, com));
TMFIXC(cnt, com)$(sum(sec,IOZ(cnt,com,sec))
                  +  CZ(cnt,com) +  CGZ(cnt,com) +  IZ(cnt,com)) =
                         TMFIX(cnt)*(sum(sec,IOZ(cnt,com,sec))+  CZ(cnt,com) +  CGZ(cnt,com) +
                                                 IZ(cnt,com))/
                                 sum(comm, sum(sec,IOZ(cnt,comm,sec))+  CZ(cnt,comm) +  CGZ(cnt,comm) +
                                                                 IZ(cnt,comm)) ;

* Adjust consumption figures for taxes and trade margins
* Here it is basically decreasing the value of the commodities to eliminate the effect of consumption taxes.
* These will be included back as mark-ups in the CGE model
Parameters
TOTALCONSZ(cnt,com)   total taxed consumption
TAXTOTALZ(cnt,com)    sum of taxes and margins
;

TOTALCONSZ(cnt,com)   = sum(sec,IOZ(cnt,com,sec)) +  CZ(cnt,com) +  CGZ(cnt,com) + IZ(cnt,com) ;

TAXTOTALZ(cnt,com)    =  TAXCZ(cnt,com) ;

display TMCZ, TAXCZ, totalconsz, taxtotalz;


IOZ(cnt,com,sec)$TOTALCONSZ(cnt,com)
                                 = IOZ(cnt,com,sec) - TAXTOTALZ(cnt,com)*IOZ(cnt,com,sec)/TOTALCONSZ(cnt,com) ;
CZ(cnt,com)$TOTALCONSZ(cnt,com)
                                 = CZ(cnt,com) - TAXTOTALZ(cnt,com)*CZ(cnt,com)/TOTALCONSZ(cnt,com) ;
CGZ(cnt,com)$TOTALCONSZ(cnt,com)
                                 = CGZ(cnt,com) - TAXTOTALZ(cnt,com)*CGZ(cnt,com)/TOTALCONSZ(cnt,com) ;
IZ(cnt,com)$TOTALCONSZ(cnt,com)
                                 = IZ(cnt,com) - TAXTOTALZ(cnt,com)*IZ(cnt,com)/TOTALCONSZ(cnt,com) ;

CGLZ(cnt,com)$(TOTALCONSZ(cnt,com) and  CGLZ(cnt,com))
                                 = CGLZ(cnt,com) - TAXTOTALZ(cnt,com)*CGLZ(cnt,com)/TOTALCONSZ(cnt,com) ;


* HERE WE FIND INDICES FOR POSSIBLE IOZ NEGATIVE VALUES
parameter
possec
poscom
poscnt
amnt;

* check there there are no negative values
loop ((cnt,com),
   if ((CZ(cnt,com) lt 0) and (abs(CZ(cnt,com)) gt 1e-5) ,
         CZ(cnt, com) = 0;
         poscom = ord(com);
         poscnt = ord(cnt);
         amnt = CZ(cnt,com)
         display amnt;
          abort "check CZ(cnt,com) "
   );
   if ((CGZ(cnt,com) lt 0) and (abs(CGZ(cnt,com)) gt 1e-5) ,
         CGZ(cnt, com) = 0;
         poscom = ord(com);
         poscnt = ord(cnt);
         amnt = CGZ(cnt,com)
         display amnt;
          abort "CGZ(cnt,com) "
   );
   if ((IZ(cnt,com) lt 0) and (abs(IZ(cnt,com)) gt 1e-5) ,
         IZ(cnt, com)= 0;
         poscom = ord(com);
         poscnt = ord(cnt);
         amnt = IZ(cnt,com)
         display amnt;
          abort "IZ(cnt,com) "
   );
loop (sec,
   if ((IOZ(cnt,com,sec) lt 0) and (abs(IOZ(cnt,com,sec)) gt 1e-5) ,
         possec = ord(sec);
         poscom = ord(com);
         poscnt = ord(cnt);
         amnt = IOZ(cnt, com, sec);
         IOZ(cnt, com, sec) = 0;
         display amnt;
          abort "check IOZ(cnt,com,sec)"
   );
);
);

* for each commodity and country
* compute percentage trade margins over consumption (trmz) and total sales (XZ)
* CZ, CGZ, IZ and IOZ have already been reduced for the effect of the taxes
* =========== Calculate transport and trade margins ============================
Parameter
trmz(cnt,com) initial transport and trade margins
trm(cnt,com) transport and trade margins
;

trmz(cnt,com)$(sum(sec,IOZ(cnt,com,sec))+  CZ(cnt,com) +  CGZ(cnt,com)+  IZ(cnt,com)) =
                 (TMCZ(cnt,com))/(sum(sec,IOZ(cnt,com,sec))+  CZ(cnt,com) +  CGZ(cnt,com) +  IZ(cnt,com)) ;

trm(cnt,com) = trmz(cnt,com) ;

*f.        Balance checks

* ========== Check trade flows balance =========================================
XZ(cnt,com) =  sum(sec,IOZ(cnt,com,sec)) +  CZ(cnt,com) +  CGZ(cnt,com)
               + TMXZ(cnt,com) + IZ(cnt,com) + SVZ(cnt,com) ;



Parameter
check_tradebal(cnt,com) sales equal domestic supply plus imports
check_tradebal_2(cnt,com) outputs equal domestic products supply + Export to ROW and Export other countries
;

check_tradebal(cnt,com) = XZ(cnt,com) - ( XXDZ(cnt,com) + MROWZ(cnt,com)
   + sum(cntt, TRADEZ(com,cntt,cnt)) ) ;




check_tradebal_2(cnt,com) = sum(sec,XDDZ(cnt,sec,com))- XXDZ(cnt,com)- EROWZ(cnt,com) -
               sum(cntt, TRADEZ(com,cnt,cntt)) ;

Execute_unload "sjekk_tradebal" XZ,XXDZ,MROWZ,TRADEZ,check_tradebal,check_tradebal_2;

EZ(cnt,com) =  EROWZ(cnt,com) + sum(cntt,TRADEZ(com,cnt,cntt)) ;

*g.        Calculation of initial tax rates
* ====== Calculate the levels of  taxes ========================================
Parameter
taxcz(cnt,com) initial taxes on products
taxpz(cnt,sec) initial taxes on production

taxc(cnt,com) taxes on products
taxp(cnt,sec) taxes on production

tyz(cnt)      initial tax on income
ty(cnt)       tax on income
;

taxcz(cnt,com)$(sum(sec,IOZ(cnt,com,sec))+  CZ(cnt,com) +  CGZ(cnt,com) +  IZ(cnt,com)) =
                  TAXCZ(cnt,com)/( (sum(sec,IOZ(cnt,com,sec))  +  CZ(cnt,com) +  CGZ(cnt,com)+  IZ(cnt,com)) ) ;

taxpz(cnt,sec)$XDZ(cnt,sec) =   TAXPZ(cnt,sec)/XDZ(cnt,sec) ;

*h.        Calculation of baseline CO2 emissions
* =================== Calculate CO2 Emissions =================================

* https://www.eea.europa.eu/data-and-maps/data/data-viewers/greenhouse-gases-viewer
Parameter
CO2B(cnt)         co2 budget
CO2P(cnt,com,sec) co2 payments per commodity and sector
CO2H(cnt,com)     HOUSEHOLDS CO2 PAYMENT
CO2G(cnt,com)     GOVERNMENT CO2 PAYMENT
CO2I(cnt,com)     INVESTMENTS CO2 PAYMENT
CO2r(cnt,com,*)         emission factors;

Parameter
CO2Emissions(cnt,com,*);

$gdxin 'Co2Emission'
*FOR GDX INPUT
$load CO2Emissions
$gdxin

CO2r(cnt,com,sec)=0;
CO2r(cnt,com,sec)$(CO2Emissions(cnt,com,sec))=CO2Emissions(cnt,com,sec)/SAM(cnt,com,sec);
CO2r(cnt,com,"HOUS")$(CO2Emissions(cnt,com,"HOUS"))=CO2Emissions(cnt,com,"HOUS")/SAM(cnt,com,"HOUS");
CO2r(cnt,com,"INV")$(CO2Emissions(cnt,com,"INV"))=CO2Emissions(cnt,com,"INV")/SAM(cnt,com,"INV");
CO2r(cnt,com,"GOVT")$(CO2Emissions(cnt,com,"GOVT"))=CO2Emissions(cnt,com,"GOVT")/SAM(cnt,com,"GOVT");
CO2r(cnt,com,"i-H2S")=CO2r(cnt,com,"i-NG");
*CO2r(cnt,com,"i-H2CCS")=CO2r(cnt,com,"i-NG");
CO2r(cnt,com,"i-H2E")=CO2r(cnt,com,"i-NG");

* need to reallocate emissions in industry because the sectors
* i-CON and i-ALA are not featured in the Co2Emission.gdx file
* Here I reallocate it. IND in CO2 emissions refers to all of them (IND, ALA and CON) because it has not beed disaggregated
* IND in the SAM is already been reduced by extracting ALA and CON as selfstanding sectors

CO2r(cnt,com,"i-IND")$(CO2Emissions(cnt,com,"i-IND"))=CO2Emissions(cnt,com,"i-IND")/(SAM(cnt,com,"i-IND")+SAM(cnt,com,"i-ALA"));
CO2r(cnt,com,"i-ALA")$(CO2Emissions(cnt,com,"i-IND"))=CO2Emissions(cnt,com,"i-IND")/(SAM(cnt,com,"i-IND")+SAM(cnt,com,"i-ALA"));
*CO2r(cnt,com,"i-CON")$(CO2Emissions(cnt,com,"i-IND"))=CO2Emissions(cnt,com,"i-IND")/(SAM(cnt,com,"i-IND")+SAM(cnt,com,"i-ALA") +SAM(cnt,com,"i-CON") );

*execute_unload 'CO2factors.gdx' CO2r;

CO2P(cnt,com,sec)=0;
CO2H(cnt,com)=0;
CO2I(cnt,com)=0;
CO2G(cnt,com)=0;

CO2P(cnt,com,sec)$(FF(com) eq 1 )     = IOZ(cnt,com,sec)*CO2r(cnt,com,sec);
CO2H(cnt,com)$(FF(com) eq 1 )         = CZ(cnt,com)*CO2r(cnt,com,"HOUS");
CO2G(cnt,com)$(FF(com) eq 1 )         = CGLZ(cnt,com)*CO2r(cnt,com,"INV");
CO2I(cnt,com)$(FF(com) eq 1 )         = IZ(cnt,com)*CO2r(cnt,com,"GOVT");


display CO2P,CO2H,CO2G,CO2I;
CO2B(cnt)=0;


*************************
parameter check_taxcom(cnt, com);
check_taxcom(cnt, com) = CZ(cnt, com)*(1+taxcz(cnt, com))*(1 + trmz(cnt, com));
display check_taxcom;

************************


taxc(cnt,com) = taxcz(cnt,com) ;
taxp(cnt,sec) = taxpz(cnt,sec) ;
taxp(cnt,"i-PCCS")=taxp(cnt,"i-POW");
* Income tax computation in percentage
tyz(cnt)$((LSZ(cnt) + KSZ(cnt)) ne 0) =  TTYZ(cnt)/(LSZ(cnt) + KSZ(cnt)) ;
ty(cnt)  =  tyz(cnt) ;

*i.        Trade Balance checks
Parameter
trade_bal_global(cnt) global trade balance
trade_bal_global_nat national trade balance
;

trade_bal_global(cnt) =
* Incoming monetary flows - exports
*Exports
  sum(com,EROWZ(cnt,com))
         + sum((com,cntt),TRADEZ(com,cnt,cntt))
         +  TRROWZ(cnt)
         +  TRHROWZ(cnt)
         +  SROWZ(cnt)
* Outgong monetary flows - imports
         - ( sum(com,MROWZ(cnt,com))
         + sum((com,cntt),TRADEZ(com,cntt,cnt)) ) ;

trade_bal_global_nat = sum(cnt,trade_bal_global(cnt));

display trade_bal_global,trade_bal_global_nat;


Parameter
investment_bal(cnt) balance of savings and investments
investment_bal_nat
;

investment_bal(cnt) =+ sum(sec,INVZ(cnt,sec))
  + SHZ(cnt) + SGZ(cnt) + SROWZ(cnt) - ITZ(cnt)
  - sum(com, SVZ(cnt,com))  ;

investment_bal_nat = sum(cnt, investment_bal(cnt));



parameter
TaxedTradeMargins(cnt, com)
;

TaxedTradeMargins(cnt, com) = (CZ(cnt, com)+IZ(cnt, com)
         +CGZ(cnt, com)+sum(sec,IOZ(cnt, com, sec)))*trmz(cnt, com);

display investment_bal,investment_bal_nat,TaxedTradeMargins;


* ======================= UPGRADE ELASTICITIES =================================

*aggregate elasticities for old sectors
ELAS(sec,"KL")$(not sameas(sec,"i-H2S") and not sameas(sec,"i-H2CCS") and not sameas(sec,"i-H2E") and not sameas(sec,"i-PCCS")) = sum((r,sec0)$maps(sec0,sec),ELAS0(sec0,"KL")*XD0(r,sec0))/sum((cnt,sec0)$maps(sec0,sec),XD0(cnt,sec0));
ELAS(sec,"KLE")$(not sameas(sec,"i-H2S") and not sameas(sec,"i-H2CCS") and not sameas(sec,"i-H2E") and not sameas(sec,"i-PCCS")) = sum((r,sec0)$maps(sec0,sec),ELAS0(sec0,"KLE")*XD0(r,sec0))/sum((cnt,sec0)$maps(sec0,sec),XD0(cnt,sec0));
ELAS(sec,"KLEM")$(not sameas(sec,"i-H2S") and not sameas(sec,"i-H2CCS") and not sameas(sec,"i-H2E") and not sameas(sec,"i-PCCS")) = sum((r,sec0)$maps(sec0,sec),ELAS0(sec0,"KLEM")*XD0(r,sec0))/sum((cnt,sec0)$maps(sec0,sec),XD0(cnt,sec0));

elasM(com)$(not sameas(com, "gH2"))= sum((r,com0)$mapc(com0,com),elasM0(com0)*XZ(r,com))/sum((cnt,com0)$mapc(com0,com),XZ(cnt,com));
elasM("gH2")=elasM("gNG");

display ELAS0,ELAS,elasM;


* ============                             ===================
* ============ Currencies                  ===================
* ============                             ===================
*PP 8) HERE WE SET A FLAG FOR THE CURRENCY IN EACH COUNTRY. This is not ROW, but still "internal" trade with another currency
set CRR /EURO, NOK, SEK, GBP, DNK, SWF/;
*set CRR /EURO, NOK/;

parameter used_currency(cnt, CRR);

used_currency(cnt, 'EURO') = 1;

used_currency('NO', 'EURO') = 0;
used_currency('NO', 'NOK') = 1;

used_currency('SE', 'EURO') = 0;
used_currency('SE', 'SEK') = 1;
used_currency('GB', 'EURO') = 0;
used_currency('GB', 'GBP') = 1;
used_currency('DK', 'EURO') = 0;
used_currency('DK', 'DNK') = 1;
used_currency('CH', 'EURO') = 0;
used_currency('CH', 'SWF') = 1;

parameter Exch_out(CRR)
Exch_in(CRR);

*PP 9) HERE WE COMPUTE THE TOTAL OUTFLOWS AND INFLOWS IN A GIVEN CURRENCY
Exch_out(CRR) = (sum(cnt$used_currency(cnt, CRR), sum(com, MROWZ(cnt, com)) - TRROWZ(cnt)$(TRROWZ(cnt) < 0) + SROWZ(cnt) -  TRHROWZ(cnt)$( TRHROWZ(cnt) < 0)));

Exch_in(CRR) =  (sum(cnt$used_currency(cnt, CRR), sum(com,EROWZ(cnt, com)) + TRROWZ(cnt)$(TRROWZ(cnt) > 0) +  TRHROWZ(cnt)$( TRHROWZ(cnt) > 0)));

display used_currency,Exch_out,Exch_in;
display MROWZ, TRROWZ, SROWZ, TRHROWZ, EROWZ;

* ============ Define variable to study and the set of increments ==============================
* INCLUDE GROWTH FOR POPULATION AND GDP PROJECTIONS
parameter t;
t=1;

parameter R_GDP(step, cnt),
gdp_p(cnt),growth_p(cnt);

* ============                                  ===================
* ============ Definitions of the TRANSPORT CASE ===================
* ============                                  ===================
* NewSharet DESCRIBES HOW FUELS MIX CHANGES WITH TIME MOVING FROM CONVENTIONAL TO H2 AND ELECTRICITY
* THE SHARES ARE TAKEN FROM EXTERNAL DATA. (openENTRANCE scenario platform)
parameter T_adj(cnt, *, *)   Adjustment to Transport sectors
NewSharet(*, *, *, *)   Share of fuels according to external data;

*j.        Read input from openENTRANCE platform

* openENTRANCE
* REMOVE blanks before reading the file "the netherlands" --> "thenetherlands"
* ====== Include IAMC input file ============0
*=== Import from Excel using GDX utilities
set year /2015,2020,2025,2030,2035,2040,2045,2050/

* primary energy from GENeSYS-MOD
set source
/
'SecondaryEnergy|Electricity|Oil'
'SecondaryEnergy|Electricity|Solar'
'SecondaryEnergy|Electricity|Hydro'
'SecondaryEnergy|Electricity|Wind|Offshore'
'SecondaryEnergy|Electricity|Wind|Onshore'
'SecondaryEnergy|Electricity|Nuclear'
'SecondaryEnergy|Electricity|Coal'
'SecondaryEnergy|Electricity|Biomass'
'SecondaryEnergy|Electricity|Gas|NaturalGas'
*'SecondaryEnergy|Electricity|Gas|SyntheticMethane'
/;

* countries from GENeSYS-MOD
set countries
/
Lithuania
Slovenia
Spain
TheNetherlands
SlovakRepublic
France
Norway
Finland
Sweden
Bulgaria
Romania
Portugal
Austria
Hungary
Luxembourg
Ireland
CzechRepublic
Belgium
Denmark
Poland
Croatia
Switzerland
Estonia
Italy
Germany
Latvia
UnitedKingdom
Greece
/;

*$ontext
*=== First unload to GDX file (occurs during compilation phase)
$call gdxxrw.exe oePathway.xlsx par=PrimaryEnergy rng=Sheet1!A1:G11602 cdim=1 rdim=6


*=== Now import data from GDX
Parameter PrimaryEnergy(*,*,countries,source,*,year,*),
SelEnet(countries,source,year),SelEne(cnt,*,step),SelEne0(cnt,*,step);
$gdxin oePathway.gdx
$load PrimaryEnergy
$gdxin
SelEnet(countries,source,year)=
PrimaryEnergy('GENeSYS-MOD2.9.0-oe','DirectedTransition1.0',countries,source,'EJ/yr',year,'value');
display SelEnet;


set linkCnt(countries,cnt) /
Lithuania     .        LT
Slovenia      .        SI
Spain         .        ES
TheNetherlands.        NL
SlovakRepublic.        SK
France        .        FR
Norway        .        NO
Finland       .        FI
Sweden        .        SE
Bulgaria      .        BG
Romania       .        RO
Portugal      .        PT
Austria       .        AT
Hungary       .        HU
Luxembourg    .        LU
Ireland       .        IE
CzechRepublic .        CZ
Belgium       .        BE
Denmark       .        DK
Poland        .        PL
Switzerland   .        CH
Estonia       .        EE
Italy         .        IT
Germany       .        DE
Latvia        .        LV
UnitedKingdom .        GB
Greece        .        GR
/;

set linkSor(source,*)/
'SecondaryEnergy|Electricity|Oil'.gOIL
'SecondaryEnergy|Electricity|Solar'.K
'SecondaryEnergy|Electricity|Hydro'.K
'SecondaryEnergy|Electricity|Wind|Offshore'.K
'SecondaryEnergy|Electricity|Wind|Onshore'.K
'SecondaryEnergy|Electricity|Nuclear'.K
'SecondaryEnergy|Electricity|Coal'.gCOA
'SecondaryEnergy|Electricity|Biomass'.gBIO
'SecondaryEnergy|Electricity|Gas|NaturalGas'.gNG
/;


set linktime(year,step)/
2015.3
2020.4
2025.5
2030.6
2035.7
2040.8
2045.9
2050.10
/;

* Transform the data from the openENTRANCE Scenario platform into data understandable by REMES
* aggregate the sources into REMES commodities
SelEne0(cnt,g,step)=0;
SelEne0(cnt,'K',step)=0;
SelEne0(cnt,g,step)=sum((countries,source,year)$(linkCnt(countries,cnt) and linkSor(source,g) and linktime(year,step)), SelEnet(countries,source,year));
SelEne0(cnt,'K',step)=sum((countries,source,year)$(linkCnt(countries,cnt) and linkSor(source,'K') and linktime(year,step)), SelEnet(countries,source,year));
SelEne0(cnt,g,step)$(ord(step) lt 3)=SelEne0(cnt,g,'3');
SelEne0(cnt,'K',step)$(ord(step) lt 3)=SelEne0(cnt,'K','3');


SelEne(cnt,'K',step)$(SelEne0(cnt,'K',step))=SelEne0(cnt,'K',step)/(sum(com,SelEne0(cnt,com,step))+SelEne0(cnt,'K',step));
SelEne(cnt,g,step)$(SelEne0(cnt,g,step))=SelEne0(cnt,g,step)/(sum(com,SelEne0(cnt,com,step))+SelEne0(cnt,'K',step));

display SelEne;


* ================ CPD - COUNTERFACTUAL POLICY DEFINITION =====================
* Counterfactual point 1
* choose where to read the data from depending on the case study
$ifthen %CaseStudy%==1
* nothing happens for technology
newsharet(cnt,sec0,com0,step)=0;
newsharet("UK",sec0,com0,step)=0;
newsharet("UK","i-H2S","gH2",step)=0;
newsharet("UK","i-H2CCS","gH2",step)=0;
newsharet("UK","i-H2E","gH2",step)=0;
newsharet("UK","HOUS",com0,step)=0;
newsharet("UK","GOVT",com0,step)=0;
newsharet("UK","INV",com0,step)=0;
$endif


*PP 15c) THE H2 COMMODITY IS THE ONLY EXTRA COMMODITY CONSIDERED. initially its share is set to zero.
T_adj(cnt, sec, com) = 0;
T_adj(cnt, sec, "c-H2") = 0;

T_adj(cnt, "HOUS", com) = 0;
T_adj(cnt, "HOUS", "c-H2") = 0;

T_adj(cnt, "GOVT", com) = 0;
T_adj(cnt, "GOVT", "c-H2") = 0;





* k.        Translation of openENTRANCE input into REMES technology shares

* =============== newshare IS REDEFINED WITH THE GROUPED SECTORS ===============

parameter newshare0(*,*,*,*), newshare(*,*,*,*), KZ0(cnt,sec,step),KZshare(cnt,sec,step);

newshare0(cnt,'i-POW',com,step)=SelEne(cnt,com,step);
KZ0(cnt,'i-POW',step)=1-sum(com,newshare0(cnt,'i-POW',com,step));

* check data
*execute_unload 'FromPlatform.gdx' SelEnet, SelEne0,SelEne, newshare0;


alias(step,pass);

parameter
temp0(cnt,sec)       total sum of commodities that subject to technical change from SAM ,
multSAM(cnt,sec,*) ensures that in the first period the resharing give the same values as the SAM even with external shares,
multKZ(cnt,sec)  ensures that in the first period the resjaring gives the same values as the SAM for the capital,
reSAM(cnt,sec,*,step)   reallocation of values with same magnitude as into the SAM,
reKZ(cnt,sec,step)            reallocation of values for capital. same magnitude as the SAM,
KAP0(cnt,sec)    initial share belonging to capital
FZ0(cnt,sec)     initial share belonging to fuels;

* if at one point the share is nonzero compute the sum only for commodities with a nonzero share
* the initial sum of newshare0 over goods is not 1. The rest is kapital
temp0(cnt,sec) = sum(com$(sum(pass,newshare0(cnt,sec,com,pass))), IOZ(cnt,com,sec));

* Prices: compute the prices for the goods in the SAM
multSAM(cnt,sec,com)$(sum(pass,newshare0(cnt,sec,com,pass)) and IOZ(cnt,com,sec) and newshare0(cnt,sec,com,"3"))=IOZ(cnt,com,sec)/(newshare0(cnt,sec,com,"3")*temp0(cnt,sec));
multKZ(cnt,sec)$(sum((com,pass),newshare0(cnt,sec,com,pass)) and SID(sec)=3)=KZ(cnt,sec)/(KZ0(cnt,sec,"3")*temp0(cnt,sec))

* count how many multSAM are nonnegative
parameter count(cnt,sec);
count(cnt,sec)=sum(com$(multSAM(cnt,sec,com)),multSAM(cnt,sec,com)/multSAM(cnt,sec,com));

* Prices: if their initial share in the SAM is zero
multSAM(cnt,sec,com)$(sum(pass,newshare0(cnt,sec,com,pass)) and FID(com)>0 and FID(com)<3 and SID(sec)=3 and (IOZ(cnt,com,sec)=0 or newshare0(cnt,sec,com,"3")=0))=sum(g$(multSAM(cnt,sec,g)),multSAM(cnt,sec,g))/count(cnt,sec);



reSAM(cnt,sec,com,step)$(sum(pass,newshare0(cnt,sec,com,pass)))=0;
reSAM(cnt,sec,"gH2",step)=0;
reSAM(cnt,sec,com,step)$(sum(pass,newshare0(cnt,sec,com,pass)))=newshare0(cnt,sec,com,step)*temp0(cnt,sec)*multSAM(cnt,sec,com);
reSAM(cnt,sec,"gH2",step)=newshare0(cnt,sec,"gH2",step)*temp0(cnt,sec)*multSAM(cnt,sec,"gH2");
reKZ(cnt,sec,step)= KZ0(cnt,sec,step)*temp0(cnt,sec)*multKZ(cnt,sec);

* compute new shares for the power sector techchange
newshare(cnt,sec,com,step)$(sum(pass,newshare0(cnt,sec,com,pass)) and reSAM(cnt,sec,com,step))=reSAM(cnt,sec,com,step)/(sum(g$(CID(g)=1),reSAM(cnt,sec,g,step))+reSAM(cnt,sec,"gH2",step)+reKZ(cnt,sec,step));
newshare(cnt,sec,"gH2",step)$(newshare(cnt,sec,"gH2",step))=reSAM(cnt,sec,"gH2",step)/(sum(g$(CID(g)=1),reSAM(cnt,sec,g,step))+reSAM(cnt,sec,"gH2",step)+reKZ(cnt,sec,step));
KZshare(cnt,sec,step)$(sum(com,newshare(cnt,sec,com,step)))=1-sum(com,newshare(cnt,sec,com,step));



*execute_unload "reshare",temp0, newshare0, multSAM, multKZ, IOZ, temp0, reSAM, reKZ, newshare,KZshare,KZ,KZ0;


* ================================ DONE ========================================


parameter Pathway_adj(cnt, *, *) Sum of the adjustments from all cases


*PP 17) THIS FILE ABOUT BUILDINGS IS ALWAYS INCLUDED, BUT IT SEEMS TO GENERATE PROBLEMS BECAUSE THE
* GDX FILES ARE MISSING FOR THE BUILDING CASE
*$if "%SW_BUILD%" <> "No"
*$include "SET-NAV_Building_Pathways2.gms"

*PP 18) THIS IS NOT CLEAR. WHAT ARE THESE PARAMETERS USED FOR? ORIGINAL VALUES FOR WHAT?
* IT SEEMS LIKE THEY ARE THE SHOCKS TO BE INCLUDED IN THE STRUCTURE OF THE SECTORS IN THE MPSGE MODEL
parameter temp(cnt,*),
selected(cnt,sec),
pathway_adj_total(cnt, *, *)  Original values plus the total adjustments ,
pathway_unadj_total(cnt, *, *)  Original Input coeficient ,
Pathway_total(cnt, *)  New total input  per sector and consumers after adjustments,
Pathway_adj_cap(cnt, sec) Original capital minus the pathway adjustment total if the latter is negative;
Parameter Pathway_adjusted(step, cnt,  *, com);
* it is important that temp is initialized to 0 for defining the parameter pathways_cap_adj
temp(cnt,sec)=0;

parameter bin to account for unemployment (0 in benchmark and 1 in counterfactual);
bin=0;

*l.        Inclusion of the CGE model
* ============                             ===================
* ============ DEFINITION OF THE CGE MODEL ===================
* ============                             ===================

$include "REMES_MPSGE_alt.gms"

* ============                             ===================
* ============ DEFINITION OF THE CGE MODEL ===================
* ============                             ===================

* ============ Provide initial levels of the model variables ===================


option mcp = path ;
Arrow_Debreu.iterlim = IterLim;
Arrow_Debreu.tolProj = 0.00001;
Arrow_Debreu.tolInfeas = 0.01;
Arrow_Debreu.workfactor = 3;
Arrow_Debreu.reslim = 6000;

*PP 20) POPULATE THE SECTORS AND COMMODITIES THAT WILL BE MODIFIED
* SEEMS LIKE IT CONSIDERS ALL THE SECTORS + HOUS + GOVT
* ALL THE COMMODITIES + H2
*populate the sets for the adjustment operations

set adjust_sec(*), adjust_com(*);


adjust_sec(sec)=YES;
adjust_sec("Hous")=YES;
adjust_sec("Govt")=YES;

adjust_com(com)=YES;
adjust_com("gH2")=YES;


parameter check(cnt, *, *);

Pathway_adj(cnt, sec, com)=0;
Pathway_adj(cnt, "HOUS", com)=0;
Pathway_adj(cnt, "GOVT", com)=0;
Pathway_adj_cap(cnt, sec)=KZ(cnt,sec);
Pathway_total(cnt, "HOUS")=0;
Pathway_total(cnt, "GOVT")=0;
Pathway_total(cnt, sec)=0;
* GDP growth is set to unit for the benchmark solution
gdp_p(cnt)=1;
growth_p(cnt)=1;
display ty;

parameter time;
time=0;

parameter PRC(cnt);
PRC(cnt)=1;
*==================== Benckmark Solution ======================
*execute_unload "junk" XDDZ,TRADEZ,EROWZ,MROWZ;

parameter Kap(cnt),Capital(cnt,step),Investments(cnt,step);

* ================= Other scenario optons =========================
parameter tfp(cnt) tariff per country;
tfp(cnt)=0;
* ================================================================

scalar hb /0/;


$include "reset_initial_values_basic.gms"
$INCLUDE ARROW_DEBREU.GEN
Arrow_Debreu.iterlim = 0;
ARROW_DEBREU.Savepoint = 1;
Solve ARROW_DEBREU using mcp;

parameter depr(cnt) depreciation;
*PP 20a) Capital accumulation
* the depreciation must depend on the number of periods
* first year is 2007 last is 2050 and there are 10 periods so every period is 5 years long
* II(cnt) in the benckmark year are the investments that are transfered to the next year to increase the capital
* Then we assume that for one period (5 years) the additional investment is II*5
* If investments are too small the capital might become zero (sector shuts down).
* we define the depreciation such that Kap(1-depr)+I=Kap(1+gdp)
* depr(cnt)=5*II.l(cnt)/Kap(cnt)-(gdp(cnt,"1")-1);
* Kap(cnt)=Kap(cnt)*(1-depr(cnt))+5*II.l(cnt);





parameter emissions(cnt,com,sec);
emissions(cnt,com,sec)=(IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com))*CO2r(cnt,com,sec);
display emissions;

* define the visegrad countries for non cooperative case studies.

set visegrad(cnt)/
CZ
HU
PL
SK
/;

parameter inVis(cnt) visegrad countries flag;
inVis(cnt)=0;
inVis(visegrad)=1;

*m.         Base year output definition
* PPOUT ============= Define Parameters for Output =============================
parameter production(cnt,*,*,step), finaldemand(cnt,com,step),import(cnt,com,step),exports(cnt,*,step),
IOanalysis(*,*,*,*,step), inputsec3(cnt,*,*,step), outputsec3(cnt,*,*,step), inputsec4(cnt,*,*,step),
TradeAnalysis(*,*,com,step)
outputsec4(cnt,*,*,step) total value entering a sector and total value exiting a sector;


finaldemand(cnt,com,"1")=CZ(cnt,com)+IZ(cnt,com)+CGZ(cnt,com);
production(cnt,sec,com,"1")=XDDZ(cnt,sec,com);
IOanalysis('input',cnt,sec,com,"1")=IOZ(cnt,com,sec)*(1+taxcz(cnt,com));
IOanalysis('input',cnt,sec,"Labour","1")=LZ(cnt,sec);
IOanalysis('input',cnt,sec,"Capital","1")=Pathway_adj_cap(cnt, sec)+AOGR(cnt)$(sameas(sec,"i-COIL"))+ACR(cnt)$(sameas(sec,"i-COAL"))+ANGR(cnt)$(sameas(sec,"i-NG"));
IOanalysis('input',cnt,sec,"tax_sec","1")=sum(com,XDDZ(cnt,sec,com)*taxpz(cnt,sec));
IOanalysis('input',cnt,"demand",com,"1")=finaldemand(cnt,com,"1")*(1+taxcz(cnt,com));
IOanalysis('input',cnt,"stocks",com,"1")=SVZ(cnt,com);
IOanalysis('input',cnt,"tmarg",com,"1")=TMXZ(cnt,com);
IOanalysis('input',cnt,"exportsROW",com,"1")=EROWZ(cnt,com)+sum(cntt$(ord(cntt) ne ord(cnt)),TRADEZ(com,cnt,cntt));

IOanalysis('output',cnt,sec,com,"1")=XDDZ(cnt,sec,com);
IOanalysis('output',cnt,"tax_com",com,"1")=(sum(sec,IOZ(cnt,com,sec))+finaldemand(cnt,com,"1"))*taxcz(cnt,com);
IOanalysis('output',cnt,"tmarg",com,"1")=sum(cntt,trademargins(com, cntt, cnt));
IOanalysis('output',cnt,"importsROW",com,"1")=MROWZ(cnt,com)+sum(cntt$(ord(cntt) ne ord(cnt)),TRADEZ(com,cntt,cnt));


parameter UNEMPLOYMENT(cnt,*);
UNEMPLOYMENT(cnt,"1")=ROUND(urate(cnt)*100);

parameter EneDem(cnt,*,*),EneDemBase(cnt,*),EneDemProj(cnt,*),EneDemTot(cnt,*),Alloc(cnt,*,*),EneDemTWh(cnt,*,*);
EneDem(cnt,sec,"1")=IOZ(cnt, "gPOW", sec);
EneDem(cnt,"i-H2S","1")=0;
EneDem(cnt,"i-H2CCS","1")=0;
EneDem(cnt,"i-H2E","1")=0;
EneDem(cnt,"i-PCCS","1")=0;
EneDem(cnt,"CONS","1")=CZ(cnt,"gPOW")
                 +CGLZ(cnt,"gPOW")
                 +IZ(cnt,"gPOW");


parameter PriceCO2(step),ElPrice(cnt,step);
PriceCO2("1")=1;
ElPrice(cnt,"1")=1;


parameter FFdem(cnt,com,step),EEdem(cnt,step);

FFdem(cnt,energy,"1")=sum(sec,IOZ(cnt,energy,sec))+CZ(cnt,energy)+CGLZ(cnt,energy)+IZ(cnt,energy);
EEdem(cnt,"1")=sum((sec,fosfuels),IOZ(cnt,fosfuels,sec)*CO2r(cnt,fosfuels,sec))+sum(fosfuels,CZ(cnt,fosfuels)*CO2r(cnt,fosfuels,"HOUS")+CGLZ(cnt,fosfuels)*CO2r(cnt,fosfuels,"GOVT")+IZ(cnt,fosfuels)*CO2r(cnt,fosfuels,"INV"));


parameter demand(cnt,*,com,step),cdem(cnt,com,step);
demand(cnt,sec,com,"1")=IOZ(cnt,com,sec);
demand(cnt,"HOUS",com,"1")=CZ(cnt,com);
demand(cnt,"GOVT",com,"1")=CGZ(cnt,com);
demand(cnt,"INVB",com,"1")=IZ(cnt,com);
demand(cnt,"stocks",com,"1")=max(0,SVZ(cnt,com));
demand(cnt,"Exports",com,"1")=EROWZ(cnt,com);

cdem(cnt,com,"1")=sum(sec,demand(cnt,sec,com,"1"))+demand(cnt,"HOUS",com,"1")+demand(cnt,"GOVT",com,"1")+demand(cnt,"INVB",com,"1")+demand(cnt,"Exports",com,"1")+demand(cnt,"stocks",com,"1");

parameter SAMout(cnt,*,*,step),QQQ(cnt,*,*,step),PPP(cnt,*,*,step),Quantity(cnt,*,*,step);
SAMout(cnt,sec,com,step)=0;
QQQ(cnt,sec,com,step)=0;
PPP(cnt,sec,com,step)=0;
Quantity(cnt,samd,samr,step)=0;

parameter MCO2B(cnt,step) monetary value of the CO2 budget;

parameter VA(cnt,sec,step),FuelPrice(cnt,fosfuels,step),GDPout(cnt,step);


SAMout(cnt,com,sec,"1")=IOZ(cnt,com,sec)*(1+taxcz(cnt,com));
SAMout(cnt,sec,com,"1")$(XDDZ(cnt,sec,com))=XDDZ(cnt,sec,com);
SAMout(cnt,"i-H2S","gH2","1")=0;
SAMout(cnt,"i-H2CCS","gH2","1")=0;
SAMout(cnt,"i-H2E","gH2","1")=0;
SAMout(cnt,"i-PCCS",com,"1")=0;
SAMout(cnt,"Capital",sec,"1")=Pathway_adj_cap(cnt, sec)+AOGR(cnt)$(sameas(sec,"i-COIL"))+ACR(cnt)$(sameas(sec,"i-COAL"))+ANGR(cnt)$(sameas(sec,"i-NG"));
SAMout(cnt,"Labour",sec,"1")=LZ(cnt,sec);
SAMout(cnt,"tax_sec",sec,"1")=sum(com,taxpz(cnt,sec)*XDDZ(cnt,sec,com));
SAMout(cnt,com,"HOUS","1")=CZ(cnt,com)*(1+taxcz(cnt,com));
SAMout(cnt,com,"GOVT","1")=CGLZ(cnt,com)*(1+taxcz(cnt,com));
SAMout(cnt,com,"INV","1")=IZ(cnt,com)*(1+taxcz(cnt,com));
SAMout(cnt,com,"STOCKS","1")=SVZ(cnt,com);
SAMout(cnt,"HOUS","Capital","1")=KSZ(cnt)+AOGR(cnt)+ACR(cnt)+ANGR(cnt);
SAMout(cnt,"GOVT","Capital","1")=-sum(sec,pathway_total(cnt, sec));
SAMout(cnt,"HOUS","Labour","1")=sum(sec,LZ(cnt,sec));
SAMout(cnt,"INV","HOUS","1")=SHZ(cnt);
SAMout(cnt,"HOUS","trade","1")=max(0, TRHROWZ(cnt));
SAMout(cnt,"trade","HOUS","1")=max(0,-TRHROWZ(cnt));
SAMout(cnt,"GOVT","tax_sec","1")=sum(sec,taxp(cnt,sec)*sum(com,XDDZ(cnt,sec,com)));
SAMout(cnt,"GOVT","tax_com","1")=sum(com,sum(sec,IOZ(cnt,com,sec)*taxcz(cnt,com))+(CZ(cnt,com)+CGLZ(cnt,com)+IZ(cnt,com))*taxcz(cnt,com));
SAMout(cnt,"tax_sec",sec,"1")=taxpz(cnt,sec)*sum(com,XDDZ(cnt,sec,com));
SAMout(cnt,"tax_com",com,"1")=sum(sec,IOZ(cnt,com,sec))*taxcz(cnt,com)+(CZ(cnt,com)+CGLZ(cnt,com)+IZ(cnt,com))*taxcz(cnt,com);
SAMout(cnt,"STOCKS","INV","1")=sum(com,SVZ(cnt,com));
SAMout(cnt,com,"tmarg","1")= TMXZ(cnt,com);
SAMout(cnt,"tmarg",com,"1")= TMCZ(cnt,com);
SAMout(cnt,com,"trade","1")= EROWZ(cnt,com)+sum(cntt,TRADEZ(com,cnt,cntt));
SAMout(cnt,"trade",com,"1")=MROWZ(cnt,com)+sum(cntt,TRADEZ(com,cntt,cnt));
SAMout(cnt,"GOVT","trade","1")=TRROWZ(cnt);
SAMout(cnt,"CO2allow",sec,"1")=0;
SAMout(cnt,"CO2allow","HOUS","1")=0;
SAMout(cnt,"CO2allow","GOVT","1")=0;
SAMout(cnt,"CO2allow","INV","1") =0;
SAMout(cnt,"GOVT","CO2allow","1")=0;

VA(cnt,sec,"1")=SAMout(cnt,"Capital",sec,"1")+SAMout(cnt,"Labour",sec,"1")+SAMout(cnt,"tax_sec",sec,"1")+SAMout(cnt,"GOVT","CO2allow","1");
GDPout(cnt,"1")=sum(sec,VA(cnt,sec,"1"));

QQQ(cnt,com,sec,"1")$SAM(cnt,com,sec)=0;
QQQ(cnt,sec,com,"1")$SAM(cnt,sec,com)=0;
QQQ(cnt,"Capital",sec,"1")$SAM(cnt,"Capital",sec)=0;
QQQ(cnt,"Labour",sec,"1")$SAM(cnt,"Labour",sec)=0;
QQQ(cnt,"tax_sec",sec,"1")$SAM(cnt,"tax_sec",sec)=0;
QQQ(cnt,com,"HOUS","1")$SAM(cnt,com,"HOUS")=0;
QQQ(cnt,com,"GOVT","1")$SAM(cnt,com,"GOVT")=0;
QQQ(cnt,com,"INV","1")$SAM(cnt,com,"INV")=0;
QQQ(cnt,com,"STOCKS","1")$SAM(cnt,com,"STOCKS")=0;
QQQ(cnt,"HOUS","Capital","1")$SAM(cnt,"HOUS","Capital")=0;
QQQ(cnt,"GOVT","Capital","1")$SAM(cnt,"GOVT","Capital")=0;
QQQ(cnt,"HOUS","Labour","1")$SAM(cnt,"HOUS","Labour")=0;
QQQ(cnt,"INV","HOUS","1")$SAM(cnt,"INV","HOUS")=0;
QQQ(cnt,"HOUS","trade","1")$SAM(cnt,"HOUS","trade")=0;
QQQ(cnt,"trade","HOUS","1")$SAM(cnt,"trade","HOUS")=0;
QQQ(cnt,"GOVT","tax_sec","1")=0;
QQQ(cnt,"GOVT","tax_com","1")=0;
QQQ(cnt,"tax_sec",sec,"1")$SAM(cnt,"tax_sec",sec)=0;
QQQ(cnt,"tax_com",com,"1")$SAM(cnt,"tax_com",com)=0;
QQQ(cnt,"STOCKS","INV","1")=0;
QQQ(cnt,com,"tmarg","1")$SAM(cnt,com,"tmarg")=0;
QQQ(cnt,"tmarg",com,"1")= 0;
QQQ(cnt,com,"trade","1")$SAM(cnt,com,"trade")=0;
QQQ(cnt,"trade",com,"1")$SAM(cnt,"trade",com)=0;
QQQ(cnt,"GOVT","trade","1")$SAM(cnt,"GOVT","trade")=0;
QQQ(cnt,"CO2allow",sec,"1")=0;
QQQ(cnt,"CO2allow","HOUS","1")=0;
QQQ(cnt,"CO2allow","GOVT","1")=0;
QQQ(cnt,"CO2allow","INV","1") =0;
QQQ(cnt,"GOVT","CO2allow","1")=0;

Quantity(cnt,samd,samr,"1")=SAM(cnt,samd,samr);
Quantity(cnt,sec,com,"1")=SAM(cnt,sec,com);
Quantity(cnt,com,sec,"1")=SAM(cnt,com,sec);

Quantity(cnt,com,sec,"1")=IOZ(cnt,com,sec);
Quantity(cnt,sec,com,"1")$(XDDZ(cnt,sec,com))=XDDZ(cnt,sec,com);
Quantity(cnt,"i-H2S","gH2","1")=0;
Quantity(cnt,"i-H2CCS","gH2","1")=0;
Quantity(cnt,"i-H2E","gH2","1")=0;
Quantity(cnt,"i-PCCS",com,"1")=0;
Quantity(cnt,"Capital",sec,"1")=Pathway_adj_cap(cnt, sec)+AOGR(cnt)$(sameas(sec,"i-COIL"))+ACR(cnt)$(sameas(sec,"i-COAL"))+ANGR(cnt)$(sameas(sec,"i-NG"));
Quantity(cnt,"Labour",sec,"1")=LZ(cnt,sec);
Quantity(cnt,com,"HOUS","1")=CZ(cnt,com);
Quantity(cnt,com,"GOVT","1")=CGLZ(cnt,com);
Quantity(cnt,com,"INV","1")=IZ(cnt,com);
Quantity(cnt,com,"STOCKS","1")=SVZ(cnt,com);
Quantity(cnt,"HOUS","Capital","1")=KSZ(cnt)+AOGR(cnt)+ACR(cnt)+ANGR(cnt);
Quantity(cnt,"GOVT","Capital","1")=-sum(sec,pathway_total(cnt, sec));
Quantity(cnt,"HOUS","Labour","1")=sum(sec,LZ(cnt,sec));
Quantity(cnt,"INV","HOUS","1")=SHZ(cnt);
Quantity(cnt,"HOUS","trade","1")=max(0, TRHROWZ(cnt));
Quantity(cnt,"trade","HOUS","1")=max(0,-TRHROWZ(cnt));
Quantity(cnt,"STOCKS","INV","1")=sum(com,SVZ(cnt,com));
Quantity(cnt,com,"tmarg","1")= TMXZ(cnt,com);
Quantity(cnt,"tmarg",com,"1")= TMCZ(cnt,com);
Quantity(cnt,com,"trade","1")= EROWZ(cnt,com)+sum(cntt,TRADEZ(com,cnt,cntt));
Quantity(cnt,"trade",com,"1")=MROWZ(cnt,com)+sum(cntt,TRADEZ(com,cntt,cnt));
Quantity(cnt,"GOVT","trade","1")=TRROWZ(cnt);
Quantity(cnt,"CO2allow",sec,"1")=0;
Quantity(cnt,"CO2allow","HOUS","1")=0;
Quantity(cnt,"CO2allow","GOVT","1")=0;
Quantity(cnt,"CO2allow","INV","1") =0;
Quantity(cnt,"GOVT","CO2allow","1")=0;




PPP(cnt,com,sec,"1")=(1+taxc(cnt,com))/(1+taxcz(cnt,com));
PPP(cnt,sec,com,"1")$(XDDZ(cnt,sec,com))=1;
PPP(cnt,"Capital",sec,"1")=1;
PPP(cnt,"Labour",sec,"1")=1;
PPP(cnt,com,"HOUS","1")=(1+taxc(cnt,com))/(1+taxcz(cnt,com));
PPP(cnt,com,"GOVT","1")=(1+taxc(cnt,com))/(1+taxcz(cnt,com));
PPP(cnt,com,"INV","1")=(1+taxc(cnt,com))/(1+taxcz(cnt,com));
PPP(cnt,com,"STOCKS","1")=1;
PPP(cnt,"HOUS","Capital","1")=1;
PPP(cnt,"GOVT","Capital","1")=1;
PPP(cnt,"HOUS","Labour","1")=1;
PPP(cnt,"INV","HOUS","1")=1;
PPP(cnt,"HOUS","trade","1")=1;
PPP(cnt,"trade","HOUS","1")=1;
PPP(cnt,"GOVT","tax_sec","1")=1;
PPP(cnt,"GOVT","tax_com","1")=1;
PPP(cnt,"tax_sec",sec,"1")=1;
PPP(cnt,"tax_com",com,"1")=1;
PPP(cnt,"STOCKS","INV","1")=1;
PPP(cnt,com,"tmarg","1")= 1;
PPP(cnt,"tmarg",com,"1")= 1;
PPP(cnt,com,"trade","1")= 1;
PPP(cnt,"trade",com,"1")=1;
PPP(cnt,"GOVT","trade","1")=1;
PPP(cnt,"CO2allow",sec,"1")=1;
PPP(cnt,"CO2allow","HOUS","1")=1;
PPP(cnt,"CO2allow","GOVT","1")=1;
PPP(cnt,"CO2allow","INV","1") =1;
PPP(cnt,"GOVT","CO2allow","1")=1;

parameter grow(cnt) single period (5 years) growth trend;
grow(cnt)$(GDPt eq 0)=(gdp(cnt,"10")*GDPcal(cnt))**(5/(2050-2005))-1;
grow(cnt)$(GDPt eq 1)=0;
display grow;
*$exit
Capital(cnt,"1")=KSZ(cnt)/ror(cnt);
Investments(cnt,"1")=ITZ(cnt)*5;

*n.        Recoursive step definition

* ================ Dynamic data for first iteration ===================
* one period depreciation (5 years)
Kap(cnt)=KSZ(cnt)/ror(cnt);
depr(cnt)=ITZ(cnt)*5/Kap(cnt)-grow(cnt);
Kap(cnt)=(Kap(cnt)*(1-depr(cnt))+ITZ(cnt)*5);
KSZ(cnt)=Kap(cnt)*ror(cnt);
* ======================================================================

display Kap,KSZ,depr;

parameter gdptest(cnt,step);
gdptest(cnt,"1")=1;

parameter NRS(cnt,sec,com,step) new remes share;
NRS(cnt,sec,com,step)=0;

parameter outLab(cnt,sec,step), outAct(cnt,sec,step),outPrice(cnt,com,step);


loop(step$(ord(step) gt 1 and ord(step) le STEPS),
t=t+1;
*PRC(cnt)=1+(PRC0(cnt)-1)/(card(step)-1)*(ord(step)-1);
*Reset variables to initial levels
$include "reset_initial_values_basic.gms"

*put a tax on electricity exports for visegrad countries
tfp(cnt)$(sameas(cnt,"HU"))=tft(step)*tariff;
tfp(cnt)$(sameas(cnt,"CZ"))=tft(step)*tariff;
tfp(cnt)$(sameas(cnt,"PL"))=tft(step)*tariff;
tfp(cnt)$(sameas(cnt,"SK"))=tft(step)*tariff;
*clear****************************************

* GDP is set to the one from the database for the counterfactual
gdp_p(cnt) = gdp_p(cnt)*(1+grow(cnt));
growth_p(cnt)=growth(cnt,step);
* if we want no GDP growth
gdp_p(cnt)$(GDPt eq 1)=1;

cint(cnt)=1;
*+(cint0(cnt)-1)/(card(step)-1)*(ord(step)-1);
eint(cnt)$(EF eq 1)=1+(eint0(cnt)-1)/(card(step)-1)*(ord(step)-1);

display cint,eint;

*o.        Application of counterfactuals

time=time+1;

display P_S;

         PU.FX("CY")=1;

* Technology Adjustment
* here the data from the scenario Platform is transformed in the final parameters for the model

         loop((cnt, sec),
                 temp(cnt,sec)$(P_S gt 1) = sum( com$(sum(pass,newshare(cnt,sec,com,pass))), IOZ(cnt,com,sec)  )+KZ(cnt,sec);
                 T_adj(cnt, sec, com)$(P_S gt 1 and sum(pass,newshare(cnt,sec,com,pass))) = newshare( cnt, sec, com, step)*temp(cnt,sec) - IOZ(cnt,com,sec);
                 T_adj(cnt, sec, "gH2")$(P_S gt 1) = newshare( cnt, sec, "gH2", step)*temp(cnt,sec);
                 );

* This holds for all sectors except for i-POW, whose techchange is managed by newshare and natural resource sectors, which keep buying their resource.
         loop((cnt,sec),
* reassign Natual Gas into H2 to simulate a change in technology (50%/50%).

* TESTone
*                 T_adj(cnt, sec, "gNG")$(P_S gt 1 and IOZ(cnt,"gNG",sec) and not sameas(sec,"i-POW") and indsecs(sec))= IOZ(cnt,"gNG",sec)*(1+(0.5-1)/(card(pass)-1)*(step.val-1))-IOZ(cnt,"gNG",sec);
*                 T_adj(cnt, sec, "gH2")$(P_S gt 1 and IOZ(cnt,"gNG",sec) and not sameas(sec,"i-POW") and indsecs(sec))= IOZ(cnt,"gNG",sec)*(-(0.5-1)/(card(pass)-1)*(step.val-1));
* reassign industry into services to simulate an increase in Circular Economy adoption (decrease Ind by 20%)
                 T_adj(cnt, sec, "gIND")$(IOZ(cnt,"gIND",sec) and CE eq 1)= IOZ(cnt,"gIND",sec)*(1+(0.2-1)/(card(step)-1)*(ord(step)-1))-IOZ(cnt,"gIND",sec);

* reduce also aluminium
* once finished send output to Hettie.
                 T_adj(cnt, sec, "gSER")$(IOZ(cnt,"gIND",sec) and CE eq 1)= IOZ(cnt,"gIND",sec)*(-(0.2-1)/(card(step)-1)*(ord(step)-1));
                 );

display T_adj;
selected(cnt,sec)=sum((com,pass),newshare(cnt,sec,com,pass));

* THESE PARAMETERS GO RIGHT INTO THE MODEL

*Caculate the unadjusted total of sectors and consumer's inputs
pathway_unadj_total(cnt, sec, com)       = IOZ(cnt, com, sec);
pathway_unadj_total(cnt, "Hous", com)    = CZ(cnt, com);
pathway_unadj_total(cnt, "Govt", com)    = CGLZ(cnt, com);


*calculate the pathway adjustment
Pathway_adj(cnt, adjust_sec, com)        =  T_adj(cnt, adjust_sec, com);
Pathway_adj(cnt, adjust_sec, "gH2")      =  T_adj(cnt, adjust_sec, "gH2");


*Calculate the adjustment total
pathway_adj_total(cnt, sec, com) = IOZ(cnt, com, sec) + Pathway_adj(cnt, sec, com);
pathway_adj_total(cnt, "Hous", com) = CZ(cnt, com) + Pathway_adj(cnt, "Hous", com);
pathway_adj_total(cnt, "Govt", com) = CGLZ(cnt, com) + Pathway_adj(cnt, "Govt", com);

*calculate the new total coefficient
loop((cnt, adjust_sec), Pathway_total(cnt, adjust_sec) = sum(adjust_com,  pathway_adj_total(cnt, adjust_sec, adjust_com) - pathway_unadj_total(cnt, adjust_sec, adjust_com)));

* THE TOTAL INCREASE IN OTHER MATERIALS DECREASES THE USAGE OF CAPITAL
* calculate the capital increase per sector

* only if there is a change in shares (temp is non zero)
Pathway_adj_cap(cnt, sec) = KZ(cnt,sec);
Pathway_adj_cap(cnt, sec)$(P_S gt 1 and selected(cnt,sec))=temp(cnt,sec)*KZshare(cnt,sec,step)$(temp(cnt,sec));
*KZ(cnt,sec) - pathway_total(cnt, sec)$(pathway_total(cnt, sec)<0);



display pathway_unadj_total, pathway_adj_total, pathway_total, pathway_adj_cap;


loop((cnt, adjust_sec, com), Pathway_adjusted(step, cnt,  sec, com) = Pathway_adj(cnt, sec, com););


check(cnt, com, "CZ")$(FID(com)>0 and FID(com)<3) =  CZ(cnt, com);
check(cnt, com, "T_adj")$(FID(com)>0 and FID(com)<3) = T_adj(cnt, "Hous", com);
check(cnt, "Hous", "CZ - T_adj") =  sum( com$(FID(com)>0 and FID(com)<3),CZ(cnt, com)) - (sum( com$(FID(com)>0 and FID(com)<3),T_adj(cnt, "hous",  com)) + T_adj(cnt, "Hous", "gH2"));

display check;

NRS(cnt,sec,com,step)$(FID(com)>0 and FID(com)<3)=IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com);



*=====================Re-Solve============
*option Savepoint = 1;

*execute_unload "shocks.gdx" Pathway_adj, Pathway_adj_cap, KZ, Pathway_total, gdp_p,growth_p,T_Adj,newshare,ty,PRC, Rp, OGR,AOGR,CR,ACR,NGR,ANGR,gdp_p;

*
*PCO2.L(cnt)=0;
CO2P(cnt,com,sec)$(FF(com) eq 1 )     = (IOZ(cnt,com,sec))*CO2r(cnt,com,sec);
CO2H(cnt,com)$(FF(com) eq 1 )         = (CZ(cnt,com))*CO2r(cnt,com,"HOUS");
CO2G(cnt,com)$(FF(com) eq 1 )         = (CGLZ(cnt,com))*CO2r(cnt,com,"GOVT");
CO2I(cnt,com)$(FF(com) eq 1 )         = IZ(cnt,com)*CO2r(cnt,com,"INV");


* ================ CPD - COUNTERFACTUAL POLICY DEFINITION =====================
* Here we define the CO2 budget
CO2B(cnt) = (1+(finCO2(cnt)*carbonbudget-1)/9*(step.val-1))*(sum((com,sec)$(FF(com) eq 1),(IOZ(cnt,com,sec))*CO2r(cnt,com,sec))
         +sum(com$(FF(com) eq 1),(CZ(cnt,com))*CO2r(cnt,com,"HOUS")
         +IZ(cnt,com)*CO2r(cnt,com,"INV")
         +(CGLZ(cnt,com))*CO2r(cnt,com,"GOVT")));

* this needs to be the same for all the countries until 2020 under ANY scenario
CO2B(cnt)$(ord(step) le 4) = (1+(finCO2(cnt)-1)/9*(step.val-1))*(sum((com,sec)$(FF(com) eq 1),(IOZ(cnt,com,sec))*CO2r(cnt,com,sec))
         +sum(com$(FF(com) eq 1),(CZ(cnt,com))*CO2r(cnt,com,"HOUS")
         +IZ(cnt,com)*CO2r(cnt,com,"INV")
         +(CGLZ(cnt,com))*CO2r(cnt,com,"GOVT")));


* Visegrad stop cooperating after 2020 in case of exit from the deal.
CO2B(visegrad)$(coop=0 and ord(step) gt 4)=0;
CO2B(cnt)$(GHGred eq 0)=0;
* ==============================================================================
*effects of unemployment
bin=1;


*p.        Solution of the n-th iteration
execute_loadpoint "ARROW_DEBREU_p.gdx";
Arrow_Debreu.iterlim = 9999999;
ARROW_DEBREU.Savepoint = 1;
$INCLUDE ARROW_DEBREU.GEN
Solve ARROW_DEBREU using mcp;

*q.        Output definition
finaldemand(cnt,com,step)$(ord(step) gt 1)=HOUS_DEM.l(cnt,com)+GOVT_DEM.l(cnt,com)+INVB_DEM.l(cnt,com);
production(cnt,sec,com,step)$(ord(step) gt 1)=R_PD_XD.l(cnt, sec, com);

UNEMPLOYMENT(cnt,step)=ROUND(UR.L(cnt)*100);

EneDem(cnt,sec,step)$(IOZ(cnt, "gPOW", sec))=(R_P_XD.L(cnt, sec, "gPOW"));
EneDem(cnt,"i-H2S",step)$(InputCom("i-H2S","gPOW"))=(R_P_XD.L(cnt, "i-H2S", "gPOW"));
EneDem(cnt,"i-H2CCS",step)$(InputCom("i-H2CCS","gPOW"))=(R_P_XD.L(cnt, "i-H2CCS", "gPOW"));
EneDem(cnt,"i-H2E",step)$(InputCom("i-H2E","gPOW"))=(R_P_XD.L(cnt, "i-H2E", "gPOW"));
EneDem(cnt,"i-PCCS",step)$(IOZ(cnt, "gPOW", "i-POW"))=(R_P_XD.L(cnt, "i-PCCS", "gPOW"));
EneDem(cnt,"CONS",step)$(CZ(cnt,"gPOW")
                 +CGLZ(cnt,"gPOW")
                 +IZ(cnt,"gPOW"))=(HOUS_DEM.L(cnt,"gPOW")
                 +GOVT_DEM.L(cnt,"gPOW")
                 +INVB_DEM.L(cnt,"gPOW"));

EneDemTot(cnt,step)=sum(sec,EneDem(cnt,sec,step))+EneDem(cnt,"CONS",step);

* This is multiplied by the total energy demand in a country in 2010 and give the relative consumption in the other years
* for all sectors and final consumption
EneDemTWh(cnt,sec,step)=EneDem(cnt,sec,step)/EneDemTot(cnt,"2");
EneDemTWh(cnt,"CONS",step)=EneDem(cnt,"CONS",step)/EneDemTot(cnt,"2");

PriceCO2(step)$(sum(cnt,CO2B(cnt)))=sum(cnt,PCO2.l(cnt)*CO2B(cnt))/sum(cnt,CO2B(cnt));
ElPrice(cnt,step)=P.l(cnt,"gPOW")/PU.l(cnt);

FFdem(cnt,energy,step)=sum(sec,R_P_XD.l(cnt, sec, energy))+HOUS_DEM.l(cnt,energy)+GOVT_DEM.l(cnt,energy)+INVB_DEM.l(cnt,energy);
EEdem(cnt,step)=sum((sec,fosfuels),R_P_XD.l(cnt, sec, fosfuels)*CO2r(cnt,fosfuels,sec))+sum(fosfuels,HOUS_DEM.l(cnt,fosfuels)*CO2r(cnt,fosfuels,"HOUS")+GOVT_DEM.l(cnt,fosfuels)*CO2r(cnt,fosfuels,"GOVT")+INVB_DEM.l(cnt,fosfuels)*CO2r(cnt,fosfuels,"INV"));


demand(cnt,sec,com,step)=R_P_XD.L(cnt, sec, com);
demand(cnt,"HOUS",com,step)=HOUS_DEM.L(cnt,com);
demand(cnt,"GOVT",com,step)=GOVT_DEM.L(cnt,com);
demand(cnt,"INVB",com,step)=INVB_DEM.L(cnt,com);
demand(cnt,"Exports",com,step)=REP_EXPout.l(cnt,com)+REP_EXPoutN.l(cnt,com)+REP_EXP_EU.L(cnt, com)+REP_EXP_EUN.L(cnt, com);
demand(cnt,"stocks",com,step)=max(0,SVZ(cnt,com)*R_SV.L(cnt,com));

cdem(cnt,com,step)=sum(sec,demand(cnt,sec,com,step))+demand(cnt,"HOUS",com,step)+demand(cnt,"GOVT",com,step)+demand(cnt,"INVB",com,step)+demand(cnt,"Exports",com,step)+demand(cnt,"stocks",com,step);


*===== SOCIAL ACCOUNTING MATRIX OUTPUT ======
SAMout(cnt,com,sec,step)=REP_SEC_IN.L(cnt,sec,com)*P.L(cnt, com)/PU.l(cnt)*(1+taxc(cnt,com));
SAMout(cnt,sec,com,step)$(XDDZ(cnt,sec,com))=REP_SEC_OUT.L(cnt, sec, com)*PD.L(cnt, sec, com)/PU.l(cnt);
SAMout(cnt,"i-H2S","gH2",step)=REP_SEC_OUT.L(cnt, "i-H2S","gH2")*PD.L(cnt, "i-H2S","gH2")/PU.l(cnt);
SAMout(cnt,"i-H2CCS","gH2",step)=REP_SEC_OUT.L(cnt, "i-H2CCS","gH2")*PD.L(cnt, "i-H2CCS","gH2")/PU.l(cnt);
SAMout(cnt,"i-H2E","gH2",step)=REP_SEC_OUT.L(cnt, "i-H2E","gH2")*PD.L(cnt, "i-H2E","gH2")/PU.l(cnt);
SAMout(cnt,"i-PCCS",com,step)=REP_SEC_OUT.L(cnt, "i-PCCS",com)*PD.L(cnt, "i-PCCS",com)/PU.l(cnt);
SAMout(cnt,"Capital",sec,step)=REP_Capital.L(cnt, sec)*RKC.L(cnt)/PU.l(cnt)+POG.L(cnt)*AOGR(cnt)$(sameas(sec,"i-COIL"))/PU.L(cnt)+PCL.L(cnt)*ACR(cnt)$(sameas(sec,"i-COAL"))/PU.L(cnt)+PNG.L(cnt)*ANGR(cnt)$(sameas(sec,"i-NG"))/PU.L(cnt);
SAMout(cnt,"Labour",sec,step)=REP_Labour.L(cnt, sec)*PL.L(cnt)/PU.l(cnt);
SAMout(cnt,"tax_sec",sec,step)=taxp(cnt,sec)*sum(com,REP_SEC_OUT.L(cnt, sec, com)*PD.L(cnt, sec, com)/PU.l(cnt));
SAMout(cnt,com,"HOUS",step)=HOUS_DEM.l(cnt,com)*P.l(cnt,com)/PU.l(cnt)*(1+taxc(cnt,com));
SAMout(cnt,com,"GOVT",step)=GOVT_DEM.l(cnt,com)*P.l(cnt,com)/PU.l(cnt)*(1+taxc(cnt,com));
SAMout(cnt,com,"INV",step)=INVB_DEM.l(cnt,com)*P.l(cnt,com)/PU.l(cnt)*(1+taxc(cnt,com));
SAMout(cnt,com,"STOCKS",step)=P.l(cnt,com)/PU.l(cnt)*SVZ(cnt,com)*gdp_p(cnt)*X.l(cnt,com);
SAMout(cnt,"HOUS","Capital",step)=RKC.L(cnt)/PU.l(cnt)*KSZ(cnt)*(1-ty(cnt))+POG.L(cnt)*AOGR(cnt)/PU.L(cnt)+PCL.L(cnt)*ACR(cnt)/PU.L(cnt)+PNG.L(cnt)*ANGR(cnt)/PU.L(cnt);
SAMout(cnt,"GOVT","Capital",step)=-RKC.L(cnt)/PU.l(cnt)*sum(sec,pathway_total(cnt, sec))*gdp_p(cnt);
SAMout(cnt,"HOUS","Labour",step)=sum(sec,REP_Labour.L(cnt, sec)*PL.L(cnt)/PU.l(cnt));
SAMout(cnt,"INV","HOUS",step)=SHZ(cnt)*gdp_p(cnt)*PS.L(cnt)/PU.l(cnt)*R_SH.L(cnt);
SAMout(cnt,"HOUS","trade",step)=max(0, (TRHROWZ(cnt)*gdp_p(cnt))*ERext.L/PU.l(cnt));
SAMout(cnt,"trade","HOUS",step)=max(0,-(TRHROWZ(cnt)*gdp_p(cnt))*ERext.L/PU.l(cnt));
SAMout(cnt,"GOVT","tax_sec",step)=sum(sec,taxp(cnt,sec)*sum(com,REP_SEC_OUT.L(cnt, sec, com)*PD.L(cnt, sec, com)/PU.l(cnt)));
SAMout(cnt,"GOVT","tax_com",step)=sum(com,sum(sec,REP_SEC_IN.L(cnt,sec,com))*P.L(cnt, com)/PU.l(cnt)*taxc(cnt,com)+(HOUS_DEM.l(cnt,com)+GOVT_DEM.l(cnt,com)+INVB_DEM.l(cnt,com))*P.l(cnt,com)/PU.l(cnt)*taxc(cnt,com));
SAMout(cnt,"tax_sec",sec,step)=taxp(cnt,sec)*sum(com,REP_SEC_OUT.L(cnt, sec, com)*PD.L(cnt, sec, com)/PU.l(cnt));
SAMout(cnt,"tax_com",com,step)=sum(sec,REP_SEC_IN.L(cnt,sec,com))*P.L(cnt, com)/PU.l(cnt)*taxc(cnt,com)+(HOUS_DEM.l(cnt,com)+GOVT_DEM.l(cnt,com)+INVB_DEM.l(cnt,com))*P.l(cnt,com)/PU.l(cnt)*taxc(cnt,com);
SAMout(cnt,"STOCKS","INV",step)=sum(com,P.l(cnt,com)/PU.l(cnt)*SVZ(cnt,com)*gdp_p(cnt)*X.l(cnt,com));
SAMout(cnt,com,"tmarg",step)= P.l(cnt,com)/PU.l(cnt)*TMout.L(com,cnt);
SAMout(cnt,"tmarg",com,step)= sum(cntt,PTM.L(cnt,cntt)/PU.l(cnt)*TMin.L(com,cnt,cntt)) ;
SAMout(cnt,com,"trade",step)= ERext.L/PU.l(cnt)*(REP_EXPout.l(cnt,com)+REP_EXPoutN.l(cnt,com))+ERint.L/PU.l(cnt)*(REP_EXP_EU.l(cnt,com)+REP_EXP_EUN.l(cnt,com));
SAMout(cnt,"trade",com,step)=ERext.L/PU.l(cnt)*REP_IMPout.L(cnt, com)+ ERint.L/PU.l(cnt)*REP_IMP_EU.L(cnt,com);
SAMout(cnt,"GOVT","trade",step)= ERext.L/PU.l(cnt)*TRROWZ(cnt)*gdp_p(cnt);
SAMout(cnt,"CO2allow",sec,step)=PCO2.L(cnt)/PU.l(cnt)*sum(fosfuels,CO2r(cnt,fosfuels,sec)*REP_SEC_IN.L(cnt, sec, fosfuels));
SAMout(cnt,"CO2allow","HOUS",step)=PCO2.L(cnt)/PU.l(cnt)*sum(fosfuels,CO2r(cnt,fosfuels,"HOUS")*HOUS_DEM.L(cnt,fosfuels));
SAMout(cnt,"CO2allow","GOVT",step)=PCO2.L(cnt)/PU.l(cnt)*sum(fosfuels,CO2r(cnt,fosfuels,"GOVT")*GOVT_DEM.L(cnt,fosfuels));
SAMout(cnt,"CO2allow","INV",step) =PCO2.L(cnt)/PU.l(cnt)*sum(fosfuels,CO2r(cnt,fosfuels,"INV")*INVB_DEM.L(cnt,fosfuels));
SAMout(cnt,"GOVT","CO2allow",step)=PCO2.L(cnt)/PU.l(cnt)*sum(fosfuels,sum(sec,CO2r(cnt,fosfuels,sec)*REP_SEC_IN.L(cnt, sec, fosfuels))+CO2r(cnt,fosfuels,"HOUS")*HOUS_DEM.L(cnt,fosfuels)+CO2r(cnt,fosfuels,"GOVT")*GOVT_DEM.L(cnt,fosfuels)+CO2r(cnt,fosfuels,"INV")*INVB_DEM.L(cnt,fosfuels));

IOanalysis('input',cnt,sec,com,step)$(ord(step)>1)=SAMout(cnt,com,sec,step);
IOanalysis('input',cnt,sec,"Labour",step)$(ord(step)>1)=SAMout(cnt,"Labour",sec,step);
IOanalysis('input',cnt,sec,"Capital",step)$(ord(step)>1)=SAMout(cnt,"Capital",sec,step);
IOanalysis('input',cnt,sec,"tax_sec",step)$(ord(step)>1)=SAMout(cnt,"tax_sec",sec,step);
IOanalysis('input',cnt,"demand",com,step)$(ord(step)>1)=SAMout(cnt,com,"HOUS",step)+SAMout(cnt,com,"GOVT",step)+SAMout(cnt,com,"INV",step);
IOanalysis('input',cnt,"demand","CO2allow",step)$(ord(step)>1)=PCO2.l(cnt)/PU.l(cnt)*(CO2H_dem.l(cnt)+CO2G_dem.l(cnt)+CO2I_dem.l(cnt));
IOanalysis('input',cnt,"stocks",com,step)$(ord(step)>1)=SAMout(cnt,com,"STOCKS",step);
IOanalysis('input',cnt,"tmarg",com,step)$(ord(step)>1)=SAMout(cnt,com,"tmarg",step);
IOanalysis('input',cnt,"exportsROW",com,step)$(ord(step)>1)=SAMout(cnt,com,"trade",step);

IOanalysis('input',cnt,sec,"CO2allow",step)$(ord(step)>1)=PCO2.l(cnt)/PU.l(cnt)*CO2S_dem.l(cnt,sec);

IOanalysis('output',cnt,sec,com,step)$(ord(step)>1)=SAMout(cnt,sec,com,step);
IOanalysis('output',cnt,"tax_com",com,step)$(ord(step)>1)=SAMout(cnt,"tax_com",com,step);
IOanalysis('output',cnt,"tmarg",com,step)$(ord(step)>1)=SAMout(cnt,"tmarg",com,step);
IOanalysis('output',cnt,"importsROW",com,step)$(ord(step)>1)=SAMout(cnt,"trade",com,step);


VA(cnt,sec,step)=SAMout(cnt,"Capital",sec,step)+SAMout(cnt,"Labour",sec,step)+SAMout(cnt,"tax_sec",sec,step)+SAMout(cnt,sec,"CO2allow",step);
GDPout(cnt,step)=sum(sec,VA(cnt,sec,step));


Quantity(cnt,com,sec,step)=REP_SEC_IN.L(cnt,sec,com);
Quantity(cnt,sec,com,step)$(XDDZ(cnt,sec,com))=REP_SEC_OUT.L(cnt, sec, com);
Quantity(cnt,"i-H2S","gH2",step)=REP_SEC_OUT.L(cnt, "i-H2S","gH2");
Quantity(cnt,"i-H2CCS","gH2",step)=REP_SEC_OUT.L(cnt, "i-H2CCS","gH2");
Quantity(cnt,"i-H2E","gH2",step)=REP_SEC_OUT.L(cnt, "i-H2E","gH2");
Quantity(cnt,"i-PCCS",com,step)=REP_SEC_OUT.L(cnt, "i-PCCS",com);
Quantity(cnt,"Capital",sec,step)=REP_Capital.L(cnt, sec)+AOGR(cnt)$(sameas(sec,"i-COIL"))+ACR(cnt)$(sameas(sec,"i-COAL"))+ANGR(cnt)$(sameas(sec,"i-NG"));
Quantity(cnt,"Labour",sec,step)=REP_Labour.L(cnt, sec);
Quantity(cnt,com,"HOUS",step)=HOUS_DEM.l(cnt,com);
Quantity(cnt,com,"GOVT",step)=GOVT_DEM.l(cnt,com);
Quantity(cnt,com,"INV",step)=INVB_DEM.l(cnt,com);
Quantity(cnt,com,"STOCKS",step)=SVZ(cnt,com)*gdp_p(cnt)*X.l(cnt,com);
Quantity(cnt,"HOUS","Capital",step)=KSZ(cnt)*(1-ty(cnt))+AOGR(cnt)+ACR(cnt)+ANGR(cnt);
Quantity(cnt,"GOVT","Capital",step)=-sum(sec,pathway_total(cnt, sec))*gdp_p(cnt);
Quantity(cnt,"HOUS","Labour",step)=sum(sec,REP_Labour.L(cnt, sec));
Quantity(cnt,"INV","HOUS",step)=SHZ(cnt)*gdp_p(cnt)*R_SH.L(cnt);
Quantity(cnt,"HOUS","trade",step)=max(0, (TRHROWZ(cnt)*gdp_p(cnt)));
Quantity(cnt,"trade","HOUS",step)=max(0,-(TRHROWZ(cnt)*gdp_p(cnt)));
Quantity(cnt,"STOCKS","INV",step)=sum(com,SVZ(cnt,com)*gdp_p(cnt)*X.l(cnt,com));
Quantity(cnt,com,"tmarg",step)= TMout.L(com,cnt);
Quantity(cnt,"tmarg",com,step)= sum(cntt,TMin.L(com,cnt,cntt)) ;
Quantity(cnt,com,"trade",step)= REP_EXPout.l(cnt,com)+REP_EXPoutN.l(cnt,com)+REP_EXP_EU.l(cnt,com)+REP_EXP_EUN.l(cnt,com);
Quantity(cnt,"trade",com,step)=REP_IMPout.L(cnt, com)+ REP_IMP_EU.L(cnt,com);
Quantity(cnt,"GOVT","trade",step)=TRROWZ(cnt)*gdp_p(cnt);
Quantity(cnt,"CO2allow",sec,step)=sum(fosfuels,CO2r(cnt,fosfuels,sec)*REP_SEC_IN.L(cnt, sec, fosfuels));
Quantity(cnt,"CO2allow","HOUS",step)=sum(fosfuels,CO2r(cnt,fosfuels,"HOUS")*HOUS_DEM.L(cnt,fosfuels));
Quantity(cnt,"CO2allow","GOVT",step)=sum(fosfuels,CO2r(cnt,fosfuels,"GOVT")*GOVT_DEM.L(cnt,fosfuels));
Quantity(cnt,"CO2allow","INV",step) =sum(fosfuels,CO2r(cnt,fosfuels,"INV")*INVB_DEM.L(cnt,fosfuels));
Quantity(cnt,"GOVT","CO2allow",step)=sum(fosfuels,sum(sec,CO2r(cnt,fosfuels,sec)*REP_SEC_IN.L(cnt, sec, fosfuels))+CO2r(cnt,fosfuels,"HOUS")*HOUS_DEM.L(cnt,fosfuels)+CO2r(cnt,fosfuels,"GOVT")*GOVT_DEM.L(cnt,fosfuels)+CO2r(cnt,fosfuels,"INV")*INVB_DEM.L(cnt,fosfuels));


*$ontext
QQQ(cnt,com,sec,step)$SAM(cnt,com,sec)=REP_SEC_IN.L(cnt,sec,com)/SAM(cnt,com,sec)-1;
QQQ(cnt,sec,com,step)$SAM(cnt,sec,com)=REP_SEC_OUT.L(cnt, sec, com)/SAM(cnt,sec,com)-1;
*QQQ(cnt,"Capital",sec,step)$SAM(cnt,"Capital",sec)=REP_Capital.L(cnt, sec)/SAM(cnt,"Capital",sec)-1;
QQQ(cnt,"Capital",sec,step)$SAM(cnt,"Capital",sec)=(REP_Capital.L(cnt, sec)+AOGR(cnt)$(sameas(sec,"i-COIL"))+ACR(cnt)$(sameas(sec,"i-COAL"))+ANGR(cnt)$(sameas(sec,"i-NG")))/SAM(cnt,"Capital",sec)-1;
QQQ(cnt,"Labour",sec,step)$SAM(cnt,"Labour",sec)=REP_Labour.L(cnt, sec)/SAM(cnt,"Labour",sec)-1;
QQQ(cnt,"tax_sec",sec,step)$SAM(cnt,"tax_sec",sec)=sum(com,REP_SEC_OUT.L(cnt, sec, com)*PD.L(cnt, sec, com))/SAM(cnt,"tax_sec",sec)-1;
QQQ(cnt,com,"HOUS",step)$SAM(cnt,com,"HOUS")=HOUS_DEM.l(cnt,com)/SAM(cnt,com,"HOUS")-1;
QQQ(cnt,com,"GOVT",step)$SAM(cnt,com,"GOVT")=GOVT_DEM.l(cnt,com)/SAM(cnt,com,"GOVT")-1;
QQQ(cnt,com,"INV",step)$SAM(cnt,com,"INV")=INVB_DEM.l(cnt,com)/SAM(cnt,com,"INV")-1;
QQQ(cnt,com,"STOCKS",step)$SAM(cnt,com,"STOCKS")=SVZ(cnt,com)*gdp_p(cnt)*X.l(cnt,com)/SAM(cnt,com,"STOCKS")-1;
QQQ(cnt,"HOUS","Capital",step)$SAM(cnt,"HOUS","Capital")=KSZ(cnt)*(1-ty(cnt))/SAM(cnt,"HOUS","Capital")-1;
QQQ(cnt,"GOVT","Capital",step)$SAM(cnt,"GOVT","Capital")=-sum(sec,pathway_total(cnt, sec))*gdp_p(cnt)/SAM(cnt,"GOVT","Capital")-1;
QQQ(cnt,"HOUS","Labour",step)$SAM(cnt,"HOUS","Labour")=sum(sec,REP_Labour.L(cnt, sec))/SAM(cnt,"HOUS","Labour")-1;
QQQ(cnt,"INV","HOUS",step)$SAM(cnt,"INV","HOUS")=SHZ(cnt)*gdp_p(cnt)*R_SH.L(cnt)/SAM(cnt,"INV","HOUS")-1;
QQQ(cnt,"HOUS","trade",step)$SAM(cnt,"HOUS","trade")=max(0, (TRHROWZ(cnt)*gdp_p(cnt)))/SAM(cnt,"HOUS","trade")-1;
QQQ(cnt,"trade","HOUS",step)$SAM(cnt,"trade","HOUS")=max(0,-(TRHROWZ(cnt)*gdp_p(cnt)))/SAM(cnt,"trade","HOUS")-1;
QQQ(cnt,"GOVT","tax_sec",step)=0;
QQQ(cnt,"GOVT","tax_com",step)=0;
QQQ(cnt,"tax_sec",sec,step)$SAM(cnt,"tax_sec",sec)=sum(com,REP_SEC_OUT.L(cnt, sec, com)*PD.L(cnt, sec, com))/SAM(cnt,"tax_sec",sec)-1;
QQQ(cnt,"tax_com",com,step)$SAM(cnt,"tax_com",com)=(sum(sec,REP_SEC_IN.L(cnt,sec,com))*P.L(cnt, com)+(HOUS_DEM.l(cnt,com)+GOVT_DEM.l(cnt,com)+INVB_DEM.l(cnt,com))*P.l(cnt,com))/SAM(cnt,"tax_com",com)-1;
QQQ(cnt,"STOCKS","INV",step)=0;
QQQ(cnt,com,"tmarg",step)$SAM(cnt,com,"tmarg")= TMout.L(com,cnt)/SAM(cnt,com,"tmarg")-1;
QQQ(cnt,"tmarg",com,step)= 0;
QQQ(cnt,com,"trade",step)$SAM(cnt,com,"trade")=(REP_EXPout.l(cnt,com)+REP_EXPoutN.l(cnt,com)+REP_EXP_EU.l(cnt,com)+REP_EXP_EUN.l(cnt,com))/SAM(cnt,com,"trade")-1;

QQQ(cnt,"trade",com,step)$SAM(cnt,"trade",com)=(REP_IMPout.L(cnt, com)+ REP_IMP_EU.L(cnt,com))/SAM(cnt,"trade",com)-1;
QQQ(cnt,"GOVT","trade",step)$SAM(cnt,"GOVT","trade")=TRROWZ(cnt)*gdp_p(cnt)/SAM(cnt,"GOVT","trade")-1;
QQQ(cnt,"CO2allow",sec,step)=sum(fosfuels,CO2r(cnt,fosfuels,sec)*REP_SEC_IN.L(cnt, sec, fosfuels));
QQQ(cnt,"CO2allow","HOUS",step)=sum(fosfuels,CO2r(cnt,fosfuels,"HOUS")*HOUS_DEM.L(cnt,fosfuels));
QQQ(cnt,"CO2allow","GOVT",step)=sum(fosfuels,CO2r(cnt,fosfuels,"GOVT")*GOVT_DEM.L(cnt,fosfuels));
QQQ(cnt,"CO2allow","INV",step) =sum(fosfuels,CO2r(cnt,fosfuels,"INV")*INVB_DEM.L(cnt,fosfuels));
QQQ(cnt,"GOVT","CO2allow",step)=sum(fosfuels,sum(sec,CO2r(cnt,fosfuels,sec)*REP_SEC_IN.L(cnt, sec, fosfuels))+CO2r(cnt,fosfuels,"HOUS")*HOUS_DEM.L(cnt,fosfuels)+CO2r(cnt,fosfuels,"GOVT")*GOVT_DEM.L(cnt,fosfuels)+CO2r(cnt,fosfuels,"INV")*INVB_DEM.L(cnt,fosfuels));


PPP(cnt,com,sec,step)=P.L(cnt, com)/PU.l(cnt)*(1+taxc(cnt,com));
PPP(cnt,sec,com,step)$(XDDZ(cnt,sec,com))=PD.L(cnt, sec, com)/PU.l(cnt);
*PPP(cnt,"Capital",sec,step)=RKC.L(cnt)/PU.l(cnt);
* capital might contain specific capital for some sectors. Then we consider an average price for general and specific capital for those sectors.
*                               (TotalValue/Q)/CPI)
PPP(cnt,"Capital",sec,step)$SAM(cnt,"Capital",sec)=SAMout(cnt,"Capital",sec,step)/(REP_Capital.L(cnt, sec)+AOGR(cnt)$(sameas(sec,"i-COIL"))+ACR(cnt)$(sameas(sec,"i-COAL"))+ANGR(cnt)$(sameas(sec,"i-NG")));
PPP(cnt,"Labour",sec,step)=PL.L(cnt)/PU.l(cnt);
PPP(cnt,"tax_sec",sec,step)=taxp(cnt,sec);
PPP(cnt,com,"HOUS",step)=P.l(cnt,com)/PU.l(cnt)*(1+taxc(cnt,com));
PPP(cnt,com,"GOVT",step)=P.l(cnt,com)/PU.l(cnt)*(1+taxc(cnt,com));
PPP(cnt,com,"INV",step)=P.l(cnt,com)/PU.l(cnt)*(1+taxc(cnt,com));
PPP(cnt,com,"STOCKS",step)=P.l(cnt,com)/PU.l(cnt);
PPP(cnt,"HOUS","Capital",step)=RKC.L(cnt)/PU.l(cnt);
PPP(cnt,"GOVT","Capital",step)=RKC.L(cnt)/PU.l(cnt);
PPP(cnt,"HOUS","Labour",step)=PL.L(cnt)/PU.l(cnt);
PPP(cnt,"INV","HOUS",step)=PS.L(cnt)/PU.l(cnt);
PPP(cnt,"HOUS","trade",step)=ERext.L/PU.l(cnt);
PPP(cnt,"trade","HOUS",step)=ERext.L/PU.l(cnt);
PPP(cnt,"GOVT","tax_sec",step)=sum(sec,taxp(cnt,sec)*sum(com,REP_SEC_OUT.L(cnt, sec, com)*PD.L(cnt, sec, com)/PU.l(cnt)));
PPP(cnt,"GOVT","tax_com",step)=sum(com,sum(sec,REP_SEC_IN.L(cnt,sec,com))*P.L(cnt, com)/PU.l(cnt)*taxc(cnt,com)+(HOUS_DEM.l(cnt,com)+GOVT_DEM.l(cnt,com)+INVB_DEM.l(cnt,com))*P.l(cnt,com)/PU.l(cnt)*taxc(cnt,com));
PPP(cnt,"tax_sec",sec,step)=taxp(cnt,sec);
PPP(cnt,"tax_com",com,step)=taxc(cnt,com);
PPP(cnt,"STOCKS","INV",step)=sum(com,P.l(cnt,com)/PU.l(cnt)*SVZ(cnt,com)*gdp_p(cnt)*X.l(cnt,com));
PPP(cnt,com,"tmarg",step)= P.l(cnt,com)/PU.l(cnt);
PPP(cnt,"tmarg",com,step)= sum(cntt,PTM.L(cnt,cntt)/PU.l(cnt)*TMin.L(com,cnt,cntt));
PPP(cnt,com,"trade",step)= ERext.L/PU.l(cnt);
PPP(cnt,"trade",com,step)=ERext.L/PU.l(cnt);
PPP(cnt,"GOVT","trade",step)=ERext.L/PU.l(cnt);
PPP(cnt,"CO2allow",sec,step)=PCO2.L(cnt)/PU.l(cnt);
PPP(cnt,"CO2allow","HOUS",step)=PCO2.L(cnt)/PU.l(cnt);
PPP(cnt,"CO2allow","GOVT",step)=PCO2.L(cnt)/PU.l(cnt);
PPP(cnt,"CO2allow","INV",step) =PCO2.L(cnt)/PU.l(cnt);
PPP(cnt,"GOVT","CO2allow",step)=PCO2.L(cnt)/PU.l(cnt);

* Price of fossil fuels
FuelPrice(cnt,fosfuels,step)=P.l(cnt,fosfuels)/PU.l(cnt);

* monetary value of the CO2 budget.
MCO2B(cnt,step)=PCO2.L(cnt)*CO2B(cnt);

display SHZ,gdp,PS.L,R_SH.L;

Capital(cnt,step)=Kap(cnt);
Investments(cnt,step)=II.l(cnt)*5;
* report gdp in percentage
gdptest(cnt,step)=sum(sec,VA(cnt,sec,step))/sum(sec,VA(cnt,sec,"1"));
* ================= Recoursive Capital Adjustment ==============================
* We multiply investments by 5 because even if all the projection parameters are for 5
* years the data is always based on yearly values. Therefore by projecting the closure
* parameters 5 years ahead we would get the YEARLY SAM after 5 years.
* But we need the cumulated effects of 5 years of investments. That is why we multiply
* the investments by 5.
Kap(cnt)=(Kap(cnt)*(1-depr(cnt))+II.l(cnt)*5);
KSZ(cnt)=Kap(cnt)*ror(cnt);
* update natural resources extraction (this could be used in a counterfactual)
* period 4 is 2020
if (ord(step) le 4,

* if reference case everything grows following "grow" besides Rp (productivity of renewables)
Rp(cnt)$(P_S eq 1)=1;
AOGR(cnt)$(P_S eq 1)=AOGR(cnt)*(1+grow(cnt));
ACR(cnt)$(P_S eq 1)=ACR(cnt)*(1+grow(cnt));
ANGR(cnt)$(P_S eq 1)=ANGR(cnt)*(1+grow(cnt));

* Renewable power productivity grows in the first four periods
Rp(cnt)$(P_S gt 1)=Rp(cnt)+prdR;
AOGR(cnt)$(P_S gt 1)=AOGR(cnt)*(1+grow(cnt));
ACR(cnt)$(P_S gt 1)=ACR(cnt)*(1+grow(cnt));
ANGR(cnt)$(P_S gt 1)=ANGR(cnt)*(1+grow(cnt));

else
* ================ CPD - COUNTERFACTUAL POLICY DEFINITION =====================
* Counterfactual point 7

* Renewable power productivity grows
* if reference case everything grows following "grow"
Rp(cnt)$(P_S eq 1)=1;
AOGR(cnt)$(P_S eq 1)=AOGR(cnt)*(1+grow(cnt));
ACR(cnt)$(P_S eq 1)=ACR(cnt)*(1+grow(cnt));
ANGR(cnt)$(P_S eq 1)=ANGR(cnt)*(1+grow(cnt));

* increase in productivity for power sector
Rp(cnt)$(P_S gt 1)=Rp(cnt)+prdR;
* all the countries cut their fossil extractions
AOGR(cnt)$(inVis(cnt) eq 0 and P_S gt 1 and CUT eq 1)=AOGR(cnt)*rescut;
ACR(cnt)$(inVis(cnt) eq 0 and P_S gt 1 and CUT eq 1)=ACR(cnt)*rescut;
ANGR(cnt)$(inVis(cnt) eq 0 and P_S gt  1 and CUT eq 1)=ANGR(cnt)*rescut;

AOGR(cnt)$(inVis(cnt) eq 0 and P_S gt 1 and CUT eq 0)=AOGR(cnt)*(1+grow(cnt));
ACR(cnt)$(inVis(cnt) eq 0 and P_S gt 1 and CUT eq 0)=ACR(cnt)*(1+grow(cnt));
ANGR(cnt)$(inVis(cnt) eq 0 and P_S gt  1 and CUT eq 0)=ANGR(cnt)*(1+grow(cnt));

* if there is cooperation, the Visegrad countries will cut their fossil extractions
AOGR(visegrad)$(coop=1 and P_S gt 1 and CUT eq 1)=AOGR(visegrad)*rescut;
ACR(visegrad)$(coop=1 and P_S gt 1 and CUT eq 1)=ACR(visegrad)*rescut;
ANGR(visegrad)$(coop=1 and P_S gt 1 and CUT eq 1)=ANGR(visegrad)*rescut;

AOGR(visegrad)$(coop=1 and P_S gt 1 and CUT eq 0)=AOGR(visegrad)*(1+grow(visegrad));
ACR(visegrad)$(coop=1 and P_S gt 1 and CUT eq 0)=ACR(visegrad)*(1+grow(visegrad));
ANGR(visegrad)$(coop=1 and P_S gt 1 and CUT eq 0)=ANGR(visegrad)*(1+grow(visegrad));

* if there is no cooperation, the visegrad countries will keep increasing their fossil resources
AOGR(visegrad)$(coop=0 and P_S gt 1)=AOGR(visegrad)*(1+grow(visegrad));
ACR(visegrad)$(coop=0 and P_S gt 1)=ACR(visegrad)*(1+grow(visegrad));
ANGR(visegrad)$(coop=0 and P_S gt 1)=ANGR(visegrad)*(1+grow(visegrad));


* =============================================================================
);
* close the main loop
outLab(cnt,sec,step)=REP_Labour.L(cnt,sec);
outAct(cnt,sec,step)=XD.L(cnt,sec);
outPrice(cnt,com,step)=P.L(cnt,com);
);

*execute_unload "B_adj" t_adj, pathway_adj, pathway_unadj_total, pathway_adj_total, pathway_total, pathway_adj_cap, KZ,IOZ,temp,newshare,newsharet,NRS;

*$exit

parameter EneDemM(cnt,step) monetary energy expenditure;
EneDemM(cnt,step)=ElPrice(cnt,step)*(sum(sec,EneDem(cnt,sec,step))+EneDem(cnt,"CONS",step));

EneDem(cnt,sec,step)$(EneDem(cnt,sec,"2"))=EneDem(cnt,sec,step)/EneDem(cnt,sec,"2");
EneDem(cnt,"CONS",step)$EneDem(cnt,"CONS","2")=EneDem(cnt,"CONS",step)/EneDem(cnt,"CONS","2");
EneDemTot(cnt,step)=EneDemTot(cnt,step)/EneDemTot(cnt,"2");
ElPrice(cnt,step)$(ElPrice(cnt,"2"))=ElPrice(cnt,step)/ElPrice(cnt,"2");

parameter EneDemP(cnt,*,step),EneDemTotP(cnt,step),ElPriceP(cnt,step);
EneDemP(cnt,sec,step)$(EneDem(cnt,sec,"2"))=(EneDem(cnt,sec,step)-1)*100;
EneDemP(cnt,"CONS",step)$(EneDem(cnt,"CONS","2"))=(EneDem(cnt,"CONS",step)-1)*100;
EneDemTotP(cnt,step)$(EneDemTot(cnt,"2"))=(EneDemTot(cnt,step)-1)*100;
ElPriceP(cnt,step)$(ElPrice(cnt,"2"))=(ElPrice(cnt,step)-1)*100;

DISPLAY PL.L, LS.L, LSZ;


*=====================Report any variables desired ============

* Normalize CO2 price to second period (2012)
PriceCO2(step)=PriceCO2(step)/PriceCO2("2");
ElPrice(cnt,step)=ElPrice(cnt,step)/ElPrice(cnt,"2");
demand(cnt,sec,com,step)$(demand(cnt,sec,com,"2") and not sameas('i-H2S',sec) and not sameas('i-H2CCS',sec) and not sameas('i-H2E',sec) and not sameas('i-PCCS',sec))=demand(cnt,sec,com,step)/demand(cnt,sec,com,"2");
demand(cnt,'i-H2S',com,step)=demand(cnt,'i-H2S',com,step);
demand(cnt,'i-H2CCS',com,step)=demand(cnt,'i-H2CCS',com,step);
demand(cnt,'i-H2E',com,step)=demand(cnt,'i-H2E',com,step);
demand(cnt,'i-PCCS',com,step)=demand(cnt,'i-PCCS',com,step);
demand(cnt,"HOUS",com,step)$demand(cnt,"HOUS",com,"2")=demand(cnt,"HOUS",com,step)/demand(cnt,"HOUS",com,"2");
demand(cnt,"GOVT",com,step)$demand(cnt,"GOVT",com,"2")=demand(cnt,"GOVT",com,step)/demand(cnt,"GOVT",com,"2");
demand(cnt,"INVB",com,step)$demand(cnt,"INVB",com,"2")=demand(cnt,"INVB",com,step)/demand(cnt,"INVB",com,"2");
demand(cnt,"Exports",com,step)$demand(cnt,"Exports",com,"2")=demand(cnt,"Exports",com,step)/demand(cnt,"Exports",com,"2");
demand(cnt,"stocks",com,step)$demand(cnt,"stocks",com,"2")=demand(cnt,"stocks",com,step)/demand(cnt,"stocks",com,"2");

* percentage change from period 2
*cdem(cnt,com,step)$(cdem(cnt,com,"2"))=cdem(cnt,com,step)/cdem(cnt,com,"2");

Parameter SectorGrowth(cnt,sec,step);
SectorGrowth(cnt,sec,"1")$(sum(com,SAM(cnt,sec,com)))=sum(com,SAMout(cnt,sec,com,"1"))/sum(com,SAM(cnt,sec,com))-1;
SectorGrowth(cnt,sec,step)$(ord(step) gt 1 and sum(com,SAMout(cnt,sec,com,step-1)) gt 0 and ord(step) le STEPS and sum(com,SAM(cnt,sec,com)))=sum(com,SAMout(cnt,sec,com,step))/sum(com,SAMout(cnt,sec,com,step-1))-1;

GDPout(cnt,step)=GDPout(cnt,step);


*execute_unload "REMES2GeneSys.gdx" EneDem,demand,PriceCO2,FuelPrice,SectorGrowth,EneDemTWh;

*display R_GDP, R_P_OIL;
parameter changeTech(cnt,com,sec);
changeTech(cnt,com,sec)=R_P_XD.L(cnt, sec, com)/IOZ(cnt,com,sec);

*execute_unload "checkXDDZ", XDDZ,REP_SEC_OUT.l;


display IZ;
*execute_unload "Results_.gdx" UNEMPLOYMENT,IOanalysis,Pco2.l,EneDem,ElPrice,PriceCO2,FFdem,EEdem,demand,cdem,SAM,SAMout,QQQ,PPP,Quantity,VA,gdp,GDPout,GDPtest,PU.l;
*execute_unload "Sectoral_structure.gdx" XDDZ, taxpz, IOZ, Pathway_adj, taxcz, LZ, Pathway_adj_cap, KZ, pathway_total, INVZ;

*execute_unload "counterfactuals.gdx" Pathway_adj,Pathway_adj_cap, KZ, Pathway_total,tfp,AOGR,OGR,ACR,CR,ANGR,NGR,ALR,LR,KSZ,KSZ0,growth_p,LSZ0,CO2B;

parameter price(cnt,com,sec);
price(cnt,com,sec)=(IOZ(cnt,com,sec)*(1+taxcz(cnt,com)));
display price;


parameter testCO(cnt,com,sec);
testCO(cnt,com,sec)=0;
testCO(cnt,com,sec)$(PID(com) = 1 and CO2P(cnt,com,sec) and FF(com)=1 and CO2B(cnt))=1

$include "balances.gms"

*execute_unload "capital&invest.gdx" Kap, Capital, Investments, II.l;



*################# OUTPUT IN IIASA FORMAT ######################

parameter initalEnergy(cnt) total consumption in EJ in 2010 /
AT        1507800
BE        2772000
BG        747600
CY        77593
CZ        1797600
DE        13595400
DK        819000
EE        234965
ES        6140400
FI        1297800
FR        10634400
GR        1323000
HU        1045800
IE        638400
IT        7232400
LT        235200
LU        175020
LV        186984
MT        34797
NL        4036200
PL        4124400
PT        1075200
RO        1419600
SE        2188200
SI        309506
SK        730800
GB        8841000
CH        1205400
NO        1759800
/;



scalar meanER2010 /1.33/;
scalar kWh2Gj /0.0036/;
* https://ec.europa.eu/eurostat/statistics-explained/index.php?title=File:Half-yearly_electricity_and_gas_prices_-_including_taxes_(EUR).png
parameter elp0(cnt) electricity price in 2010 in euro per kWh
/
AT        0.18
BE        0.20
BG        0.08
CY        0.13
CZ        0.13
DE        0.24
DK        0.27
EE        0.08
ES        0.16
FI        0.16
FR        0.12
GR        0.12
HU        0.15
IE        0.18
IT        0.21
LT        0.12
LU        0.17
LV        0.08
MT        0.17
NL        0.17
PL        0.13
PT        0.16
RO        0.10
SE        0.18
SI        0.14
SK        0.15
GB        0.14
CH        0.21
NO        0.20
/;


Acronym
Austria
Belgium
Bulgaria
Cyprus
CzechRepublic
Germany
Denmark
Estonia
Spain
Finland
France
Greece
Hungary
Ireland
Italy
Lithuania
Luxembourg
Latvia
Malta
TheNetherlands
Poland
Portugal
Romania
Sweden
Slovenia
Slovakia
UnitedKingdom
Switzerland
Norway;

parameter country(cnt) /
AT Austria
BE Belgium
BG Bulgaria
CY Cyprus
CZ CzechRepublic
DE Germany
DK Denmark
EE Estonia
ES Spain
FI Finland
FR France
GR Greece
HU Hungary
IE Ireland
IT Italy
LT Lithuania
LU Luxembourg
LV Latvia
MT Malta
NL TheNetherlands
PL Poland
PT Portugal
RO Romania
SE Sweden
SI Slovenia
SK Slovakia
GB UnitedKingdom
CH Switzerland
NO Norway
/;



display country;

parameter eneConsum(cnt,step);
eneConsum(cnt,step)= initalEnergy(cnt)*EneDemTot(cnt,step);

parameter elpriceP1(cnt,step);
* el price in Gj USD2010
elp0(cnt)=elp0(cnt)/kWh2Gj*meanER2010;
ElPriceP1(cnt,step)=elp0(cnt)*(1+ElPriceP(cnt,step)/100);
*set 2020 as base year with price 0
PriceCO2(step)=PriceCO2(step)/PriceCO2("4");
* set price 30 in 2020 and convert to USD
PriceCO2(step)=PriceCO2(step)*30*meanER2010;


* Convert monetary values in Billion USD2010
GDPout(cnt,step)=GDPout(cnt, step)*meanER2010/1000;
EneDemM(cnt,step)=EneDemM(cnt,step)*meanER2010/1000;

* output for openENTRANCE platform
File remesoe2 /REMESOE2.csv/;
remesoe2.tf=0;
put remesoe2;
put 'model,scenario,region,variable,unit,subannual,2010,2015,2020,2025,2030,2035,2040,2045,2050', put /;
loop((cnt)$(not (sameas(cnt,'CZ') or sameas(cnt,'GB') or sameas(cnt,'NL'))), put 'REMES:EU 1.2,Directed Transition,', put country(cnt), put ',Consumption,billion US$2010/yr,Year',
         loop(step$(ord(step) gt 1), put',', put  EneDemM(cnt,step)) put /;);
loop((cnt)$((sameas(cnt,'CZ'))), put 'REMES:EU 1.1,Directed Transition,', put 'Czech Republic', put ',Consumption,billion US$2010/yr,Year',
         loop(step$(ord(step) gt 1), put',', put  EneDemM(cnt,step)) put /;);
loop((cnt)$((sameas(cnt,'GB'))), put 'REMES:EU 1.1,Directed Transition,', put 'United Kingdom', put ',Consumption,billion US$2010/yr,Year',
         loop(step$(ord(step) gt 1), put',', put  EneDemM(cnt,step)) put /;);
loop((cnt)$((sameas(cnt,'NL'))), put 'REMES:EU 1.1,Directed Transition,', put 'The Netherlands', put ',Consumption,billion US$2010/yr,Year',
         loop(step$(ord(step) gt 1), put',', put  EneDemM(cnt,step)) put /;);

loop((cnt)$(not (sameas(cnt,'CZ') or sameas(cnt,'GB') or sameas(cnt,'NL'))), put 'REMES:EU 1.2,Directed Transition,', put country(cnt), put ',Final Energy|Electricity,EJ/yr,Year',
         loop(step$(ord(step) gt 1), put',', put  eneConsum(cnt,step)) put /;);
loop((cnt)$((sameas(cnt,'CZ'))), put 'REMES:EU 1.1,Directed Transition,', put 'Czech Republic', put ',Final Energy|Electricity,EJ/yr,Year',
         loop(step$(ord(step) gt 1), put',', put  eneConsum(cnt,step)) put /;);
loop((cnt)$((sameas(cnt,'GB'))), put 'REMES:EU 1.1,Directed Transition,', put 'United Kingdom', put ',Final Energy|Electricity,EJ/yr,Year',
         loop(step$(ord(step) gt 1), put',', put  eneConsum(cnt,step)) put /;);
loop((cnt)$((sameas(cnt,'NL'))), put 'REMES:EU 1.1,Directed Transition,', put 'The Netherlands', put ',Final Energy|Electricity,EJ/yr,Year',
         loop(step$(ord(step) gt 1), put',', put  eneConsum(cnt,step)) put /;);

loop((cnt)$(not (sameas(cnt,'CZ') or sameas(cnt,'GB') or sameas(cnt,'NL'))), put 'REMES:EU 1.2,Directed Transition,', put country(cnt), put ',Price|Final Energy|Residential|Electricity,US$2010/GJ,Year',
         loop(step$(ord(step) gt 1), put',', put ElPriceP1(cnt,step)) put /;);
loop((cnt)$((sameas(cnt,'CZ'))), put 'REMES:EU 1.1,Directed Transition,', put 'Czech Republic', put ',Price|Final Energy|Residential|Electricity,US$2010/GJ,Year',
         loop(step$(ord(step) gt 1), put',', put  ElPriceP1(cnt,step)) put /;);
loop((cnt)$((sameas(cnt,'GB'))), put 'REMES:EU 1.1,Directed Transition,', put 'United Kingdom', put ',Price|Final Energy|Residential|Electricity,US$2010/GJ,Year',
         loop(step$(ord(step) gt 1), put',', put  ElPriceP1(cnt,step)) put /;);
loop((cnt)$((sameas(cnt,'NL'))), put 'REMES:EU 1.1,Directed Transition,', put 'The Netherlands', put ',Price|Final Energy|Residential|Electricity,US$2010/GJ,Year',
         loop(step$(ord(step) gt 1), put',', put  ElPriceP1(cnt,step)) put /;);

loop((cnt)$(not (sameas(cnt,'CZ') or sameas(cnt,'GB') or sameas(cnt,'NL'))), put 'REMES:EU 1.2,Directed Transition,', put country(cnt), put ',GDP|PPP,billion US$2010/yr,Year',
         loop(step$(ord(step) gt 1), put',', put GDPout(cnt,step)) put /;);
loop((cnt)$((sameas(cnt,'CZ'))), put 'REMES:EU 1.1,Directed Transition,', put 'Czech Republic', put ',GDP|PPP,billion US$2010/yr,Year',
         loop(step$(ord(step) gt 1), put',', put  GDPout(cnt,step)) put /;);
loop((cnt)$((sameas(cnt,'GB'))), put 'REMES:EU 1.1,Directed Transition,', put 'United Kingdom', put ',GDP|PPP,billion US$2010/yr,Year',
         loop(step$(ord(step) gt 1), put',', put  GDPout(cnt,step)) put /;);
loop((cnt)$((sameas(cnt,'NL'))), put 'REMES:EU 1.1,Directed Transition,', put 'The Netherlands', put ',GDP|PPP,billion US$2010/yr,Year',
         loop(step$(ord(step) gt 1), put',', put  GDPout(cnt,step)) put /;);

put 'REMES:EU 1.1,Directed Transition,', put 'Europe', put ',Consumption,billion US$2010/yr,Year',
loop(step$(ord(step) gt 1), put',', put sum(cnt,EneDemM(cnt,step))) put /;

put 'REMES:EU 1.1,Directed Transition,', put 'Europe', put ',Final Energy|Electricity,EJ/yr,Year',
loop(step$(ord(step) gt 1), put',', put sum(cnt,eneConsum(cnt,step))) put /;

put 'REMES:EU 1.1,Directed Transition,', put 'Europe', put ',Price|Final Energy|Residential|Electricity,US$2010/GJ,Year',
loop(step$(ord(step) gt 1), put',', put (sum(cnt,ElPriceP1(cnt,step)*eneConsum(cnt,step))/sum(cnt,eneConsum(cnt,step))) ) put /;

put 'REMES:EU 1.1,Directed Transition,', put 'Europe', put ',GDP|PPP,billion US$2010/yr,Year',
loop(step$(ord(step) gt 1), put',', put sum(cnt,GDPout(cnt,step))) put /;

put 'REMES:EU 1.1,Directed Transition,', put 'Europe', put ',Price|Carbon,US$2010/t CO2,Year',
loop(step$(ord(step) gt 1), put',', put PriceCO2(step)) put /;

putclose remesoe2;

parameter testgrow(cnt);
testgrow(cnt)=((AOGR(cnt)+ANGR(cnt))/(OGR(cnt)+NGR(cnt)));
display testgrow;

parameter apptc(cnt,com),apptp(cnt,sec),TOGR(cnt),TCR(cnt),TNGR(cnt);
apptp(cnt,sec)=taxp(cnt,sec)-taxpz(cnt,sec);
apptc(cnt,com)=taxc(cnt,com)-taxcz(cnt,com);
TOGR(cnt)=OGR(cnt)-AOGR(cnt);
TCR(cnt)=CR(cnt)-ACR(cnt);
TNGR(cnt)=NGR(cnt)-ANGR(cnt);


*execute_unload 'applied counterfactuals.gdx' PRC,apptc,apptp,pathway_adj,prdR,InputCom,TOGR,TCR,TNGR,gdp_p;

*execute_unload 'TestTNO' outAct,outLab,outPrice,gdp,gdptest;


* Final output
execute_unload "outputREMES.gdx" GDPout,VA,UNEMPLOYMENT,IOanalysis,SAM,SAMout,PPP,Quantity,PriceCO2;
