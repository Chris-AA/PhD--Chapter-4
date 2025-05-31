library(dplyr)

loc <- "/exports/geos.ed.ac.uk/landteam/N/chris_fire"

D <- readRDS(file.path(loc, "2_dataframes", "1e7_clean.Rds"))
#D <- readRDS(file.path(loc, "2_dataframes", "101e7_clean.Rds")) # Second random sample of data


df <- D %>%
  select(px_id, year, deg_fac, FA10, FP10, agc_z, buildings_l10_z,
         markets_z, flam_prop_lc_z, FF_A10_mean_z, FA10_DOY, FA10_DOY_z, lc_2000) %>% # Drop unused cols for model 1
  mutate(across(c(px_id, year),as.factor),
         deg_fac = as.factor(deg_fac)) %>% # changed to logical otherwise changing deg_fac to TRUE/FALSE doesn't work in pred_comp script
  filter(lc_2000 %in% c(1,2,3))


df$FA10 <- factor(df$FA10, levels = c("0", "1")) # Reorder factor levels
df$FP10 <- factor(df$FP10, levels = c("0", "1"))

# Filter NA rows for FA5 and FP5
df.10 <- df %>% 
  filter(!is.na(FA10) & !is.na(FP10)) # identify pixels in the middle so we know fire history before and after LUC

#df.10.small <- sample_n(df.10, 1e6)

#df_2009 <- df.10 %>% filter(year == "2009")
#df_2010 <- df.10 %>% filter(year == "2010")
#df_2011 <- df.10 %>% filter(year == "2011")# Filter to one year to remove the need for random effects

# Run Fire anti-model
a <- Sys.time()
yrs <- list(2009,2010,2011)
M_fcause <- lapply(yrs, function(y){
  glm(deg_fac ~ FA10 + agc_z + flam_prop_lc_z + markets_z + buildings_l10_z,
      df.10 %>% filter(year == y),
      family=binomial(link="logit"))
  
})
Sys.time()-a
lapply(M_fcause, summary)
summary(M_fcause[[1]], ci_method="wald")

DHARMa::plotResiduals(M_fcause[[1]]) # residual vs plotted
performance::check_residuals(M_fcause[[1]]) # check if residuals normally distributed
lapply(M_fcause, performance::performance)
performance::performance(M_fcause[[1]]) # goodness of fit
### Get plot_model working####
#saveRDS(lm.A10, "/exports/geos.ed.ac.uk/landteam/N/chris_fire/3_analysis/glms_Oct24/lm_A10.Rds")

# Run Fire post-model
a <- Sys.time()
yrs <- list(2009,2010,2011)
M_fcon <- lapply(yrs, function(y){
  glm(FP10 ~ deg_fac + FA10 + agc_z + flam_prop_lc_z + markets_z + buildings_l10_z,
      df.10 %>% filter(year == y),
      family=binomial(link="logit"))
  
})
Sys.time()-a
lapply(M_fcon, performance::performance)

summary(lm.P10)
performance::performance(lm.P10) # goodness of fit
saveRDS(lm.P10, "/exports/geos.ed.ac.uk/landteam/N/chris_fire/3_analysis/glms_Oct24/lm_P10.Rds")
