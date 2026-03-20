repos <- c("https://predictiveecology.r-universe.dev", getOption("repos"))
source("https://raw.githubusercontent.com/PredictiveEcology/pemisc/refs/heads/development/R/getOrUpdatePkg.R")
getOrUpdatePkg(c("Require", "SpaDES.project"), c("	1.0.1.9013", "0.1.4")) # only install/update if required
#Require::Install("PredictiveEcology/SpaDES.core@box")

projPath = "~/git/caribouWorkFlow"
reproducibleInputsPath = "~/git/reproducibleInputs"
out <- SpaDES.project::setupProject(
  Restart = TRUE,
  useGit = "JWTurn",            # keep your current default; module repos can override via module strings
  updateRprofile = TRUE,
  paths = list(
    projectPath = projPath
  ),
  #use default dots to update the jurisdiction with experiment
  # defaultDots = list(
  #   .jurisdiction = "NT"
  # ),

  options = list(
    spades.allowInitDuringSimInit = TRUE,
    spades.allowSequentialCaching = TRUE,
    spades.moduleCodeChecks = FALSE,
    spades.recoveryMode = 1,

    reproducible.inputPaths = reproducibleInputsPath,
    reproducible.useMemoise = TRUE,
    reproducible.cloudFolderID = "https://drive.google.com/drive/folders/1RS-NFX6FLBLV_QxfcGyJhws_GW1CHDA9?usp=drive_link"
  ),

  modules = c(
    "PredictiveEcology/Biomass_borealDataPrep@development",
    "PredictiveEcology/Biomass_core@development",
    "PredictiveEcology/Biomass_regeneration@master",
    file.path("PredictiveEcology/scfm@development/modules",
              c("scfmDataPrep",
                "scfmIgnition", "scfmEscape", "scfmSpread",
                "scfmDiagnostics")),
    "JWTurn/caribou_SSUD@main"
  ),

  params = list(
    .globals = list(
      .plots = c("png"),
      #make this the jurisdiction being run
      .studyAreaName = c("all"),
      .useCache = c(".inputObjects"),
      #make this the jurisdiction being run
      jurisdiction = c("NT"),
      modelScale = "global",
      dataYear = 2020,
      sppEquivCol = "LandR",
      normalizePDE = TRUE
    ),

    scfmDataPrep = list(
     targetN = 2000,
     .useParallelFireRegimePolys = TRUE
    ),

    caribou_SSUD = list(
     simulationProcess = "dynamic",
     simulationScale = "global"
    ),
  ),

  packages = c(
    "RCurl", "XML", "snow", "googledrive", "httr2",
    "terra", "gert", "remotes", "reproducible",
    "PredictiveEcology/LandR@development",
    "PredictiveEcology/SpaDES.core@box (HEAD)",
    "glmmTMB"
  ),

  times = list(start = 2011, end = 2051),

  #change this to the studyArea_juris for each tmux session
  studyArea = {

    sa <- reproducible::prepInputs(url = 'https://drive.google.com/file/d/1-_iR8rnJ-apN3RHmc6P1L3nlmo5rqOaA/view?usp=drive_link',
                                   destinationPath = paths$inputPath,
                                   targetFile = "studyareabc.shp",
                                   alsoExtract = "similar", fun = "terra::vect") |>
      reproducible::Cache()

  },

  studyAreaLarge = {
    terra::buffer(studyArea, 2000)
  },

  studyAreaCalibration = studyAreaLarge,

  rasterToMatchLarge = {
    rtml <- terra::rast(studyAreaLarge, res = c(250, 250))
    rtml[] <- 1
    terra::mask(rtml, studyAreaLarge)
  },

  rasterToMatch = {
    reproducible::postProcess(rasterToMatchLarge, cropTo = studyArea, maskTo = studyArea)
  },

  rasterToMatchCoarse = {
    terra::aggregate(rasterToMatch, 2)
  },

  rasterToMatchCalibration = {
    rtmc <- terra::rast(studyAreaCalibration, res = c(250, 250))
    rtmc[] <- 1
    terra::mask(rtmc, studyAreaCalibration)
  },

  ## scfm workaround retained
  treedFirePixelTableSinceLastDisp = data.table::data.table(
    pixelIndex = integer(), pixelGroup = integer(), burnTime = numeric()
  ),

  sppEquiv = {
    speciesInStudy <- LandR::speciesInStudyArea(studyAreaLarge, dPath = paths$inputPath)
    species <- LandR::equivalentName(speciesInStudy$speciesList, df = LandR::sppEquivalencies_CA, "LandR")
    sppEquiv <- LandR::sppEquivalencies_CA[LandR %in% species]
    sppEquiv <- sppEquiv[KNN != "" & LANDIS_traits != ""]
    sppEquiv
  }
)


results <- SpaDES.core::simInitAndSpades2(out)
