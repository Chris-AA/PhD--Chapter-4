library(tidyr)
library(dplyr)
library(tibble)
library(dtplyr)
library(roll)
z2 <- function(x) (x-mean(x, na.rm = TRUE))/(2 * sd(x, na.rm = TRUE))


df <- readRDS("/exports/geos.ed.ac.uk/landteam/N/chris_fire/2_dataframes/101e7_reg.Rds")
#df <- readRDS("/exports/geos.ed.ac.uk/landteam/N/chris_fire/process_100/1e6_dataframes/read_in/D1.Rds")

df$buildings2 <- df$buildings
df$buildings2[df$buildings2==0] <- min(df$buildings2[df$buildings2!=0])

df <- df %>%
  mutate(
    px_id = 1:nrow(df), # add a pixel id column
    lc_2000 = as.factor(lc_2000),
    roads = roads/1000,
    markets = markets/1000,
    urban = urban/1000,
    buildings2 = buildings2/9,
    buildings_l10 = log10(buildings2/9),
    catchment = as.factor(catchment),
  )

# --------------------
# part 1. make long
# ---------------------
# df1 <- lazy_dt(df)
df_long <- df %>% select(c(57, 1:56, 58)) %>% # 59 = px_id first, all other cols after
  filter(!is.na(deg_all)) %>% # remove rows with NAs
  # sample_frac(prop) %>% # change value###################
pivot_longer(cols = starts_with(c("m_", "flc_")),
             names_to = c(".value", "year"), 
             names_pattern = "^(m_|flc_)(.*)$",
             values_to = c("doy", "value"))

rm(df); gc()

# --------------------
# part 2. mutates
# ---------------------
df_long <- df_long %>% #head(1e5) %>%
  lazy_dt()

df2 <- df_long %>%
  mutate(year = as.integer(year)) %>%
  rename(doy = m_, flam_prop_lc = flc_) %>%
  mutate(burn = doy>0,
         deg = deg_all == year, # could remove
         deg_fac = as.factor(deg),
         doy_clean = ifelse(doy ==0, NA_integer_, doy),
         ) %>%
  filter(!is.na(flam_prop_lc))

df2 <- as_tibble(df2)
rm(df_long); gc()


df2 <- df2 %>% lazy_dt()
df3 <- df2 %>%
  #filter(px_id == 467382) %>%
  arrange(px_id, year) %>% #sorts by pxid and year, creates time-series for rolling mean
  group_by(px_id) %>% 
  mutate(
    # Fire freq:
    #FA2_DOY = roll::roll_mean(doy_clean, width = 5, weights = c(0,0,0,.5,.5), min_obs = 2, online = FALSE),
    #FA5_DOY = roll::roll_mean(doy_clean, width = 11, weights = c(0,0,0,0,0,0,.2,.2,.2,.2,.2), min_obs = 5, online = FALSE),
    #FA10_DOY = roll::roll_mean(doy_clean, width = 21, weights = c(0,0,0,0,0,0,0,0,0,0,0,.1,.1,.1,.1,.1,.1,.1,.1,.1,.1), min_obs = 10, online = FALSE),
    #FF_A2_mean = roll::roll_mean(burn, width = 5, weights = c(0,0,0,.5,.5), min_obs = 2, online = FALSE), # DANGER will need to remove start of series
    FF_A5_mean = roll::roll_mean(burn, width = 11, weights = c(0,0,0,0,0,0,.2,.2,.2,.2,.2), min_obs = 5, online = FALSE),
    FF_A10_mean = roll::roll_mean(burn, width = 21, weights = c(0,0,0,0,0,0,0,0,0,0,0,.1,.1,.1,.1,.1,.1,.1,.1,.1,.1), min_obs = 10, online = FALSE),
    #FP2_DOY = roll::roll_mean(doy_clean, width = 5, weights = c(0,0,0,.5,.5), min_obs = 2, online = FALSE),
    #FP5_DOY = roll::roll_mean(doy_clean, width = 11, weights = c(0,0,0,0,0,0,.2,.2,.2,.2,.2), min_obs = 5, online = FALSE),
    #FP10_DOY = roll::roll_mean(doy_clean, width = 21, weights = c(0,0,0,0,0,0,0,0,0,0,0,.1,.1,.1,.1,.1,.1,.1,.1,.1,.1), min_obs = 10, online = FALSE),
    #FF_P2_mean = roll::roll_mean(burn, width = 5, weights = c(.5,.5,0,0,0), min_obs = 2, online = FALSE), # DANGER will need to remove start of series
    FF_P5_mean = roll::roll_mean(burn, width = 11, weights = c(.2,.2,.2,.2,.2,0,0,0,0,0,0), min_obs = 5, online = FALSE),
    FF_P10_mean = roll::roll_mean(burn, width = 21, weights = c(.1,.1,.1,.1,.1,.1,.1,.1,.1,.1,0,0,0,0,0,0,0,0,0,0,0), min_obs = 10, online = FALSE),
    # FF_A2_mean = zoo::rollapply(burn, width = 2, mean, align = "right", fill = NA), # FIRE ANTI
    # FF_A2_mean = zoo::rollmean(burn, k = 2, mean, align = "right", fill = NA), # FIRE ANTI
    # FF_A5_mean = zoo::rollmean(burn, k = 5, mean, align = "right", fill = NA),
    # FF_A10_mean = zoo::rollmean(burn, k = 5, mean, align = "right", fill = NA),# FIRE ANTI
    #FF_A5_mean = zoo::rollapply(burn, width = 5, mean, align = "right", fill = NA), # fire frequency for 5 years
    #FF_A10_mean = zoo::rollapply(burn, width = 10, mean, align = "right", fill = NA),
    FA5_DOY = zoo::rollapply(doy_clean, width = 5, mean, align = "right", fill = NA, na.rm = TRUE), # mean DOY over 5 years
    FA10_DOY = zoo::rollapply(doy_clean, width = 10, mean, align = "right", fill = NA, na.rm = TRUE),
    FA5 = zoo::rollapply(burn, width = 5, max, align = "right", fill = NA), # fire in last 5 years
    FA10 = zoo::rollapply(burn, width = 10, max, align = "right", fill = NA), # fire in last 10 years
    # FF_P5_mean = zoo::rollapply(burn, width = 5, mean, align = "left", fill = NA),
    # FF_P10_mean = zoo::rollapply(burn, width = 10, mean, align = "left", fill = NA),
    FP5_DOY = zoo::rollapply(doy_clean, width = 5, mean, align = "left", fill = NA, na.rm = TRUE),
    FP10_DOY = zoo::rollapply(doy_clean, width = 10, mean, align = "left", fill = NA, na.rm = TRUE),
    FP5 = zoo::rollapply(burn, width = 5, max, align = "left", fill = NA),
    FP10 = zoo::rollapply(burn, width = 10, max, align = "left", fill = NA),
    FA5 = as.factor(FA5),
    FA10 = as.factor(FA10),
    FP5 = as.factor(FP5),
    FP10 = as.factor(FP10)
  )
a <- Sys.time(); df3 <- as_tibble(df3); Sys.time()-a

rm(df2); gc()

# Z scale
df3$agc_z <- z2(df3$agc) # z standardised to 2 standard deviations due to binary dependent in model
df3$buildings2_z <- z2(df3$buildings2)
df3$buildings_l10_z <- z2(df3$buildings_l10)
df3$markets_z <- z2(df3$markets)
df3$urban_z <- z2(df3$urban)
df3$roads_z <- z2(df3$roads)
df3$flam_prop_lc_z <- z2(df3$flam_prop_lc)
df3$FF_A5_mean_z <- z2(df3$FF_A5_mean)
df3$FA5_DOY_z <- z2(df3$FA5_DOY)
df3$FF_A10_mean_z <- z2(df3$FF_A10_mean)
df3$FA10_DOY_z <- z2(df3$FA10_DOY)
df3$FF_P5_mean_z <- z2(df3$FF_P5_mean)
df3$FP5_DOY_z <- z2(df3$FP5_DOY)
df3$FF_P10_mean_z <- z2(df3$FF_P10_mean)
df3$FP10_DOY_z <- z2(df3$FP10_DOY)
# return(df3)


saveRDS(df3, "2_dataframes/101e7_clean.Rds")

