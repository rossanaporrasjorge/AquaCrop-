unit InitialSettings;

interface


uses Global, interface_global, DefaultCropSoil, interface_defaultcropsoil, interface_initialsettings;

PROCEDURE InitializeSettings;

implementation

 PROCEDURE InitializeSettings;
 TYPE rep_string20 = string[20];
 VAR TempString1,TempString2 : string;
     Nri : INTEGER;

 BEGIN
 // 1. Program settings
 // Settings of Program parameters
 // 1a. General.PAR
 WITH SimulParam DO
   BEGIN
   PercRAW := 50; //Threshold [% of RAW] for determination of Inet
   NrCompartments := 12; //Number of soil compartments (maximum is 12) (not a program parameter)
   CompDefThick := 0.10; //Default thickness of soil compartments [m]
   CropDay1 := 81; //DayNumber of first day cropping period (1..365)
   Tbase:= 10.0;  //Default base temperature (degC) below which no crop development
   Tupper:= 30.0; //Default upper temperature threshold for crop development
   IrriFwInSeason := 100; //Percentage of soil surface wetted by irrigation in crop season
   IrriFwOffSeason := 100; // Percentage of soil surface wetted by irrigation off-season
   END;
 // 1b. Soil.PAR - 6 parameters
 WITH SimulParam DO
   BEGIN
   RunoffDepth := 0.30; //considered depth (m) of soil profile for calculation of mean soil water content
   CNcorrection := true;
   SaltDiff := 20; // salt diffusion factor (%)
   SaltSolub := 100; // salt solubility (g/liter)
   RootNrDF := 16; // shape factor capillary rise factor
   IniAbstract := 5; // fixed in Version 5.0 cannot be changed since linked with equations for CN AMCII and CN converions
   END;
 // 1c. Rainfall.PAR - 4 parameters
 WITH SimulParam DO
   BEGIN
   EffectiveRain.Method := USDA;
   EffectiveRain.PercentEffRain := 70; // IF Method is Percentage
   EffectiveRain.ShowersInDecade := 2;  // For estimation of surface run-off
   EffectiveRain.RootNrEvap := 5; // For reduction of soil evaporation
   END;
 // 1d. Crop.PAR  - 12 parameters
 WITH SimulParam DO
   BEGIN
   EvapDeclineFactor := 4; // evaporation decline factor in stage 2
   KcWetBare := 1.10; //Kc wet bare soil [-]
   PercCCxHIfinal := 5; // CC threshold below which HI no longer increase(% of 100)
   RootPercentZmin := 70; //Starting depth of root sine function (% of Zmin)
   MaxRootZoneExpansion := 5.00; // fixed at 5 cm/day
   KsShapeFactorRoot := -6; // Shape factor for effect water stress on rootzone expansion
   TAWGermination := 20;  // Soil water content (% TAW) required at sowing depth for germination
   pAdjFAO := 1; //Adjustment factor for FAO-adjustment soil water depletion (p) for various ET
   DelayLowOxygen := 3; //number of days for full effect of deficient aeration
   ExpFsen := 1.00; // exponent of senescence factor adjusting drop in photosynthetic activity of dying crop
   Beta := 12; // Decrease (percentage) of p(senescence) once early canopy senescence is triggered
   ThicknessTopSWC := 10; // Thickness top soil (cm) in which soil water depletion has to be determined
   END;
 // 1e. Field.PAR - 1 parameter
 WITH SimulParam DO
   BEGIN
   EvapZmax := 30; //maximum water extraction depth by soil evaporation [cm]
   END;
 // 1f. Temperature.PAR - 3 parameters
 WITH SimulParam DO
   BEGIN
   Tmin := 12.0;   //Default minimum temperature (degC) if no temperature file is specified
   Tmax := 28.0;   //Default maximum temperature (degC) if no temperature file is specified
   GDDMethod := 3; //Default method for GDD calculations
   END;


 PreDay := false;
 IniPercTAW := 50; // Default Value for Percentage TAW for Display in Initial Soil Water Content Menu

 // Default for soil compartments
 IF (NrCompartments > max_No_compartments) //Savety check of value in General.PAR;
    THEN NrCompartments := max_No_compartments;
 FOR Nri := 1 TO max_No_compartments DO  // required for formactivate ParamNew
     Compartment[Nri].Thickness := SimulParam.CompDefThick;
 // Default CropDay1 - Savety check of value in General.PAR
 WHILE (SimulParam.CropDay1 > 365) DO SimulParam.CropDay1 := SimulParam.CropDay1-365;
 If (SimulParam.CropDay1 < 1) THEN SimulParam.CropDay1 := 1;

 // 2a. Ground water table
 GroundWaterFile := '(None)';
 GroundWaterFilefull := GroundWaterFile;  (* no file *)
 GroundWaterDescription := 'no shallow groundwater table';
 ZiAqua := undef_int;
 ECiAqua := undef_int;
 SimulParam.ConstGwt := true;

 // 2b. Soil profile and initial soil water content
 ResetDefaultSoil; // Reset the soil profile to its default values
 ProfFile := 'DEFAULT.SOL';
 ProfFilefull := CONCAT(PathNameSimul,ProfFile);
 // required for Soil.RootMax := RootMaxInSoilProfile(Crop.RootMax,Crop.RootMin,Soil.NrSoilLayers,SoilLayer) in LoadProfile
 Crop.RootMin := 0.30; //Minimum rooting depth (m)
 Crop.RootMax := 1.00; //Maximum rooting depth (m)
 // Crop. RootMin, RootMax, and Soil.RootMax are correctly calculated in LoadCrop
 LoadProfile(ProfFilefull);
 CompleteProfileDescription; // Simulation.ResetIniSWC AND specify_soil_layer whcih contains PROCEDURE DeclareInitialCondAtFCandNoSalt,
                             // in which SWCiniFile := '(None)', and settings for Soil water and Salinity content

 // 2c. Complete initial conditions (crop development)
 Simulation.CCini := undef_int;
 Simulation.Bini := 0.000;
 Simulation.Zrini := undef_int;


 // 3. Crop characteristics and cropping period
 ResetDefaultCrop; // Reset the crop to its default values
 CropFile := 'DEFAULT.CRO';
 CropFilefull := CONCAT(PathNameSimul,CropFile);
 //LoadCrop ==============================
 Crop.CCo := (Crop.PlantingDens/10000) * (Crop.SizeSeedling/10000);
 Crop.CCini := (Crop.PlantingDens/10000) * (Crop.SizePlant/10000);
 // maximum rooting depth in given soil profile
 Soil.RootMax := RootMaxInSoilProfile(Crop.RootMax,Soil.NrSoilLayers,SoilLayer);
 // determine miscellaneous
 Crop.Day1 := SimulParam.CropDay1;
 CompleteCropDescription;
 Simulation.YearSeason := 1;
 NoCropCalendar;

 // 4. Field Management
 ManFile := '(None)';
 ManFilefull := ManFile;  (* no file *)
 NoManagement;

 // 5. Climate
 // 5.1 Temperature
 SetTemperatureFile('(None)');
 SetTemperatureFilefull(GetTemperatureFile());  (* no file *)
 Str(SimulParam.Tmin:8:1,TempString1);
 Str(SimulParam.Tmax:8:1,TempString2);
 TemperatureDescription := '';
 // WITH TemperatureRecord DO
 //  BEGIN
 SetTemperatureRecord_DataType(Daily);
 SetTemperatureRecord_NrObs(0);
 SetTemperatureRecord_FromString('any date');
 SetTemperatureRecord_ToString('any date');
 SetTemperatureRecord_FromY(1901);
 //  END;

 // 5.2 ETo
 EToFile := '(None)';
 EToFilefull := EToFile;  (* no file *)
 EToDescription := '';
 WITH EToRecord DO
   BEGIN
   DataType := Daily;
   NrObs := 0;
   FromString := 'any date';
   ToString := 'any date';
   FromY := 1901;
   END;

 // 5.3 Rain
 RainFile := '(None)';
 RainFilefull := RainFile;  (* no file *)
 RainDescription := '';
 WITH RainRecord DO
   BEGIN
   DataType := Daily;
   NrObs := 0;
   FromString := 'any date';
   ToString := 'any date';
   FromY := 1901;
   END;

 // 5.4 CO2
 SetCO2File('MaunaLoa.CO2');
 CO2FileFull := CONCAT(PathNameSimul,GetCO2File());
 GetCO2Description(CO2FileFull,CO2Description);

 // 5.5 Climate file
 ClimateFile := '(None)';
 ClimateFileFull := ClimateFile;
 ClimateDescription := '';

 // 5.6 Set Climate and Simulation Period
 SetClimData;
 Simulation.LinkCropToSimPeriod := true;
(* adjusting Crop.Day1 and Crop.DayN to ClimFile *)
 AdjustCropYearToClimFile(Crop.Day1,Crop.DayN);
(* adjusting ClimRecord.'TO' for undefined year with 365 days *)
 IF ((ClimFile <> '(None)') AND (ClimRecord.FromY = 1901)
   AND (ClimRecord.NrObs = 365)) THEN AdjustClimRecordTo(Crop.DayN);
(* adjusting simulation period *)
 AdjustSimPeriod;

 // 6. irrigation
 IrriFile := '(None)';
 IrriFilefull := IrriFile;  (* no file *)
 NoIrrigation;

 // 7. Off-season
 OffSeasonFile := '(None)';
 OffSeasonFileFull := OffSeasonFile;
 NoManagementOffSeason;

 // 8. Project and Multiple Project file
 ProjectFile := '(None)';
 ProjectFileFull := ProjectFile;
 ProjectDescription := 'No specific project';
 Simulation.MultipleRun := false; // No sequence of simulation runs in the project
 Simulation.NrRuns := 1;
 Simulation.MultipleRunWithKeepSWC := false;
 Simulation.MultipleRunConstZrx := undef_int;
 MultipleProjectFile := ProjectFile;
 MultipleProjectFileFull := ProjectFileFull;
 MultipleProjectDescription := ProjectDescription;


 // 9. Observations file
 ObservationsFile := '(None)';
 ObservationsFileFull := ObservationsFile;
 ObservationsDescription := 'No field observations';

 // 10. Output files
 OutputName := 'Project';

 // 11. Onset
 Onset.Criterion := RainPeriod;
 Onset.AirTCriterion := CumulGDD;
 AdjustOnsetSearchPeriod;

 // 12. Simulation run
 ETo := 5.0;
 Rain := 0;
 Irrigation := 0;
 SurfaceStorage := 0;
 ECstorage := 0.0;
 DaySubmerged := 0;
 GlobalZero(SumWabal);
 Drain:= 0.0; // added 4.0
 Runoff:= 0.0;// added 4.0
 Infiltrated := 0.0; // added 4.0
 CRwater := 0; // added 4.0
 CRsalt := 0; // added 4.0
 Simulation.ResetIniSWC := true;
 Simulation.EvapLimitON := false;
 MaxPlotNew := 50;
 MaxPlotTr := 10;
 Simulation.InitialStep := 10; // Length of period (days) for displaying intermediate results during simulation run
 Simulation.LengthCuttingInterval := 40; // Default length of cutting interval (days)
 END; (* InitializeSettings *)


end.
