# Fire regime stats
library(dplyr)
library(tidyr)
library(tibble)
a <- Sys.time()

#df <- readRDS("/exports/geos.ed.ac.uk/landteam/N/chris_fire/2_dataframes/fire_regime_df.Rds")
df <- readRDS("/exports/geos.ed.ac.uk/landteam/N/chris_fire/2_dataframes/1e7_reg.Rds")

# df2 <- df %>%
#   as_tibble() %>%
#   filter(agc >0 & !is.na(agc) & !is.na(lc) & ff_mean >= 0 & lc_2000 %in% c(1, 2, 3, 4, 5, 6, 7, 8, 9) & buildings < 7200)# add buildings < 7200?
  #sample_frac(0.5) # sample frac for developing script

rm(df);gc()


# Format data
df2 <- df %>%
  mutate(
    lc = as.factor(lc_2000),
    roads = roads/1000,
    markets = markets/1000,
    urban = urban/1000,
    buildings = buildings/9,
    #burn = ff_mean > 0,
    deg_fac = deg_all > 0)

## Degradation rate 2001-2020
deg_0 <- df2 %>%
  filter(deg_all == 0 | deg_all > 2000) # filter deg to 2001-2020 and keep undegraded

mean(deg_0$deg_fac) # Degradation rate 2001-2020

## Proportion of each lc that has degraded
deg_1 <- deg_0 %>%
  #filter(st_lc == 1) %>%
  group_by(lc) %>%
  summarise(
    length = length(deg_fac),
    count_deg = sum(deg_fac),
    prop_deg = sum(deg_fac == TRUE)/ length(deg_fac)*100,
    prop_burn_sem = sqrt(prop_deg*(1-prop_deg)/length(deg_fac)),
    area_km2 = sum(deg_fac)*(28*30)/1000000
  )

## Proportion of each lc that burns
prev <- df2 %>%
  #filter(st_lc == 1) %>%
  group_by(lc) %>%
  summarise(
    prop_burn = sum(burn == TRUE)/ length(burn)*100,
    #prop_burn_sem = sqrt(prop_burn*(1-prop_burn)/length(burn)) # SEM of a proportion
    area_km2 = sum(burn)*(28*30)/1000000
  )

## FF and DOY stats
ff <- df2 %>%
  #filter(st_lc == 1) %>%
  group_by(lc) %>%
  summarise(
    mean_ff = mean(ff_mean),
    sd_ff = sd(ff_mean),
  )

doy <- df2 %>% # Seasonality and mean intensity (DOY)
  filter(burn == TRUE) %>%
  group_by(lc) %>%
  summarise(
    mean_doy = mean(doy_mean),
    sd_doy = sd(doy_mean),
    min_doy = min(doy_mean),
    max_doy = max(doy_mean)
  )

fire_stats <- merge(prev, ff)
fire_stats <- merge(fire_stats, doy, by= "lc")

print(fire_stats)
saveRDS(fire_stats, "/exports/geos.ed.ac.uk/landteam/N/chris_fire/2_dataframes/fire_stats_whole_area.Rds")
Sys.time()-a

#readRDS("/exports/geos.ed.ac.uk/landteam/N/chris_fire/2_dataframes/fire_stats_whole_area.Rds")

# library(ggplot2)
# ggplot(data = df2 %>% filter(st_lc == 1 & lc %in% c(1,2,3,4,5,6,7,8,9)), aes(x = doy_mean, group = lc, fill = lc)) +
#   geom_density(adjust = 1.5, alpha = .4) + 
#   theme(legend.position = "bottom") +
#   theme_classic() +
#   facet_wrap(~lc)
# 
# ggplot(data = df2 %>% filter(st_lc == 1 & lc %in% c(1,2,3,4,5,6,7,8,9)), aes(x = lc, y =doy_mean, fill = lc )) +
#   geom_violin()

