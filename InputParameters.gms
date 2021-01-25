* ============                             ===================
* ============ Elasticities                  ===================
* ============                             ===================
*PP 11) INTRODUCE ELASTICITIES (kl, kle, klem PER SECTOR)
parameter ELAS(*, *),ELAS0(*, *),elasM(*);

$gdxin 'TestElas'
$load ELAS0=ELAS
$gdxin

parameter urate(cnt) unemployment rate in base year (2010) /
AT        =        0.041
BE        =        0.07
BG        =        0.092
CY        =        0.051
CZ        =        0.064
DE        =        0.0697
DK        =        0.063
EE        =        0.149
ES        =        0.178
FI        =        0.066
FR        =        0.077
GR        =        0.127
HU        =        0.1
IE        =        0.12
IT        =        0.084
LT        =        0.161
LU        =        0.038
LV        =        0.174
MT        =        0.056
NL        =        0.039
PL        =        0.081
PT        =        0.105
RO        =        0.0696
SE        =        0.086
SI        =        0.065
SK        =        0.125
GB        =        0.058
CH        =        0.0166
NO        =        0.027
/;

* from file Scenario_emissions/BAU by TNO
parameter eint0(cnt)  energy intensity in 2050 /
AT        =        0.61
BE        =        0.50
BG        =        0.40
CY        =        0.54
CZ        =        0.40
DE        =        0.65
DK        =        0.58
EE        =        0.55
ES        =        0.48
FI        =        0.49
FR        =        0.54
GR        =        0.66
HU        =        0.52
IE        =        0.55
IT        =        0.53
LT        =        0.64
LU        =        0.4
LV        =        0.65
MT        =        0.49
NL        =        0.48
PL        =        0.35
PT        =        0.57
RO        =        0.38
SE        =        0.44
SI        =        0.51
SK        =        0.23
GB        =        0.44
CH        =        0.69
NO        =        0.69
/;

* from file Scenario_emissions/BAU by TNO
parameter cint0(cnt)  carbon intensity in 2050 /
AT        =        0.55
BE        =        0.57
BG        =        0.43
CY        =        0.72
CZ        =        0.49
DE        =        0.60
DK        =        0.55
EE        =        0.39
ES        =        0.59
FI        =        0.46
FR        =        0.57
GR        =        0.48
HU        =        0.50
IE        =        0.31
IT        =        0.60
LT        =        0.49
LU        =        0.48
LV        =        0.29
MT        =        0.16
NL        =        0.55
PL        =        0.40
PT        =        0.61
RO        =        0.48
SE        =        0.25
SI        =        0.49
SK        =        0.50
GB        =        0.45
CH        =        0.57
NO        =        0.57
/;

*PP 10) HERE WE IDENTIFY THE RESOURCES (1) ENERGY (2) TRANSPORT (3) COMMODITIES
* FOR THE OUTPUT PRINTS (?)

*Identify the transport commodities and sectors, and the energy commodities
Parameter PID0(com0), SID0(sec0);
PID0(com0) = 0;
SID0(sec0) = 0;
* PRODUCT IDENTIFIER, SECTOR IDENTIFIER, FACTOR IDENTIFIER, TRANSPORT IDENTIFIER
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

* ####### write sam in percentages for selected goods. #############
set leap /l3*l10/;

Parameter CID0(com0);
CID0(com0)=0;
CID0('c-POWF')=1;
CID0('c-POWR')=1;
CID0('c-POWT')=1;
CID0('c-CRUDE-OIL')=1;
CID0('c-OIL-GSL')=1;
CID0('c-OIL-DSL')=1;
CID0('c-OIL-KER')=1;
CID0('c-OIL-LDSF')=1;
CID0('c-OIL-HDI')=1;
CID0('c-BIO')=1;
CID0('c-COAL')=1;
CID0('c-NG')=1;
*CID0('c-H2')=1;

* from GTAP
parameter elasM0(com0) armington elasticities between imports and domestic /
C-AAGR        3
C-IMIN        0.9
C-IRES        3.5
C-NG          17.2
C-BIO         1.4
C-POWF        2.8
C-POWR        2.8
C-POWT        2.8
C-LTH         1.4
C-COTH        1.9
C-CCON        1.9
C-CWSR        1.9
C-COFF        1.9
C-C_TRAI      1.9
C-C_TLND      1.9
C-C_TPIP      1.9
C-CHEA        1.9
C-Waste       1.9
C-COAL        3
C-CRUDE-OIL   5.2
C-GASE        17.2
C-OIL-GSL     5.2
C-OIL-JET     5.2
C-OIL-KER     5.2
C-OIL-DSL     5.2
C-OIL-HDI     5.2
C-OIL-LDSF    5.2
C-IMEA        3.75
C-C_TWAS      1.9
C-C_TWAI      1.9
C-C_TAIR      1.9
C-COIL        5.2
/;


* ========== Redefinition of the SAM, trade and trade margin matrices ==========

set sec /
i-AGR
i-IND
i-ALA
i-SERV
i-TRA
i-POW
i-POWT
i-COAL
i-COIL
i-NG
i-H2S
i-H2E
i-H2CCS
i-PCCS
/

set com /
gAGR
gIND
gALA
gSER
gTRA
gPOW
gPOT
gLTH
gOIL
gGSL
gDSL
gHDI
gNG
gCOA
gBIO
gFUL
gH2
/;

parameter worldcom(com);
worldcom(com)=0;
worldcom("gOIL")=1;
worldcom("gNG")=1;
worldcom("gCOA")=1;

* mapping original sectors and selected aggregations
set maps(sec0,sec)/
AAGR.i-AGR
COAL.i-COAL
COIL.i-COIL
IMIN.i-IND
IRES.i-IND
IALA.i-ALA
POWF.i-POW
POWR.i-POW
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

* mapping original commodities and selected aggregations
set mapc(com0,com)/
c-AAGR.gAGR
c-IMIN.gIND
c-IRES.gIND
c-NG.gNG
c-BIO.gBIO
c-POWF.gPOW
c-POWR.gPOW
c-POWT.gPOT
c-LTH.gLTH
c-COTH.gSER
c-CCON.gIND
c-CWSR.gSER
c-COFF.gSER
c-C_TRAI.gTRA
c-C_TLND.gTRA
c-C_TPIP.gTRA
c-CHEA.gSER
c-Waste.gSER
c-COAL.gCOA
c-CRUDE-OIL.gOIL
c-GASE.gNG
c-OIL-GSL.gGSL
c-OIL-JET.gFUL
c-OIL-KER.gFUL
c-OIL-DSL.gDSL
c-OIL-HDI.gHDI
c-OIL-LDSF.gFUL
c-IMEA.gALA
c-C_TWAS.gTRA
c-C_TWAI.gTRA
c-C_TAIR.gTRA
c-COIL.gOIL
/;

* resource sectors
set ressecs(sec) /
i-COIL
i-COAL
i-NG
/;

* industrial sectors
set indsecs(sec) /
i-IND
i-TRA
/;

* fossil fuels
set fosfuels(com) /
gOIL
gGSL
gDSL
gHDI
gNG
gCOA
gFUL
/;

* energy commodities
set energy(com) /
gGSL
gDSL
gHDI
gNG
gCOA
gFUL
gPOW
gH2
gBIO
gOIL
/

* power sectors
set powsecs(sec)
/
i-POW
/;

* fossil fuels identifier
parameter FF(com);
FF(com)=0;
FF(fosfuels)=1;


Parameter PID(com);
PID(com) = 0;

PID('gbio') = 1;
*PID('gpof') = 2;
PID('gpow') = 2;
PID('gpot') = 4;
PID('gcoa') = 1;
PID('gng')  = 1;
PID('goil') = 1;
PID('ghdi') = 1;
PID('ggsl') = 1;
PID('gdsl') = 1;
PID('gful') = 1;
PID('gtra') = 3;
PID('gH2')  = 1;


* assign the new sector with zero activity in the benchmark
XDDZ(cnt,"i-H2S","gH2") = 0 ;
XDDZ(cnt,"i-H2CCS","gH2") = 0 ;
XDDZ(cnt,"i-H2E","gH2") = 0 ;
XDDZ(cnt,"i-PCCS",com) = 0 ;



Parameter SID(sec);
Parameter FID(com);
FID(com) = 0;
FID('gng') = 1;
FID('gbio') = 1;
FID('gpow') = 2;
FID('gful') = 1;
FID('gpot') = 2;
FID('goil') = 1;
FID('ggsl') = 1;
FID('gdsl') = 1;
FID('ghdi') = 1;
FID('gcoa') = 1;
FID('gtra') = 3;
FID('gH2')=1;

SID(sec) = 0;
* SECTORS THAT UNDERGO TRANSITION (UNDER TAG "T")
SID('i-TRA') = 3;
SID('i-AGR') = 3;
SID('i-IND') = 3;
SID('i-ALA') = 3;
*SID('i-POWF') = 3;
SID('i-POW') = 3;
SID('i-POWT') = 3;
SID('i-SERV') = 3;
SID('i-TRA') = 3;
SID('i-COIL') = 3;
SID('i-NG') = 3;

*SID('i-H2') = 3;

Parameter TID(sec),CID(com);

TID(sec) = 0;
CID(com)=0;

TID('i-tra') = 3;
* commodities that are in newshare at the beginning (time 2)
*CID('gPOR')=1;
CID('gPOW')=1;
CID('gPOT')=1;
CID('gOIL')=1;
CID('gGSL')=1;
CID('gDSL')=1;
CID('gFUL')=1;
CID('gBIO')=1;
CID('gCOA')=1;
CID('gNG')=1;
CID('gHDI')=1;
CID('gH2')=1;


* New sectors structure
parameter InputCom(sec,com) New sectors input
/
i-H2S.gSER   0.2
i-H2S.gIND   0.58
i-H2S.gNG    0.76
i-H2CCS.gSER   0.2
i-H2CCS.gIND   0.38
i-H2CCS.gNG    0.76
i-H2CCS.gPOW    0.4
i-H2E.gSER   0.1
i-H2E.gPOW   3.46
i-H2E.gIND   0.02
/;

* ======================= UPGRADE ELASTICITIES =================================

*elasticities for new sectors
ELAS("i-H2S","KL")=0.3;
ELAS("i-H2S","KLE")=0.1;
ELAS("i-H2S","KLEM")=0.1;
ELAS("i-H2CCS","KL")=0.3;
ELAS("i-H2CCS","KLE")=0.1;
ELAS("i-H2CCS","KLEM")=0.1;
ELAS("i-H2E","KL")=0.3;
ELAS("i-H2E","KLE")=0.1;
ELAS("i-H2E","KLEM")=0.1;

* rate of return for recoursive dynamic model
parameter ror(cnt) return on capital (non-temporal measure) /
AT        0.064750563
BE        0.089533446
BG        0.136334302
CY        0.106362307
CZ        0.060507687
DE        0.063182178
DK        0.057037486
EE        0.106545872
ES        0.091810948
FI        0.071815675
FR        0.077219314
GR        0.063228241
HU        0.049390369
IE        0.127667441
IT        0.077656774
LT        0.060549631
LU        0.062262071
LV        0.086238967
MT        0.089632201
NL        0.064158495
PL        0.073664362
PT        0.113106184
RO        0.253896301
SE        0.096012898
SI        0.233838599
SK        0.079693654
GB        0.052138654
CH        0.061020907
NO        0.063209706
/;


* Definition of CO2 final emissions
* ================ CPD - COUNTERFACTUAL POLICY DEFINITION =====================
parameter finCO2(cnt) final percentage by country /
AT        0.18
BE        0.18
BG        0.18
CY        1
CZ        0.18
DE        0.18
DK        0.18
EE        0.18
ES        0.18
FI        0.18
FR        0.18
GR        0.18
HU        0.18
IE        0.18
IT        0.18
LT        0.18
LU        1
LV        1
MT        1
NL        0.18
PL        0.18
PT        0.18
RO        0.18
SE        0.18
SI        0.18
SK        0.18
GB        0.18
CH        0.18
NO        0.18
/;


* calibratiom values to obtain baseline GDP
parameter GDPcal(cnt) gdp calibration /
AT        0.96
BE        0.94
BG        0.89
CY        0.94
CZ        0.9
DE        0.95
DK        0.95
EE        0.89
ES        0.9
FI        0.93
FR        0.94
GR        0.97
HU        0.9
IE        0.92
IT        0.93
LT        0.94
LU        0.86
LV        0.89
MT        0.92
NL        0.93
PL        0.92
PT        0.91
RO        0.88
SE        0.92
SI        0.9
SK        0.82
GB        0.94
CH        0.97
NO        1.02
/;

* ================ CPD - COUNTERFACTUAL POLICY DEFINITION =====================
* growth of land use
parameter LandGrowth(cnt) 5 year land growth rate /
AT        0.138111229
BE        0.266441895
BG        0.336005748
CH        0.245966987
CY        0.53514481
CZ        0.313588857
DE        0.262087695
DK        0.337924053
EE        0.574071693
FI        0.280064776
FR        0.321284907
GR        0.370655046
HU        0.504724073
IE        0.471565163
IT        0.236370753
LV        0.293095751
LT        0.567068177
LU        0.143335207
MT        0.655050653
NL        0.487332752
PL        0.541141177
PT        0.234034764
RO        0.28126186
SK        0.294977163
SI        0.108682411
ES        0.270714647
SE        0.208998247
GB        0.45782146
NO        0.107295791
/;

scalar prdR productivity increase factor after the benchmark /0/;

* ================ CPD - COUNTERFACTUAL POLICY DEFINITION =====================
Set step /1*10/;

* Counterfactual point 5 Tariffs

parameter tft(step) tariff on imports per period /
1  0
2  0
3  0
4  0.1
5  0.5
6  1.5
7  2
8  2.5
9  3
10 4
/;

$include "growth_table.gms"
