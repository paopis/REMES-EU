$Ontext
SET-Nav cases for REMES EUROPA
$Offtext

*PP 0) THE ULTIMATE GOAL OF THE CASES IS TO DEFINE A CHANGE OF THE SECTORAL STRUCTURES UNDER THE DIFFERENT PERIODS (STEPS)
* THIS IS DONE BY CREATING THE FOLLOWING PARAMETERS
* 1 - Pathway_adj ADJUST THE CONSUMPTION OF FUELS AND ELECTRICITY BY THE PRODUCTION SECTORS AND AGENTS (THE SUM OF THE REALLOCATIONS IS ZERO)
* 2 - Pathway_adj_cap ADJUSTS THE AVAILABLE CAPITAL TO THE PRODUCTION SECTORS (IT ADDS CAPITAL REQUIREMENTS IN THE SECTORS)
* 3 - Pathway_total ADJUSTS THE TOTAL CONSUMPTION BUDGET FOR THE CONSUMERS. AND IS ALSO IN THE GOVT BUDGET FOR THE SECTORS
* THE CAPITAL NEEDED TO CHANGE THE STRUCTURE OF THE SECTORS COMES FROM THE GOVERNMENT (IN THE "RKC" FIELD)
* The Government makes the investments into the sectors that need to reconfigure:
* pathway_total(cnt, sec) starts from the government (it is capital endowment) and ends up in the capital field of the sectors
* The pathway_total(cnt,sec) corresponds to the adjustments done in the input (pathway_adj(cnt,sec,com)).
* the adjustments are made depending on the pathway
* we use newshare for the Transport shock; PowGrowth### for the building shock; refdata for the Generation shock


* WHAT IS Pathway_total ... HERE ARE THE RELATIONS:
*LVL 1
* loop((cnt, adjust_sec), Pathway_total(cnt, adjust_sec) = sum(adjust_com,  pathway_adj_total(cnt, adjust_sec, adjust_com) - pathway_unadj_total(cnt, adjust_sec, adjust_com)))
* which is equivalent to
* loop((cnt, adjust_sec), Pathway_total(cnt, adjust_sec) = sum(adjust_com, Pathway_adj(cnt, adjust_sec, adjust_com)))


*LVL 2
*pathway_adj_total(cnt, sec, com) = IOZ(cnt, com, sec) + Pathway_adj(cnt, sec, com);
*pathway_adj_total(cnt, "Hous", com) = CZ(cnt, com) + Pathway_adj(cnt, "Hous", com);
*pathway_adj_total(cnt, "Govt", com) = CGLZ(cnt, com) + Pathway_adj(cnt, "Govt", com);

*LVL 3
*pathway_unadj_total(cnt, sec, com) = IOZ(cnt, com, sec);
*pathway_unadj_total(cnt, "Hous", com) = CZ(cnt, com);
*pathway_unadj_total(cnt, "Govt", com) = CGLZ(cnt, com);

* WHAT IS Pathway_adj ... HERE ARE THE RELATIONS:
* Pathway_adj(cnt, adjust_sec, com) = weight_b*B_adj(cnt, adjust_sec, com)+ weight_t*T_adj(cnt, adjust_sec, com);
* Pathway_adj(cnt, adjust_sec, "H2") =  weight_t*T_adj(cnt, adjust_sec, "H2");

*LVL 4
* ## Both T_adj and B_adj show the decrease and increase of some inputs in the structure of a sector (or consumer) ##
* The transport shock changes the structure in energy commodities of some sectors (due to the change of the transports in this sectors?)
* The buildings shock changes the structure of the composition of fossil and renewable power in the sectors (due to building efficiency?)
*T_adj=(step.val-1)/9)*newshare( cnt, sec, com, step)*temp + (1-(step.val-1)/9)*IOZ(cnt, com, sec) - IOZ(cnt,com,sec);
* T_adj TRASPORTA DA 0 A (newshare*sum(com,IOZ(cnt,com,sec)) - IOZ)
*temp = sum( com$(FID(com)>0 and FID(com)<3), IOZ(cnt,com,sec)  );
* ALL'INIZIO LA VARIAZIONE È ZERO, POI LA VARIAZIONE È LA NUOVA ALLOCAZIONE DEI PRODOTTI INTERMEDI MENO LA PRECEDENTE ALLOCAZIONE
*newshare IS DATA AND COMES FROM THE 'ASTRA' DATABASE. and it is for the TRANSPORT SHOCK
* there is a different newshare file depending on the shock and pathway chosen

*LVL 5
*B_adj = PowGrowth### (Ref, Loc, Div etc...)
* PowGrowth###=PowGrowthRefAlpha
* FOR ENERGY
* PowGrowthRefAlpha(C_POWF)=(PowDirty_HC + PowDirty_NHC)/(PowDirty_HC(Xsupertype, PSet, cnt, "1") + PowDirty_NHC(Xsupertype, PSet,  cnt, "1"))
* PowGrowthRefAlpha(C_POWR)=(PowGreen_HC + PowGreen_NHC)/(PowGreen_HC(Xsupertype, PSet, cnt, "1") + PowGreen_NHC(Xsupertype, PSet,  cnt, "1"));
* It is a growth rate...
* for FF=LTH, COAL, OIL AND BIO
* PowGrowth###=InvertEERemes("Nonresidential_public", FF, step, cnt)  / InvertEERemes("Nonresidential_public", FF, "1", cnt);

*LVL 6
* HC - household consumption; NHC - non household consumption (?)
* PowGreen_HC = sharePOW*InvertEERemes("Electricity")+ InvertEERemes("Solar Thermal") + InvertEERemes("Ambient heat");
* sharePOW is the share of electricity from renewable sources.
* PowDirty_HC=(1-sharePOW)*InvertEERemes("Electricity")
* PowGreen_NHC=(PrimeselRemes-TotalPOW_HC)*PowGreen_HC/TotalPOW_HC
* PowDirty_NHC=(PrimeselRemes-TotalPOW_HC)*PowDirty_HC/TotalPOW_HC
* NHC è quello che rimane dopo aver considerato HC, distribuito come HC (Household Consumption?)
* PrimeselRemes ARE THE PRIMES DATA ON ELECTRICITY DEMAND FOR DIFFERENT CONSUMPTION SOURCES
* InvertEERemes(t)=sum((Xtype,Xtechnology),inputBuildings(t));

* Xtype /space heating, hot water, cooling, auxiliary energy demand/
* Xtechnology /heat pumps, electric direct heaters, district heating, Fuel oil boiler or stove, Gas boiler or stove, Coal boiler or stove, biomass boiler or stove, Solar thermal collector, air conditioning/

* InvertEERemes(Xsupertype, Xfuel, step, cnt) gives the total electricity demand from different
* XSupertype /Residential, Nonresidential_private, Nonresidential_public/
* Xfuel /Electricity, district heating, fuel oil, gas, coal, biomass, ambient heat, solar thermal/

* InvertEERemes provides the electricity consumption from different consumers.
* PowGrowthRef IS THE RELATIVE POWER VARIATION FOR DIFFERENT ACTORS AND SECTORS
* IT IS ALSO FUELS CONSUMPTION VARIATION FOR ACTORS, BUT NOT FOR SECTORS (WHY?)

* WHAT IS Pathway_adj_cap ... HERE ARE THE RELATIONS:
* Pathway_adj_cap(cnt, sec)$(KZ(cnt,sec)) = KZ(cnt,sec) - pathway_total(cnt, sec)$(pathway_total(cnt, sec)<0);
* pathway_total(cnt, sec) is the sum of the Pathway_adj in the sector. Basically if there is a slack out of the sum of the pathway adjs it is included in capital to balance the sectoral structure
* pathway_total should be quite small for the sectors but sometimes there is the H2 that is getting some share but is not used in the MPSGE model.





************Options************
*PP 1) HERE YOU CHOOSE THE PATHWAY, THE STARTING POINT AND THE CASE STUDY (B,T,P)
*Choose "No", "Ref", "Div", "Loc", "Nat", "Dir", for No case, Reference, Diversification, Localization, National Champions, Directed Vision pathways.
$setglobal SW_Case "Nat";
*Chose if you want all cases to be run from the trivial equilibrium "Zero", to start from the past iteration's solution "Past", from the same iteration's solution "Same", or from a custom start "Custom". To warmstart the reference scenario use "Ref"
$setglobal SW_start "No";
*Chose if you want to run No, the buildings B, transport T or production P shock"
$setglobal SW_shock "T";


$setglobal Iteration "10";

*PP 2) ITERATIONS FOR THE ANALYSIS WITH GDP. STEPS DEFINE TIME PERIODS
*Chose the numeraire for the model
scalar num /1/;
scalar STEPS /7/;

scalar  alpha /0/;

STEPS = %Iteration%;

*PP 3) DEPENDING ON THE SELECTED CASE STUDY WE WILL HAVE A DIFFERENT SET OF WEIGTHS
* P_S IS FOR THE PATHWAY, WHILE T_S AND B_S ARE FOR THE SHOCKS. Note that P_S defined here is not used.
* IT IS REDEFINED LATER AFTER PP 4)
parameter P_S Case Switch 0: No Case | 1: Reference | 2: Diversification | 3: Localization | 4: National Champions | 5: Directed Vision  /2/;
Parameter T_S /0/;
Parameter B_S /0/;

scalar weight_t /0/;
scalar weight_b /0/;
scalar weight_g /0/;

scalar IterLim 0 1 1e9 /0/;

*PP 4) HERE WE GO TO THE RIGHT PATHWAY DEPENDING ON OUR PREVIOUS CHOICE
$if "%SW_Case%" == "No" $goto CaseEnd

$if "%SW_Case%" == "Ref" $goto PathReference
$if "%SW_Case%" == "Div" $goto PathDiversification
$if "%SW_Case%" == "Loc" $goto PathLocalization
$if "%SW_Case%" == "Nat" $goto PathNational
$if "%SW_Case%" == "Dir" $goto PathDirected

$label PathReference
P_S = 1;
$goto CaseEnd
$label PathDiversification
P_S = 2;
$goto CaseEnd
$label PathLocalization
P_S = 3;
$goto CaseEnd
$label PathNational
P_S = 4;
$goto CaseEnd
$label PathDirected
P_S = 5;
$goto CaseEnd


$label CaseEnd





$if "%SW_Shock%" == "No" $goto ShockEnd

$if "%SW_Shock%" == "B" $goto Buildingsshock
$if "%SW_Shock%" == "T" $goto TransportShock
$if "%SW_Shock%" == "P" $goto ProductionShock

$label Buildingsshock
weight_t = 0;
weight_b = 1;
weight_g = 0;
$goto ShockEnd
$label TransportShock
weight_t = 1;
weight_b = 0;
weight_g = 0;
$goto ShockEnd
$label ProductionShock
weight_t = 0;
weight_b = 0;
weight_g = 1;
$goto ShockEnd


$label ShockEnd


display STEPS, P_S, weight_t, weight_b, weight_g;

************************************************************
************************ Model Starts **********************
************************************************************

*PP 5) USUAL REMES DATA HANDLING

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


*PP 10) HERE WE IDENTIFY THE RESOURCES (1) ENERGY (2) AND TRANSPORT (3) COMMODITIES
* FOR THE OUTPUT PRINTS (?)

*Identify the transport commodities and sectors, and the energy commodities
Parameter PID0(com0), SID0(sec0);
PID0(com0) = 0;
SID0(sec0) = 0;

PID0('c-bio') = 1;
PID0('c-powf') = 2;
PID0('c-powr') = 2;
PID0('c-coal') = 1;
PID0('c-crude-oil') = 1;
PID0('c-gase') = 1;
PID0('c-oil-gsl') = 1;
PID0('c-oil-jet') = 1;
PID0('c-oil-ker') = 1;
PID0('c-oil-dsl') = 1;
PID0('c-oil-hdi') = 1;
PID0('c-oil-ldsf') = 1;
PID0('c-c_trai') = 3;
PID0('c-c_tlnd') = 3;
PID0('c-c_tpip') = 3;
PID0('c-c_twas') = 3;
PID0('c-c_twai') = 3;
PID0('c-c_tair') = 3;

SID0('c_trai') = 3;
SID0('c_tlnd') = 3;
SID0('c_tpip') = 3;
SID0('c_twas') = 3;
SID0('c_twai') = 3;
SID0('c_tair') = 3;

Parameter FID0(com0), TID0(sec0);
FID0(com0) = 0;
TID0(sec0) = 0;


FID0('c-ng') = 1;
FID0('c-bio') = 1;
FID0('c-powf') = 2;
FID0('c-powr') = 2;
FID0('c-oil-gsl') = 1;
FID0('c-oil-jet') = 1;
FID0('c-oil-ker') = 1;
FID0('c-oil-dsl') = 1;
FID0('c-c_trai') = 3;
FID0('c-c_tlnd') = 3;
FID0('c-c_tpip') = 3;
FID0('c-c_twas') = 3;
FID0('c-c_twai') = 3;
FID0('c-c_tair') = 3;

TID0('c_trai') = 3;
TID0('c_tlnd') = 3;
TID0('c_twas') = 3;
TID0('c_twai') = 3;
TID0('c_tair') = 3;


* ============                             ===================
* ============ Elasticities                  ===================
* ============                             ===================
*PP 11) INTRODUCE ELASTICITIES (kl, kle, klem PER SECTOR)
parameter ELAS(*, *),ELAS0(*, *);

$gdxin 'SET-Nav elasticities'
$load ELAS0=ELAS
$gdxin

display ELAS0;

*PP 12) MAKE POWER SECTORS VERY COST INSENSITIVE. WHY?
ELAS0("POWF", "KL") = 100;
ELAS0("POWF", "KLE") = 100;
ELAS0("POWF", "KLEM") = 100;
ELAS0("POWG", "KL") = 100;
ELAS0("POWG", "KLE") = 100;
ELAS0("POWG", "KLEM") = 100;


* ========== Redefinition of the SAM, trade and trade margin matries ===========

set sec /
i-AGR
i-IND
i-SERV
i-TRA
i-POWF
i-POWR
i-POWT
i-COAL
i-COIL
i-NG
/

set com /
g-AGR
g-IND
g-SERV
g-TRA
g-POWR
g-POWF
g-POWT
g-LTH
g-OIL
g-OIL-GSL
g-OIL-DSL
g-OIL-HDI
g-NG
g-COAL
g-BIO
g-FUEL
/;


set maps(sec0,sec)/
AAGR.i-AGR
COAL.i-COAL
COIL.i-COIL
IMIN.i-IND
IRES.i-IND
IALA.i-IND
POWF.i-POWF
POWR.i-POWR
POWT.i-POWT
NG.i-NG
LTH.i-IND
COTH.i-SERV
CCON.i-IND
CWSR.i-SERV
COFF.i-SERV
C_TRAI.i-TRA
C_TLND.i-TRA
C_TPIP.i-TRA
C_TWAS.i-TRA
C_TWAI.i-TRA
C_TAIR.i-TRA
CHEA.i-IND
Waste.i-SERV
BIO.i-AGR
/;

set mapc(com0,com)/
c-AAGR.g-AGR
c-IMIN.g-IND
c-IRES.g-IND
c-NG.g-NG
c-BIO.g-BIO
c-POWF.g-POWF
c-POWR.g-POWR
c-POWT.g-POWT
c-LTH.g-LTH
c-COTH.g-SERV
c-CCON.g-IND
c-CWSR.g-SERV
c-COFF.g-SERV
c-C_TRAI.g-TRA
c-C_TLND.g-TRA
c-C_TPIP.g-TRA
c-CHEA.g-SERV
c-Waste.g-SERV
c-COAL.g-COAL
c-CRUDE-OIL.g-OIL
c-GASE.g-NG
c-OIL-GSL.g-OIL-GSL
c-OIL-JET.g-FUEL
c-OIL-KER.g-FUEL
c-OIL-DSL.g-OIL-DSL
c-OIL-HDI.g-OIL-HDI
c-OIL-LDSF.g-FUEL
c-IMEA.g-IND
c-C_TWAS.g-TRA
c-C_TWAI.g-TRA
c-C_TAIR.g-TRA
c-COIL.g-OIL
/;

Alias(samd,samdd);

parameter SAM1(cnt,*,*),SAM(cnt,*,*);
* Populating the SAM only using the initial elements (no sectors, no commodities)
SAM1(cnt,samdd,samr)=SAMt(cnt,samdd,samr);
SAM(cnt,samdd,samd)=SAM1(cnt,samdd,samd);
execute_unload 'boh' SAMt,SAM;

* including commodities and sectors in the index
samd(com)=yes;
samd(sec)=yes;

alias
(cnt,r)
(sec,s)
(com,g);

display samd,samr;




*SAM1(cnt,samdd,samr)=SAMt(cnt,samdd,samr);
SAM1(cnt,sec,samr)=sum(sec0$maps(sec0,sec),SAMt(cnt,sec0,samr));
SAM1(cnt,com,samr)=sum(com0$mapc(com0,com),SAMt(cnt,com0,samr));
*SAM(cnt,samdd,samd)=SAM1(cnt,samdd,samd);

SAM(cnt,samd,samdd)=SAM1(cnt,samd,samdd);

SAM(cnt,samd,sec)=sum(sec0$maps(sec0,sec),SAM1(cnt,samd,sec0));
SAM(cnt,samd,com)=sum(com0$mapc(com0,com),SAM1(cnt,samd,com0));

parameter tradeData(com,*,*);
tradeData(com,cnt,cntt)=sum(com0$mapc(com0,com),tradeDatat(com0,cnt,cntt));
tradeData(com,cnt,"ROW")=sum(com0$mapc(com0,com),tradeDatat(com0,cnt,"ROW"));
tradeData(com,"ROW",cntt)=sum(com0$mapc(com0,com),tradeDatat(com0,"ROW",cntt));

parameter TradeMargins(com,cnt,cntt);
TradeMargins(com,cnt,cntt)=sum(com0$mapc(com0,com),TradeMarginst(com0,cnt,cntt));

*SAM1(r,*,g1)=sum(g$mapc(g,g1),SAM1(r,*,g1));






* ===================== check if SAM is balanced ===============================
Parameter SAM_balance(cnt,*) ;
SAM_balance(cnt,samd) =  sum(samdd,SAM(cnt,samd,samdd))
       -  sum(samdd,SAM(cnt,samdd,samd)) ;
display SAM_balance;
execute_unload "sambalance.gdx" SAM_balance;
execute_unload "newSAM.gdx" SAM1,SAM,tradeData,TradeMargins,SAM_balance;


* ============================ end =============================================



* ===== Calculate initial levels of variables for calibration ==================
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

;

*Assign symbols out of the SAM
XDDZ(cnt,sec,com)    = SAM(cnt,sec,com)   ;
XDZ(cnt,sec)         = sum(com,XDDZ(cnt,sec,com)) ;
IOZ(cnt,com,sec)     = SAM(cnt, com, sec) ;
CZ(cnt, com)             =  SAM(cnt, com, "HOUS");
CGZ(cnt, com)            = SAM(cnt, com, "GOVT");
IZ(cnt, com)             = SAM(cnt, com, "INV");
LZ(cnt,sec)          = SAM(cnt,'Labour',sec)                     ;
KZ(cnt,sec)          = SAM(cnt,'Capital',sec)                    ;

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


*Read initial consumtion figures
ITZ(cnt)             = sum(com, SAM(cnt,com, "INV"));
CBUDZ(cnt)           = sum(com, SAM(cnt,com, "HOUS"))  ;


*Define the local governments budget
CBUDGLZ(cnt)  = sum(com, SAM(cnt,com, "GOVT"))  ;


*Define Local Government Consumption
CGLZ(cnt, com) = CGZ(cnt, com);


EROWZ(cnt,com)       = TradeData(com,cnt,'ROW') ;
MROWZ(cnt,com)       = TradeData(com,'ROW',cnt) ;

TRADEZ(com,cnt,cntt) = TradeData(com,cnt,cntt) ;
TMCRZ(com,cnt,cntt)  = TradeMargins(com,cnt,cntt) ;

XXDZ(cnt,com)        = sum(sec,XDDZ(cnt,sec,com))- EROWZ(cnt,com) - sum(cntt,TRADEZ(com,cnt,cntt));

loop ((com,cnt), TRADEZ(com, cnt, cnt) = 0);

TMCZ(cnt,com)        = SAM(cnt,'tmarg',com) ;
TMXZ(cnt,com)        = SAM(cnt,com,'tmarg') ;

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


parameter sVA(cnt,sec),sVAperc(cnt,sec);
sVA(cnt,sec)=(LZ(cnt,sec)+LZ(cnt,sec)+TAXPZ(cnt,sec));
sVAperc(cnt,sec)=(LZ(cnt,sec)+LZ(cnt,sec)+TAXPZ(cnt,sec))/sum(secc,LZ(cnt,secc)+LZ(cnt,secc)+TAXPZ(cnt,secc));
execute_unload "InitialVA.gdx", sVA,sVAperc;



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


*Adjust consumption figures for taxes and trade margins
Parameters
TOTALCONSZ(cnt,com)   total taxed consumption
TAXTOTALZ(cnt,com)    sum of taxes and margins
;

TOTALCONSZ(cnt,com)   = sum(sec,IOZ(cnt,com,sec)) +  CZ(cnt,com) +  CGZ(cnt,com) + IZ(cnt,com) ;

TAXTOTALZ(cnt,com)    = TAXCZ(cnt,com) ;

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

*PP 6) HERE WE FIND INDICES FOR POSSIBLE IOZ NEGATIVE VALUES
parameter
possec
poscom
poscnt
amnt;

* check there there are no negative values
loop ((cnt,com),
   if ((CZ(cnt,com) lt 0) and (abs(CZ(cnt,com)) gt 1e-6) ,
         CZ(cnt, com) = 0;
*         display amnt;
*          abort "check CZ(cnt,com) "
   );
   if ((CGZ(cnt,com) lt 0) and (abs(CGZ(cnt,com)) gt 1e-6) ,
         CGZ(cnt, com) = 0;
*         display amnt;
*          abort "CGZ(cnt,com) "
   );
   if ((IZ(cnt,com) lt 0) and (abs(IZ(cnt,com)) gt 1e-6) ,
         IZ(cnt, com)= 0;
*         display amnt;
*          abort "IZ(cnt,com) "
   );
loop (sec,
   if ((IOZ(cnt,com,sec) lt 0) and (abs(IOZ(cnt,com,sec)) gt 1e-6) ,
         possec = ord(sec);
         poscom = ord(com);
         poscnt = ord(cnt);
         amnt = IOZ(cnt, com, sec);
         IOZ(cnt, com, sec) = 0;
*         display amnt;
*          abort "check IOZ(cnt,com,sec)"
   );
);
);

*PP 7) USUAL REMES
* =========== Calculate transport and trade margins ============================
Parameter
trmz(cnt,com) initial transport and trade margins
trm(cnt,com) transport and trade margins
;

trmz(cnt,com)$(sum(sec,IOZ(cnt,com,sec))+  CZ(cnt,com) +  CGZ(cnt,com)+  IZ(cnt,com)) =
                 (TMCZ(cnt,com))/(sum(sec,IOZ(cnt,com,sec))+  CZ(cnt,com) +  CGZ(cnt,com) +  IZ(cnt,com)) ;

trm(cnt,com) = trmz(cnt,com) ;


* ========== Check trade flows balance =========================================
XZ(cnt,com) =  sum(sec,IOZ(cnt,com,sec)) +  CZ(cnt,com) +  CGZ(cnt,com)
               + TMXZ(cnt,com) + IZ(cnt,com) + SVZ(cnt,com) ;


Parameter
check_tradebal(cnt,com) sales equal domestic supply plus imports
check_tradebal_2(cnt,com) outputs equal domestic products supply + Export and Export other regions
;

check_tradebal(cnt,com) = XZ(cnt,com) - ( XXDZ(cnt,com) + MROWZ(cnt,com)
   + sum(cntt, TRADEZ(com,cntt,cnt)) ) ;

Execute_unload "sjekk_tradebal" XZ,XXDZ,MROWZ,TRADEZ,check_tradebal;


check_tradebal_2(cnt,com) = sum(sec,XDDZ(cnt,sec,com))- XXDZ(cnt,com)- EROWZ(cnt,com) -
               sum(cntt, TRADEZ(com,cnt,cntt)) ;


EZ(cnt,com) =  EROWZ(cnt,com) + sum(cntt,TRADEZ(com,cnt,cntt)) ;


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


*************************
parameter check_taxcom(cnt, com);
check_taxcom(cnt, com) = CZ(cnt, com)*(1+taxcz(cnt, com))*(1 + trmz(cnt, com));
display check_taxcom;

************************


taxc(cnt,com) = taxcz(cnt,com) ;
taxp(cnt,sec) = taxpz(cnt,sec) ;

tyz(cnt)$((LSZ(cnt) + KSZ(cnt)) ne 0) =  TTYZ(cnt)/(LSZ(cnt) + KSZ(cnt)) ;
ty(cnt)  =  tyz(cnt) ;


Parameter
trade_bal_global(cnt) global trade balance
trade_bal_global_nat national trade balance
;

trade_bal_global(cnt) =
* Incomming monetary flows - exports
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



Parameter
investment_bal(cnt) balance of savings and investments
investment_bal_nat
;

investment_bal(cnt) =  + sum(sec,INVZ(cnt,sec))
  + SHZ(cnt) + SGZ(cnt) + SROWZ(cnt) - ITZ(cnt)
  - sum(com, SVZ(cnt,com))  ;

investment_bal_nat = sum(cnt, investment_bal(cnt));


parameter
TaxedTradeMargins(cnt, com)
;

TaxedTradeMargins(cnt, com) = (CZ(cnt, com)+IZ(cnt, com)
         +CGZ(cnt, com)+sum(sec,IOZ(cnt, com, sec)))*trmz(cnt, com);

display TaxedTradeMargins;


* ======================= UPGRADE ELASTICITIES =================================
*ELAS("KL", sec)=1;
*ELAS("KLE", sec)=0.01;
*ELAS("KLEM", sec)=0.01;


ELAS(sec,"KL") = sum((r,sec0)$maps(sec0,sec),ELAS0(sec0,"KL")*XD0(r,sec0))/sum((cnt,sec0)$maps(sec0,sec),XD0(cnt,sec0));
ELAS(sec,"KLE") = sum((r,sec0)$maps(sec0,sec),ELAS0(sec0,"KLE")*XD0(r,sec0))/sum((cnt,sec0)$maps(sec0,sec),XD0(cnt,sec0));
ELAS(sec,"KLEM") = sum((r,sec0)$maps(sec0,sec),ELAS0(sec0,"KLEM")*XD0(r,sec0))/sum((cnt,sec0)$maps(sec0,sec),XD0(cnt,sec0));

display ELAS0,ELAS;


* ============                             ===================
* ============ Currencies                  ===================
* ============                             ===================
*PP 8) HERE WE SET A FLAG FOR THE CURRENCY IN EACH COUNTRY
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
*Exch_out is right
Exch_out(CRR) = (sum(cnt$used_currency(cnt, CRR), sum(com, MROWZ(cnt, com)) - TRROWZ(cnt)$(TRROWZ(cnt) < 0) + SROWZ(cnt) -  TRHROWZ(cnt)$( TRHROWZ(cnt) < 0)));

Exch_in(CRR) = (sum((cnt, com)$used_currency(cnt, CRR), EROWZ(cnt, com) + TRROWZ(cnt)$(TRROWZ(cnt) > 0) +  TRHROWZ(cnt)$( TRHROWZ(cnt) > 0)));

display used_currency




* ============ Define variable to study and the set of increments ==============================
*PP 13) INCLUDE GROWTH FOR POPULATION AND GDP PROJECTIONS
$include "growth_table.gms"

Set step /1*10/;

parameter R_GDP(step, cnt)
gdp_p(cnt);




* ============                                  ===================
* ============ Definitions of the TrANSPORT CASE ===================
* ============                                  ===================
*PP 14) THIS ADJUSTS THE STRUCTURE OF THE TRANSPORT SECTORS INTRODUCING H2
* IT SEEMS THAT THE SHOCK IS SELECTED, AND WITHIN THE SHOCK THE CHOSEN PATHWAY
* IS UTILIZED. NewShare DESCRIBES HOW FUELS MIX CHANGES WITH TIME MOVING FROM CONVENTIONAL TO H2 AND ELECTRICITY
* THE SHARES ARE TAKEN FROM ASTRA MODEL. consgrowth IS EMPTY.
parameter T_adj(cnt, *, *)   Adjustment to Transport sectors
NewSharet(*, *, *, *)   Share of fuels according to Astra
consgrowth(cnt, *, *);

*PP 15) LOAD THE INPUT FILE FOR THE TRANSPORT CASE DEPENDING ON THE CHOSEN PATHWAY
* THIS SELECTS A DIFFERENT EVOLUTION OF THE FUELS THAT ARE IN THE NewShare array
*"No", "Ref", "Div", "Loc", "Nat", "Dir", for No case, Reference, Diversification, Localization, National Champions, Directed Vision .
display P_S;
$if "%SW_shock%" != "T" $goto no_trans
$IF "%SW_Case%" == "Div" $goto i_trans_div
$IF "%SW_Case%" == "Dir" $goto i_trans_dir
$IF "%SW_Case%" == "Ref" $goto i_trans_ref
$IF "%SW_Case%" == "Loc" $goto i_trans_nat
$IF "%SW_Case%" == "Nat" $goto i_trans_nat
$goto no_trans


$label i_trans_div
$GDXin DivTransport
$load newsharet=newshare
*$load consgrowth
*T_S = 1;
$GDXin
$goto i_transport_end

$label i_trans_dir
$GDXin DirTransport
$load newsharet=newshare
*$load consgrowth
*T_S = 1;
$GDXin
$goto i_transport_end

$label i_trans_nat
$GDXin NatTransport
$load newsharet=newshare
*$load consgrowth
*T_S = 1;
$GDXin
$goto i_transport_end


$label i_trans_Loc
$GDXin LocTransport
$load newsharet=newshare
*$load consgrowth
*T_S = 1;
$GDXin
$goto i_transport_end


$label i_trans_ref
* no shock
$GDXin RefTransport
$load newsharet=newshare
newsharet(cnt,sec0,com0,step)=0;
*$load consgrowth
*T_S = 1;
$GDXin
$goto i_transport_end

*PP 15b) IN CASE THERE IS NO TRANSPORT CASE THE NEWSHARE IS ALL ZEROS.
$label no_trans
newsharet("one", "two", "Three", "four") = 0;
*$load consgrowth
*T_S = 0;
$goto i_transport_end



$label i_transport_end

*PP 15c) THE H2 COMMODITY IS THE ONLY EXTRA COMMODITY CONSIDERED.
T_adj(cnt, sec, com) = 0;
T_adj(cnt, sec, "H2") = 0;

T_adj(cnt, "HOUS", com) = 0;
T_adj(cnt, "HOUS", "H2") = 0;

T_adj(cnt, "GOVT", com) = 0;
T_adj(cnt, "GOVT", "H2") = 0;


Parameter PID(com), SID(sec);
PID(com) = 0;
SID(sec) = 0;

PID('g-bio') = 1;
PID('g-powf') = 2;
PID('g-powr') = 2;
PID('g-coal') = 1;
PID('g-ng') = 1;
PID('g-oil') = 1;
PID('g-oil-hdi') = 1;
PID('g-oil-gsl') = 1;
PID('g-oil-dsl') = 1;
PID('g-tra') = 3;

SID('i-tra') = 3;


Parameter FID(com), TID(sec);
FID(com) = 0;
TID(sec) = 0;


FID('g-ng') = 1;
FID('g-bio') = 1;
FID('g-powf') = 2;
FID('g-powr') = 2;
FID('g-oil') = 1;
FID('g-oil-gsl') = 1;
FID('g-oil-dsl') = 1;
FID('g-tra') = 3;

TID('i-tra') = 3;

* =============== newshare IS REDEFINED WITH THE GROUPED SECTORS ===============
PARAMETER newsharetemp(*,*,*,*),newshare(*,*,*,*);
*newshare( cnt, sec, com, step)

newsharetemp(cnt,sec,com,step)$(sum(g,IOZ(cnt,g,sec)) gt 0)=sum((sec0,com0)$(mapc(com0,com) and maps(sec0,sec)),newsharet(cnt,sec0,com0,step))*sum(g,IOZ(cnt,g,sec));
newsharetemp(cnt,sec,"g-H2",step)=sum((sec0)$maps(sec0,sec),newsharet(cnt,sec0,"H2",step))*sum(g,IOZ(cnt,g,sec));
newsharetemp(cnt,"HOUS",com,step)$(sum(g,CZ(cnt,g)) gt 0)=sum((sec0,com0)$(mapc(com0,com) ),newsharet(cnt,"HOUS",com0,step))*sum(g,CZ(cnt,g));
newsharetemp(cnt,"GOVT",com,step)$(sum(g,CGZ(cnt,g)) gt 0)=sum((sec0,com0)$(mapc(com0,com) ),newsharet(cnt,"GOVT",com0,step))*sum(g,CGZ(cnt,g));


newshare(cnt,sec,com,step)$(newsharetemp(cnt,sec,com,step))=newsharetemp(cnt,sec,com,step)/(sum(g,newsharetemp(cnt,sec,g,step))+newsharetemp(cnt,sec,"g-H2",step));
newshare(cnt,sec,"g-H2",step)$(newsharetemp(cnt,sec,"g-H2",step))=newsharetemp(cnt,sec,"g-H2",step)/(sum(g,newsharetemp(cnt,sec,g,step))+newsharetemp(cnt,sec,"g-H2",step));
newshare(cnt,"HOUS",com,step)$(newsharetemp(cnt,"HOUS",com,step))=newsharetemp(cnt,"HOUS",com,step)/(sum(g,newsharetemp(cnt,"HOUS",g,step))+newsharetemp(cnt,"HOUS","g-H2",step));
newshare(cnt,"GOVT",com,step)$(newsharetemp(cnt,"GOVT",com,step))=newsharetemp(cnt,"GOVT",com,step)/(sum(g,newsharetemp(cnt,"GOVT",g,step))+newsharetemp(cnt,"GOVT","g-H2",step));

newshare(cnt,sec,com,"1")=0;
newshare(cnt,sec,"g-H2","1")=0;
newshare(cnt,"HOUS",com,"1")=0;
newshare(cnt,"GOVT",com,"1")=0;
*===============================================================================


display newshare,newsharetemp;
execute_unload "reshare" newshare;


* ============                                  ===================
* ============ Definitions of the BUILDINGS CASE ===================
* ============                                  ===================
*PP 16) A SIMILAR STRUCTURE IS USED FOR ANALYSIS OF BUILDING CASE.
* B_adj ADJUSTS THE BUILDING CONSUMPTION (this is not present in the MPSGE model)
* T_adj ADJUSTS THE TRANSPORT SECTOR. (this is not present in the MPSGE model)
* EVEN IF B_adj and T_adj ARE USED TO COMPUTE
* Pathway_adj, WHICH CORRESPONDS EITHER TO T_adj OR TO B_adj.
* PowGrowth### (Ref, Div, Loc etc...) measures the power demand change under the different pathways.
* THE PARAMETERS ARE COMPUTED IN THE "SET-NAV_Building_Pathways" FILE.

parameter
B_adj(cnt, *, com) Adjustment to Building Consumption
Pathway_adj(cnt, *, *) Sum of the adjustments from all cases
PowGrowthRef(*,  cnt, com, step)
PowGrowthDiv(*,  cnt, com, step)
PowGrowthLoc(*,  cnt, com, step)
PowGrowthNat(*,  cnt, com, step)
PowGrowthDir(*,  cnt, com, step)
Difference(*,  cnt, com, step);


*PP 17) THIS FILE ABOUT BUILDINGS IS ALWAYS INCLUDED, BUT IT SEEMS TO GENERATE PROBLEMS BECAUSE THE
* GDX FILES ARE MISSING FOR THE BUILDING CASE
*$if "%SW_BUILD%" <> "No"
$include "SET-NAV_Building_Pathways2.gms"

*PP 18) THIS IS NOT CLEAR. WHAT ARE THESE PARAMETERS USED FOR? ORIGINAL VALUES FOR WHAT?
* IT SEEMS LIKE THEY ARE THE SHOCKS TO BE INCLUDED IN THE STRUCTURE OF THE SECTORS IN THE MPSGE MODEL
parameter temp(cnt,*),
pathway_adj_total(cnt, *, *)  Original values plus the total adjustments ,
pathway_unadj_total(cnt, *, *)  Original Input coeficient ,
Pathway_total(cnt, *)  New total input  per sector and consumers after adjustments,
Pathway_adj_cap(cnt, sec) Original capital minus the pathway adjustment total if the latter is negative;

*display PowGrowthCase, PowGrowthCase;




*PP 19) SAME AS OTHER CASE STUDIES BUT HERE WE ANALYSE AN INCREASE OF POWER GENERATION
* ALSO IN THIS CASE THE GDX FILE SEEMS TO BE REQUIRED EITHER WAY. ALSO WITHOUT USING THE CASE STUDY

* ============                                  ===================
* ============ Definitions of the GENERATION CASE ===================
* ============                                  ===================
parameter
refdata0(*, step, cnt, sec0) Adjustment to Generaton Expenses
refdata(*, step, cnt, sec) Adjustment to Generaton Expenses
gen_sub_level(cnt, sec, com)
;


$gdxin Pathways/generation
$load refdata0=refdata

$gdxin

refdata("Div",step,cnt,'i-POWF')=refdata0("Div",step,cnt,'POWF');
refdata("Div",step,cnt,'i-POWR')=refdata0("Div",step,cnt,'POWR');
refdata("Nat",step,cnt,'i-POWF')=refdata0("Nat",step,cnt,'POWF');
refdata("Nat",step,cnt,'i-POWR')=refdata0("Nat",step,cnt,'POWR');
refdata("Dir",step,cnt,'i-POWF')=refdata0("Dir",step,cnt,'POWF');
refdata("Dir",step,cnt,'i-POWR')=refdata0("Dir",step,cnt,'POWR');
refdata("Loc",step,cnt,'i-POWF')=refdata0("Loc",step,cnt,'POWF');
refdata("Loc",step,cnt,'i-POWR')=refdata0("Loc",step,cnt,'POWR');

display refdata;


*execute_unload "Symbols MPSGE" XDDZ, XDZ, IOZ, CZ, CGZ, IZ, LZ, KZ;


* ============                             ===================
* ============ DEFINITION OF THE CGE MODEL ===================
* ============                             ===================


$include "REMES_MPSGE_alt.gms"

* ============                             ===================
* ============ DEFINITION OF THE CGE MODEL ===================
* ============                             ===================


*display exch_out, exch_in, EZ, XZ, XDZ, XDDZ, TAXPZ, IOZ, TRMZ, TAXCZ, LZ, KZ, INVZ, TRADEZ, XXDZ, CZ;
*display CBUDZ, CBUDGLZ, CGLZ, ITZ, IZ, XZ, TRADEMARGINS, TAXEDTRADEMARGINS, TMXZ, LSZ, KSZ, SHZ;
*display TRANSFZ, SGZ;
*display MROWZ, TRROWZ, SROWZ, TRHROWZ, EROWZ;



* ============ Provide initial levels of the model variables ===================


option mcp = path ;
Arrow_Debreu.iterlim = IterLim;
Arrow_Debreu.tolProj = 0.00001;
Arrow_Debreu.tolInfeas = 0.01;
Arrow_Debreu.workfactor = 3;
Arrow_Debreu.reslim = 6000;











Parameter
R_Welfare(step, cnt)
R_labour(step, cnt,  sec)
R_Capital(step, cnt, sec)
R_Production(step, cnt, sec, com)
R_EUtrade(step, cnt, com, CRR)
R_Income(step, cnt)
R_XD(step, cnt, sec)
R_P(step, cnt, com)
R_U(step, cnt)
R_PU(step, cnt)
R_HOUS(step, cnt)
Status(step)
R_HOUS_CONS(step, cnt)
R_GOV_CONS(step, cnt)
R_EXP_EU(step, cnt, CRR)
R_IMP_ERR(step, cnt, com, CRR)
R_IMP_PTM(step, cnt, com, cntt)
R_SEC_OUT(step, cnt, sec, com)
R_SEC_IN(step, cnt, sec, com)
R_VA(step, cnt, sec)
Pathway_adjusted(step, cnt,  *, com)

REPORT_GDP(step, cnt)
REPORT_GDP_LABOUR(step, cnt)
REPORT_GDP_CAPITAL(step, cnt, sec)
REPORT_HOUS_CONS(step, cnt)
REPORT_GOV_CONS(step, cnt)
REPORT_FIX_CAP_FORM(step, cnt)
REPORT_EXPORTS(step, cnt)
REPORT_IMPORTS(step, cnt)
REPORT_STOCKS(step, cnt)
REPORT_VA(step, cnt, sec)
REPORT_EMPLOYMENT(step, cnt, sec)
R_P_OIL

VAR_WELFARE(step,cnt)
VAR_GDP(step, cnt)
VAR_LABOUR(step, cnt, sec)
VAR_CAPITAL(step, cnt, sec)
VAR_PRODUCTION(step,cnt,sec)
VAR_EUTRADE(step, cnt, com, CRR)


;







*PP 20) POPULATE THE SECTORS AND COMMODITIES THAT WILL BE MODIFIED
* SEEMS LIKE IT CONSIDERS ALL THE SECTORS + HOUS + GOVT
* ALL THE COMMODITIES + H2
*populaew the sets for the adjustment operations

set adjust_sec(*), adjust_com(*);

adjust_sec(sec)=YES;
adjust_sec("Hous")=YES;
adjust_sec("Govt")=YES;

adjust_com(com)=YES;
adjust_com("g-H2")=YES;


parameter check(cnt, *, *);

Pathway_adj(cnt, sec, com)=0;
Pathway_adj(cnt, "HOUS", com)=0;
Pathway_adj(cnt, "GOVT", com)=0;
Pathway_adj_cap(cnt, sec)=KZ(cnt,sec);
Pathway_total(cnt, "HOUS")=0;
Pathway_total(cnt, "GOVT")=0;
Pathway_total(cnt, sec)=0;
gdp_p(cnt)=1;

display ty;


*==================== Benckmark Solution ======================
*execute_unload "junk" XDDZ,TRADEZ,EROWZ,MROWZ;

display elas;



$include "reset_initial_values_basic.gms"
$INCLUDE ARROW_DEBREU.GEN
Arrow_Debreu.iterlim = 0;
Solve ARROW_DEBREU using mcp;


parameter diff(CRR),testER(CRR), testER2(CRR);
*PP 20b) THE BENCHMARK SOLUTION IS NOT SATISFIED USING EuroSAM15!
* HERE WE CAN SEE THAT THE INITIAL DATA AND THE INITIAL RELATED VARIABLES
* FOR VARIABLE ER(CRR) DO NOT COINCIDE. THIS IS NOT GOOD, BECAUSE THE VALUE OF THE REPORT VARIABLES SHOULD BE THE SAME
* AS THE INITIAL DATA WHEN THE RESULTS ARE OBTAINED WITHOUT COMPUTING POWER. THEREFORE EVEN JUST WRITING THE RESULTS USING FORMULAS
* LEAD TO MISMATCHES BETWEEN DATA AND OUTPUT OF THE MODEL IN THE BENCHMARK SOLUTION. THIS BOILS DOWN TO THE QUALITY OF THE DATA
* I.E. ALL THE NUMBERS THAT ARE TOO SMALL AND SHOULD NOT BE IN A EUROPEAN SAM. SEE E.G. SAM(AT,C-POWR,POWF): IT IS EQUAL TO 107€!!!
testER(CRR)=
*sum(cnt$(used_currency(cnt, CRR)),TRHROWZ(cnt)+TRROWZ(cnt)+SROWZ(cnt))
sum((cnt,com)$(used_currency(cnt, CRR)),REP_EXPout.l(CRR,cnt,com));
*-sum((cnt,com)$(used_currency(cnt, CRR)),REP_EXPin.l(CRR,cnt,com));

testER2(CRR)=
sum((com,cnt,cntt)$(used_currency(cnt, CRR)),TRADEZ(com,cnt,cntt))+sum((com,cnt)$(used_currency(cnt, CRR)),EROWZ(cnt,com));
*-sum((com,cnt)$(used_currency(cnt, CRR)),MROWZ(cnt,com))-sum((com,cnt,cntt)$(used_currency(cnt, CRR)),TRADEZ(com,cntt,cnt));

diff(CRR)=testER(CRR)-testER2(CRR);

display testER,testER2,diff;
parameter tt(cnt,sec);
parameter Ttot(cnt,com),Btot(cnt,com);
*=====================Loop over the increments set============
*PP 21) HERE WE POPULATE THE ADJUSTMENT PARAMETERS AND MAKE THE MODEL RUN
* ONLY RUNS step 10 BECAUSE THE VALUE OF THE STEP IS FIXED TO STEPS,
* WHICH HAS BEEN FIXED TO 10 AT THE BEGINNING OF THE PROGRAM
* IT LOOKS LIKE WE ARE USING THE MODEL AS A SINGLE PERIOD WHAT-IF 2007-2050.

loop(step$(step.val = STEPS ),

*Reset variables to initial levels
$include "reset_initial_values_basic.gms"


gdp_p(cnt) = gdp(cnt, step);

*PP 22) HERE P_S DEFINES THE PATHWAY. THE LOOP OVER THE CASES ARE DONE EITHER WAY,
* BUT I ASSUME THAT THERE IS NO CHANGE FROM THE INITIAL VALUES IF A PARTICULAR CASE HAS NOT BEEN SELECTED
* FOR THE BUILDING ADJUSTMENT THERE WILL BE AN INCREASE OF POWER DEMAND FROM A PREDEFINED VECTOR
display P_S;
if(P_S=1,
*Reference Case
         display "Pathway: Reference";
*Buildings Adjustment
         display PowGrowthRef;
         PU.FX("CY")=1;
         B_adj(cnt, sec, com)$(PowGrowthRef(sec,  cnt, com, "1")) = PowGrowthRef(sec,  cnt, com, step);
         B_adj(cnt, "Hous", com)$(PowGrowthRef("Hous",  cnt, com, "1")) = PowGrowthRef("Hous",  cnt, com, step)   ;
         B_adj(cnt, "Govt",  com)$(PowGrowthRef("Govt",  cnt, com, "1")) = PowGrowthRef("Govt",  cnt, com, step)  ;
         B_adj(cnt, sec, com)$(PowGrowthRef(sec,  cnt, com, "1")=0) = 1                    ;
         B_adj(cnt, "Hous", com)$(PowGrowthRef("Hous",  cnt, com, "1")=0) = 1              ;
         B_adj(cnt, "Govt", com)$(PowGrowthRef("Govt",  cnt, com, "1")=0) = 1              ;

*PP 23) FOR THE TRANSPORT ADJUSTMENT WE UPGRADE THE T_adj PARAMETER FOR RESOURCES AND ENERGY SECTORS
*Transport Adjustment
         loop((cnt, sec),
                 temp(cnt,sec) = 0*sum( com$(FID(com)>0 and FID(com)<3), IOZ(cnt,com,sec)  );
                 T_adj(cnt, sec, com)$(FID(com)>0 and FID(com)<3) = 0*(((step.val-1)/9)*newshare( cnt, sec, com, step)*temp(cnt,sec) + (1-(step.val-1)/9)*IOZ(cnt, com, sec) - IOZ(cnt,com,sec));
                 T_adj(cnt, sec, "g-H2") =   0*(((step.val-1)/9)*newshare( cnt, sec, "g-H2", step)*temp(cnt,sec) - (1-(step.val-1)/9)*0) ; );
         loop(cnt,
                 temp(cnt,"Hous") = 0*sum( com$(FID(com)>0 and FID(com)<3 ), CZ(cnt,com)  );
                 T_adj(cnt, "HOUS", com)$(FID(com)>0 and FID(com)<3 and  newshare( cnt, "Hous", com, step)) =  0*(((step.val-1)/9)*newshare( cnt, "Hous", com, step)*temp(cnt,"Hous") + (1-(step.val-1)/9)*CZ(cnt, com) - CZ(cnt, com));
                 T_adj(cnt, "HOUS", "g-H2") = 0*(((step.val-1)/9)*newshare( cnt, "Hous", "g-H2", step)*temp(cnt,"Hous"))  ;);
         loop(cnt,
                 temp(cnt,"GOVT") = 0*sum( com$(FID(com)>0 and FID(com)<3 ), CGLZ(cnt,com)  );
                 T_adj(cnt, "GOVT", com)$(FID(com)>0 and FID(com)<3 and  newshare( cnt, "govt", com, step)) =  0*(((step.val-1)/9)*newshare( cnt, "GOVT", com, step)*temp(cnt,"GOVT") + (1-(step.val-1)/9)*CGZ(cnt, com) - CGLZ(cnt, com));
                 T_adj(cnt, "GOVT", "g-H2") = 0*(((step.val-1)/9)*newshare( cnt, "GOVT", "g-H2", step)*temp(cnt,"GOVT"));  );

display b_adj, newshare, T_adj;





);
if(P_S=2,
*Diversification Case
         display "Pathway: Diversification" ;
*Buildings Adjustment
         PU.FX("CY")=1;
         B_adj(cnt, sec, com)$(PowGrowthDiv(sec,  cnt, com, "1")) = PowGrowthDiv(sec,  cnt, com, step)   ;
         B_adj(cnt, "Hous",  com)$(PowGrowthDiv("Hous",  cnt, com, "1")) = PowGrowthDiv("Hous",  cnt, com, step) ;
         B_adj(cnt, "Govt",  com)$(PowGrowthDiv("Govt",  cnt, com, "1")) = PowGrowthDiv("Govt",  cnt, com, step)  ;
         B_adj(cnt, sec, com)$(PowGrowthDiv(sec,  cnt, com, "1")=0) = 1                      ;
         B_adj(cnt, "Hous",  com)$(PowGrowthDiv("Hous",  cnt, com, "1")=0) = 1                ;
         B_adj(cnt, "Govt",  com)$(PowGrowthDiv("Govt",  cnt, com, "1")=0) = 1                ;



*Production Adjustment
if(weight_g,
         XD.LO(cnt, sec)$(step.val > 6 and XDZ(cnt, sec) and refdata("Div",  step, cnt,  sec)) = refdata("Div",  step, cnt,  sec);
);


*Transport Adjustment
         loop((cnt, sec),
                 temp(cnt,sec) = sum( com$(FID(com)>0 and FID(com)<3), IOZ(cnt,com,sec)  );
                 T_adj(cnt, sec, com)$(FID(com)>0 and FID(com)<3) = ((step.val-1)/9)*newshare( cnt, sec, com, step)*temp(cnt,sec) + (1-(step.val-1)/9)*IOZ(cnt, com, sec) - IOZ(cnt,com,sec);
                 T_adj(cnt, sec, "g-H2") =   ((step.val-1)/9)*newshare( cnt, sec, "g-H2", step)*temp(cnt,sec) - (1-(step.val-1)/9)*0 ; );
         loop(cnt,
                 temp(cnt,"Hous") = sum( com$(FID(com)>0 and FID(com)<3 ), CZ(cnt,com)  );
                 T_adj(cnt, "HOUS", com)$(FID(com)>0 and FID(com)<3 and  newshare( cnt, "Hous", com, step)) =  ((step.val-1)/9)*newshare( cnt, "Hous", com, step)*temp(cnt,"Hous") + (1-(step.val-1)/9)*CZ(cnt, com) - CZ(cnt, com);
                 T_adj(cnt, "HOUS", "g-H2") = ((step.val-1)/9)*newshare( cnt, "Hous", "g-H2", step)*temp(cnt,"Hous")  ;);
         loop(cnt,
                 temp(cnt,"GOVT") = sum( com$(FID(com)>0 and FID(com)<3 ), CGLZ(cnt,com)  );
                 T_adj(cnt, "GOVT", com)$(FID(com)>0 and FID(com)<3 and  newshare( cnt, "govt", com, step)) =  ((step.val-1)/9)*newshare( cnt, "GOVT", com, step)*temp(cnt,"GOVT") + (1-(step.val-1)/9)*CGZ(cnt, com) - CGLZ(cnt, com);
                 T_adj(cnt, "GOVT", "g-H2") = ((step.val-1)/9)*newshare( cnt, "GOVT", "g-H2", step)*temp(cnt,"GOVT");  );




);
if(P_S=3,
*Localization Case
         display "Pathway: Localization" ;
*Buildings Adjustment
         PU.FX("CY")=1;
         B_adj(cnt, sec, com)$(PowGrowthLoc(sec,  cnt, com, "1")) = PowGrowthLoc(sec,  cnt, com, step)   ;
         B_adj(cnt, "Hous",  com)$(PowGrowthLoc("Hous",  cnt, com, "1")) = PowGrowthLoc("Hous",  cnt, com, step) ;
         B_adj(cnt, "Govt",  com)$(PowGrowthLoc("Govt",  cnt, com, "1")) = PowGrowthLoc("Govt",  cnt, com, step)  ;
         B_adj(cnt, sec, com)$(PowGrowthLoc(sec,  cnt, com, "1")=0) = 1                      ;
         B_adj(cnt, "Hous",  com)$(PowGrowthLoc("Hous",  cnt, com, "1")=0) = 1                ;
         B_adj(cnt, "Govt",  com)$(PowGrowthLoc("Govt",  cnt, com, "1")=0) = 1                ;


*Production Adjustment
if(weight_g,
         XD.LO(cnt, sec)$(step.val > 6 and XDZ(cnt, sec) and refdata("Loc",  step, cnt,  sec)) = refdata("Loc",  step, cnt,  sec);
);

*Transport Adjustment
         loop((cnt, sec),
                 temp(cnt,sec) = sum( com$(FID(com)>0 and FID(com)<3), IOZ(cnt,com,sec)  );
                 T_adj(cnt, sec, com)$(FID(com)>0 and FID(com)<3) = ((step.val-1)/9)*newshare( cnt, sec, com, step)*temp(cnt,sec) + (1-(step.val-1)/9)*IOZ(cnt, com, sec) - IOZ(cnt,com,sec);
                 T_adj(cnt, sec, "g-H2") =   ((step.val-1)/9)*newshare( cnt, sec, "g-H2", step)*temp(cnt,sec) - (1-(step.val-1)/9)*0 ; );
         loop(cnt,
                 temp(cnt,"Hous") = sum( com$(FID(com)>0 and FID(com)<3 ), CZ(cnt,com)  );
                 T_adj(cnt, "HOUS", com)$(FID(com)>0 and FID(com)<3 and  newshare( cnt, "Hous", com, step)) =  ((step.val-1)/9)*newshare( cnt, "Hous", com, step)*temp(cnt,"Hous") + (1-(step.val-1)/9)*CZ(cnt, com) - CZ(cnt, com);
                 T_adj(cnt, "HOUS", "g-H2") = ((step.val-1)/9)*newshare( cnt, "Hous", "g-H2", step)*temp(cnt,"Hous")  ;);
         loop(cnt,
                 temp(cnt,"GOVT") = sum( com$(FID(com)>0 and FID(com)<3 ), CGLZ(cnt,com)  );
                 T_adj(cnt, "GOVT", com)$(FID(com)>0 and FID(com)<3 and  newshare( cnt, "govt", com, step)) =  ((step.val-1)/9)*newshare( cnt, "GOVT", com, step)*temp(cnt,"GOVT") + (1-(step.val-1)/9)*CGZ(cnt, com) - CGLZ(cnt, com);
                 T_adj(cnt, "GOVT", "g-H2") = ((step.val-1)/9)*newshare( cnt, "GOVT", "g-H2", step)*temp(cnt,"GOVT");  );





*Production Adjustment
*         XD.LO(cnt,  "POWR")$(step.val > 6) = refdata("Loc", step, cnt,  "POWR");



);
if(P_S=4,
*National Champions Case
         display "Pathway: National Champions" ;
*Buildings Adjustment
         PU.FX("CY")=1;
         B_adj(cnt, sec, com)$(PowGrowthNat(sec,  cnt, com, "1")) = PowGrowthNat(sec,  cnt, com, step)   ;
         B_adj(cnt, "Hous",  com)$(PowGrowthNat("Hous",  cnt, com, "1")) = PowGrowthNat("Hous",  cnt, com, step) ;
         B_adj(cnt, "Govt",  com)$(PowGrowthNat("Govt",  cnt, com, "1")) = PowGrowthNat("Govt",  cnt, com, step)  ;
         B_adj(cnt, sec, com)$(PowGrowthNat(sec,  cnt, com, "1")=0) = 1                      ;
         B_adj(cnt, "Hous",  com)$(PowGrowthNat("Hous",  cnt, com, "1")=0) = 1                ;
         B_adj(cnt, "Govt",  com)$(PowGrowthNat("Govt",  cnt, com, "1")=0) = 1                ;


*Production Adjustment
if(weight_g,
         XD.LO(cnt, sec)$(step.val > 6 and XDZ(cnt, sec) and refdata("Nat",  step, cnt,  sec)) = refdata("Nat",  step, cnt,  sec);
);


*Transport Adjustment
         loop((cnt, sec),
                 temp(cnt,sec) = sum( com$(FID(com)>0 and FID(com)<3), IOZ(cnt,com,sec)  );
                 T_adj(cnt, sec, com)$(FID(com)>0 and FID(com)<3) = ((step.val-1)/9)*newshare( cnt, sec, com, step)*temp(cnt,sec) + (1-(step.val-1)/9)*IOZ(cnt, com, sec) - IOZ(cnt,com,sec);
                 T_adj(cnt, sec, "g-H2") =   ((step.val-1)/9)*newshare( cnt, sec, "g-H2", step)*temp(cnt,sec) - (1-(step.val-1)/9)*0 ; );
         loop(cnt,
                 temp(cnt,"Hous") = sum( com$(FID(com)>0 and FID(com)<3 ), CZ(cnt,com)  );
                 T_adj(cnt, "HOUS", com)$(FID(com)>0 and FID(com)<3 and  newshare( cnt, "Hous", com, step)) =  ((step.val-1)/9)*newshare( cnt, "Hous", com, step)*temp(cnt,"Hous") + (1-(step.val-1)/9)*CZ(cnt, com) - CZ(cnt, com);
                 T_adj(cnt, "HOUS", "g-H2") = ((step.val-1)/9)*newshare( cnt, "Hous", "g-H2", step)*temp(cnt,"Hous")  ;);
         loop(cnt,
                 temp(cnt,"GOVT") = sum( com$(FID(com)>0 and FID(com)<3 ), CGLZ(cnt,com)  );
                 T_adj(cnt, "GOVT", com)$(FID(com)>0 and FID(com)<3 and  newshare( cnt, "govt", com, step)) =  ((step.val-1)/9)*newshare( cnt, "GOVT", com, step)*temp(cnt,"GOVT") + (1-(step.val-1)/9)*CGZ(cnt, com) - CGLZ(cnt, com);
                 T_adj(cnt, "GOVT", "g-H2") = ((step.val-1)/9)*newshare( cnt, "GOVT", "g-H2", step)*temp(cnt,"GOVT");  );





);
*PP test

if(P_S=5,
*Directed Vision Case
         display "Pathway: Directed Vision"  ;
*Buildings Adjustment
         PU.FX("CY")=1;
         B_adj(cnt, sec, com)$(PowGrowthDir(sec,  cnt, com, "1")) = PowGrowthDir(sec,  cnt, com, step)   ;
         B_adj(cnt, "Hous",  com)$(PowGrowthDir("Hous",  cnt, com, "1")) = PowGrowthDir("Hous",  cnt, com, step) ;
         B_adj(cnt, "Govt",  com)$(PowGrowthDir("Govt",  cnt, com, "1")) = PowGrowthDir("Govt",  cnt, com, step)  ;
         B_adj(cnt, sec, com)$(PowGrowthDir(sec,  cnt, com, "1")=0) = 1                      ;
         B_adj(cnt, "Hous",  com)$(PowGrowthDir("Hous",  cnt, com, "1")=0) = 1                ;
         B_adj(cnt, "Govt",  com)$(PowGrowthDir("Govt",  cnt, com, "1")=0) = 1                ;


*Production Adjustment
if(weight_g,
         XD.LO(cnt, sec)$(step.val > 6 and XDZ(cnt, sec) and refdata("Dir",  step, cnt,  sec)) = refdata("Dir",  step, cnt,  sec);
);

*Transport Adjustment
         loop((cnt, sec),
                 temp(cnt,sec) = sum( com$(FID(com)>0 and FID(com)<3), IOZ(cnt,com,sec)  );
                 T_adj(cnt, sec, com)$(FID(com)>0 and FID(com)<3) = ((step.val-1)/9)*newshare( cnt, sec, com, step)*temp(cnt,sec) + (1-(step.val-1)/9)*IOZ(cnt, com, sec) - IOZ(cnt,com,sec);
                 T_adj(cnt, sec, "g-H2") =   ((step.val-1)/9)*newshare( cnt, sec, "g-H2", step)*temp(cnt,sec) - (1-(step.val-1)/9)*0 ; );
         loop(cnt,
                 temp(cnt,"Hous") = sum( com$(FID(com)>0 and FID(com)<3 ), CZ(cnt,com)  );
                 T_adj(cnt, "HOUS", com)$(FID(com)>0 and FID(com)<3 and  newshare( cnt, "Hous", com, step)) =  ((step.val-1)/9)*newshare( cnt, "Hous", com, step)*temp(cnt,"Hous") + (1-(step.val-1)/9)*CZ(cnt, com) - CZ(cnt, com);
                 T_adj(cnt, "HOUS", "g-H2") = ((step.val-1)/9)*newshare( cnt, "Hous", "g-H2", step)*temp(cnt,"Hous")  ;);
         loop(cnt,
                 temp(cnt,"GOVT") = sum( com$(FID(com)>0 and FID(com)<3 ), CGLZ(cnt,com)  );
                 T_adj(cnt, "GOVT", com)$(FID(com)>0 and FID(com)<3 and  newshare( cnt, "govt", com, step)) =  ((step.val-1)/9)*newshare( cnt, "GOVT", com, step)*temp(cnt,"GOVT") + (1-(step.val-1)/9)*CGZ(cnt, com) - CGLZ(cnt, com);
                 T_adj(cnt, "GOVT", "g-H2") = ((step.val-1)/9)*newshare( cnt, "GOVT", "g-H2", step)*temp(cnt,"GOVT");  );
*PP test






*Production Adjustment
*         XD.LO(cnt,  "POWR")$(step.val > 6) = refdata("Dir", step, cnt,  "POWR");


);

display B_adj, T_adj;


*Transform the adjustment coeficients to make them compatible with transport and other adjustments
B_adj(cnt, sec, com) = IOZ(cnt, com, sec)*B_adj(cnt, sec, com) - IOZ(cnt, com, sec);
B_adj(cnt, "Hous", com) = CZ(cnt, com)*B_adj(cnt, "Hous", com) - CZ(cnt, com);
B_adj(cnt, "GOVT", com) = CGLZ(cnt, com)*B_adj(cnt, "Govt", com) - CGLZ(cnt, com);



*Caculate the unadjusted total of sectors and consumer's inputs
pathway_unadj_total(cnt, sec, com) = IOZ(cnt, com, sec);
pathway_unadj_total(cnt, "Hous", com) = CZ(cnt, com);
pathway_unadj_total(cnt, "Govt", com) = CGLZ(cnt, com);
*pathway_unadj_total(cnt, sec, "H2") = 0;
*pathway_unadj_total(cnt, "Hous", "H2") = 0;
*pathway_unadj_total(cnt, "Govt", "H2") = 0;

*pathway_adj_total(cnt, sec, com)$(PID(com) = 2) = IOZ(cnt, com, sec) + B_adj(cnt, sec, com)+ T_adj*cnt, sec, com);
*pathway_adj_total(cnt, sec, com)$(PID(com) ne 2) = IOZ(cnt, com, sec);


*calculate the pathway adjustment
Pathway_adj(cnt, adjust_sec, com) = weight_b*B_adj(cnt, adjust_sec, com)+ weight_t*T_adj(cnt, adjust_sec, com);
Pathway_adj(cnt, adjust_sec, "g-H2") =  weight_t*T_adj(cnt, adjust_sec, "g-H2");


*Calculate the adjustment total
pathway_adj_total(cnt, sec, com) = IOZ(cnt, com, sec) + Pathway_adj(cnt, sec, com);
pathway_adj_total(cnt, "Hous", com) = CZ(cnt, com) + Pathway_adj(cnt, "Hous", com);
pathway_adj_total(cnt, "Govt", com) = CGLZ(cnt, com) + Pathway_adj(cnt, "Govt", com);
*pathway_adj_total(cnt, sec, "H2") = Pathway_adj(cnt, sec, "H2");
*pathway_adj_total(cnt, "Hous", "H2") =  Pathway_adj(cnt, "Hous", "H2");
*pathway_adj_total(cnt, "Govt", "H2") = Pathway_adj(cnt, "Govt", "H2");

*calculate the new total coeficient
loop((cnt, adjust_sec), Pathway_total(cnt, adjust_sec) = sum(adjust_com,  pathway_adj_total(cnt, adjust_sec, adjust_com) - pathway_unadj_total(cnt, adjust_sec, adjust_com)));
*b_total(cnt, "Hous") = sum(com,  pathway_adj_total(cnt, "Hous", com) - pathway_unadj_total(cnt, "Hous", com));
*b_total(cnt, "Govt") = sum(com,  pathway_adj_total(cnt, "Govt", com) - pathway_unadj_total(cnt, "Govt", com));

*PP 24) THE TOTAL INCREASE IN OTHER MATERIALS DECREASES THE USAGE OF CAPITAL
*caculate the capital increase per sector
Pathway_adj_cap(cnt, sec)$(KZ(cnt,sec)) = KZ(cnt,sec) - pathway_total(cnt, sec)$(pathway_total(cnt, sec)<0);


display B_adj, pathway_unadj_total, pathway_adj_total, pathway_total, pathway_adj_cap;


loop((cnt, adjust_sec, com), Pathway_adjusted(step, cnt,  sec, com) = Pathway_adj(cnt, sec, com););
*B_adjusted(step, cnt, "Hous", com) = b_adj(cnt, "Hous", com);
*B_adjusted(step, cnt, "Govt", com) = b_adj(cnt, "Govt", com);


Ttot(cnt,com)=sum((adjust_sec),T_adj(cnt, adjust_sec, com));
Btot(cnt,com)=sum((adjust_sec),B_adj(cnt, adjust_sec, com));

execute_unload "B_adj" b_adj, t_adj, pathway_adj, pathway_unadj_total, pathway_adj_total, pathway_total, pathway_adj_cap, KZ,IOZ,temp,newshare,newsharet,Btot,Ttot;



*check(cnt, sec, "IOZsum ")$(TID(sec)) = sum( com$(FID(com)>0 and FID(com)<3),IOZ(cnt, com, sec));
*check(cnt, sec, "T_adj")$(TID(sec)) = sum( com$(FID(com)>0 and FID(com)<3), T_adj(cnt, sec, com));
*check(cnt, sec, "IOZ-T_adj")$(TID(sec)) = sum( com$(FID(com)>0 and FID(com)<3), IOZ(cnt, com, sec) - T_adj(cnt, sec, com)) + newshare( cnt, sec, "H2", step)*temp;
*check(cnt, sec, com)$(FID(com)>0 and FID(com)<3 and TID(sec)) = IOZ(cnt, com, sec) - T_adj(cnt, sec, com);
check(cnt, com, "CZ")$(FID(com)>0 and FID(com)<3) =  CZ(cnt, com);
check(cnt, com, "T_adj")$(FID(com)>0 and FID(com)<3) = T_adj(cnt, "Hous", com);
*check(cnt, "H2", "T_adj") =  T_adj(cnt, "Hous", "H2");
check(cnt, "Hous", "CZ - T_adj") =  sum( com$(FID(com)>0 and FID(com)<3),CZ(cnt, com)) - (sum( com$(FID(com)>0 and FID(com)<3),T_adj(cnt, "hous",  com)) + T_adj(cnt, "Hous", "g-H2"));


*CAPITAL.L(cnt, sec)$((P_S> 0 and pathway_adj_cap(cnt, sec)))              =pathway_adj_cap(cnt, sec);
*CAPITAL.L(cnt, sec)$(P_S = 0)              =KZ(cnt,sec);


display check;

*=====================Re-Solve============
*option Savepoint = 1;

execute_unload "shocks.gdx" Pathway_adj, Pathway_adj_cap, KZ, Pathway_total, gdp_p,T_Adj,newshare,B_Adj;



$include "series_warmstart.gms"
*9000000
*execute_loadpoint "ARROW_DEBREU_p.gdx";
Arrow_Debreu.iterlim = 9999999;
ARROW_DEBREU.Savepoint = 1;
$INCLUDE ARROW_DEBREU.GEN
Solve ARROW_DEBREU using mcp;




*=====================save the values of the variables of interests ============

R_GDP(step, cnt) = (sum((com, sec), PD.L(cnt, sec, com)*R_PD_XD.L(cnt, sec, com) - P.L(cnt, com)*R_P_XD.L(cnt, sec, com)))/PU.L(cnt);
R_VA(step, cnt, sec) = (sum((com), PD.L(cnt, sec, com)*R_PD_XD.L(cnt, sec, com) - P.L(cnt, com)*R_P_XD.L(cnt, sec, com)))/PU.L(cnt);
R_P_OIL(step, cnt) = P.L(cnt, 'g-Oil');

R_welfare(step, cnt)$(not B_S) = REP_Welfare.L(cnt);
R_Welfare(step, cnt)$(B_S) = REP_Welfare_B.L(cnt);
R_labour(step, cnt,  sec) = (PL.L(cnt)*REP_Labour.L(cnt, sec))/PU.L(cnt);
R_Capital(step, cnt, sec) = RKC.L(cnt, sec)*REP_Capital.L(cnt, sec)/PU.L(cnt);
R_Production(step, cnt, sec, com) = REP_Production.L(cnt, sec, com);
R_EUtrade(step, cnt, com, CRR)$(used_currency(cnt, CRR)) = REP_EUTrade.L(cnt, com, CRR);
R_Income(step, cnt) = REP_Income.L(cnt);
R_XD(step, cnt, sec) = XD.L(cnt, sec);
R_P(step, cnt, com) = P.L(cnt, com);
R_U(step, cnt) = U.L(cnt);
R_PU(step, cnt) = PU.L(cnt);
R_HOUS(step, cnt) = HOUS.L(cnt);
Status(step) = Arrow_Debreu.solvestat;


REPORT_GDP(step, cnt) = (PL.L(cnt)*(LS.L(cnt)*(1-ty(cnt))*gdp_p(cnt)) + sum(sec, RKC.L(cnt, sec)*(KZ(cnt,sec)*(1-ty(cnt))*gdp_p(cnt))))/PU.L(cnt);
*REPORT_GDP(step, cnt) = PL.L(cnt)*(LS.L(cnt)*(1-ty(cnt))*gdp_p(cnt)) + sum(sec, RKC.L(cnt)*(KZ(cnt,sec)*(1-ty(cnt))*gdp_p(cnt)));
REPORT_GDP_labour(step, cnt) = PL.L(cnt)/PU.L(cnt);
REPORT_GDP_Capital(step, cnt, sec) = RKC.L(cnt, sec)/PU.L(cnt);
*REPORT_GDP_Capital(step, cnt, sec) = RKC.L(cnt);
REPORT_HOUS_CONS(step, cnt) = REP_HOUS_CONS.L(cnt);
REPORT_GOV_CONS(step, cnt) = REP_GOV_CONS.L(cnt);
REPORT_FIX_CAP_FORM(step, cnt) = sum(sec, RKC.L(cnt, sec)*(KZ(cnt,sec)*(1-ty(cnt))*gdp_p(cnt)));
*REPORT_FIX_CAP_FORM(step, cnt) = sum(sec, RKC.L(cnt)*(KZ(cnt,sec)*(1-ty(cnt))*gdp_p(cnt)));
REPORT_EXPORTS(step, cnt) = sum((CRR, com), ER.L(CRR)*REP_EXP_EU.L(cnt, com, CRR))/PU.L(cnt);
REPORT_IMPORTS(step, cnt) = (sum((CRR, com),   ER.L(CRR)*REP_IMP_ERR.L(cnt, com, CRR))
                            + sum( ( com, cntt )$(ord(cnt) ne ord(cntt))  , PTM.L(cnt, cntt)*REP_IMP_PTM.L(cnt, com, cntt) ))/PU.L(cnt);
REPORT_STOCKS(step, cnt) =  sum(com, P.L(cnt,com) * (-SV.L(cnt,com)) * R_SV.L(cnt,com))/PU.L(cnt);
REPORT_VA(step, cnt, sec) =    (sum(com, REP_SEC_OUT.L(cnt, sec, com))   - sum(com, REP_SEC_IN.L(cnt, sec, com)))/PU.L(cnt);
REPORT_EMPLOYMENT(step, cnt, sec)$(PL.L(cnt)*(LS.L(cnt)*(1-ty(cnt))*gdp_p(cnt))) =   REP_Labour.L(cnt, sec) /  (PL.L(cnt)*(LS.L(cnt)*(1-ty(cnt))*gdp_p(cnt)));


VAR_WELFARE(step,cnt)=(round(100*R_Welfare(step, cnt)/(CBUDZ(cnt) + Pathway_total(cnt, "Hous")$(Pathway_total(cnt, "Hous")<0)))/100-1)*100;
VAR_GDP(step, cnt)= (round(100*R_GDP(step, cnt)/(sum((com,sec),XDDZ(cnt,sec,com)-(IOZ(cnt,com,sec)+Pathway_adj(cnt, sec, com)))))/100-1)*100;
VAR_LABOUR(step, cnt, sec)=(round(100*REP_Labour.L(cnt, sec)/LZ(cnt,sec))/100-1)*100;
VAR_CAPITAL(step, cnt, sec)=(round(100*R_Capital(step, cnt, sec)/KZ(cnt,sec))/100-1)*100;
*VAR_PRODUCTION(step,cnt,sec)
*VAR_EUTRADE(step, cnt, com, CRR)
);



*=====================Report any variables desired ============




parameter demand(cnt,*,com,*), supply(cnt,*,com,*),report(*,cnt,*,com,*);
demand(cnt,sec,com,"2007")=IOZ(cnt,com,sec);
demand(cnt,"HOUS",com,"2007")=CZ(cnt,com);
demand(cnt,"GOVT",com,"2007")=CGZ(cnt,com);
demand(cnt,"INVB",com,"2007")=IZ(cnt,com);
demand(cnt,"stocks",com,"2007")=max(0,SVZ(cnt,com));
demand(cnt,"Exports",com,"2007")=sum(cntt$(ord(cntt) ne ord(cnt)),TRADEZ(com,cnt,cntt))+EROWZ(cnt,com);
demand(cnt,sec,com,"2050")=R_P_XD.L(cnt, sec, com);
demand(cnt,"HOUS",com,"2050")=HOUS_DEM.L(cnt,com);
demand(cnt,"GOVT",com,"2050")=GOVT_DEM.L(cnt,com);
demand(cnt,"INVB",com,"2050")=INVB_DEM.L(cnt,com);
demand(cnt,"Exports",com,"2050")=sum(crr,REP_EUTrade.L(cnt, com, CRR));
demand(cnt,"stocks",com,"2050")=max(0,SVZ(cnt,com)*R_SV.L(cnt,com));
demand(cnt,"tmarg",com,"2007")=TMCZ(cnt,com);

supply(cnt,sec,com,"2007")=XDDZ(cnt,sec,com);
supply(cnt,sec,com,"2050")=R_PD_XD.L(cnt, sec, com);
supply(cnt,"Imports",com,"2007")=MROWZ(cnt,com)+sum(cntt$(ord(cntt) ne ord(cnt)),TRADEZ(com,cntt,cnt));
supply(cnt,"Imports",com,"2050")=sum(crr,REP_EXPin.L(CRR,cnt,com));
supply(cnt,"stocks",com,"2007")=max(0,-SVZ(cnt,com));
supply(cnt,"stocks",com,"2050")=max(0,-SVZ(cnt,com)*R_SV.L(cnt,com));
supply(cnt,"tmarg",com,"2007")=TMXZ(cnt,com);

report("demand",cnt,sec,com,"2007")=(1+taxc(cnt,com))*demand(cnt,sec,com,"2007");
report("demand",cnt,"HOUS",com,"2007")=(1+taxc(cnt,com))*demand(cnt,"HOUS",com,"2007");
report("demand",cnt,"GOVT",com,"2007")=(1+taxc(cnt,com))*demand(cnt,"GOVT",com,"2007");
report("demand",cnt,"INVB",com,"2007")=(1+taxc(cnt,com))*demand(cnt,"INVB",com,"2007");
report("demand",cnt,"Exports",com,"2007")=demand(cnt,"Exports",com,"2007");
report("demand",cnt,"stocks",com,"2007")=demand(cnt,"stocks",com,"2007");
report("demand",cnt,"tmarg",com,"2007")=demand(cnt,"tmarg",com,"2007");
report("demand",cnt,sec,com,"2050")=P.L(cnt, com)*(1+taxc(cnt,com))*demand(cnt,sec,com,"2050");
report("demand",cnt,"HOUS",com,"2050")=P.L(cnt, com)*(1+taxc(cnt,com))*demand(cnt,"HOUS",com,"2050");
report("demand",cnt,"GOVT",com,"2050")=P.L(cnt, com)*(1+taxc(cnt,com))*demand(cnt,"GOVT",com,"2050");
report("demand",cnt,"INVB",com,"2050")=P.L(cnt, com)*(1+taxc(cnt,com))*demand(cnt,"INVB",com,"2050");
report("demand",cnt,"Exports",com,"2050")=sum(crr,ER.L(CRR)*REP_EUTrade.L(cnt, com, CRR));
report("demand",cnt,"stocks",com,"2050")=P.L(cnt, com)*demand(cnt,"stocks",com,"2050");
report("demand",cnt,"tmarg",com,"2050")=P.L(cnt,com)*TMout.l(com,cnt);

report("supply",cnt,sec,com,"2007")=(1-taxp(cnt,sec))*supply(cnt,sec,com,"2007");
report("supply",cnt,sec,com,"2050")=PD.L(cnt,sec,com)*(1-taxp(cnt,sec))*supply(cnt,sec,com,"2050");
report("supply",cnt,"Imports",com,"2007")=supply(cnt,"Imports",com,"2007");
report("supply",cnt,"Imports",com,"2050")=sum(crr,ER.L(CRR)*REP_EXPin.L(CRR,cnt,com));
report("supply",cnt,"stocks",com,"2007")=supply(cnt,"stocks",com,"2007");
report("supply",cnt,"stocks",com,"2050")=P.L(cnt, com)*supply(cnt,"stocks",com,"2050");
report("supply",cnt,"tmarg",com,"2007")=supply(cnt,"tmarg",com,"2007");
report("supply",cnt,"tmarg",com,"2050")=sum(cntt,PTM.L(cntt,cnt)*TMin.l(com,cntt,cnt));

*display R_GDP, R_P_OIL;
execute_unload "Results.gdx" R_GDP, R_welfare, R_P_Oil, CRR, R_XD, R_P, R_U, R_PU, R_HOUS,  R_labour, R_capital, R_production, R_eutrade, R_income, used_currency, Status;
execute_unload "REMES_Results.gdx" R_GDP, Status, CRR, used_currency, REPORT_GDP, REPORT_GDP_CAPITAL, REPORT_GDP_LABOUR, REPORT_HOUS_CONS, REPORT_GOV_CONS,
REPORT_FIX_CAP_FORM, REPORT_EXPORTS, REPORT_IMPORTS, REPORT_STOCKS, REPORT_VA, REPORT_EMPLOYMENT, R_LAbour, R_Capital,
R_Income, R_welfare, R_P_Oil, CRR, R_XD, R_P, R_U, R_PU, R_HOUS,  R_labour, R_capital, R_production, R_eutrade, R_income, used_currency, REP_SEC_OUT, REP_SEC_In, R_VA, Pathway_adjusted;

parameter changeTech(cnt,com,sec);
changeTech(cnt,com,sec)=R_P_XD.L(cnt, sec, com)/IOZ(cnt,com,sec);

display IZ;
execute_unload "Results_PAOLO.gdx" VAR_WELFARE, VAR_GDP,VAR_LABOUR,VAR_CAPITAL,changeTech,demand,supply,report;
execute_unload "Sectoral_structure.gdx" XDDZ, taxpz, IOZ, Pathway_adj, taxcz, LZ, Pathway_adj_cap, KZ, pathway_total, INVZ;
display status;

parameter price(cnt,com,sec);
price(cnt,com,sec)=(IOZ(cnt,com,sec)*(1+taxcz(cnt,com)));
display price;

parameter EneDem(cnt,*),EneDemBase(cnt,*),EneDemProj(cnt,*);
EneDem(cnt,sec)=(R_P_XD.L(cnt, sec, "g-POWR")+R_P_XD.L(cnt, sec, "g-POWF"))/
                 (IOZ(cnt, "g-POWR", sec)+IOZ(cnt, "g-POWF", sec));
EneDem(cnt,"CONS")=(HOUS_DEM.L(cnt,"g-POWR")+HOUS_DEM.L(cnt,"g-POWF")
                 +GOVT_DEM.L(cnt,"g-POWR")+GOVT_DEM.L(cnt,"g-POWF")
                 +INVB_DEM.L(cnt,"g-POWR")+INVB_DEM.L(cnt,"g-POWF"))/
                 (CZ(cnt,"g-POWR")+CZ(cnt,"g-POWF")
                 +CGLZ(cnt,"g-POWR")+CGLZ(cnt,"g-POWF")
                 +IZ(cnt,"g-POWR")+IZ(cnt,"g-POWF"));

EneDemBase(cnt,sec)=IOZ(cnt, "g-POWR", sec)+IOZ(cnt, "g-POWF", sec);
EneDemBase(cnt,"CONS")=CZ(cnt,"g-POWR")+CZ(cnt,"g-POWF")
                 +CGLZ(cnt,"g-POWR")+CGLZ(cnt,"g-POWF")
                 +IZ(cnt,"g-POWR")+IZ(cnt,"g-POWF");


EneDemProj(cnt,sec)=R_P_XD.L(cnt, sec, "g-POWR")+R_P_XD.L(cnt, sec, "g-POWF");
EneDemProj(cnt,"CONS")=HOUS_DEM.L(cnt,"g-POWR")+HOUS_DEM.L(cnt,"g-POWF")
                 +GOVT_DEM.L(cnt,"g-POWR")+GOVT_DEM.L(cnt,"g-POWF")
                 +INVB_DEM.L(cnt,"g-POWR")+INVB_DEM.L(cnt,"g-POWF");


*EneDem(cnt,"HOUS")=(HOUS_DEM.L(cnt,"g-POWR")+HOUS_DEM.L(cnt,"g-POWF")+HOUS_DEM.L(cnt,"g-POWT"))/
*                 (CZ(cnt,"g-POWR")+CZ(cnt,"g-POWF")+CZ(cnt,"g-POWT"));
*EneDem(cnt,"GOVT")=(GOVT_DEM.L(cnt,"g-POWR")+GOVT_DEM.L(cnt,"g-POWF")+GOVT_DEM.L(cnt,"g-POWT"))/
*                 (CGLZ(cnt,"g-POWR")+CGLZ(cnt,"g-POWF")+CGLZ(cnt,"g-POWT"));
*EneDem(cnt,"INV")=(INVB_DEM.L(cnt,"g-POWR")+INVB_DEM.L(cnt,"g-POWF")+INVB_DEM.L(cnt,"g-POWT"))/
*                 (IZ(cnt,"g-POWR")+IZ(cnt,"g-POWF")+IZ(cnt,"g-POWT"));



execute_unload "energy_demand.gdx" EneDem, EneDemBase,EneDemProj;

$include "balances.gms"

parameter enedemand(cnt,*,*);
enedemand(cnt,"HOUS","2007")=sum(com$(PID(com)=2),demand(cnt,"HOUS",com,"2007"));
enedemand(cnt,"HOUS","2050")=sum(com$(PID(com)=2),demand(cnt,"HOUS",com,"2050"));

parameter outTemplate(*,*,cnt,*,*,*);
*outtemplate("REMES EU",SW_Case,r,"Power Demand Households","base index","2007")=demand(cnt,"HOUS",com,"2007");
outTemplate("REMES EU","Ref",cnt,"Power Demand Households","base index","2010")=1;
outTemplate("REMES EU","Ref",cnt,"Power Demand Households","base index","2015")=(enedemand(cnt,"HOUS","2007")+(enedemand(cnt,"HOUS","2050")-enedemand(cnt,"HOUS","2007"))/(2050-2007)*(2015-2007))/(enedemand(cnt,"HOUS","2007")+(enedemand(cnt,"HOUS","2050")-enedemand(cnt,"HOUS","2007"))/(2050-2007)*(2010-2007));
outTemplate("REMES EU","Ref",cnt,"Power Demand Households","base index","2020")=(enedemand(cnt,"HOUS","2007")+(enedemand(cnt,"HOUS","2050")-enedemand(cnt,"HOUS","2007"))/(2050-2007)*(2020-2007))/(enedemand(cnt,"HOUS","2007")+(enedemand(cnt,"HOUS","2050")-enedemand(cnt,"HOUS","2007"))/(2050-2007)*(2010-2007));
outTemplate("REMES EU","Ref",cnt,"Power Demand Households","base index","2025")=(enedemand(cnt,"HOUS","2007")+(enedemand(cnt,"HOUS","2050")-enedemand(cnt,"HOUS","2007"))/(2050-2007)*(2025-2007))/(enedemand(cnt,"HOUS","2007")+(enedemand(cnt,"HOUS","2050")-enedemand(cnt,"HOUS","2007"))/(2050-2007)*(2010-2007));
outTemplate("REMES EU","Ref",cnt,"Power Demand Households","base index","2030")=(enedemand(cnt,"HOUS","2007")+(enedemand(cnt,"HOUS","2050")-enedemand(cnt,"HOUS","2007"))/(2050-2007)*(2030-2007))/(enedemand(cnt,"HOUS","2007")+(enedemand(cnt,"HOUS","2050")-enedemand(cnt,"HOUS","2007"))/(2050-2007)*(2010-2007));
outTemplate("REMES EU","Ref",cnt,"Power Demand Households","base index","2035")=(enedemand(cnt,"HOUS","2007")+(enedemand(cnt,"HOUS","2050")-enedemand(cnt,"HOUS","2007"))/(2050-2007)*(2035-2007))/(enedemand(cnt,"HOUS","2007")+(enedemand(cnt,"HOUS","2050")-enedemand(cnt,"HOUS","2007"))/(2050-2007)*(2010-2007));
outTemplate("REMES EU","Ref",cnt,"Power Demand Households","base index","2040")=(enedemand(cnt,"HOUS","2007")+(enedemand(cnt,"HOUS","2050")-enedemand(cnt,"HOUS","2007"))/(2050-2007)*(2040-2007))/(enedemand(cnt,"HOUS","2007")+(enedemand(cnt,"HOUS","2050")-enedemand(cnt,"HOUS","2007"))/(2050-2007)*(2010-2007));
outTemplate("REMES EU","Ref",cnt,"Power Demand Households","base index","2045")=(enedemand(cnt,"HOUS","2007")+(enedemand(cnt,"HOUS","2050")-enedemand(cnt,"HOUS","2007"))/(2050-2007)*(2045-2007))/(enedemand(cnt,"HOUS","2007")+(enedemand(cnt,"HOUS","2050")-enedemand(cnt,"HOUS","2007"))/(2050-2007)*(2010-2007));
outTemplate("REMES EU","Ref",cnt,"Power Demand Households","base index","2050")=enedemand(cnt,"HOUS","2050")/(enedemand(cnt,"HOUS","2007")+(enedemand(cnt,"HOUS","2050")-enedemand(cnt,"HOUS","2007"))/(2050-2007)*(2010-2007));

execute_unload "dataTemplate.gdx" outTemplate;
