## ----echo=FALSE, message=FALSE, warning=FALSE---------------------------------
library(ggmcmc)

## -----------------------------------------------------------------------------
library(ggmcmc)
data(radon)
s.radon.short <- radon$s.radon.short

## -----------------------------------------------------------------------------
S <- ggs(s.radon.short)

## -----------------------------------------------------------------------------
S

## -----------------------------------------------------------------------------
str(S)

## ---- eval=FALSE--------------------------------------------------------------
#  ggmcmc(S)

## ---- eval=FALSE--------------------------------------------------------------
#  ggmcmc(S, file="model_simple-diag.pdf", param_page=2)

## ---- eval=FALSE--------------------------------------------------------------
#  ggmcmc(S, plot=c("density", "running", "caterpillar"))

## ---- eval=FALSE--------------------------------------------------------------
#  ggmcmc(S, file = "model_simple.html", dev_type_html = "svg")

## ----histogram, fig.cap='Histogram (ggs\\_histogram())', fig.width=6, fig.height=6, fig.margin=TRUE, warning=FALSE----
ggs_histogram(S)

## ----density, fig.cap='Density plots (ggs\\_density())', fig.width=6, fig.height=6, fig.margin=TRUE----
ggs_density(S)

## ----traceplot, fig.cap='Traceplots (ggs\\_traceplot())', fig.width=8, fig.height=4, fig.margin=FALSE----
ggs_traceplot(S)

## ----running, fig.cap='Running means (ggs\\_running())', fig.width=4.9, fig.height=8, fig.margin=TRUE----
ggs_running(S)

## ----compare_partial, fig.cap='Comparison of the whole chain with the latest part (ggs\\_compare\\_partial())', fig.width=4.9, fig.height=6, fig.margin=TRUE----
ggs_compare_partial(S)

## ----autocorrelation, fig.cap='Autocorrelation (ggs\\_autocorrelation())', fig.width=4.9, fig.height=8, fig.margin=TRUE----
ggs_autocorrelation(S)

## ----crosscorrelation, fig.cap='Crosscorrelation (ggs\\_crosscorrelation())', fig.height=3, fig.width=4, fig.margin=TRUE, sanitize=FALSE, warning=FALSE----
ggs_crosscorrelation(S)

## ----Rhat, fig.cap='Potential Scale Reduction Factor (ggs\\_Rhat())', fig.height=4, fig.width=6, fig.margin=TRUE, sanitize=TRUE----
ggs_Rhat(S) + xlab("R_hat")

## ----geweke, fig.cap='Geweke diagnostic (ggs\\_geweke())', fig.height=4, fig.width=6, fig.margin=TRUE----
ggs_geweke(S)

## ----par_labels, fig.width=6, fig.height=6, fig.margin=TRUE, fig.cap='Labels of the parameter names are changed by argument par\\_labels.', warning=FALSE----
P <- data.frame(
  Parameter=c("sigma.alpha", "sigma.beta", "sigma.y"),
  Label=c("Intercept (sd)", "Covariate (sd)", "Outcome (sd)"))
ggs_density(ggs(radon$s.radon, par_labels=P, family="sigma"))

## ----caterpillar_preparation, warning=FALSE-----------------------------------
L.radon.intercepts <- plab("alpha", list(County = radon$counties$County))
head(L.radon.intercepts)
S.full <- ggs(radon$s.radon, par_labels=L.radon.intercepts, family="^alpha")

## ----caterpillar, fig.height=9, fig.width=6, fig.margin=TRUE, fig.cap='Caterpillar plot (ggs\\_caterpillar()).'----
ggs_caterpillar(S.full)

## ---- fig.width=6, fig.height=4, fig.margin=TRUE, fig.cap='Caterpillar plot against a continuous variable.'----
Z <- data.frame(
  Parameter=paste("alpha[", radon$counties$id.county, "]", sep=""),
  value=radon$counties$uranium)
ggs_caterpillar(ggs(radon$s.radon, family="^alpha"), X=Z, horizontal=FALSE)

## ----ci-----------------------------------------------------------------------
ci(S)

## ----sample_mu----------------------------------------------------------------
data(linear) # brings 's.y.rep', 'y' and 's'
S.y.rep <- ggs(s.y.rep)
y.observed <- y

## ----ppmean, fig.width=4, fig.height=4, fig.margin=TRUE, fig.cap='Posterior predictive means against the sample mean (ggs\\_ppmean()).'----
ggs_ppmean(S.y.rep, outcome=y.observed)

## ----ppsd, fig.width=4, fig.height=4, fig.margin=TRUE, fig.cap='Posterior predictive standard deviations against the sample standard deviation (ggs\\_ppsd()).'----
ggs_ppsd(S.y.rep, outcome=y.observed)

## -----------------------------------------------------------------------------
data(binary)
S.binary <- ggs(s.binary, family="mu")

## ---- roc, fig.width=6, fig.height=5, fig.cap='ROC (receiver operating characteristic) curve.'----
ggs_rocplot(S.binary, outcome=y.binary)

## ---- separation, fig.width=6, fig.height=2, fig.cap='Separation plot.', fig.margin=TRUE----
ggs_separation(S.binary, outcome=y.binary)

## ---- separation_arguments, fig.width=10, fig.height=3, fig.cap='Separation plot with parameter labels and without uncertainty band on the predicted values.', fig.margin=FALSE----
ggs_separation(S.binary, outcome=y.binary,
  show_labels = TRUE, uncertainty_band = FALSE)

## ---- separation_minimalist, fig.width=4, fig.height=1, fig.cap='Separation plot (minimalist version).', fig.margin=TRUE----
ggs_separation(S.binary, outcome=y.binary, minimalist = TRUE)

## ---- pcp, fig.width=6, fig.height=5, fig.cap='Distribution of the percentage of cases correctly predicted.'----
ggs_pcp(S.binary, outcome=y.binary)

## ----pairs, fig.width=10, fig.height=10, fig.cap='Paired plot showing scatterplots, densities and crosscorrelations.', message= FALSE----
ggs_pairs(S, lower = list(continuous = "density"))

## ----histogram_greek, fig.cap='Histogram (ggs\\_histogram()) with parameter names using Greek letters.', fig.width=6, fig.height=6, fig.margin=TRUE, warning=FALSE----
ggs_histogram(S, greek = TRUE)

## ----extension_facets_aes, fig.width=12, fig.height=8, fig.cap='Caterpillar plot of the varying intercepts faceted by North/South location and using county\'s uranium level as color indicator.', warning=FALSE----
ci.median <- ci(ggs(radon$s.radon, family = "^alpha|^beta")) %>%
  select(Parameter, median)

L.radon <- bind_rows(
   plab("alpha", list(County = radon$counties$County)) %>%
     mutate(Coefficient = "Intercept"),
   plab("beta", list(County = radon$counties$County)) %>%
     mutate(Coefficient = "Slope")) %>%
  left_join(radon$counties) %>%
  rename(Uranium = uranium) %>%
  rename(Location = ns.location)

head(L.radon)

ggs_caterpillar(ggs(radon$s.radon, par_labels = L.radon, family = "^alpha")) +
  facet_wrap(~ Location, scales = "free") +
  aes(color = Uranium)

## ----facets, fig.width = 10, fig.height = 14, fig.cap = 'Density plots of the varying intercepts faceted in a grid by columns.'----
ggs_density(ggs(radon$s.radon, par_labels=L.radon, family="^alpha"),
            hpd = TRUE) +
  facet_wrap(~ Parameter, ncol = 6)

