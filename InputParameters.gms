* ============                             ===================
* ============ Elasticities                  ===================
* ============                             ===================
*PP 11) INTRODUCE ELASTICITIES (kl, kle, klem PER SECTOR)
parameter ELAS(*, *),ELAS0(*, *),elasM(*);

$gdxin 'TestElas'
$load ELAS0=ELAS
$gdxin

set EU27(cnt) /
AT
BE
BG
CZ
CY
DK
EE
FI
FR
DE
GR
HU
IE
IT
LV
LT
LU
MT
NL
PL
PT
RO
SK
SI
ES
SE
*NO
*GB
*CH
/;



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

* from file Scenario_emissions/BAU by TNO Extra 20% decrease
parameter eint1(cnt)  energy intensity in 2050 /
AT        =        0.42
BE        =        0.34
BG        =        0.52
CH        =        0.37
CZ        =        0.47
CY        =        0.40
DK        =        0.41
EE        =        0.40
FI        =        0.36
FR        =        0.38
DE        =        0.46
GR        =        0.43
HU        =        0.39
IE        =        0.38
IT        =        0.40
LV        =        0.42
LT        =        0.48
LU        =        0.31
MT        =        0.47
NL        =        0.41
PL        =        0.51
PT        =        0.39
RO        =        0.52
SK        =        0.47
SI        =        0.42
ES        =        0.42
SE        =        0.38
GB        =        0.39
NO        =        0.39
/;

*eint0(cnt)$(ExEff eq 1)=0*eint0(cnt)+1*eint1(cnt);


$ontext
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
* ##### REMOVE THIS!!! ######
*cint0(cnt)=0.8;
*############################
$offtext


*PP9b) HERE I PUT THE GROWTH OF THE DEMAND FROM THE REST OF THE WORLD.
* I ASSUME THAT IN GRADUAL DEVELOPMENT THE INDEX IS 1
* the data comes from Scenario_input_communication_fileGD_TNO.xlsx - sheet GDP_ROW
PARAMETER ROWd;
* for Gradual Development and Reference
ROWd=1;
* update only if the switch ROWgr is = 1
* for Techno-Friendly (denominator is the base value used for GD and Ref
ROWd$(P_S eq 3 and ROWgr eq 1)=((2.56+4.5)/(2.56+3.31))**(5/(2050-2011));
* for Societal Commitment
ROWd$(P_S eq 4 and ROWgr eq 1)=((2.56+4.5)/(2.56+3.31))**(5/(2050-2011));
* for Directed Transition
ROWd$(P_S eq 5 and ROWgr eq 1)=((2.57+3.31)/(2.56+3.31))**(5/(2050-2011));

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
iAGR
iIND
iALU
iSER
iTRA
iELC
iTRD
iCOA
iCOI
iNG
*New sectors
iH2S
iH2E
iH2C
*iECS
/

set secout /
iAGRI
iINDU
iCOAL
iCOIL
iALUM
iTRDI
iNGAS
iSERV
iTRAN
iELCE
iH2
/;

set com /
pAGR
pIND
pALU
pSER
pTRA
pELE
pTRD
pHTW
pOIL
pGSL
pDSL
pHDI
pNG
pCOA
pBIO
pFUL
pH2
/;

set comout /
pAGRI
pINDU
pALUM
pSERV
pTRAN
pELEC
pTRDI
pHTWT
pOIL
pGSL
pDSL
pHDI
pNG
pCOA
pBIO
pFUL
pH2
/;


set GWsec(sec) sectors hit by effects of global warming /
iAGR
iIND
iALU
iTRA
iCOA
iCOI
iNG
/;

parameter ENC(comout);
ENC(comout)=0;
ENC('pOIL')=1;
ENC('pGSL')=1;
ENC('pDSL')=1;
ENC('pHDI')=1;
ENC('pNG')=1;
ENC('pCOA')=1;
ENC('pBIO')=1;
ENC('pFUL')=1;


parameter worldcom(com);
worldcom(com)=0;
worldcom("pOIL")=1;
worldcom("pNG")=1;
worldcom("pCOA")=1;

* mapping original sectors and selected aggregations
set maps(sec0,sec)/
AAGR.iAGR
COAL.iCOA
COIL.iCOI
IMIN.iIND
IRES.iIND
IALA.iALU
POWF.iELC
POWR.iELC
POWT.iTRD
NG.iNG
LTH.iIND
COTH.iSER
CCON.iIND
CWSR.iSER
COFF.iSER
C_TRAI.iTRA
C_TLND.iTRA
C_TPIP.iTRA
C_TWAS.iTRA
C_TWAI.iTRA
C_TAIR.iTRA
CHEA.iIND
Waste.iSER
BIO.iAGR
/;

* mapping original commodities and selected aggregations
set mapc(com0,com)/
c-AAGR.pAGR
c-IMIN.pIND
c-IRES.pIND
c-NG.pNG
c-BIO.pBIO
c-POWF.pELE
c-POWR.pELE
c-POWT.pTRD
c-LTH.pHTW
c-COTH.pSER
c-CCON.pIND
c-CWSR.pSER
c-COFF.pSER
c-C_TRAI.pTRA
c-C_TLND.pTRA
c-C_TPIP.pTRA
c-CHEA.pSER
c-Waste.pSER
c-COAL.pCOA
c-CRUDE-OIL.pOIL
c-GASE.pNG
c-OIL-GSL.pGSL
c-OIL-JET.pFUL
c-OIL-KER.pFUL
c-OIL-DSL.pDSL
c-OIL-HDI.pHDI
c-OIL-LDSF.pFUL
c-IMEA.pALU
c-C_TWAS.pTRA
c-C_TWAI.pTRA
c-C_TAIR.pTRA
c-COIL.pOIL
/;

set maps2(sec,secout) /
iAGR        .        iAGRI
iIND        .        iINDU
iALU        .        iALUM
iSER        .        iSERV
iTRA        .        iTRAN
iELC        .        iELCE
iTRD        .        iTRDI
iCOA        .        iCOAL
iCOI        .        iCOIL
iNG         .        iNGAS
iH2S        .        iH2
iH2E        .        iH2
iH2C        .        iH2
/;

set mapc2(com,comout) /
pAGR        .        pAGRI
pIND        .        pINDU
pALU        .        pALUM
pSER        .        pSERV
pTRA        .        pTRAN
pELE        .        pELEC
pTRD        .        pTRDI
pHTW        .        pHTWT
pOIL        .        pOIL
pGSL        .        pGSL
pDSL        .        pDSL
pHDI        .        pHDI
pNG         .        pNG
pCOA        .        pCOA
pBIO        .        pBIO
pFUL        .        pFUL
pH2         .        pH2
/;

* resource sectors
set ressecs(sec) /
iCOI
iCOA
iNG
/;

* industrial sectors
set indsecs(sec) /
iIND
iTRA
/;

set ensecs(sec) /
iELC
iCOA
iCOI
iNG
iH2S
iH2E
iH2C
/;

* fossil fuels
set fosfuels(com) /
pOIL
pGSL
pDSL
pHDI
pNG
pCOA
pFUL
/;


* energy commodities
set energy(com) /
pGSL
pDSL
pHDI
pNG
pCOA
pFUL
pELE
pH2
pBIO
pOIL
/



set materials(com) /
pAGR
pIND
pALU
pSER
pTRA
pTRD
pHTW
/;


* power sectors
set powsecs(sec)
/
iELC
/;

* fossil fuels identifier
parameter FF(com);
FF(com)=0;
FF(fosfuels)=1;


Parameter PID(com);
PID(com) = 0;

PID('pBIO') = 1;
*PID('gpof') = 2;
PID('pELE') = 2;
PID('pTRD') = 4;
PID('pCOA') = 1;
PID('pNG')  = 1;
PID('pOIL') = 1;
PID('pHDI') = 1;
PID('pGSL') = 1;
PID('pDSL') = 1;
PID('pFUL') = 1;
PID('pTRA') = 3;
PID('pH2')  = 1;


* assign the new sector with zero activity in the benchmark
XDDZ(cnt,"iH2S","pH2") = 0 ;
XDDZ(cnt,"iH2C","pH2") = 0 ;
XDDZ(cnt,"iH2E","pH2") = 0 ;



Parameter SID(sec);
Parameter FID(com);
FID(com) = 0;
FID('pNG') = 1;
FID('pBIO') = 1;
FID('pELE') = 2;
FID('pFUL') = 1;
FID('pTRD') = 2;
FID('pOIL') = 1;
FID('pGSL') = 1;
FID('pDSL') = 1;
FID('pHDI') = 1;
FID('pCOA') = 1;
FID('pTRA') = 3;
FID('pH2')=1;

SID(sec) = 0;
* SECTORS THAT UNDERGO TRANSITION (UNDER TAG "T")
SID('iTRA') = 3;
SID('iAGR') = 3;
SID('iIND') = 3;
SID('iALU') = 3;
*SID('iELCF') = 3;
SID('iELC') = 3;
SID('iTRD') = 3;
SID('iSER') = 3;
SID('iTRA') = 3;
SID('iCOI') = 3;
SID('iNG') = 3;

*SID('i-H2') = 3;

Parameter TID(sec),CID(com);

TID(sec) = 0;
CID(com)=0;

TID('iTRA') = 3;
* commodities that are in newshare at the beginning (time 2)
*CID('gPOR')=1;
CID('pELE')=1;
CID('pTRD')=1;
CID('pOIL')=1;
CID('pGSL')=1;
CID('pDSL')=1;
CID('pFUL')=1;
CID('pBIO')=1;
CID('pCOA')=1;
CID('pNG')=1;
CID('pHDI')=1;
CID('pH2')=1;


* New sectors structure
* H2 production pg 16   and pg 41
parameter InputCom(sec,com) New sectors input
/
iH2S.pSER   0.2
iH2S.pIND   0.58
iH2S.pNG    0.76
iH2C.pSER   0.2
iH2C.pIND   0.58
iH2C.pNG    0.76
iH2C.pELE    0.4
iH2E.pSER   0.1
iH2E.pELE   3.46
iH2E.pIND   0.02
/;

* ======================= UPGRADE ELASTICITIES =================================

*elasticities for new sectors
ELAS("iH2S","KL")=0.3;
ELAS("iH2S","KLE")=0.1;
ELAS("iH2S","KLEM")=0.1;
ELAS("iH2C","KL")=0.3;
ELAS("iH2C","KLE")=0.1;
ELAS("iH2C","KLEM")=0.1;
ELAS("iH2E","KL")=0.3;
ELAS("iH2E","KLE")=0.1;
ELAS("iH2E","KLEM")=0.1;

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
$ontext
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
$offtext
parameter finCO2(cnt);
finCO2(cnt)=carbonbudget;
finCO2("CY")=1;
finCO2("LU")=1;
finCO2("LV")=1;
finCO2("MT")=1;

* calibration values to obtain baseline GDP
* This works on GDv1 scenario
parameter GDPcal(cnt) gdp calibration /
AT        0.9087
BE        0.8813
BG        0.7679
CY        0.8997
CZ        0.8392
DE        0.9108
DK        0.9027
EE        0.8325
ES        0.8611
FI        0.8964
FR        0.8970
GR        0.9281
HU        0.8519
IE        0.8886
IT        0.8995
LT        0.8757
LU        0.8124
LV        0.8193
MT        0.8705
NL        0.8857
PL        0.8245
PT        0.8637
RO        0.8442
SE        0.8687
SI        0.8396
SK        0.7052
GB        0.8974
CH        0.9412
NO        1.0053
/;


* calibratiom values to obtain baseline GDP
* this works on the case with only GDP growth witout any other shock
parameter GDPcalBase(cnt) gdp calibration /
AT        0.9920
BE        0.9944
BG        0.9900
CY        0.9919
CZ        0.9957
DE        0.9987
DK        0.9953
EE        0.9846
ES        0.9899
FI        0.9972
FR        0.9994
GR        0.9989
HU        0.9953
IE        0.9857
IT        0.9937
LT        0.9920
LU        0.9887
LV        0.9857
MT        0.9972
NL        0.9995
PL        0.9924
PT        0.9936
RO        0.9947
SE        0.9916
SI        0.9881
SK        0.9945
GB        0.9979
CH        0.9949
NO        1.0007
/;

set nonpoll(sec) nonpolluting sectors /
iH2C
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

* PRC0 data comes from the file Scenario_emissions from TNO using Kaya identity.
parameter PRC0(cnt) 5yr compound productivity /
AT                 0.0539
BE                 0.0415
BG                 0.1098
CY                 0.0532
CZ                 0.0744
DE                 0.0618
DK                 0.0617
EE                 0.1031
ES                 0.0607
FI                 0.0457
FR                 0.0520
GR                 0.0506
HU                 0.0828
IE                 0.0547
IT                 0.0350
LT                 0.1282
LU                 0.0337
LV                 0.1324
MT                 0.0782
NL                 0.0498
PL                 0.1158
PT                 0.0630
RO                 0.1080
SE                 0.0653
SI                 0.0621
SK                 0.1128
GB                 0.0521
CH                 0.0350
NO                 0.0635
/;


parameter PRC1(cnt) 5yr compound productivity counterfactual /
AT                 0.0539
BE                 0.0415
BG                 0.1098
CY                 0.0532
CZ                 0.0744
DE                 0.0618
DK                 0.0617
EE                 0.1031
ES                 0.0607
FI                 0.0457
FR                 0.0520
GR                 0.0506
HU                 0.0828
IE                 0.0547
IT                 0.0350
LT                 0.1282
LU                 0.0337
LV                 0.1324
MT                 0.0782
NL                 0.0498
PL                 0.1158
PT                 0.0630
RO                 0.1080
SE                 0.0653
SI                 0.0621
SK                 0.1128
GB                 0.0521
CH                 0.0350
NO                 0.0635
/;

parameter PRC2(cnt) 5yr compound productivity counterfactual /
AT        0.124030379
BE        0.111005386
BG        0.182928235
CY        0.123343821
CZ        0.145618268
DE        0.13235938
DK        0.132278715
EE        0.175777311
ES        0.131184043
FI        0.115440992
FR        0.122050115
GR        0.120526516
HU        0.154444103
IE        0.124867571
IT        0.104082756
LT        0.202188116
LU        0.102735183
LV        0.206635695
MT        0.149646384
NL        0.119713656
PL        0.189205011
PT        0.133656995
RO        0.180936351
SE        0.136007663
SI        0.132674202
SK        0.186010378
GB        0.122112657
CH        0.104082756
NO        0.141626523
/;


* from file emis_assumptions.xlsx
parameter cint0(cnt,sec)  carbon intensity change per year until 2020 /
AT        .        iAGR        0.970275294
BE        .        iAGR        0.983348248
BG        .        iAGR        0.941278696
CY        .        iAGR        0.972125273
CZ        .        iAGR        0.963242891
DE        .        iAGR        0.974985292
DK        .        iAGR        0.952937157
EE        .        iAGR        0.96391429
ES        .        iAGR        0.974635216
FI        .        iAGR        0.975100262
FR        .        iAGR        0.973061228
GR        .        iAGR        0.97195345
HU        .        iAGR        0.96487356
IE        .        iAGR        0.928945047
IT        .        iAGR        0.97259731
LT        .        iAGR        0.963464412
LU        .        iAGR        0.960870741
LV        .        iAGR        0.980271733
MT        .        iAGR        0.898118811
NL        .        iAGR        0.971676787
PL        .        iAGR        0.965045469
PT        .        iAGR        0.973139618
RO        .        iAGR        1
SE        .        iAGR        0.957718396
SI        .        iAGR        0.967050067
SK        .        iAGR        0.969682125
GB        .        iAGR        0.955543894
CH        .        iAGR        0.970275294
NO        .        iAGR        0.952937157
AT        .        iIND        0.970275294
BE        .        iIND        0.983348248
BG        .        iIND        0.941278696
CY        .        iIND        0.972125273
CZ        .        iIND        0.963242891
DE        .        iIND        0.974985292
DK        .        iIND        0.952937157
EE        .        iIND        0.96391429
ES        .        iIND        0.974635216
FI        .        iIND        0.975100262
FR        .        iIND        0.973061228
GR        .        iIND        0.97195345
HU        .        iIND        0.96487356
IE        .        iIND        0.928945047
IT        .        iIND        0.97259731
LT        .        iIND        0.963464412
LU        .        iIND        0.960870741
LV        .        iIND        0.980271733
MT        .        iIND        0.898118811
NL        .        iIND        0.971676787
PL        .        iIND        0.965045469
PT        .        iIND        0.973139618
RO        .        iIND        1
SE        .        iIND        0.957718396
SI        .        iIND        0.967050067
SK        .        iIND        0.969682125
GB        .        iIND        0.955543894
CH        .        iIND        0.970275294
NO        .        iIND        0.952937157
AT        .        iALU        0.970275294
BE        .        iALU        0.983348248
BG        .        iALU        0.941278696
CY        .        iALU        0.972125273
CZ        .        iALU        0.963242891
DE        .        iALU        0.974985292
DK        .        iALU        0.952937157
EE        .        iALU        0.96391429
ES        .        iALU        0.974635216
FI        .        iALU        0.975100262
FR        .        iALU        0.973061228
GR        .        iALU        0.97195345
HU        .        iALU        0.96487356
IE        .        iALU        0.928945047
IT        .        iALU        0.97259731
LT        .        iALU        0.963464412
LU        .        iALU        0.960870741
LV        .        iALU        0.980271733
MT        .        iALU        0.898118811
NL        .        iALU        0.971676787
PL        .        iALU        0.965045469
PT        .        iALU        0.973139618
RO        .        iALU        1
SE        .        iALU        0.957718396
SI        .        iALU        0.967050067
SK        .        iALU        0.969682125
GB        .        iALU        0.955543894
CH        .        iALU        0.970275294
NO        .        iALU        0.952937157
AT        .        iSER        0.970275294
BE        .        iSER        0.983348248
BG        .        iSER        0.941278696
CY        .        iSER        0.972125273
CZ        .        iSER        0.963242891
DE        .        iSER        0.974985292
DK        .        iSER        0.952937157
EE        .        iSER        0.96391429
ES        .        iSER        0.974635216
FI        .        iSER        0.975100262
FR        .        iSER        0.973061228
GR        .        iSER        0.97195345
HU        .        iSER        0.96487356
IE        .        iSER        0.928945047
IT        .        iSER        0.97259731
LT        .        iSER        0.963464412
LU        .        iSER        0.960870741
LV        .        iSER        0.980271733
MT        .        iSER        0.898118811
NL        .        iSER        0.971676787
PL        .        iSER        0.965045469
PT        .        iSER        0.973139618
RO        .        iSER        1
SE        .        iSER        0.957718396
SI        .        iSER        0.967050067
SK        .        iSER        0.969682125
GB        .        iSER        0.955543894
CH        .        iSER        0.970275294
NO        .        iSER        0.952937157
AT        .        iTRA        0.970275294
BE        .        iTRA        0.983348248
BG        .        iTRA        0.941278696
CY        .        iTRA        0.972125273
CZ        .        iTRA        0.963242891
DE        .        iTRA        0.974985292
DK        .        iTRA        0.952937157
EE        .        iTRA        0.96391429
ES        .        iTRA        0.974635216
FI        .        iTRA        0.975100262
FR        .        iTRA        0.973061228
GR        .        iTRA        0.97195345
HU        .        iTRA        0.96487356
IE        .        iTRA        0.928945047
IT        .        iTRA        0.97259731
LT        .        iTRA        0.963464412
LU        .        iTRA        0.960870741
LV        .        iTRA        0.980271733
MT        .        iTRA        0.898118811
NL        .        iTRA        0.971676787
PL        .        iTRA        0.965045469
PT        .        iTRA        0.973139618
RO        .        iTRA        1
SE        .        iTRA        0.957718396
SI        .        iTRA        0.967050067
SK        .        iTRA        0.969682125
GB        .        iTRA        0.955543894
CH        .        iTRA        0.970275294
NO        .        iTRA        0.952937157
AT        .        iELC        0.970275294
BE        .        iELC        0.983348248
BG        .        iELC        0.941278696
CY        .        iELC        0.972125273
CZ        .        iELC        0.963242891
DE        .        iELC        0.974985292
DK        .        iELC        0.952937157
EE        .        iELC        0.96391429
ES        .        iELC        0.974635216
FI        .        iELC        0.975100262
FR        .        iELC        0.973061228
GR        .        iELC        0.97195345
HU        .        iELC        0.96487356
IE        .        iELC        0.928945047
IT        .        iELC        0.97259731
LT        .        iELC        0.963464412
LU        .        iELC        0.960870741
LV        .        iELC        0.980271733
MT        .        iELC        0.898118811
NL        .        iELC        0.971676787
PL        .        iELC        0.965045469
PT        .        iELC        0.973139618
RO        .        iELC        1
SE        .        iELC        0.957718396
SI        .        iELC        0.967050067
SK        .        iELC        0.969682125
GB        .        iELC        0.955543894
CH        .        iELC        0.970275294
NO        .        iELC        0.952937157
AT        .        iTRD        0.970275294
BE        .        iTRD        0.983348248
BG        .        iTRD        0.941278696
CY        .        iTRD        0.972125273
CZ        .        iTRD        0.963242891
DE        .        iTRD        0.974985292
DK        .        iTRD        0.952937157
EE        .        iTRD        0.96391429
ES        .        iTRD        0.974635216
FI        .        iTRD        0.975100262
FR        .        iTRD        0.973061228
GR        .        iTRD        0.97195345
HU        .        iTRD        0.96487356
IE        .        iTRD        0.928945047
IT        .        iTRD        0.97259731
LT        .        iTRD        0.963464412
LU        .        iTRD        0.960870741
LV        .        iTRD        0.980271733
MT        .        iTRD        0.898118811
NL        .        iTRD        0.971676787
PL        .        iTRD        0.965045469
PT        .        iTRD        0.973139618
RO        .        iTRD        1
SE        .        iTRD        0.957718396
SI        .        iTRD        0.967050067
SK        .        iTRD        0.969682125
GB        .        iTRD        0.955543894
CH        .        iTRD        0.970275294
NO        .        iTRD        0.952937157
AT        .        iCOA        0.970275294
BE        .        iCOA        0.983348248
BG        .        iCOA        0.941278696
CY        .        iCOA        0.972125273
CZ        .        iCOA        0.963242891
DE        .        iCOA        0.974985292
DK        .        iCOA        0.952937157
EE        .        iCOA        0.96391429
ES        .        iCOA        0.974635216
FI        .        iCOA        0.975100262
FR        .        iCOA        0.973061228
GR        .        iCOA        0.97195345
HU        .        iCOA        0.96487356
IE        .        iCOA        0.928945047
IT        .        iCOA        0.97259731
LT        .        iCOA        0.963464412
LU        .        iCOA        0.960870741
LV        .        iCOA        0.980271733
MT        .        iCOA        0.898118811
NL        .        iCOA        0.971676787
PL        .        iCOA        0.965045469
PT        .        iCOA        0.973139618
RO        .        iCOA        1
SE        .        iCOA        0.957718396
SI        .        iCOA        0.967050067
SK        .        iCOA        0.969682125
GB        .        iCOA        0.955543894
CH        .        iCOA        0.970275294
NO        .        iCOA        0.952937157
AT        .        iCOI        0.970275294
BE        .        iCOI        0.983348248
BG        .        iCOI        0.941278696
CY        .        iCOI        0.972125273
CZ        .        iCOI        0.963242891
DE        .        iCOI        0.974985292
DK        .        iCOI        0.952937157
EE        .        iCOI        0.96391429
ES        .        iCOI        0.974635216
FI        .        iCOI        0.975100262
FR        .        iCOI        0.973061228
GR        .        iCOI        0.97195345
HU        .        iCOI        0.96487356
IE        .        iCOI        0.928945047
IT        .        iCOI        0.97259731
LT        .        iCOI        0.963464412
LU        .        iCOI        0.960870741
LV        .        iCOI        0.980271733
MT        .        iCOI        0.898118811
NL        .        iCOI        0.971676787
PL        .        iCOI        0.965045469
PT        .        iCOI        0.973139618
RO        .        iCOI        1
SE        .        iCOI        0.957718396
SI        .        iCOI        0.967050067
SK        .        iCOI        0.969682125
GB        .        iCOI        0.955543894
CH        .        iCOI        0.970275294
NO        .        iCOI        0.952937157
AT        .        iNG        0.970275294
BE        .        iNG        0.983348248
BG        .        iNG        0.941278696
CY        .        iNG        0.972125273
CZ        .        iNG        0.963242891
DE        .        iNG        0.974985292
DK        .        iNG        0.952937157
EE        .        iNG        0.96391429
ES        .        iNG        0.974635216
FI        .        iNG        0.975100262
FR        .        iNG        0.973061228
GR        .        iNG        0.97195345
HU        .        iNG        0.96487356
IE        .        iNG        0.928945047
IT        .        iNG        0.97259731
LT        .        iNG        0.963464412
LU        .        iNG        0.960870741
LV        .        iNG        0.980271733
MT        .        iNG        0.898118811
NL        .        iNG        0.971676787
PL        .        iNG        0.965045469
PT        .        iNG        0.973139618
RO        .        iNG        1
SE        .        iNG        0.957718396
SI        .        iNG        0.967050067
SK        .        iNG        0.969682125
GB        .        iNG        0.955543894
CH        .        iNG        0.970275294
NO        .        iNG        0.952937157
AT        .        iH2S        0.970275294
BE        .        iH2S        0.983348248
BG        .        iH2S        0.941278696
CY        .        iH2S        0.972125273
CZ        .        iH2S        0.963242891
DE        .        iH2S        0.974985292
DK        .        iH2S        0.952937157
EE        .        iH2S        0.96391429
ES        .        iH2S        0.974635216
FI        .        iH2S        0.975100262
FR        .        iH2S        0.973061228
GR        .        iH2S        0.97195345
HU        .        iH2S        0.96487356
IE        .        iH2S        0.928945047
IT        .        iH2S        0.97259731
LT        .        iH2S        0.963464412
LU        .        iH2S        0.960870741
LV        .        iH2S        0.980271733
MT        .        iH2S        0.898118811
NL        .        iH2S        0.971676787
PL        .        iH2S        0.965045469
PT        .        iH2S        0.973139618
RO        .        iH2S        1
SE        .        iH2S        0.957718396
SI        .        iH2S        0.967050067
SK        .        iH2S        0.969682125
GB        .        iH2S        0.955543894
CH        .        iH2S        0.970275294
NO        .        iH2S        0.952937157
AT        .        iH2E        0.970275294
BE        .        iH2E        0.983348248
BG        .        iH2E        0.941278696
CY        .        iH2E        0.972125273
CZ        .        iH2E        0.963242891
DE        .        iH2E        0.974985292
DK        .        iH2E        0.952937157
EE        .        iH2E        0.96391429
ES        .        iH2E        0.974635216
FI        .        iH2E        0.975100262
FR        .        iH2E        0.973061228
GR        .        iH2E        0.97195345
HU        .        iH2E        0.96487356
IE        .        iH2E        0.928945047
IT        .        iH2E        0.97259731
LT        .        iH2E        0.963464412
LU        .        iH2E        0.960870741
LV        .        iH2E        0.980271733
MT        .        iH2E        0.898118811
NL        .        iH2E        0.971676787
PL        .        iH2E        0.965045469
PT        .        iH2E        0.973139618
RO        .        iH2E        1
SE        .        iH2E        0.957718396
SI        .        iH2E        0.967050067
SK        .        iH2E        0.969682125
GB        .        iH2E        0.955543894
CH        .        iH2E        0.970275294
NO        .        iH2E        0.952937157
AT        .        iH2C        0.970275294
BE        .        iH2C        0.983348248
BG        .        iH2C        0.941278696
CY        .        iH2C        0.972125273
CZ        .        iH2C        0.963242891
DE        .        iH2C        0.974985292
DK        .        iH2C        0.952937157
EE        .        iH2C        0.96391429
ES        .        iH2C        0.974635216
FI        .        iH2C        0.975100262
FR        .        iH2C        0.973061228
GR        .        iH2C        0.97195345
HU        .        iH2C        0.96487356
IE        .        iH2C        0.928945047
IT        .        iH2C        0.97259731
LT        .        iH2C        0.963464412
LU        .        iH2C        0.960870741
LV        .        iH2C        0.980271733
MT        .        iH2C        0.898118811
NL        .        iH2C        0.971676787
PL        .        iH2C        0.965045469
PT        .        iH2C        0.973139618
RO        .        iH2C        1
SE        .        iH2C        0.957718396
SI        .        iH2C        0.967050067
SK        .        iH2C        0.969682125
GB        .        iH2C        0.955543894
CH        .        iH2C        0.970275294
NO        .        iH2C        0.952937157
/;

* from file emis_assumptions.xlsx
parameter cint1(cnt,sec)  carbon intensity change per year after 2021 /
AT        .        iAGR        0.979427459
BE        .        iAGR        0.979427459
BG        .        iAGR        0.979427459
CY        .        iAGR        0.979427459
CZ        .        iAGR        0.979427459
DE        .        iAGR        0.979427459
DK        .        iAGR        0.979427459
EE        .        iAGR        0.979427459
ES        .        iAGR        0.979427459
FI        .        iAGR        0.979427459
FR        .        iAGR        0.979427459
GR        .        iAGR        0.979427459
HU        .        iAGR        0.979427459
IE        .        iAGR        0.979427459
IT        .        iAGR        0.979427459
LT        .        iAGR        0.979427459
LU        .        iAGR        0.979427459
LV        .        iAGR        0.979427459
MT        .        iAGR        0.979427459
NL        .        iAGR        0.979427459
PL        .        iAGR        0.979427459
PT        .        iAGR        0.979427459
RO        .        iAGR        0.979427459
SE        .        iAGR        0.979427459
SI        .        iAGR        0.979427459
SK        .        iAGR        0.979427459
GB        .        iAGR        0.979427459
CH        .        iAGR        0.979427459
NO        .        iAGR        0.979427459
AT        .        iIND        0.979427459
BE        .        iIND        0.979427459
BG        .        iIND        0.979427459
CY        .        iIND        0.979427459
CZ        .        iIND        0.979427459
DE        .        iIND        0.979427459
DK        .        iIND        0.979427459
EE        .        iIND        0.979427459
ES        .        iIND        0.979427459
FI        .        iIND        0.979427459
FR        .        iIND        0.979427459
GR        .        iIND        0.979427459
HU        .        iIND        0.979427459
IE        .        iIND        0.979427459
IT        .        iIND        0.979427459
LT        .        iIND        0.979427459
LU        .        iIND        0.979427459
LV        .        iIND        0.979427459
MT        .        iIND        0.979427459
NL        .        iIND        0.979427459
PL        .        iIND        0.979427459
PT        .        iIND        0.979427459
RO        .        iIND        0.979427459
SE        .        iIND        0.979427459
SI        .        iIND        0.979427459
SK        .        iIND        0.979427459
GB        .        iIND        0.979427459
CH        .        iIND        0.979427459
NO        .        iIND        0.979427459
AT        .        iALU        0.979427459
BE        .        iALU        0.979427459
BG        .        iALU        0.979427459
CY        .        iALU        0.979427459
CZ        .        iALU        0.979427459
DE        .        iALU        0.979427459
DK        .        iALU        0.979427459
EE        .        iALU        0.979427459
ES        .        iALU        0.979427459
FI        .        iALU        0.979427459
FR        .        iALU        0.979427459
GR        .        iALU        0.979427459
HU        .        iALU        0.979427459
IE        .        iALU        0.979427459
IT        .        iALU        0.979427459
LT        .        iALU        0.979427459
LU        .        iALU        0.979427459
LV        .        iALU        0.979427459
MT        .        iALU        0.979427459
NL        .        iALU        0.979427459
PL        .        iALU        0.979427459
PT        .        iALU        0.979427459
RO        .        iALU        0.979427459
SE        .        iALU        0.979427459
SI        .        iALU        0.979427459
SK        .        iALU        0.979427459
GB        .        iALU        0.979427459
CH        .        iALU        0.979427459
NO        .        iALU        0.979427459
AT        .        iSER        0.991751577
BE        .        iSER        0.991751577
BG        .        iSER        0.991751577
CY        .        iSER        0.991751577
CZ        .        iSER        0.991751577
DE        .        iSER        0.991751577
DK        .        iSER        0.991751577
EE        .        iSER        0.991751577
ES        .        iSER        0.991751577
FI        .        iSER        0.991751577
FR        .        iSER        0.991751577
GR        .        iSER        0.991751577
HU        .        iSER        0.991751577
IE        .        iSER        0.991751577
IT        .        iSER        0.991751577
LT        .        iSER        0.991751577
LU        .        iSER        0.991751577
LV        .        iSER        0.991751577
MT        .        iSER        0.991751577
NL        .        iSER        0.991751577
PL        .        iSER        0.991751577
PT        .        iSER        0.991751577
RO        .        iSER        0.991751577
SE        .        iSER        0.991751577
SI        .        iSER        0.991751577
SK        .        iSER        0.991751577
GB        .        iSER        0.991751577
CH        .        iSER        0.991751577
NO        .        iSER        0.991751577
AT        .        iTRA        0.998567035
BE        .        iTRA        0.998567035
BG        .        iTRA        0.998567035
CY        .        iTRA        0.998567035
CZ        .        iTRA        0.998567035
DE        .        iTRA        0.998567035
DK        .        iTRA        0.998567035
EE        .        iTRA        0.998567035
ES        .        iTRA        0.998567035
FI        .        iTRA        0.998567035
FR        .        iTRA        0.998567035
GR        .        iTRA        0.998567035
HU        .        iTRA        0.998567035
IE        .        iTRA        0.998567035
IT        .        iTRA        0.998567035
LT        .        iTRA        0.998567035
LU        .        iTRA        0.998567035
LV        .        iTRA        0.998567035
MT        .        iTRA        0.998567035
NL        .        iTRA        0.998567035
PL        .        iTRA        0.998567035
PT        .        iTRA        0.998567035
RO        .        iTRA        0.998567035
SE        .        iTRA        0.998567035
SI        .        iTRA        0.998567035
SK        .        iTRA        0.998567035
GB        .        iTRA        0.998567035
CH        .        iTRA        0.998567035
NO        .        iTRA        0.998567035
AT        .        iELC        0.975588683
BE        .        iELC        0.975588683
BG        .        iELC        0.975588683
CY        .        iELC        0.975588683
CZ        .        iELC        0.975588683
DE        .        iELC        0.975588683
DK        .        iELC        0.975588683
EE        .        iELC        0.975588683
ES        .        iELC        0.975588683
FI        .        iELC        0.975588683
FR        .        iELC        0.975588683
GR        .        iELC        0.975588683
HU        .        iELC        0.975588683
IE        .        iELC        0.975588683
IT        .        iELC        0.975588683
LT        .        iELC        0.975588683
LU        .        iELC        0.975588683
LV        .        iELC        0.975588683
MT        .        iELC        0.975588683
NL        .        iELC        0.975588683
PL        .        iELC        0.975588683
PT        .        iELC        0.975588683
RO        .        iELC        0.975588683
SE        .        iELC        0.975588683
SI        .        iELC        0.975588683
SK        .        iELC        0.975588683
GB        .        iELC        0.975588683
CH        .        iELC        0.975588683
NO        .        iELC        0.975588683
AT        .        iTRD        0.991751577
BE        .        iTRD        0.991751577
BG        .        iTRD        0.991751577
CY        .        iTRD        0.991751577
CZ        .        iTRD        0.991751577
DE        .        iTRD        0.991751577
DK        .        iTRD        0.991751577
EE        .        iTRD        0.991751577
ES        .        iTRD        0.991751577
FI        .        iTRD        0.991751577
FR        .        iTRD        0.991751577
GR        .        iTRD        0.991751577
HU        .        iTRD        0.991751577
IE        .        iTRD        0.991751577
IT        .        iTRD        0.991751577
LT        .        iTRD        0.991751577
LU        .        iTRD        0.991751577
LV        .        iTRD        0.991751577
MT        .        iTRD        0.991751577
NL        .        iTRD        0.991751577
PL        .        iTRD        0.991751577
PT        .        iTRD        0.991751577
RO        .        iTRD        0.991751577
SE        .        iTRD        0.991751577
SI        .        iTRD        0.991751577
SK        .        iTRD        0.991751577
GB        .        iTRD        0.991751577
CH        .        iTRD        0.991751577
NO        .        iTRD        0.991751577
AT        .        iCOA        0.975588683
BE        .        iCOA        0.975588683
BG        .        iCOA        0.975588683
CY        .        iCOA        0.975588683
CZ        .        iCOA        0.975588683
DE        .        iCOA        0.975588683
DK        .        iCOA        0.975588683
EE        .        iCOA        0.975588683
ES        .        iCOA        0.975588683
FI        .        iCOA        0.975588683
FR        .        iCOA        0.975588683
GR        .        iCOA        0.975588683
HU        .        iCOA        0.975588683
IE        .        iCOA        0.975588683
IT        .        iCOA        0.975588683
LT        .        iCOA        0.975588683
LU        .        iCOA        0.975588683
LV        .        iCOA        0.975588683
MT        .        iCOA        0.975588683
NL        .        iCOA        0.975588683
PL        .        iCOA        0.975588683
PT        .        iCOA        0.975588683
RO        .        iCOA        0.975588683
SE        .        iCOA        0.975588683
SI        .        iCOA        0.975588683
SK        .        iCOA        0.975588683
GB        .        iCOA        0.975588683
CH        .        iCOA        0.975588683
NO        .        iCOA        0.975588683
AT        .        iCOI        0.975588683
BE        .        iCOI        0.975588683
BG        .        iCOI        0.975588683
CY        .        iCOI        0.975588683
CZ        .        iCOI        0.975588683
DE        .        iCOI        0.975588683
DK        .        iCOI        0.975588683
EE        .        iCOI        0.975588683
ES        .        iCOI        0.975588683
FI        .        iCOI        0.975588683
FR        .        iCOI        0.975588683
GR        .        iCOI        0.975588683
HU        .        iCOI        0.975588683
IE        .        iCOI        0.975588683
IT        .        iCOI        0.975588683
LT        .        iCOI        0.975588683
LU        .        iCOI        0.975588683
LV        .        iCOI        0.975588683
MT        .        iCOI        0.975588683
NL        .        iCOI        0.975588683
PL        .        iCOI        0.975588683
PT        .        iCOI        0.975588683
RO        .        iCOI        0.975588683
SE        .        iCOI        0.975588683
SI        .        iCOI        0.975588683
SK        .        iCOI        0.975588683
GB        .        iCOI        0.975588683
CH        .        iCOI        0.975588683
NO        .        iCOI        0.975588683
AT        .        iNG        0.975588683
BE        .        iNG        0.975588683
BG        .        iNG        0.975588683
CY        .        iNG        0.975588683
CZ        .        iNG        0.975588683
DE        .        iNG        0.975588683
DK        .        iNG        0.975588683
EE        .        iNG        0.975588683
ES        .        iNG        0.975588683
FI        .        iNG        0.975588683
FR        .        iNG        0.975588683
GR        .        iNG        0.975588683
HU        .        iNG        0.975588683
IE        .        iNG        0.975588683
IT        .        iNG        0.975588683
LT        .        iNG        0.975588683
LU        .        iNG        0.975588683
LV        .        iNG        0.975588683
MT        .        iNG        0.975588683
NL        .        iNG        0.975588683
PL        .        iNG        0.975588683
PT        .        iNG        0.975588683
RO        .        iNG        0.975588683
SE        .        iNG        0.975588683
SI        .        iNG        0.975588683
SK        .        iNG        0.975588683
GB        .        iNG        0.975588683
CH        .        iNG        0.975588683
NO        .        iNG        0.975588683
AT        .        iH2S        0.975588683
BE        .        iH2S        0.975588683
BG        .        iH2S        0.975588683
CY        .        iH2S        0.975588683
CZ        .        iH2S        0.975588683
DE        .        iH2S        0.975588683
DK        .        iH2S        0.975588683
EE        .        iH2S        0.975588683
ES        .        iH2S        0.975588683
FI        .        iH2S        0.975588683
FR        .        iH2S        0.975588683
GR        .        iH2S        0.975588683
HU        .        iH2S        0.975588683
IE        .        iH2S        0.975588683
IT        .        iH2S        0.975588683
LT        .        iH2S        0.975588683
LU        .        iH2S        0.975588683
LV        .        iH2S        0.975588683
MT        .        iH2S        0.975588683
NL        .        iH2S        0.975588683
PL        .        iH2S        0.975588683
PT        .        iH2S        0.975588683
RO        .        iH2S        0.975588683
SE        .        iH2S        0.975588683
SI        .        iH2S        0.975588683
SK        .        iH2S        0.975588683
GB        .        iH2S        0.975588683
CH        .        iH2S        0.975588683
NO        .        iH2S        0.975588683
AT        .        iH2E        0.975588683
BE        .        iH2E        0.975588683
BG        .        iH2E        0.975588683
CY        .        iH2E        0.975588683
CZ        .        iH2E        0.975588683
DE        .        iH2E        0.975588683
DK        .        iH2E        0.975588683
EE        .        iH2E        0.975588683
ES        .        iH2E        0.975588683
FI        .        iH2E        0.975588683
FR        .        iH2E        0.975588683
GR        .        iH2E        0.975588683
HU        .        iH2E        0.975588683
IE        .        iH2E        0.975588683
IT        .        iH2E        0.975588683
LT        .        iH2E        0.975588683
LU        .        iH2E        0.975588683
LV        .        iH2E        0.975588683
MT        .        iH2E        0.975588683
NL        .        iH2E        0.975588683
PL        .        iH2E        0.975588683
PT        .        iH2E        0.975588683
RO        .        iH2E        0.975588683
SE        .        iH2E        0.975588683
SI        .        iH2E        0.975588683
SK        .        iH2E        0.975588683
GB        .        iH2E        0.975588683
CH        .        iH2E        0.975588683
NO        .        iH2E        0.975588683
AT        .        iH2C        0.975588683
BE        .        iH2C        0.975588683
BG        .        iH2C        0.975588683
CY        .        iH2C        0.975588683
CZ        .        iH2C        0.975588683
DE        .        iH2C        0.975588683
DK        .        iH2C        0.975588683
EE        .        iH2C        0.975588683
ES        .        iH2C        0.975588683
FI        .        iH2C        0.975588683
FR        .        iH2C        0.975588683
GR        .        iH2C        0.975588683
HU        .        iH2C        0.975588683
IE        .        iH2C        0.975588683
IT        .        iH2C        0.975588683
LT        .        iH2C        0.975588683
LU        .        iH2C        0.975588683
LV        .        iH2C        0.975588683
MT        .        iH2C        0.975588683
NL        .        iH2C        0.975588683
PL        .        iH2C        0.975588683
PT        .        iH2C        0.975588683
RO        .        iH2C        0.975588683
SE        .        iH2C        0.975588683
SI        .        iH2C        0.975588683
SK        .        iH2C        0.975588683
GB        .        iH2C        0.975588683
CH        .        iH2C        0.975588683
NO        .        iH2C        0.975588683

/;


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


parameter opent(cnt,sec,step);
opent(cnt,sec,step)=1;

$ifthen %CaseStudy%==1
opent(cnt,"iH2E",step)$(ord(step) le 4)=0.0001;
opent(cnt,"iH2S",step)$(ord(step) le 4)=0.0001;
opent(cnt,"iH2C",step)$(ord(step) le 4)=0.0001;
$elseif %CaseStudy%==2
opent(cnt,"iH2E",step)$(ord(step) le 4)=0.0001;
opent(cnt,"iH2S",step)$(ord(step) le 4)=0.0001;
opent(cnt,"iH2C",step)$(ord(step) le 4)=0.0001;
$elseif %CaseStudy%==3
opent(cnt,"iH2E",step)$(ord(step) le 4)=0.0001;
opent(cnt,"iH2S",step)$(ord(step) le 4)=0.0001;
opent(cnt,"iH2C",step)$(ord(step) le 4)=0.0001;
$elseif %CaseStudy%==4
opent(cnt,"iH2E",step)$(ord(step) le 4)=0.0001;
opent(cnt,"iH2S",step)$(ord(step) le 4)=0.0001;
opent(cnt,"iH2C",step)$(ord(step) le 4)=0.0001;
$elseif %CaseStudy%==5
opent(cnt,"iH2E",step)$(ord(step) le 4)=0.0001;
opent(cnt,"iH2S",step)$(ord(step) le 4)=0.0001;
opent(cnt,"iH2C",step)$(ord(step) le 4)=0.0001;
$elseif %CaseStudy%==6
opent(cnt,"iH2E",step)$(ord(step) le 4)=0.0001;
opent(cnt,"iH2S",step)$(ord(step) le 4)=0.0001;
opent(cnt,"iH2C",step)$(ord(step) le 4)=0.0001;
$endif

$ifthen %CaseStudy%==0
parameter Circular(cnt);
Circular(cnt)=0.8;
$endif

$ifthen %CaseStudy%==1
parameter Circular(cnt);
Circular(cnt)=0.8
$endif

$ifthen %CaseStudy%==6
parameter Circular(cnt);
Circular(cnt)=0.8
$ontext

parameter Circular(cnt) material reduction /
AT        0.8
BE        0.8
BG        1
CY        1
CZ        1
DE        0.8
DK        0.8
EE        1
ES        1
FI        0.8
FR        0.8
GR        1
HU        1
IE        0.8
IT        1
LT        1
LU        0.8
LV        1
MT        1
NL        0.8
PL        1
PT        1
RO        1
SE        0.8
SI        1
SK        1
GB        1
CH        1
NO        0.8
/;
$offtext
$endif

$ifthen %CaseStudy%==2
parameter Circular(cnt);
*Circular(cnt)=0.8;
*$ontext
parameter Circular(cnt) material reduction /
AT        0.8
BE        0.8
BG        1
CY        1
CZ        1
DE        0.8
DK        0.8
EE        1
ES        1
FI        0.8
FR        0.8
GR        1
HU        1
IE        0.8
IT        1
LT        1
LU        0.8
LV        1
MT        1
NL        0.8
PL        1
PT        1
RO        1
SE        0.8
SI        1
SK        1
GB        1
CH        1
NO        0.8
/;
*$offtext
$endif

$ifthen %CaseStudy%==3
parameter Circular(cnt) material reduction /
AT        0.95
BE        0.95
BG        1
CY        1
CZ        1
DE        0.95
DK        0.95
EE        1
ES        1
FI        0.95
FR        0.95
GR        1
HU        1
IE        0.95
IT        1
LT        1
LU        0.95
LV        1
MT        1
NL        0.95
PL        1
PT        1
RO        1
SE        0.95
SI        1
SK        1
GB        1
CH        1
NO        0.95
/;
$endif

$ifthen %CaseStudy%==4
parameter Circular(cnt);
Circular(cnt)=0.67;
*Circular(cnt)=0.65;
$endif


$ifthen %CaseStudy%==5
parameter Circular(cnt);
Circular(cnt)=0.8;
$endif



$include "growth_table.gms"



$ifthen %CaseStudy%==1
parameter lpd(cnt) change in productivity due to climate change /
AT        -0.00152
BE        -0.00162
BG        -0.00166
CY        -0.01625
CZ        -0.00023
DE        -0.00051
DK        0.00064
EE        0.00264
ES        -0.01433
FI        0.00244
FR        -0.00455
GR        -0.01399
HU        -0.00263
IE        0.00035
IT        -0.00998
LT        0.00222
LU        -0.00027
LV        0.00175
MT        -0.01432
NL        -0.00098
PL        0.00014
PT        -0.00801
RO        0.00035
SE        0.00148
SI        -0.00110
SK        -0.00141
GB        -0.00061
CH        -0.00152
NO        0.00148
/;
$endif

$ifthen %CaseStudy%==2
parameter lpd(cnt) change in productivity due to climate change /
AT        -0.00072
BE        -0.00079
BG        -0.00064
CY        -0.01227
CZ        0.00008
DE        -0.00014
DK        0.00065
EE        0.00213
ES        -0.01009
FI        0.00163
FR        -0.00286
GR        -0.00863
HU        -0.00166
IE        0.00042
IT        -0.00665
LT        0.00198
LU        0.00015
LV        0.00147
MT        -0.01077
NL        -0.00058
PL        0.00044
PT        -0.00587
RO        0.00069
SE        0.00095
SI        -0.00045
SK        -0.00065
GB        -0.00039
CH        -0.00072
NO        0.00095
/;
$endif

$ifthen %CaseStudy%==3
parameter lpd(cnt) change in productivity due to climate change /
AT        -0.00052
BE        -0.00058
BG        -0.00036
CY        -0.01025
CZ        0.00016
DE        -0.00002
DK        0.00062
EE        0.00189
ES        -0.00821
FI        0.00141
FR        -0.00219
GR        -0.00718
HU        -0.00123
IE        0.00042
IT        -0.00549
LT        0.00179
LU        0.00023
LV        0.00132
MT        -0.00899
NL        -0.00040
PL        0.00047
PT        -0.00483
RO        0.00073
SE        0.00083
SI        -0.00024
SK        -0.00046
GB        -0.00027
CH        -0.00052
NO        0.00083
/;
$endif

$ifthen %CaseStudy%==4
parameter lpd(cnt) change in productivity due to climate change /
AT        -0.00052
BE        -0.00058
BG        -0.00036
CY        -0.01025
CZ        0.00016
DE        -0.00002
DK        0.00062
EE        0.00189
ES        -0.00821
FI        0.00141
FR        -0.00219
GR        -0.00718
HU        -0.00123
IE        0.00042
IT        -0.00549
LT        0.00179
LU        0.00023
LV        0.00132
MT        -0.00899
NL        -0.00040
PL        0.00047
PT        -0.00483
RO        0.00073
SE        0.00083
SI        -0.00024
SK        -0.00046
GB        -0.00027
CH        -0.00052
NO        0.00083
/;
$endif

$ifthen %CaseStudy%==5
parameter lpd(cnt) change in productivity due to climate change /
AT        -0.00052
BE        -0.00058
BG        -0.00036
CY        -0.01025
CZ        0.00016
DE        -0.00002
DK        0.00062
EE        0.00189
ES        -0.00821
FI        0.00141
FR        -0.00219
GR        -0.00718
HU        -0.00123
IE        0.00042
IT        -0.00549
LT        0.00179
LU        0.00023
LV        0.00132
MT        -0.00899
NL        -0.00040
PL        0.00047
PT        -0.00483
RO        0.00073
SE        0.00083
SI        -0.00024
SK        -0.00046
GB        -0.00027
CH        -0.00052
NO        0.00083
/;
$endif


$ifthen %CaseStudy%==6
* Climate Change Effects = Drop in Labour productivity and increase in Energy demand.
parameter lpd(cnt) change in productivity due to climate change /
AT        -0.024476882
BE        -0.011556298
BG        -0.013292354
CY        -0.041831028
CZ        -0.024652165
DE        -0.022852234
DK        -0.00748509
EE        -0.013011347
ES        -0.052556627
FI        -0.014482259
FR        -0.022356525
GR        -0.032747425
HU        -0.022118296
IE        -0.007291855
IT        -0.031230142
LT        -0.013292354
LU        -0.013210835
LV        -0.013210835
MT        -0.040775648
NL        -0.014089765
PL        -0.016413713
PT        -0.039519075
RO        -0.023316487
SE        -0.012704408
SI        -0.025810286
SK        -0.024304078
GB        -0.010177949
CH        -0.021564283
NO        -0.006182978
/;
$endif

