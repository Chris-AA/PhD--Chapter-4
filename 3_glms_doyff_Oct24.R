library(dplyr)
library(ggplot2)
library(viridis)

D <- readRDS("/exports/geos.ed.ac.uk/landteam/N/chris_fire/2_dataframes/1e7_clean_m2.Rds")

df.10 <- D %>% 
  select(!(c(FA5, FP5, FF_A5_mean_z, FA5_DOY, FA5_DOY_z))) %>%
  filter(!is.na(FA10) & !is.na(FP10))

df_2009 <- df.10 %>% filter(year == "2009")
df_2010 <- df.10 %>% filter(year == "2010")
df_2011 <- df.10 %>% filter(year == "2011")

lm.09 <- glm(deg_fac ~ FF_A10_mean_z + FA10_DOY_z + agc_z + flam_prop_lc_z + markets_z + buildings_l10_z,
             df_2009,
             family=binomial(link="logit"))
lm.10 <- glm(deg_fac ~ FF_A10_mean_z + FA10_DOY_z + agc_z + flam_prop_lc_z + markets_z + buildings_l10_z,
             df_2010,
             family=binomial(link="logit"))
lm.11 <- glm(deg_fac ~ FF_A10_mean_z + FA10_DOY_z + agc_z + flam_prop_lc_z + markets_z + buildings_l10_z,
              df_2011,
              family=binomial(link="logit"))

performance::performance(lm.09)
performance::performance(lm.10)
performance::performance(lm.11)

# Predict EDS vs LDS probabilities of deg
doy_pred <- ggeffects::ggpredict(lm, terms = c("FA10_DOY_z[-1.6,0.531]"))

# Predict once in ten years and annual FF probabilities of deg
ff_pred <- ggeffects::ggpredict(lm, terms = c("FF_A10_mean_z[-0.55,1.719499]"))

# Get predictions to plot
ff_09 <- sjPlot::plot_model(lm.09, type = "pred", terms = "FF_A10_mean_z")
ff_10 <- sjPlot::plot_model(lm.10, type = "pred", terms = "FF_A10_mean_z")
ff_11 <- sjPlot::plot_model(lm.11, type = "pred", terms = "FF_A10_mean_z")
doy_09 <- sjPlot::plot_model(lm.09, type = "pred", terms = "FA10_DOY_z")
doy_10 <- sjPlot::plot_model(lm.10, type = "pred", terms = "FA10_DOY_z")
doy_11 <- sjPlot::plot_model(lm.11, type = "pred", terms = "FA10_DOY_z")

# Make dataframes
ff_df <- data.frame(
  year = rep(c(2009, 2010, 2011), each = length(ff_09$data$predicted)),
  x = c(ff_09$data$x, ff_10$data$x, ff_11$data$x),
  p = c(ff_09$data$predicted, ff_10$data$predicted, ff_11$data$predicted),
  ci_hi = c(ff_09$data$conf.high, ff_10$data$conf.high, ff_11$data$conf.high),
  ci_lo = c(ff_09$data$conf.low, ff_10$data$conf.low, ff_11$data$conf.low))  %>%
  mutate(year = as.factor(year))

doy_df <- data.frame(
  year = rep(c(2009, 2010, 2011), each = length(doy_09$data$predicted)),
  x = c(doy_09$data$x, doy_10$data$x, doy_11$data$x),
  p = c(doy_09$data$predicted, doy_10$data$predicted, doy_11$data$predicted),
  ci_hi = c(doy_09$data$conf.high, doy_10$data$conf.high, doy_11$data$conf.high),
  ci_lo = c(doy_09$data$conf.low, doy_10$data$conf.low, doy_11$data$conf.low)) %>%
  mutate(year = as.factor(year))

# Plot
ggplot(data=ff_df, aes(x=x, y=p, ymin=ci_lo, ymax=ci_hi, fill=year)) + 
  geom_line() + 
  geom_ribbon(alpha=0.5) +
  geom_vline(xintercept= 1.719499, color="orange", size=.5) +
  geom_vline(xintercept= -0.55, color="grey", size=.5) +
  xlab("Fire Frequency") + 
  ylab("Probability of Canopy Opening")

doy <- ggplot(data=doy_df, aes(x=x, y=p, ymin=ci_lo, ymax=ci_hi, fill=year)) + 
  geom_line() + 
  geom_ribbon(alpha=0.5) + 
  geom_vline(xintercept= 0.531, color="orange", size=.8, linetype="dotted") +
  geom_vline(xintercept= -1.66, color="grey", size=.8, linetype="dotted") +
  scale_x_continuous(labels = c("100", "131", "183", "235", "287", "300")) +  # New labels for those positions
  scale_fill_viridis(discrete = TRUE, option = "A", alpha = 0.75, name="") +
  xlab("Day of Year of Fire") + 
  ylab("Probability of Canopy Opening") +
  theme_classic() +
  theme(legend.position="bottom",
        legend.title=element_text(size = 14),
        legend.text=element_text(size= 12),
        axis.text.x  = element_text(size = 12),
        axis.text.y  = element_text(size = 12),
        axis.title.x  = element_text(size = 14),
        axis.title.y  = element_text(size = 14))

ggsave("/exports/geos.ed.ac.uk/landteam/N/chris_fire/doy_fig.png", doy, width = 20, height = 20, units = "cm", dpi = 300)

