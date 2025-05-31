library(dplyr)

loc <- "/exports/geos.ed.ac.uk/landteam/N/chris_fire"

D <- readRDS(file.path(loc, "2_dataframes", "1e7_clean.Rds"))
df <- D %>%
  select(px_id, year, deg_fac, FA10, FP10, agc_z, buildings_l10_z,
         markets_z, flam_prop_lc_z, FF_A10_mean_z, FA10_DOY, FA10_DOY_z) %>% # Drop unused cols for model 1
  mutate(across(c(px_id, year),as.factor))


df$FA10 <- factor(df$FA10, levels = c("0", "1")) # Reorder factor levels
df$FP10 <- factor(df$FP10, levels = c("0", "1"))

# Filter NA rows for FA5 and FP5
df.10 <- df %>% 
  filter(!is.na(FA10) & !is.na(FP10))

# Models for deg ~ fire anti + adjustment set + pixel_id + year
m1.10 <- readRDS("/exports/geos.ed.ac.uk/landteam/N/chris_fire/3_analysis/glms_Oct24/lm_A10.Rds") # Fire within 10 year period before burning

# Models for fire_post ~ deg + adjustment set + pixel_id + year
m3.10 <- readRDS("/exports/geos.ed.ac.uk/landteam/N/chris_fire/3_analysis/glms_Oct24/lm_P10.Rds") # Fire within 10 year period after burning

#-----
## Model summaries
#-----
# summary(m1.10)
# summary(m3.10)

#-----
## Fire off predictions
#-----
df2 <- df.10
df2$deg_num <- as.numeric(df2$deg_fac) -1
#levels(df2$FA5) <- c("fire", "no.fire")

yhat <- predict(m1.10, df.10, se.fit=TRUE, type = "link") # Predict yhat for data
yhatp <- exp(yhat$fit)/(1+exp(yhat$fit))

critval <- 1.96 ## approx 95% CI
upr <- yhat$fit + (critval * yhat$se.fit) # Calculate CI's
lwr <- yhat$fit - (critval * yhat$se.fit)
yhat_se_up <- exp(upr)/(1+exp(upr))
yhat_se_lw <- exp(lwr)/(1+exp(lwr))
#xtabs(~yhat+ df2$deg_num)

df0 <- df.10
df0$FA10 <- "0" # Fire off
yhat0 <- predict(m1.10, df0, se.fit=TRUE, type = "link") # Predict yhat for fire off
yhat0p <- exp(yhat0$fit)/(1+exp(yhat0$fit))

upr0 <- yhat0$fit + (critval * yhat0$se.fit) # Calculate CI's
lwr0 <- yhat0$fit - (critval * yhat0$se.fit)
yhat0_se_up <- exp(upr0)/(1+exp(upr0))
yhat0_se_lw <- exp(lwr0)/(1+exp(lwr0))

df1 <- df.10
df1$FA10 <- "1"  # fire on
yhat1 <- predict(m1.10, df1, se.fit=TRUE, type = "link") # Predict yhat for fire on
yhat1p <- exp(yhat1$fit)/(1+exp(yhat1$fit))

upr1 <- yhat1$fit + (critval * yhat1$se.fit) # Calculate CI's
lwr1 <- yhat1$fit - (critval * yhat1$se.fit)
yhat1_se_up <- exp(upr1)/(1+exp(upr1))
yhat1_se_lw <- exp(lwr1)/(1+exp(lwr1))

#mean(df2$deg_num, na.rm = TRUE)
mean(yhatp)
myhat0 <- mean(yhat0p, na.rm = TRUE)
myhat0_sd <- sd(yhat0p, na.rm = TRUE)
myhat1 <- mean(yhat1p, na.rm = TRUE)
myhat1_sd <- sd(yhat1p, na.rm = TRUE)

myhat0/myhat1 # fractional
(myhat1-myhat0)/myhat0 # deg as a proportion of yaht0
sqrt(((-(myhat1/myhat0^2))*myhat0_sd)^2+((1/myhat0)*myhat1_sd)^2)

#-----
## Deg off predictions
#-----
df3 <- df.10
df3$FP10_num <- as.numeric(df3$FP10) -1

yhat_m3 <- predict(m3.10, df3, se.fit=TRUE, type = "link") # Predict yhat for data
yhatp_m3 <- exp(yhat_m3$fit)/(1+exp(yhat_m3$fit)) 

upr_m3 <- yhat_m3$fit + (critval * yhat_m3$se.fit) # Calculate upper and lower CI's
lwr_m3 <- yhat_m3$fit - (critval * yhat_m3$se.fit)
yhat_m3_se_up <- exp(upr_m3)/(1+exp(upr_m3))
yhat_m3_se_lw <- exp(lwr_m3)/(1+exp(lwr_m3))

df0_m3 <- df.10 
df0_m3$deg_fac <- FALSE # deg off
yhat0_m3 <- predict(m3.10, df0_m3, se.fit=TRUE, type = "link") # Predict yhat for no deg
yhat0p_m3 <- exp(yhat0_m3$fit)/(1+exp(yhat0_m3$fit))

upr0_m3 <- yhat0_m3$fit + (critval * yhat0_m3$se.fit) # Calculate CI's
lwr0_m3 <- yhat0_m3$fit - (critval * yhat0_m3$se.fit)
yhat0_m3_se_up <- exp(upr0_m3)/(1+exp(upr0_m3))
yhat0_m3_se_lw <- exp(lwr0_m3)/(1+exp(lwr0_m3))

df1_m3 <- df.10
df1_m3$deg_fac <- TRUE # deg on
yhat1_m3 <- predict(m3.10, df1_m3, se.fit=TRUE, type = "link") # Predict yhat for deg on
yhat1p_m3 <- exp(yhat1_m3$fit)/(1+exp(yhat1_m3$fit))

upr1_m3 <- yhat1_m3$fit + (critval * yhat1_m3$se.fit) # Calculate CI's
lwr1_m3 <- yhat1_m3$fit - (critval * yhat1_m3$se.fit)
yhat1_m3_se_up <- exp(upr1_m3)/(1+exp(upr1_m3))
yhat1_m3_se_lw <- exp(lwr1_m3)/(1+exp(lwr1_m3))

#mean(df3$FP5_num)
mean(yhatp_m3)
myhat0_m3 <- mean(yhat0p_m3, na.rm = TRUE)
myhat0_m3_sd <- sd(yhat0p_m3, na.rm = TRUE)
myhat1_m3 <- mean(yhat1p_m3, na.rm = TRUE)
myhat1_m3_sd <- sd(yhat1p_m3, na.rm = TRUE)

myhat1_m3/myhat0_m3 # fractional
(myhat1_m3-myhat0_m3)/myhat0_m3 # deg as a proportion of yaht0
sqrt(((-(myhat1_m3/myhat0_m3^2))*myhat0_m3_sd)^2+((1/myhat0_m3)*myhat1_m3_sd)^2)
