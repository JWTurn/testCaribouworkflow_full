repos <- c("https://predictiveecology.r-universe.dev", getOption("repos"))
source("https://raw.githubusercontent.com/PredictiveEcology/pemisc/refs/heads/development/R/getOrUpdatePkg.R")
getOrUpdatePkg(c("Require", "SpaDES.project"), c("	1.0.1.9013", "0.1.4")) # only install/update if required
#Require::Install("PredictiveEcology/SpaDES.core@box")

projPath = "~/git/caribouWorkFlow"
reproducibleInputsPath = "~/git/reproducibleInputs"
Sys.setenv(MOVEBANK_USERNAME = "")
Sys.setenv(MOVEBANK_PASSWORD = "")
out <- SpaDES.project::setupProject(
  Restart = TRUE,
  useGit = "JWTurn",            # keep your current default; module repos can override via module strings
  updateRprofile = TRUE,
  paths = list(
    projectPath = projPath
  ),

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
    "gc-rmcinnes/caribouLocPrep@main",
    "gc-rmcinnes/prepTracks@main",
    "JWTurn/prepLandscape@main",
    "gc-rmcinnes/extractLand@main",
    "gc-rmcinnes/caribouiSSA@main"
  ),

  params = list(
    .globals = list(
      .plots = c("png"),
      .studyAreaName = c("all"),
      .useCache = c(".inputObjects"),
      MoveBankUser = "",
      MoveBankPass = "",
      histLandYears = 2009:2025,
      modelScale = "global"
    )
  ),

  packages = c(
    "RCurl", "XML", "snow", "googledrive", "httr2",
    "terra", "gert", "remotes", "reproducible",
    "PredictiveEcology/SpaDES.core@box (HEAD)",
    "glmmTMB"
  )
)


results <- SpaDES.core::simInitAndSpades2(out)
