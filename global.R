repos <- c("https://predictiveecology.r-universe.dev", getOption("repos"))
source("https://raw.githubusercontent.com/PredictiveEcology/pemisc/refs/heads/development/R/getOrUpdatePkg.R")
getOrUpdatePkg(c("Require", "SpaDES.project"), c("1.0.1.9020", "0.1.1.9043")) # only install/update if required
#Require::Install("PredictiveEcology/SpaDES.core@box")

projPath = "~/git/testCaribouworkflow_full"
reproducibleInputsPath = "~/git/reproducibleInputs"

out <- SpaDES.project::setupProject(
  Restart = TRUE,
  useGit = TRUE,
  updateRprofile = TRUE,
  #overwrite = TRUE,
  paths = list(projectPath =  projPath
               #"packagePath" = file.path("packages", Require:::versionMajorMinor())
  ),
  options = options(spades.allowInitDuringSimInit = TRUE,
    spades.allowSequentialCaching = TRUE,
    spades.moduleCodeChecks = FALSE,
    spades.recoveryMode = 1,
    reproducible.inputPaths = reproducibleInputsPath,
    reproducible.useMemoise = TRUE
  ),
  modules = c('gc-rmcinnes/caribouLocPrep@main',
              'gc-rmcinnes/prepTracks@main',
              'JWTurn/prepLandscape@main',
              'gc-rmcinnes/extractLand@main'

  ),
  params = list(
    .globals = list(
      .plots = c("png"),
      .studyAreaName=  "bc",
      jurisdiction = c("BC"),
      .useCache = c(".inputObjects"),
      histLandYears = 2019:2021
    )


  ),

  packages = c('RCurl', 'XML', 'snow', 'googledrive', 'httr2', "terra", "gert", "remotes",
               "PredictiveEcology/reproducible@AI", "PredictiveEcology/LandR@development",
               "PredictiveEcology/SpaDES.core@box")

  # OUTPUTS TO SAVE -----------------------
  # outputs = {
  #   # save to disk 2 objects, every year
  #   #will add once works, ha
  #
  # }

)


results <- SpaDES.core::simInitAndSpades2(out)




out <- SpaDES.project::setupProject(
  Restart = TRUE,
  updateRprofile = FALSE,
  paths = list(projectPath = projPath),
  options = options(
    spades.allowSequentialCaching = TRUE,
    spades.moduleCodeChecks = FALSE,
    spades.recoveryMode = 1,
    reproducible.inputPaths = reproducibleInputsPath,
    reproducible.useMemoise = TRUE
  ),

  modules = c('gc-rmcinnes/caribouLocPrep@main',
              'gc-rmcinnes/prepTracks@main',
              'JWTurn/prepLandscape@main',
              'gc-rmcinnes/extractLand@main'),

  params = list(
    .globals = list(
      .plots = c("png"),
      .useCache = c(".inputObjects"),
      jurisdiction = c("BC"),
      .studyAreaName=  "bcnwt",
      histLandYears = 2019:2021)
  ),

  packages = c('RCurl', 'XML', 'snow', 'googledrive', 'httr2', "terra", "gert", "remotes",
               "PredictiveEcology/reproducible@AI", "PredictiveEcology/LandR@development",
               "PredictiveEcology/SpaDES.core@box")
)

