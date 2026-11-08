suppressMessages(require(rms, quietly = TRUE, warn.conflicts = FALSE))
require(splines, quietly = TRUE)
require(plotly, quietly = TRUE, warn.conflicts = FALSE)
require(Hmisc, quietly = TRUE)
require(e1071, quietly = TRUE)
require(caret, quietly = TRUE)
require(BiodiversityR, quietly = TRUE)
require(logistf, quietly = TRUE)
require(rmarkdown, quietly = TRUE)
NA_THRESHOLD = 0.03
# CORR_THRESHOLD is set by the config file

# Remove variables that correlation are non-relevant. These are the identification variables or dependant variable.
# Warning: This is redefined for each model construction!!!
dropToPredict = c("File.Path", "Project", "Language", "Table.Name","Name","Kind","Table.Name", "X..Bugs.Post", "File", "Distinct.count.of.Issue.Key.POST", "X..Catch", "X..Throws")

source(file = file.path(CODE_DIR, "construction_functions.R"))
source(file = file.path(CODE_DIR, "analysis_functions.R"))
load(file = DATA_RDATA)
all_list_omitted_2 = all_no_missing
all_list_omitted = vector("list", 0)
for (i in 1:length(projects)) {
  print(paste("Project:", projects[i]))
  temp_data = as.data.frame(all_list_omitted_2[i])
  temp_data_bkp = temp_data
  print(paste("nrow:",nrow(temp_data),"ncol:",ncol(temp_data)))
  
  # Make 0 catch blocks become NA and remove NA's.
  No_Catch <- temp_data$X..Catch == 0
  temp_data$X..Catch[No_Catch] <- NA
  temp_data <- na.omit(temp_data)
  print(paste("nrow:",nrow(temp_data),"ncol:",ncol(temp_data)))
  
  if (nrow(temp_data) == 0){
    write.csv(temp_data_bkp, file = "temp_data.csv")
  }
  
  # Remove throws columns
  temp_data = temp_data[,!(names(temp_data) %in% throws_names)]
  print(paste("nrow:",nrow(temp_data),"ncol:",ncol(temp_data)))

  all_list_omitted <- c(all_list_omitted, list(list(project=projects[i], data=temp_data)))
}
modelSelectionAndNormalityAdjustment(all_list_omitted)
all_list_omitted_m0 = vector("list", 0)
for (i in 1:length(projects)) {
  print(paste("Project:", projects[i]))
  temp_data = as.data.frame(all_list_omitted[[i]]$data)

  keepForID = c("Project", "File.Path")
  keepForCatch = c(keepForID)
  keepForTry = c(keepForID)
  keepForThrows = c(keepForID)

  catch_names_drop = catch_names[!(catch_names %in% keepForCatch)]
  try_names_drop = try_names[!(try_names %in% keepForTry)]
  throws_names_drop = throws_names[!(throws_names %in% keepForThrows)]

  temp_data = temp_data[,!(names(temp_data) %in% catch_names_drop)]
  temp_data = temp_data[,!(names(temp_data) %in% try_names_drop)]
  temp_data = temp_data[,!(names(temp_data) %in% throws_names_drop)]
  
  print(names(temp_data))

  all_list_omitted_m0 <- c(all_list_omitted_m0, list(temp_data))
}
all_list_model_m0 = dataApplyReduction(all_list_omitted_m0)
form_list_bin_m0 = dataSetupFormulasBinary(all_list_model_m0)
models_2_BASE = modelFitLogistic(all_list_model_m0,form_list_bin_m0,"CAT.BASE")
model_things_2_BASE = vector("list", 0)
model_things_2_BASE = modelStats(models_2_BASE)
model_things_2_BASE = modelValidate(models_2_BASE, model_things_2_BASE)
model_things_2_BASE = modelSignificance(models_2_BASE, model_things_2_BASE)
model_things_2_BASE = modelSimplification(models_2_BASE, model_things_2_BASE)
all_list_omitted_m2 = all_list_omitted
all_list_omitted_m2 = vector("list", 0)

for (i in 1:length(models_2_BASE)) {
  name = models_2_BASE[[i]]$name
  project = models_2_BASE[[i]]$project
  fit = models_2_BASE[[i]]$fit
  class = as.character(class(fit)[1])
  print(paste("Project:", project, "Name:", name))
  
  if(class != "try-error") {
  
    temp_data_index = findProjectData(all_list_omitted,project)
    temp_data = as.data.frame(all_list_omitted[[temp_data_index]]$data)
    
    # Keep catch metrics, remove try and throws, adjust base.
    keepForID = c("Project", "File.Path")
    keepForBase = c("Distinct.count.of.Issue.Key.POST",keepForID)
    keepForTry = c(keepForID)
    keepForThrows = c(keepForID)
    
    base_names_drop = base_names[!(base_names %in% keepForBase)]
    try_names_drop = try_names[!(try_names %in% keepForTry)]
    throws_names_drop = throws_names[!(throws_names %in% keepForThrows)]
  
    temp_data = temp_data[,!(names(temp_data) %in% try_names_drop)]
    temp_data = temp_data[,!(names(temp_data) %in% throws_names_drop)]
    
    # Remove insignificant metrics according to related base model.
    temp_sig_index = findModel(model_things_2_BASE,name,project)
    
    # Only move forward with the models that are under budget.
    if (!model_things_2_BASE[[temp_sig_index]][["over_budget"]]){
      temp_significant = model_things_2_BASE[[temp_sig_index]][["signifcant_r"]]
      if (!is.na(temp_significant)) {
        # The significant metrics from the base model as a vector of char.
        temp_significant_list = unlist(strsplit(temp_significant, ", "))
      } else
        temp_significant_list = unlist(strsplit("", ", "))
      
      # The insignificant metrics: all from the base model minus the significant ones.
      base_names_insignificant = base_names_drop[!(base_names_drop %in% temp_significant_list)]
      # The clean list of metrics for modeling: all metrics minus the base insignificant ones.
      temp_data = temp_data[,!(names(temp_data) %in% base_names_insignificant)]
      print(names(temp_data))
  
      all_list_omitted_m2 <- c(all_list_omitted_m2, list(list(name=name, project=project, data=temp_data, sig=temp_significant_list)))
    } else
      print(paste("!-ERROR-! - model over budget."))
    
  } else
    print(paste("!-ERROR-! - model construction had issues."))
}
dropToPredict = c("File.Path",  "Project", "Language", "Table.Name","Name","Kind", "X..Bugs.Post", "File", "Distinct.count.of.Issue.Key.POST")
all_list_model_m2 = dataApplyReductionByModel(all_list_omitted_m2, "BSAP")
form_list_bin_m2 = dataSetupFormulasBinaryByModel(all_list_model_m2)
models_2_BSAP = modelFitLogisticByModel(all_list_model_m2,form_list_bin_m2,"CAT.BSAP")
model_things_2_BSAP = vector("list", 0)
model_things_2_BSAP = modelStats(models_2_BSAP)
model_things_2_BSAP = modelValidate(models_2_BSAP, model_things_2_BSAP)
model_things_2_BSAP = modelSignificance(models_2_BSAP, model_things_2_BSAP)
model_things_2_BSAP = modelSimplification(models_2_BSAP, model_things_2_BSAP)
all_list_omitted_m3 = all_list_omitted
all_list_omitted_m3 = vector("list", 0)

for (i in 1:length(models_2_BASE)) {
  name = models_2_BASE[[i]]$name
  project = models_2_BASE[[i]]$project
  fit = models_2_BASE[[i]]$fit
  class = as.character(class(fit)[1])
  print(paste("Project:", project, "Name:", name))
  
  if(class != "try-error") {
  
    temp_data_index = findProjectData(all_list_omitted,project)
    temp_data = as.data.frame(all_list_omitted[[temp_data_index]]$data)
    
    # Keep catch metrics, remove try and throws, adjust base.
    keepForID = c("Project", "File.Path")
    keepForBase = c("Distinct.count.of.Issue.Key.POST",keepForID)
    keepForCatch = c(keepForID)
    keepForThrows = c(keepForID)
    
    base_names_drop = base_names[!(base_names %in% keepForBase)]
    catch_names_drop = catch_names[!(catch_names %in% keepForCatch)]
    throws_names_drop = throws_names[!(throws_names %in% keepForThrows)]
  
    temp_data = temp_data[,!(names(temp_data) %in% catch_names_drop)]
    temp_data = temp_data[,!(names(temp_data) %in% throws_names_drop)]
    
    # Remove insignificant metrics according to related base model.
    temp_sig_index = findModel(model_things_2_BASE,name,project)
    
    # Only move forward with the models that are under budget.
    if (!model_things_2_BASE[[temp_sig_index]][["over_budget"]]){
      temp_significant = model_things_2_BASE[[temp_sig_index]][["signifcant_r"]]
      if (!is.na(temp_significant)) {
        # The significant metrics from the base model as a vector of char.
        temp_significant_list = unlist(strsplit(temp_significant, ", "))
      } else
        temp_significant_list = unlist(strsplit("", ", "))
      
      # The insignificant metrics: all from the base model minus the significant ones.
      base_names_insignificant = base_names_drop[!(base_names_drop %in% temp_significant_list)]
      # The clean list of metrics for modeling: all metrics minus the base insignificant ones.
      temp_data = temp_data[,!(names(temp_data) %in% base_names_insignificant)]
      print(names(temp_data))
  
      all_list_omitted_m3 <- c(all_list_omitted_m3, list(list(name=name, project=project, data=temp_data, sig=temp_significant_list)))
    } else
      print(paste("!-ERROR-! - model over budget."))
    
  } else
    print(paste("!-ERROR-! - model construction had issues."))
}
dropToPredict = c("File.Path",  "Project", "Language", "Table.Name","Name","Kind", "X..Bugs.Post", "File", "Distinct.count.of.Issue.Key.POST")
all_list_model_m3 = dataApplyReductionByModel(all_list_omitted_m3, "BSFC")
form_list_bin_m3 = dataSetupFormulasBinaryByModel(all_list_model_m3)
models_2_BSFC = modelFitLogisticByModel(all_list_model_m3,form_list_bin_m3,"CAT.BSFC")

model_things_2_BSFC = vector("list", 0)
model_things_2_BSFC = modelStats(models_2_BSFC)
model_things_2_BSFC = modelValidate(models_2_BSFC, model_things_2_BSFC)
model_things_2_BSFC = modelSignificance(models_2_BSFC, model_things_2_BSFC)
model_things_2_BSFC = modelSimplification(models_2_BSFC, model_things_2_BSFC)
write.table(data.frame(model_things_2_BASE[[1]])[0,], 'output/base_test_2.csv'  , append= F, sep=',', row.names = F, col.names = T )

lapply(model_things_2_BASE, function(x) write.table( data.frame(x), 'output/base_test_2.csv'  , append= T, sep=',', row.names = F, col.names = F ))
lapply(model_things_2_BSAP, function(x) write.table( data.frame(x), 'output/base_test_2.csv'  , append= T, sep=',', row.names = F, col.names = F ))
lapply(model_things_2_BSFC, function(x) write.table( data.frame(x), 'output/base_test_2.csv'  , append= T, sep=',', row.names = F, col.names = F ))

