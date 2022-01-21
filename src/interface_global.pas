unit interface_global;


interface


const
    max_SoilLayers = 5;
    undef_double = -9.9;
    undef_int = -9;
    CO2Ref = 369.41;
    ElapsedDays : ARRAY[1..12] of double = (0,31,59.25,90.25,120.25,151.25,181.25,
                                                212.25,243.25,273.25,304.25,334.25);

type
    rep_string25 = string[25]; (* Description SoilLayer *)

    rep_salt = ARRAY[1..11] of double; (* saltcontent in g/m2 *)

    SoilLayerIndividual = Record
        Description  : rep_string25;
        Thickness    : double;   (* meter *)
        SAT          : double;   (* Vol % at Saturation *)
        FC           : double;   (* Vol % at Field Capacity *)
        WP           : double;   (* Vol % at Wilting Point *)
        tau          : double;   (* drainage factor 0 ... 1 *)
        InfRate      : double;   (* Infiltration rate at saturation mm/day *)
        Penetrability : ShortInt; (* root zone expansion rate in percentage*)
        GravelMass    : ShortInt; (* mass percentage of gravel *)
        GravelVol      : double; (* volume percentage of gravel *)
        WaterContent : double;   (* mm *)
        // salinity parameters (cells)
        Macro        : ShortInt; (* Macropores : from Saturation to Macro [vol%] *)
        SaltMobility : rep_salt; (* Mobility of salt in the various salt cellS  *)
        SC           : ShortInt;  (* number of Saltcels between 0 and SC/(SC+2)*SAT vol% *)
        SCP1         : ShortInt;  (* SC + 1   (1 extra Saltcel between SC/(SC+2)*SAT vol% and SAT)
                                  THis last celL is twice as large as the other cels *)
        UL           : double;  (* Upper Limit of SC salt cells = SC/(SC+2) * (SAT/100) in m3/m3 *)
        Dx           : double; (* Size of SC salt cells [m3/m3] = UL/SC *)
        // capilary rise parameters
        SoilClass    : shortInt; // 1 = sandy, 2 = loamy, 3 = sandy clayey, 4 - silty clayey soils
        CRa, CRb     : double; (* coefficients for Capillary Rise *)
        END;

    rep_SoilLayer = ARRAY[1..max_SoilLayers] of SoilLayerIndividual;
    
    rep_int_array = ARRAY[1..4] OF INTEGER;

    rep_modeCycle = (GDDays, CalendarDays);

    rep_planting = (Seed,Transplant,Regrowth);

    rep_EffectStress = Record
         RedCGC          : ShortInt; (* Reduction of CGC (%) *)
         RedCCX          : ShortInt; (* Reduction of CCx (%) *)
         RedWP           : ShortInt; (* Reduction of WP (%) *)
         CDecline        : Double; (* Average decrease of CCx in mid season (%/day) *)
         RedKsSto        : ShortInt; (* Reduction of KsSto (%) *)
         end;

    rep_Shapes = Record
         Stress          : ShortInt; (* Percentage soil fertility stress for calibration*)
         ShapeCGC        : Double; (* Shape factor for the response of Canopy Growth Coefficient to soil fertility stress *)
         ShapeCCX        : Double; (* Shape factor for the response of Maximum Canopy Cover to soil fertility stress *)
         ShapeWP         : Double; (* Shape factor for the response of Crop Water Producitity to soil fertility stress *)
         ShapeCDecline   : Double; (* Shape factor for the response of Decline of Canopy Cover to soil fertility stress *)
         Calibrated      : BOOLEAN;
         end;

     rep_RootZoneWC = Record
         Actual : double; // actual soil water content in rootzone [mm]
         FC     : double; //  soil water content [mm] in rootzone at FC
         WP     : double; // soil water content [mm] in rootzone at WP
         SAT    : double; // soil water content [mm] in rootzone at Sat
         Leaf   : double; // soil water content [mm] in rootzone at upper Threshold for leaf expansion
         Thresh : double; // soil water content [mm] in rootzone at Threshold for stomatal closure
         Sen    : double; // soil water content [mm] in rootzone at Threshold for canopy senescence
         ZtopAct : double;  // actual soil water content [mm] in top soil (= top compartment)
         ZtopFC  : double;  // soil water content [mm] at FC in top soil (= top compartment)
         ZtopWP  : double;  // soil water content [mm] at WP in top soil (= top compartment)
         ZtopThresh : double; // soil water content [mm] at Threshold for stomatal closure in top soil
         end;

     rep_IrriECw = Record
         PreSeason  : double;
         PostSeason : double;
         end;

     rep_CropFileSet = Record
         DaysFromSenescenceToEnd : integer;
         DaysToHarvest      : integer;  //given or calculated from GDD
         GDDaysFromSenescenceToEnd : integer;
         GDDaysToHarvest    : integer;  //given or calculated from Calendar Days
         end;

     rep_TimeCuttings = (NA,IntDay,IntGDD,DryB,DryY,FreshY);

     rep_Cuttings = Record
         Considered : BOOLEAN;
         CCcut      : Integer; // Canopy cover (%) after cutting
         CGCPlus    : Integer; // Increase (percentage) of CGC after cutting
         Day1       : Integer; // first day after time window for generating cuttings (1 = start crop cycle)
         NrDays     : Integer; // number of days of time window for generate cuttings (-9 is whole crop cycle)
         Generate   : Boolean; // ture: generate cuttings; false : schedule for cuttings
         Criterion  : rep_TimeCuttings; // time criterion for generating cuttings
         HarvestEnd : BOOLEAN; // final harvest at crop maturity
         FirstDayNr : LongInt; // first dayNr of list of specified cutting events (-9 = onset growing cycle)
         end;

     rep_Manag = Record
         Mulch           : ShortInt; (* percent soil cover by mulch in growing period *)
         SoilCoverBefore : ShortInt; (* percent soil cover by mulch before growing period *)
         SoilCoverAfter  : ShortInt; (* percent soil cover by mulch after growing period *)
         EffectMulchOffS : ShortInt; (* effect Mulch on evaporation before and after growing period *)
         EffectMulchInS  : ShortInt; (* effect Mulch on evaporation in growing period *)
         FertilityStress : ShortInt;
         BundHeight      : double; // meter;
         RunoffOn        : BOOLEAN;  (* surface runoff *)
         CNcorrection    : INTEGER; // percent increase/decrease of CN
         WeedRC          : ShortInt; (* Relative weed cover in percentage at canopy closure *)
         WeedDeltaRC     : INTEGER; (* Increase/Decrease of Relative weed cover in percentage during mid season*)
         WeedShape       : Double; (* Shape factor for crop canopy suppression*)
         WeedAdj         : ShortInt; (* replacement (%) by weeds of the self-thinned part of the Canopy Cover - only for perennials *)
         Cuttings        : rep_Cuttings; // Multiple cuttings
         end;


function AquaCropVersion(FullNameXXFile : string) : double;
         external 'aquacrop' name '__ac_global_MOD_aquacropversion';
         

function RootMaxInSoilProfile(
            constref ZmaxCrop : double;
            constref TheNrSoilLayers : shortint;
            constref TheSoilLayer : rep_SoilLayer) : single;
         external 'aquacrop' name '__ac_global_MOD_rootmaxinsoilprofile';


procedure ZrAdjustedToRestrictiveLayers(ZrIN : double;
                                        TheNrSoilLayers : ShortInt;
                                        TheLayer : rep_SoilLayer;
                                        var ZrOUT : double);
         external 'aquacrop' name '__ac_global_MOD_zradjustedtorestrictivelayers';

function TimeRootFunction(
            constref t : double;
            constref ShapeFactor : shortint;
            constref tmax, t0 : double) : double;
         external 'aquacrop' name '__ac_global_MOD_timerootfunction';

procedure set_layer_undef(
            var LayerData : SoilLayerIndividual);
         external 'aquacrop' name '__ac_global_MOD_set_layer_undef';

procedure DetermineDayNr(
            constref Dayi,Monthi,Yeari : integer;
            var DayNr : longint);
         external 'aquacrop' name '__ac_global_MOD_determinedaynr';

procedure DetermineDate(
            constref DayNr : longint;
            var Dayi,Monthi,Yeari : integer);
         external 'aquacrop' name '__ac_global_MOD_determinedate';
                        
function TimeToReachZroot(
            constref Zi, Zo, Zx : double;
            constref ShapeRootDeepening : shortint;
            constref Lo, LZxAdj : integer) : double;
         external 'aquacrop' name '__ac_global_MOD_timetoreachzroot';

function MaxCRatDepth(
            constref ParamCRa, ParamCRb, Ksat : double;
            constref Zi, DepthGWT : double) : double;
         external 'aquacrop' name '__ac_global_MOD_maxcratdepth';

function FromGravelMassToGravelVolume(
	    constref PorosityPercent : double;
            constref GravelMassPercent : shortint) : double;
         external 'aquacrop' name '__ac_global_MOD_fromgravelmasstogravelvolume';

function __GetWeedRC(
            constref TheDay : integer;
            constref GDDayi : double;
            constref fCCx : double;
            constref TempWeedRCinput : shortint;
            constref TempWeedAdj : shortint;
            var TempWeedDeltaRC : integer;
            constref L12SF : integer;
            constref TempL123 : integer;
            constref GDDL12SF : integer;
            constref TempGDDL123 : integer;
            constref TheModeCycle : integer) : double;
         external 'aquacrop' name '__ac_global_MOD_getweedrc';
		
function GetWeedRC(
            constref TheDay : integer;
            constref GDDayi : double;
            constref fCCx : double;
            constref TempWeedRCinput : shortint;
            constref TempWeedAdj : shortint;
            var TempWeedDeltaRC : integer;
            constref L12SF : integer;
            constref TempL123 : integer;
            constref GDDL12SF : integer;
            constref TempGDDL123 : integer;
            constref TheModeCycle : rep_modeCycle) : double;

procedure DetermineLengthGrowthStages_wrap(
            constref CCoVal : double;
            constref CCxVal : double;
            constref CDCVal : double;
            constref L0 : integer;
            constref TotalLength : integer;
            constref CGCgiven : boolean;
            constref TheDaysToCCini : integer;
            constref ThePlanting : integer;
            VAR Length123 : integer;
            VAR StLength : rep_int_array;
            VAR Length12 : integer;
            VAR CGCVal : double);
        external 'aquacrop' name '__ac_interface_global_MOD_determinelengthgrowthstages_wrap';

procedure DetermineLengthGrowthStages(
            constref CCoVal : double;
            constref CCxVal : double;
            constref CDCVal : double;
            constref L0 : integer;
            constref TotalLength : INTEGER;
            constref CGCgiven : BOOLEAN;
            constref TheDaysToCCini : INTEGER;
            constref ThePlanting : rep_planting;
            VAR Length123 : INTEGER;
            VAR StLength : rep_int_array;
            VAR Length12 : integer;
            VAR CGCVal : double);

function __TimeToCCini(
            constref ThePlantingType : integer;
            constref TheCropPlantingDens : integer;
            constref TheSizeSeedling : double;
            constref TheSizePlant : double;
            constref TheCropCCx : double;
            constref TheCropCGC : double) : Integer;
        external 'aquacrop' name '__ac_global_MOD_timetoccini';

function TimeToCCini(
            constref ThePlantingType : rep_planting;
            constref TheCropPlantingDens : integer;
            constref TheSizeSeedling : double;
            constref TheSizePlant : double;
            constref TheCropCCx : double;
            constref TheCropCGC : double) : Integer;


function MultiplierCCxSelfThinning(
            constref Yeari : integer;
            constref Yearx : integer;
            constref ShapeFactor : double) : double;
         external 'aquacrop' name '__ac_global_MOD_multiplierccxselfthinning';

function DaysToReachCCwithGivenCGC(
           constref CCToReach : double;
           constref CCoVal : double;
           constref CCxVal : double;
           constref CGCVal : double;
           constref L0 : integer) : integer;
        external 'aquacrop' name '__ac_global_MOD_daystoreachccwithgivencgc';

function LengthCanopyDecline(
           constref CCx : double;
           constref CDC : double) : integer;
        external 'aquacrop' name '__ac_global_MOD_lengthcanopydecline';

function CCmultiplierWeed(
            constref ProcentWeedCover : shortint;
            constref CCxCrop : double;
            constref FshapeWeed : double) : double;
         external 'aquacrop' name '__ac_global_MOD_ccmultiplierweed';


function HarvestIndexGrowthCoefficient(
        constref HImax,dHIdt : double) : double;
        external 'aquacrop' name '__ac_global_MOD_harvestindexgrowthcoefficient';

function TauFromKsat(constref Ksat : double) : double;
         external 'aquacrop' name '__ac_global_MOD_taufromksat';

function BMRange(constref HIadj : integer) : double;
         external 'aquacrop' name '__ac_global_MOD_bmrange';

function HImultiplier(
            constref RatioBM : double;
            constref RangeBM : double;
            constref HIadj : ShortInt) : double;
         external 'aquacrop' name '__ac_global_MOD_himultiplier';

function NumberSoilClass (
            constref SatvolPro : double;
            constref FCvolPro : double;
            constref PWPvolPro : double;
            constref Ksatmm : double) : shortint;
         external 'aquacrop' name '__ac_global_MOD_numbersoilclass';

procedure DeriveSmaxTopBottom(
            constref SxTopQ : double;
            constref SxBotQ : double;
            var SxTop : double;
            var SxBot : double);
         external 'aquacrop' name '__ac_global_MOD_derivesmaxtopbottom';

procedure CropStressParametersSoilFertility(
            constref CropSResp : rep_Shapes;
            constref StressLevel : ShortInt;
            var StressOUT : rep_EffectStress);
         external 'aquacrop' name '__ac_global_MOD_cropstressparameterssoilfertility';

function SoilEvaporationReductionCoefficient(
            constref Wrel : double;
            constref EDecline : double) : double;
         external 'aquacrop' name '__ac_global_MOD_soilevaporationreductioncoefficient';

function KsTemperature(
            constref T0,T1,Tin : double) : double;
         external 'aquacrop' name '__ac_global_MOD_kstemperature';

function KsSalinity(
            constref SalinityResponsConsidered : boolean;
            constref ECeN,ECeX : ShortInt;
            constref ECeVAR,KsShapeSalinity : double) : double;
         external 'aquacrop' name '__ac_global_MOD_kssalinity';

function MultiplierCCoSelfThinning(
            constref Yeari,Yearx : integer;
            constref ShapeFactor : double) : double;
         external 'aquacrop' name '__ac_global_MOD_multiplierccoselfthinning';

function KsAny(
            constref Wrel,pULActual,pLLActual,ShapeFactor : double) : double;
         external 'aquacrop' name '__ac_global_MOD_ksany';

function CCatTime(
            constref Dayi : integer;
            constref CCoIN, CGCIN, CCxIN : double)  : double;
         external 'aquacrop' name '__ac_global_MOD_ccattime';

function DegreesDay(
            constref Tbase,Tupper,TDayMin,TDayMax : double;
            constref GDDSelectedMethod : ShortInt) : double;
         external 'aquacrop' name '__ac_global_MOD_degreesday';

procedure DetermineCNIandIII(
            constref CN2 : ShortInt;
            var CN1,CN3 : ShortInt);
        external 'aquacrop' name '__ac_global_MOD_determinecniandiii';

procedure DetermineCN_default(
            constref Infiltr : double;
            var CN2 : ShortInt);
        external 'aquacrop' name '__ac_global_MOD_determineCN_default';

function CCatGDD(
            constref GDDi, CCoIN, GDDCGCIN, CCxIN : double)  : double;
         external 'aquacrop' name '__ac_global_MOD_ccatgdd';

function CanopyCoverNoStressGDDaysSF(
            constref GDDL0,GDDL123,GDDLMaturity : integer;
            constref SumGDD,CCo,CCx,GDDCGC,GDDCDC : double;
            constref SFRedCGC,SFRedCCx : shortint) : double;
         external 'aquacrop' name '__ac_global_MOD_canopycovernostressgddayssf';

function fAdjustedForCO2 (
            constref CO2i, WPi : double;
            constref PercentA : ShortInt) : double;
        external 'aquacrop' name '__ac_global_MOD_fadjustedforco2';

function FullUndefinedRecord(
            constref FromY,FromD,FromM,ToD,ToM : integer) : boolean;
        external 'aquacrop' name '__ac_global_MOD_fullundefinedrecord';

procedure GetCO2Description(
            constref CO2FileFull : string;
            var CO2Description : string);

procedure GetCO2Description_wrap(
            constref CO2FileFull : PChar;
            constref strlen1 : integer;
            var CO2Description : PChar;
            constref strlen2 : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_getco2description_wrap';

procedure GetIrriDescription(
            constref IrriFileFull : string;
            var IrriDescription : string);

procedure GetIrriDescription_wrap(
            constref IrriFileFull : PChar;
            constref strlen1 : integer;
            var IrriDescription : PChar;
            constref strlen2 : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_getirridescription_wrap';

procedure GetDaySwitchToLinear(
               constref HImax : integer;
               constref dHIdt,HIGC : double;
               var tSwitch : INTEGER;
               var HIGClinear : double);
        external 'aquacrop' name '__ac_global_MOD_getdayswitchtolinear';

procedure GetNumberSimulationRuns(
            constref TempFileNameFull : string;
            var NrRuns : integer);

procedure GetNumberSimulationRuns_wrap(
            constref TempFileNameFull : PChar;
            constref strlen : integer;
            var NrRuns : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_getnumbersimulationruns_wrap';

function GetCO2File(): string;

function GetCO2File_wrap(): PChar;
        external 'aquacrop' name '__ac_interface_global_MOD_getco2file_wrap';

procedure SetCO2File(constref str : string);

procedure SetCO2File_wrap(
            constref p : PChar;
            constref strlen : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_setco2file_wrap';


function GetEToFile(): string;

function GetEToFile_wrap(): PChar;
        external 'aquacrop' name '__ac_interface_global_MOD_getetofile_wrap';

procedure SetEToFile(constref str : string);

procedure SetEToFile_wrap(
            constref p : PChar;
            constref strlen : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_setetofile_wrap';

function GetEToFileFull(): string;

function GetEToFileFull_wrap(): PChar;
        external 'aquacrop' name '__ac_interface_global_MOD_getetofilefull_wrap';

procedure SetEToFileFull(constref str : string);

procedure SetEToFileFull_wrap(
            constref p : PChar;
            constref strlen : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_setetofilefull_wrap';


function GetRainFile(): string;

function GetRainFile_wrap(): PChar;
        external 'aquacrop' name '__ac_interface_global_MOD_getrainfile_wrap';

procedure SetRainFile(constref str : string);

procedure SetRainFile_wrap(
            constref p : PChar;
            constref strlen : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_setrainfile_wrap';

function GetRainFileFull(): string;

function GetRainFileFull_wrap(): PChar;
        external 'aquacrop' name '__ac_interface_global_MOD_getrainfilefull_wrap';

procedure SetRainFileFull(constref str : string);

procedure SetRainFileFull_wrap(
            constref p : PChar;
            constref strlen : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_setrainfilefull_wrap';

function GetIrriFile(): string;

function GetIrriFile_wrap(): PChar;
        external 'aquacrop' name '__ac_interface_global_MOD_getirrifile_wrap';

procedure SetIrriFile(constref str : string);

procedure SetIrriFile_wrap(
            constref p : PChar;
            constref strlen : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_setirrifile_wrap';

function GetClimateFile(): string;

function GetClimateFile_wrap(): PChar;
        external 'aquacrop' name '__ac_interface_global_MOD_getclimatefile_wrap';

procedure SetClimateFile(constref str : string);

procedure SetClimateFile_wrap(
            constref p : PChar;
            constref strlen : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_setclimatefile_wrap';

function GetClimFile(): string;

function GetClimFile_wrap(): PChar;
        external 'aquacrop' name '__ac_interface_global_MOD_getclimfile_wrap';

procedure SetClimFile(constref str : string);

procedure SetClimFile_wrap(
            constref p : PChar;
            constref strlen : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_setclimfile_wrap';
           
function GetSWCiniFile(): string;

function GetSWCiniFile_wrap(): PChar;
        external 'aquacrop' name '__ac_interface_global_MOD_getswcinifile_wrap';

procedure SetSWCiniFile(constref str : string);

procedure SetSWCiniFile_wrap(
            constref p : PChar;
            constref strlen : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_setswcinifile_wrap';      
        
function GetProjectFile(): string;

function GetProjectFile_wrap(): PChar;
        external 'aquacrop' name '__ac_interface_global_MOD_getprojectfile_wrap';

procedure SetProjectFile(constref str : string);

procedure SetProjectFile_wrap(
            constref p : PChar;
            constref strlen : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_setprojectfile_wrap';

function GetMultipleProjectFile(): string;

function GetMultipleProjectFile_wrap(): PChar;
        external 'aquacrop' name '__ac_interface_global_MOD_getmultipleprojectfile_wrap';

procedure SetMultipleProjectFile(constref str : string);

procedure SetMultipleProjectFile_wrap(
            constref p : PChar;
            constref strlen : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_setmultipleprojectfile_wrap';
                
function FileExists(constref full_name : string) : boolean;

function FileExists_wrap(
            constref full_name : string;
            constref strlen : integer) : boolean;
        external 'aquacrop' name '__ac_interface_global_MOD_fileexists_wrap';

function HIadjWStressAtFlowering(
            constref KsVeg,KsSto : double;
            constref a : ShortInt;
            constref b : double) : double;
         external 'aquacrop' name '__ac_global_MOD_hiadjwstressatflowering';

procedure SplitStringInTwoParams(
            constref StringIN : string;
            var Par1,Par2 : double);

procedure SplitStringInTwoParams_wrap(
            constref StringIN : PChar;
            constref strlen : integer;
            var Par1,Par2 : double);
        external 'aquacrop' name '__ac_interface_global_MOD_splitstringintwoparams_wrap';

procedure SplitStringInThreeParams(
            constref StringIN : string;
            var Par1,Par2, Par3 : double);

procedure SplitStringInThreeParams_wrap(
            constref StringIN : PChar;
            constref strlen : integer;
            var Par1,Par2,Par3 : double);
        external 'aquacrop' name '__ac_interface_global_MOD_splitstringinthreeparams_wrap';

function GetRootZoneWC(): rep_RootZoneWC;
        external 'aquacrop' name '__ac_global_MOD_getrootzonewc';

procedure SetRootZoneWC_Actual(constref Actual : double);
        external 'aquacrop' name '__ac_global_MOD_setrootzonewc_actual';

procedure SetRootZoneWC_FC(constref FC : double);
        external 'aquacrop' name '__ac_global_MOD_setrootzonewc_fc';

procedure SetRootZoneWC_WP(constref WP : double);
        external 'aquacrop' name '__ac_global_MOD_setrootzonewc_wp';

procedure SetRootZoneWC_SAT(constref SAT : double);
        external 'aquacrop' name '__ac_global_MOD_setrootzonewc_sat';

procedure SetRootZoneWC_Leaf(constref Leaf : double);
        external 'aquacrop' name '__ac_global_MOD_setrootzonewc_leaf';

procedure SetRootZoneWC_Thresh(constref Thresh : double);
        external 'aquacrop' name '__ac_global_MOD_setrootzonewc_thresh';

procedure SetRootZoneWC_Sen(constref Sen : double);
        external 'aquacrop' name '__ac_global_MOD_setrootzonewc_sen';

procedure SetRootZoneWC_ZtopAct(constref ZtopAct : double);
        external 'aquacrop' name '__ac_global_MOD_setrootzonewc_ztopact';

procedure SetRootZoneWC_ZtopFC(constref ZtopFC : double);
        external 'aquacrop' name '__ac_global_MOD_setrootzonewc_ztopfc';

procedure SetRootZoneWC_ZtopWP(constref ZtopWP : double);
        external 'aquacrop' name '__ac_global_MOD_setrootzonewc_ztopwp';

procedure SetRootZoneWC_ZtopThresh(constref ZtopThresh : double);
        external 'aquacrop' name '__ac_global_MOD_setrootzonewc_ztopthresh';

function GetCalendarFile(): string;

function GetCalendarFile_wrap(): PChar;
        external 'aquacrop' name '__ac_interface_global_MOD_getcalendarfile_wrap';

procedure SetCalendarFile(constref str : string);

procedure SetCalendarFile_wrap(
            constref p : PChar;
            constref strlen : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_setcalendarfile_wrap';

function GetCalendarFileFull(): string;

function GetCalendarFileFull_wrap(): PChar;
        external 'aquacrop' name '__ac_interface_global_MOD_getcalendarfilefull_wrap';

procedure SetCalendarFileFull(constref str : string);

procedure SetCalendarFileFull_wrap(
            constref p : PChar;
            constref strlen : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_setcalendarfilefull_wrap';

function GetCropFile(): string;

function GetCropFile_wrap(): PChar;
        external 'aquacrop' name '__ac_interface_global_MOD_getcropfile_wrap';

procedure SetCropFile(constref str : string);

procedure SetCropFile_wrap(
            constref p : PChar;
            constref strlen : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_setcropfile_wrap';

function GetCropFileFull(): string;

function GetCropFileFull_wrap(): PChar;
        external 'aquacrop' name '__ac_interface_global_MOD_getcropfilefull_wrap';

procedure SetCropFileFull(constref str : string);

procedure SetCropFileFull_wrap(
            constref p : PChar;
            constref strlen : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_setcropfilefull_wrap';

function GetProfFile(): string;

function GetProfFile_wrap(): PChar;
        external 'aquacrop' name '__ac_interface_global_MOD_getproffile_wrap';

procedure SetProfFile(constref str : string);

procedure SetProfFile_wrap(
            constref p : PChar;
            constref strlen : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_setproffile_wrap';

function GetProfFilefull(): string;

function GetProfFilefull_wrap(): PChar;
        external 'aquacrop' name '__ac_interface_global_MOD_getproffilefull_wrap';

procedure SetProfFilefull(constref str : string);

procedure SetProfFilefull_wrap(
            constref p : PChar;
            constref strlen : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_setproffilefull_wrap';

function GetManFile(): string;

function GetManFile_wrap(): PChar;
        external 'aquacrop' name '__ac_interface_global_MOD_getmanfile_wrap';

procedure SetManFile(constref str : string);

procedure SetManFile_wrap(
            constref p : PChar;
            constref strlen : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_setmanfile_wrap';

function GetManFilefull(): string;

function GetManFilefull_wrap(): PChar;
        external 'aquacrop' name '__ac_interface_global_MOD_getmanfilefull_wrap';

procedure SetManFilefull(constref str : string);

procedure SetManFilefull_wrap(
            constref p : PChar;
            constref strlen : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_setmanfilefull_wrap';

function GetOffSeasonFile(): string;

function GetOffSeasonFile_wrap(): PChar;
        external 'aquacrop' name '__ac_interface_global_MOD_getoffseasonfile_wrap';

procedure SetOffSeasonFile(constref str : string);

procedure SetOffSeasonFile_wrap(
            constref p : PChar;
            constref strlen : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_setoffseasonfile_wrap';

function GetOffSeasonFilefull(): string;

function GetOffSeasonFilefull_wrap(): PChar;
        external 'aquacrop' name '__ac_interface_global_MOD_getoffseasonfilefull_wrap';

procedure SetOffSeasonFilefull(constref str : string);

procedure SetOffSeasonFilefull_wrap(
            constref p : PChar;
            constref strlen : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_setoffseasonfilefull_wrap';

function GetGroundWaterFile(): string;

function GetGroundWaterFile_wrap(): PChar;
        external 'aquacrop' name '__ac_interface_global_MOD_getgroundwaterfile_wrap';

procedure SetGroundWaterFile(constref str : string);

procedure SetGroundWaterFile_wrap(
            constref p : PChar;
            constref strlen : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_setgroundwaterfile_wrap';

function GetGroundWaterFilefull(): string;

function GetGroundWaterFilefull_wrap(): PChar;
        external 'aquacrop' name '__ac_interface_global_MOD_getgroundwaterfilefull_wrap';

procedure SetGroundWaterFilefull(constref str : string);

procedure SetGroundWaterFilefull_wrap(
            constref p : PChar;
            constref strlen : integer);
        external 'aquacrop' name '__ac_interface_global_MOD_setgroundwaterfilefull_wrap';


function LeapYear(constref Year : integer) : boolean;
        external 'aquacrop' name '__ac_global_MOD_leapyear';

procedure CheckFilesInProject(
            constref TempFullFilename : string;
            constref Runi : integer;
            var AllOK : boolean);

procedure CheckFilesInProject_wrap(
            constref TempFullFilename : PChar;
            constref strlen : integer;
            constref Runi : integer;
            var AllOK : boolean);
        external 'aquacrop' name '__ac_interface_global_MOD_checkfilesinproject_wrap';

function GetIrriECw(): rep_IrriECw;
        external 'aquacrop' name '__ac_global_MOD_getirriecw';

procedure SetIrriECw_PreSeason(constref PreSeason : double);
        external 'aquacrop' name '__ac_global_MOD_setirriecw_preseason';

procedure SetIrriECw_PostSeason(constref PostSeason : double);
        external 'aquacrop' name '__ac_global_MOD_setirriecw_postseason';

function GetManagement_Cuttings_Considered(): boolean;
        external 'aquacrop' name '__ac_global_MOD_getmanagement_cuttings_considered';

function GetManagement_Cuttings_CGCPlus(): integer;
        external 'aquacrop' name '__ac_global_MOD_getmanagement_cuttings_cgcplus';

function GetManagement_Cuttings_CCcut(): integer;
        external 'aquacrop' name '__ac_global_MOD_getmanagement_cuttings_cccut';

function GetManagement_Cuttings_Day1(): integer;
        external 'aquacrop' name '__ac_global_MOD_getmanagement_cuttings_day1';

function GetManagement_Cuttings_NrDays(): integer;
        external 'aquacrop' name '__ac_global_MOD_getmanagement_cuttings_nrdays';

function GetManagement_Cuttings_Generate(): boolean;
        external 'aquacrop' name '__ac_global_MOD_getmanagement_cuttings_generate';

function __GetManagement_Cuttings_Criterion(): integer;
        external 'aquacrop' name '__ac_global_MOD_getmanagement_cuttings_criterion';

function GetManagement_Cuttings_Criterion(): rep_TimeCuttings;

function GetManagement_Cuttings_HarvestEnd(): boolean;
        external 'aquacrop' name '__ac_global_MOD_getmanagement_cuttings_harvestend';

function GetManagement_Cuttings_FirstDayNr(): integer;
        external 'aquacrop' name '__ac_global_MOD_getmanagement_cuttings_firstdaynr';

procedure SetManagement_Cuttings_Considered(constref Considered : boolean);
        external 'aquacrop' name '__ac_global_MOD_setmanagement_cuttings_considered';

procedure SetManagement_Cuttings_CCcut(constref CCcut : integer);
        external 'aquacrop' name '__ac_global_MOD_setmanagement_cuttings_cccut';

procedure SetManagement_Cuttings_CGCPlus(constref CGCPlus : integer);
        external 'aquacrop' name '__ac_global_MOD_setmanagement_cuttings_cgcplus';

procedure SetManagement_Cuttings_Day1(constref Day1 : integer);
        external 'aquacrop' name '__ac_global_MOD_setmanagement_cuttings_day1';

procedure SetManagement_Cuttings_NrDays(constref NrDays : integer);
        external 'aquacrop' name '__ac_global_MOD_setmanagement_cuttings_nrdays';

procedure SetManagement_Cuttings_Generate(constref Generate : boolean);
        external 'aquacrop' name '__ac_global_MOD_setmanagement_cuttings_generate';

procedure __SetManagement_Cuttings_Criterion(constref Criterion : integer);
        external 'aquacrop' name '__ac_global_MOD_setmanagement_cuttings_criterion';

procedure SetManagement_Cuttings_Criterion(constref Criterion : rep_TimeCuttings);

procedure SetManagement_Cuttings_HarvestEnd(constref HarvestEnd : boolean);
        external 'aquacrop' name '__ac_global_MOD_setmanagement_cuttings_harvestend';

procedure SetManagement_Cuttings_FirstDayNr(constref FirstDayNr : integer);
        external 'aquacrop' name '__ac_global_MOD_setmanagement_cuttings_firstdaynr';

function GetManagement_Mulch(): shortint;
        external 'aquacrop' name '__ac_global_MOD_getmanagement_mulch';

function GetManagement_SoilCoverBefore(): shortint;
        external 'aquacrop' name '__ac_global_MOD_getmanagement_soilcoverbefore';

function GetManagement_SoilCoverAfter(): shortint;
        external 'aquacrop' name '__ac_global_MOD_getmanagement_soilcoverafter';

function GetManagement_EffectMulchOffS(): shortint;
        external 'aquacrop' name '__ac_global_MOD_getmanagement_effectmulchoffs';

function GetManagement_EffectMulchInS(): shortint;
        external 'aquacrop' name '__ac_global_MOD_getmanagement_effectmulchins';

function GetManagement_FertilityStress(): shortint;
        external 'aquacrop' name '__ac_global_MOD_getmanagement_fertilitystress';

function GetManagement_BundHeight(): double;
        external 'aquacrop' name '__ac_global_MOD_getmanagement_bundheight';

function GetManagement_RunoffOn(): boolean;
        external 'aquacrop' name '__ac_global_MOD_getmanagement_runoffon';

function GetManagement_CNcorrection(): integer;
        external 'aquacrop' name '__ac_global_MOD_getmanagement_cncorrection';

function GetManagement_WeedRC(): shortint;
        external 'aquacrop' name '__ac_global_MOD_getmanagement_weedrc';

function GetManagement_WeedDeltaRC(): integer;
        external 'aquacrop' name '__ac_global_MOD_getmanagement_weeddeltarc';

function GetManagement_WeedShape(): double;
        external 'aquacrop' name '__ac_global_MOD_getmanagement_weedshape';

function GetManagement_WeedAdj(): shortint;
        external 'aquacrop' name '__ac_global_MOD_getmanagement_weedadj';

function GetManagement_Cuttings(): rep_Cuttings;
        external 'aquacrop' name '__ac_global_MOD_getmanagement_cuttings';

procedure SetManagement_Mulch(constref Mulch : shortint);
        external 'aquacrop' name '__ac_global_MOD_setmanagement_mulch';

procedure SetManagement_SoilCoverBefore(constref Mulch : shortint);
        external 'aquacrop' name '__ac_global_MOD_setmanagement_soilcoverbefore';

procedure SetManagement_SoilCoverAfter(constref After : shortint);
        external 'aquacrop' name '__ac_global_MOD_setmanagement_soilcoverafter';

procedure SetManagement_EffectMulchOffS(constref EffectMulchOffS : shortint);
        external 'aquacrop' name '__ac_global_MOD_setmanagement_effectmulchoffs';

procedure SetManagement_EffectMulchInS(constref EffectMulchInS : shortint);
        external 'aquacrop' name '__ac_global_MOD_setmanagement_effectmulchins';

procedure SetManagement_FertilityStress(constref FertilityStress : shortint);
        external 'aquacrop' name '__ac_global_MOD_setmanagement_fertilitystress';

procedure SetManagement_BundHeight(constref BundHeight : double);
        external 'aquacrop' name '__ac_global_MOD_setmanagement_bundheight';

procedure SetManagement_RunOffOn(constref RunOffOn : boolean);
        external 'aquacrop' name '__ac_global_MOD_setmanagement_runoffon';

procedure SetManagement_CNcorrection(constref CNcorrection : integer);
        external 'aquacrop' name '__ac_global_MOD_setmanagement_cncorrection';

procedure SetManagement_WeedRC(constref WeedRC : shortint);
        external 'aquacrop' name '__ac_global_MOD_setmanagement_weedrc';

procedure SetManagement_WeedDeltaRC(constref WeedDeltaRC : integer);
        external 'aquacrop' name '__ac_global_MOD_setmanagement_weeddeltarc';

procedure SetManagement_WeedShape(constref WeedShape : double);
        external 'aquacrop' name '__ac_global_MOD_setmanagement_weedshape';

procedure SetManagement_WeedAdj(constref WeedAdj : shortint);
        external 'aquacrop' name '__ac_global_MOD_setmanagement_weedadj';

function GetCropFileSet(): rep_CropFileSet;
        external 'aquacrop' name '__ac_global_MOD_getcropfileset';

procedure SetCropFileSet_DaysFromSenescenceToEnd(constref DaysFromSenescenceToEnd : double);
        external 'aquacrop' name '__ac_global_MOD_setcropfileset_daysfromsenescencetoend';

procedure SetCropFileSet_DaysToHarvest(constref DaysToHarvest : double);
        external 'aquacrop' name '__ac_global_MOD_setcropfileset_daystoharvest';

procedure SetCropFileSet_GDDaysFromSenescenceToEnd(constref GDDaysFromSenescenceToEnd : double);
        external 'aquacrop' name '__ac_global_MOD_setcropfileset_gddaysfromsenescencetoend';

procedure SetCropFileSet_GDDaysToHarvest(constref GDDaysToHarvest : double);
        external 'aquacrop' name '__ac_global_MOD_setcropfileset_gddaystoharvest';


implementation


function GetWeedRC(
            constref TheDay : integer;
            constref GDDayi : double;
            constref fCCx : double;
            constref TempWeedRCinput : shortint;
            constref TempWeedAdj : shortint;
            var TempWeedDeltaRC : integer;
            constref L12SF : integer;
            constref TempL123 : integer;
            constref GDDL12SF : integer;
            constref TempGDDL123 : integer;
            constref TheModeCycle : rep_modeCycle) : double;
var
    int_modeCycle: integer;

begin
    int_modeCycle := ord(TheModeCycle);
    GetWeedRC := __GetWeedRC(TheDay, GDDayi, fCCx, TempWeedRCinput, TempWeedAdj,
                             TempWeedDeltaRC, L12SF, TempL123, GDDL12SF,
                             TempGDDL123, int_modeCycle);
end;

function TimeToCCini(
            constref ThePlantingType : rep_planting;
            constref TheCropPlantingDens : integer;
            constref TheSizeSeedling : double;
            constref TheSizePlant : double;
            constref TheCropCCx : double;
            constref TheCropCGC : double) : Integer;
VAR 
    int_planting: integer;


begin
    int_planting := ord(ThePlantingType); 
    TimeToCCini := __TimeToCCini(int_planting, TheCropPlantingDens, TheSizeSeedling,
                                 TheSizePlant, TheCropCCx, TheCropCGC);
end;

procedure DetermineLengthGrowthStages(
            constref CCoVal : double;
            constref CCxVal : double;
            constref CDCVal : double;
            constref L0 : integer;
            constref TotalLength : integer;
            constref CGCgiven : boolean;
            constref TheDaysToCCini : integer;
            constref ThePlanting : rep_planting;
            VAR Length123 : integer;
            VAR StLength : rep_int_array;
            VAR Length12 : integer;
            VAR CGCVal : double);

VAR 
    int_planting : integer;

begin
    int_planting := ord(ThePlanting);
    DetermineLengthGrowthStages_wrap(CCoVal,CCxVal,
                                            CDCVal,L0,
                                            TotalLength,
                                            CGCgiven,
                                            TheDaysToCCini,
                                            int_planting,
                                            Length123,
                                            StLength,
                                            Length12,
                                            CGCVal);
end;

function GetManagement_Cuttings_Criterion() : rep_timecuttings;
var
    int_timecuttings : integer;

begin;
    int_timecuttings := __GetManagement_Cuttings_Criterion();
    GetManagement_Cuttings_Criterion := rep_timecuttings(int_timecuttings);
end;

procedure SetManagement_Cuttings_Criterion(constref Criterion : rep_TimeCuttings); 
var
    int_timecuttings : integer;

begin;
    int_timecuttings := ord(Criterion);
    __SetManagement_Cuttings_Criterion(int_timecuttings);
end;


procedure GetNumberSimulationRuns(
            constref TempFileNameFull : string;
            var NrRuns : integer);
var
    p : PChar;
    strlen : integer;

begin;
    p := PChar(TempFileNameFull);
    strlen := Length(TempFileNameFull);
    GetNumberSimulationRuns_wrap(p, strlen, NrRuns);
end;

function FileExists(constref full_name : string) : boolean;
var 
    p : PChar;
    strlen : integer;
begin;
    p := PChar(full_name);
    strlen := Length(full_name);
    FileExists := FileExists_wrap(p, strlen);
end;

procedure SplitStringInTwoParams(
            constref StringIN : string;
            var Par1,Par2 : double);
var
    p : PChar;
    strlen : integer;

begin;
    p := PChar(StringIN);
    strlen := Length(StringIN);
    SplitStringInTwoParams_wrap(p, strlen, Par1, Par2);
end;

procedure SplitStringInThreeParams(
            constref StringIN : string;
            var Par1,Par2,Par3 : double);
var
    p : PChar;
    strlen : integer;

begin;
    p := PChar(StringIN);
    strlen := Length(StringIN);
    SplitStringInThreeParams_wrap(p, strlen, Par1, Par2,Par3);
end;

procedure GetCO2Description(
            constref CO2FileFull : string;
            var CO2Description : string);
var
    p1, p2 : PChar;
    strlen1, strlen2 : integer;

begin;
    p1 := PChar(CO2FileFull);
    p2 := PChar(CO2Description);
    strlen1 := Length(CO2FileFull);
    strlen2 := Length(CO2Description);
    GetCO2Description_wrap(p1, strlen1, p2, strlen2);
    CO2Description := AnsiString(p2);
end;

function GetCO2File(): string;
var
    p : PChar;

begin;
    p := GetCO2File_wrap();
    GetCO2File := AnsiString(p);
end;


procedure SetCO2File(constref str : string);
var
    p : PChar;
    strlen : integer;

begin;
    p := PChar(str);
    strlen := Length(str);
    SetCO2File_wrap(p, strlen);
end;


function GetEToFile(): string;
var
    p : PChar;

begin;
    p := GetEToFile_wrap();
    GetEToFile := AnsiString(p);
end;


procedure SetEToFile(constref str : string);
var
    p : PChar;
    strlen : integer;

begin;
    p := PChar(str);
    strlen := Length(str);
    SetEToFile_wrap(p, strlen);
end;

function GetEToFileFull(): string;
var
    p : PChar;

begin;
    p := GetEToFileFull_wrap();
    GetEToFileFull := AnsiString(p);
end;


procedure SetEToFileFull(constref str : string);
var
    p : PChar;
    strlen : integer;

begin;
    p := PChar(str);
    strlen := Length(str);
    SetEToFileFull_wrap(p, strlen);
end;


function GetProfFile(): string;
var
    p : PChar;

begin;
    p := GetProfFile_wrap();
    GetProfFile := AnsiString(p);
end;

procedure SetProfFile(constref str : string);
var
    p : PChar;
    strlen : integer;

begin;
    p := PChar(str);
    strlen := Length(str);
    SetProfFile_wrap(p, strlen);
end;

function GetProfFilefull(): string;
var
    p : PChar;

begin;
    p := GetProfFilefull_wrap();
    GetProfFilefull := AnsiString(p);
end;

procedure SetProfFilefull(constref str : string);
var
    p : PChar;
    strlen : integer;

begin;
    p := PChar(str);
    strlen := Length(str);
    SetProfFilefull_wrap(p, strlen);
end;

function GetManFile(): string;
var
    p : PChar;

begin;
    p := GetManFile_wrap();
    GetManFile := AnsiString(p);
end;

procedure SetManFile(constref str : string);
var
    p : PChar;
    strlen : integer;

begin;
    p := PChar(str);
    strlen := Length(str);
    SetManFile_wrap(p, strlen);
end;

function GetManFilefull(): string;
var
    p : PChar;

begin;
    p := GetManFilefull_wrap();
    GetManFilefull := AnsiString(p);
end;

procedure SetManFilefull(constref str : string);
var
    p : PChar;
    strlen : integer;

begin;
    p := PChar(str);
    strlen := Length(str);
    SetManFilefull_wrap(p, strlen);
end;

function GetOffSeasonFile(): string;
var
    p : PChar;

begin;
    p := GetOffSeasonFile_wrap();
    GetOffSeasonFile := AnsiString(p);
end;

procedure SetOffSeasonFile(constref str : string);
var
    p : PChar;
    strlen : integer;

begin;
    p := PChar(str);
    strlen := Length(str);
    SetOffSeasonFile_wrap(p, strlen);
end;

function GetOffSeasonFilefull(): string;
var
    p : PChar;

begin;
    p := GetOffSeasonFilefull_wrap();
    GetOffSeasonFilefull := AnsiString(p);
end;

procedure SetOffSeasonFilefull(constref str : string);
var
    p : PChar;
    strlen : integer;

begin;
    p := PChar(str);
    strlen := Length(str);
    SetOffSeasonFilefull_wrap(p, strlen);
end;


function GetGroundWaterFile(): string;
var
    p : PChar;

begin;
    p := GetGroundWaterFile_wrap();
    GetGroundWaterFile := AnsiString(p);
end;

procedure SetGroundWaterFile(constref str : string);
var
    p : PChar;
    strlen : integer;

begin;
    p := PChar(str);
    strlen := Length(str);
    SetGroundWaterFile_wrap(p, strlen);
end;

function GetGroundWaterFilefull(): string;
var
    p : PChar;

begin;
    p := GetGroundWaterFilefull_wrap();
    GetGroundWaterFilefull := AnsiString(p);
end;

procedure SetGroundWaterFilefull(constref str : string);
var
    p : PChar;
    strlen : integer;

begin;
    p := PChar(str);
    strlen := Length(str);
    SetGroundWaterFilefull_wrap(p, strlen);
end;



procedure CheckFilesInProject(
            constref TempFullFilename : string;
            constref Runi : integer;
            var AllOK : boolean);
var
    p : PChar;
    strlen : integer;

begin;
    p := PChar(TempFullFilename);
    strlen := Length(TempFullFilename);
    CheckFilesInProject_wrap(p, strlen, Runi, AllOK);
end;

procedure GetIrriDescription(
            constref IrriFileFull : string;
            var IrriDescription : string);
var
    p1, p2 : PChar;
    strlen1, strlen2 : integer;

begin;
    p1 := PChar(IrriFileFull);
    p2 := PChar(IrriDescription);
    strlen1 := Length(IrriFileFull);
    strlen2 := Length(IrriDescription);
    GetIrriDescription_wrap(p1, strlen1, p2, strlen2);
    IrriDescription := AnsiString(p2);
end;


function GetIrriFile(): string;
var
    p : PChar;

begin;
    p := GetIrriFile_wrap();
    GetIrriFile := AnsiString(p);
end;


procedure SetIrriFile(constref str : string);
var
    p : PChar;
    strlen : integer;

begin;
    p := PChar(str);
    strlen := Length(str);
    SetIrriFile_wrap(p, strlen);
end;


function GetClimateFile(): string;
var
    p : PChar;

begin;
    p := GetClimateFile_wrap();
    GetClimateFile := AnsiString(p);
end;


procedure SetClimateFile(constref str : string);
var
    p : PChar;
    strlen : integer;

begin;
    p := PChar(str);
    strlen := Length(str);
    SetClimateFile_wrap(p, strlen);
end;

function GetClimFile(): string;
var
    p : PChar;

begin;
    p := GetClimFile_wrap();
    GetClimFile := AnsiString(p);
end;


procedure SetClimFile(constref str : string);
var
    p : PChar;
    strlen : integer;

begin;
    p := PChar(str);
    strlen := Length(str);
    SetClimFile_wrap(p, strlen);
end;


function GetSWCiniFile(): string;
var
    p : PChar;

begin;
    p := GetSWCiniFile_wrap();
    GetSWCiniFile := AnsiString(p);
end;


procedure SetSWCiniFile(constref str : string);
var
    p : PChar;
    strlen : integer;

begin;
    p := PChar(str);
    strlen := Length(str);
    SetSWCiniFile_wrap(p, strlen);
end;

function GetProjectFile(): string;
var
    p : PChar;

begin;
    p := GetProjectFile_wrap();
    GetProjectFile := AnsiString(p);
end;


procedure SetProjectFile(constref str : string);
var
    p : PChar;
    strlen : integer;

begin;
    p := PChar(str);
    strlen := Length(str);
    SetProjectFile_wrap(p, strlen);
end;

function GetMultipleProjectFile(): string;
var
    p : PChar;

begin;
    p := GetMultipleProjectFile_wrap();
    GetMultipleProjectFile := AnsiString(p);
end;


procedure SetMultipleProjectFile(constref str : string);
var
    p : PChar;
    strlen : integer;

begin;
    p := PChar(str);
    strlen := Length(str);
    SetMultipleProjectFile_wrap(p, strlen);
end;

function GetRainFile(): string;
var
    p : PChar;

begin;
    p := GetRainFile_wrap();
    GetRainFile := AnsiString(p);
end;

procedure SetRainFile(constref str : string);
var
    p : PChar;
    strlen : integer;

begin;
    p := PChar(str);
    strlen := Length(str);
    SetRainFile_wrap(p, strlen);
end;

function GetRainFileFull(): string;
var
    p : PChar;

begin;
    p := GetRainFileFull_wrap();
    GetRainFileFull := AnsiString(p);
end;

procedure SetRainFileFull(constref str : string);
var
    p : PChar;
    strlen : integer;

begin;
    p := PChar(str);
    strlen := Length(str);
    SetRainFileFull_wrap(p, strlen);
end;



function GetCalendarFile(): string;
var
    p : PChar;

begin;
    p := GetCalendarFile_wrap();
    GetCalendarFile := AnsiString(p);
end;

procedure SetCalendarFile(constref str : string);
var
    p : PChar;
    strlen : integer;

begin;
    p := PChar(str);
    strlen := Length(str);
    SetCalendarFile_wrap(p, strlen);
end;


function GetCalendarFileFull(): string;
var
    p : PChar;

begin;
    p := GetCalendarFileFull_wrap();
    GetCalendarFileFull := AnsiString(p);
end;

procedure SetCalendarFileFull(constref str : string);
var
    p : PChar;
    strlen : integer;

begin;
    p := PChar(str);
    strlen := Length(str);
    SetCalendarFileFull_wrap(p, strlen);
end;


function GetCropFile(): string;
var
    p : PChar;

begin;
    p := GetCropFile_wrap();
    GetCropFile := AnsiString(p);
end;


procedure SetCropFile(constref str : string);
var
    p : PChar;
    strlen : integer;
begin;
    p := PChar(str);
    strlen := Length(str);
    SetCropFile_wrap(p, strlen);
end;


function GetCropFileFull(): string;
var
    p : PChar;

begin;
    p := GetCropFileFull_wrap();
    GetCropFileFull := AnsiString(p);
end;


procedure SetCropFileFull(constref str : string);
var
    p : PChar;
    strlen : integer;
begin;
    p := PChar(str);
    strlen := Length(str);
    SetCropFileFull_wrap(p, strlen);
end;



initialization


end.
