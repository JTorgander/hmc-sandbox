
<!-- README.md is generated from README.Rmd. Please edit that file -->

# hmcSandbox

<!-- badges: start -->
<!-- badges: end -->

The hmcSandbox provides a customizable R-implementation of the
[NUTS-sampler](https://arxiv.org/abs/1111.4246) which allows the user to
extract sampler diagnostics from each algorithm step.

## Installation

The hmcSandbox is built using the Bridgestan and Cmdstan frameworks,
which both needs to be installed before the package can be used.

Installation links:

- Bridgestan: <https://github.com/roualdes/bridgestan>

- Cmdstan: <https://mc-stan.org/users/interfaces/cmdstan>

The development version of hmcSandbox can then be installed from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("JTorgander/hmc-sandbox")
```

## Demonstration

### Loading models

In order to use a given stan-model within the hmc-sandbox, the
corresponding stan file `model_name.stan` needs to be placed in a named
folder `model_name`. This folder should also contain the input data in a
JSON-file named `model_name.data.json`. This folder should in turn be
placed in the folder `test_models` in the Bridgestan directory.

To illustrate this we will use the Bridgestan test model `regression`,
defined as follows:

``` r
"data {
  int<lower=0> N;
  vector[N] x;
  vector[N] y;
}
parameters {
  real alpha;
  real beta;
  real<lower=0> sigma;
}
transformed parameters {
  vector[N] mu = alpha + beta * x;
}
model {
  alpha ~ normal(0, 5);
  beta ~ normal(0, 3);
  sigma ~ cauchy(0, 1.5);
  y ~ normal(mu, sigma);
}
generated quantities {
  real x_gen = normal_rng(0, 2);
  real y_gen = normal_rng(alpha + beta * x_gen, sigma);
}"
```

For this model, the Bridgestan test_models folder contains a folder
`regression`, which in turn contains one model file `regression.stan`
and one data file `regression.data.json`.

Before the stan model can be used within Bridgestan, the .stan file
needs to be compiled in to compiled shared object `.so` file. For mac
users the model can be compiled with the following function.

``` r
library(hmcSandbox)
BS_PATH <- "~/Documents/bridgestan"
model_name <- "regression"
compile_bs(model_name=model_name, bridgestan_path=BS_PATH)
```

Here the argument “bridgestan_path” should be set to the Bridgestan
install directory. Other users are referred to the Bridgestan
[documentation](https://github.com/roualdes/bridgestan). Note that the
model needs to be recompiled whenever the `.stan` file is modified. The
compiled model can now be loaded using the following function.

``` r
bs_model <- get_model(model_name, model_seed = 1234, data=TRUE, sampler_type = "bridgestan", bridgestan_path=BS_PATH)
#> Loading Bridgestan model
#> Models loaded!
```

Setting `sampler_type = "bridgestan"` here indicates that the
implementation based on bridgestan should be used and setting
`data=TRUE` here indicates that the data.json file featured in the model
folder should be used when loading the model.

### Sampling

Having loaded the model object, we can now sample from the loaded model
using the following code:

``` r
bs_fit <- NUTS(model = bs_model, n_samples = 4000, warm_up = 2000)
#> Initializing model..
#> 
#> Initialization messages:
#> Warning: E-BFMI not computed because it is undefined for posterior chains of
#> length less than 3.
#> 
#> 
#> Model initialized!
#> Generating samples..
#> 400 out of 4000 samples generated
#> 800 out of 4000 samples generated
#> 1200 out of 4000 samples generated
#> 1600 out of 4000 samples generated
#> 2000 out of 4000 samples generated
#> 2400 out of 4000 samples generated
#> 2800 out of 4000 samples generated
#> 3200 out of 4000 samples generated
#> 3600 out of 4000 samples generated
#> 4000 out of 4000 samples generated
#> Sampling completed!
```

This will yield 4000 samples using a burn-in/initialization period of
2000 samples. For reference purposes, the model object also contains the
original cmdstan model. This model can in turn be sampled from as before
using the `sample` method:

``` r
stan_fit <- bs_model$model$cmdstan_model$sample(data = bs_model$data, chains = 1, iter_sampling = 4000)
#> Running MCMC with 1 chain...
#> 
#> Chain 1 Iteration:    1 / 5000 [  0%]  (Warmup) 
#> Chain 1 Iteration:  100 / 5000 [  2%]  (Warmup) 
#> Chain 1 Iteration:  200 / 5000 [  4%]  (Warmup) 
#> Chain 1 Iteration:  300 / 5000 [  6%]  (Warmup) 
#> Chain 1 Iteration:  400 / 5000 [  8%]  (Warmup) 
#> Chain 1 Iteration:  500 / 5000 [ 10%]  (Warmup) 
#> Chain 1 Iteration:  600 / 5000 [ 12%]  (Warmup) 
#> Chain 1 Iteration:  700 / 5000 [ 14%]  (Warmup) 
#> Chain 1 Iteration:  800 / 5000 [ 16%]  (Warmup) 
#> Chain 1 Iteration:  900 / 5000 [ 18%]  (Warmup) 
#> Chain 1 Iteration: 1000 / 5000 [ 20%]  (Warmup) 
#> Chain 1 Iteration: 1001 / 5000 [ 20%]  (Sampling) 
#> Chain 1 Iteration: 1100 / 5000 [ 22%]  (Sampling) 
#> Chain 1 Iteration: 1200 / 5000 [ 24%]  (Sampling) 
#> Chain 1 Iteration: 1300 / 5000 [ 26%]  (Sampling) 
#> Chain 1 Iteration: 1400 / 5000 [ 28%]  (Sampling) 
#> Chain 1 Iteration: 1500 / 5000 [ 30%]  (Sampling) 
#> Chain 1 Iteration: 1600 / 5000 [ 32%]  (Sampling) 
#> Chain 1 Iteration: 1700 / 5000 [ 34%]  (Sampling) 
#> Chain 1 Iteration: 1800 / 5000 [ 36%]  (Sampling) 
#> Chain 1 Iteration: 1900 / 5000 [ 38%]  (Sampling) 
#> Chain 1 Iteration: 2000 / 5000 [ 40%]  (Sampling) 
#> Chain 1 Iteration: 2100 / 5000 [ 42%]  (Sampling) 
#> Chain 1 Iteration: 2200 / 5000 [ 44%]  (Sampling) 
#> Chain 1 Iteration: 2300 / 5000 [ 46%]  (Sampling) 
#> Chain 1 Iteration: 2400 / 5000 [ 48%]  (Sampling) 
#> Chain 1 Iteration: 2500 / 5000 [ 50%]  (Sampling) 
#> Chain 1 Iteration: 2600 / 5000 [ 52%]  (Sampling) 
#> Chain 1 Iteration: 2700 / 5000 [ 54%]  (Sampling) 
#> Chain 1 Iteration: 2800 / 5000 [ 56%]  (Sampling) 
#> Chain 1 Iteration: 2900 / 5000 [ 58%]  (Sampling) 
#> Chain 1 Iteration: 3000 / 5000 [ 60%]  (Sampling) 
#> Chain 1 Iteration: 3100 / 5000 [ 62%]  (Sampling) 
#> Chain 1 Iteration: 3200 / 5000 [ 64%]  (Sampling) 
#> Chain 1 Iteration: 3300 / 5000 [ 66%]  (Sampling) 
#> Chain 1 Iteration: 3400 / 5000 [ 68%]  (Sampling) 
#> Chain 1 Iteration: 3500 / 5000 [ 70%]  (Sampling) 
#> Chain 1 Iteration: 3600 / 5000 [ 72%]  (Sampling) 
#> Chain 1 Iteration: 3700 / 5000 [ 74%]  (Sampling) 
#> Chain 1 Iteration: 3800 / 5000 [ 76%]  (Sampling) 
#> Chain 1 Iteration: 3900 / 5000 [ 78%]  (Sampling) 
#> Chain 1 Iteration: 4000 / 5000 [ 80%]  (Sampling) 
#> Chain 1 Iteration: 4100 / 5000 [ 82%]  (Sampling) 
#> Chain 1 Iteration: 4200 / 5000 [ 84%]  (Sampling) 
#> Chain 1 Iteration: 4300 / 5000 [ 86%]  (Sampling) 
#> Chain 1 Iteration: 4400 / 5000 [ 88%]  (Sampling) 
#> Chain 1 Iteration: 4500 / 5000 [ 90%]  (Sampling) 
#> Chain 1 Iteration: 4600 / 5000 [ 92%]  (Sampling) 
#> Chain 1 Iteration: 4700 / 5000 [ 94%]  (Sampling) 
#> Chain 1 Iteration: 4800 / 5000 [ 96%]  (Sampling) 
#> Chain 1 Iteration: 4900 / 5000 [ 98%]  (Sampling) 
#> Chain 1 Iteration: 5000 / 5000 [100%]  (Sampling) 
#> Chain 1 finished in 0.1 seconds.
```

### Inspecting samples

We can now inspect and compare the samples generated from our both
samplers. The output format of the samplers should work with the
[bayesplot](http://mc-stan.org/bayesplot/) library

``` r
library(bayesplot)
library(ggplot2)
library(gridExtra)
bs_posterior <- as.array(bs_fit$samples)
stan_posterior <- as.array(stan_fit$draws())

bs_hist <- mcmc_hist(bs_posterior) + labs(title = "Bridgestan")
stan_hist <- mcmc_hist(stan_posterior, pars = c("alpha", "beta", "sigma")) + labs(title = "Stan")
grid.arrange(bs_hist, stan_hist)
```

<img src="man/figures/README-plotting-1.png" width="100%" />

### Extracting sample trajectories

Given a sampling run, the trajectories of the leapfrog iterations can be
extracted as follows.

``` r
trajectories <- get_trajectory_stats(bs_fit, n_samples=1)
knitr::kable(trajectories)
```

| sample | subtree | leapfrog_iter | tree_dir | theta_alpha | theta_beta | theta_sigma |   p1_alpha |    p1_beta |   p1_sigma |   p2_alpha |    p2_beta |   p2_sigma |   g1_alpha |    g1_beta |  g1_sigma |   g2_alpha |    g2_beta |   g2_sigma | h1_diag_alpha | h1_diag_beta | h1_diag_sigma | h2_diag_alpha | h2_diag_beta | h2_diag_sigma | h1_alpha_beta | h1_alpha_sigma | h1_beta_sigma | h2_alpha_beta | h2_alpha_sigma | h2_beta_sigma |    g1_l2 |    g2_l2 |
|-------:|--------:|--------------:|---------:|------------:|-----------:|------------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|----------:|-----------:|-----------:|-----------:|--------------:|-------------:|--------------:|--------------:|-------------:|--------------:|--------------:|---------------:|--------------:|--------------:|---------------:|--------------:|---------:|---------:|
|      1 |       1 |             1 |        1 |   0.8089271 |   1.538922 |  -0.1498884 | -0.9923332 |  1.3971858 |  1.7383426 | -1.3313280 |  1.2424662 |  1.2362775 | -3.2692553 | -0.6299195 | -2.328131 | -2.1169315 | -0.9661819 | -3.1352617 |     -9.123240 |    -18.27759 |     -4.761687 |     -6.787788 |    -13.60669 |     -3.465891 |             0 |      6.4700185 |     0.9252908 |             0 |      6.4700185 |     0.9252908 | 4.062637 | 3.904455 |
|      1 |       2 |             1 |       -1 |   0.8535478 |   1.467181 |  -0.5108474 |  0.0547112 |  1.5989301 |  2.4839731 |  0.8465375 |  1.5680111 |  2.6693001 | -3.2692553 | -0.6299195 | -2.328131 | -4.9447417 |  0.1930808 | -1.1573173 |     -9.123240 |    -18.27759 |     -4.761687 |    -13.929494 |    -27.89010 |     -6.712678 |             0 |      6.4700185 |     0.9252908 |             0 |      6.4700185 |     0.9252908 | 4.062637 | 5.082040 |
|      1 |       2 |             2 |       -1 |   0.7755793 |   1.430376 |  -0.7548849 |  1.6383637 |  1.5370921 |  2.8546271 |  2.6419223 |  1.2029038 |  2.8713071 | -4.9447417 |  0.1930808 | -1.157317 | -6.2669538 |  2.0869165 | -0.1041622 |    -13.929494 |    -27.89010 |     -6.712678 |    -22.668444 |    -45.36800 |     -8.475074 |             0 |      9.8211996 |    -0.7122017 |             0 |      9.8211996 |    -0.7122017 | 5.082040 | 6.606117 |
|      1 |       3 |             1 |        1 |   0.7294377 |   1.564968 |  -0.0871218 | -1.6703228 |  1.0877467 |  0.7342124 | -1.8936676 |  0.8979387 |  0.1650806 | -2.1169315 | -0.9661819 | -3.135262 | -1.3947280 | -1.1853002 | -3.5540746 |     -6.787788 |    -13.60669 |     -3.465891 |     -5.991728 |    -12.01457 |     -2.771137 |             0 |      4.1691489 |     1.5903810 |             0 |      4.1691489 |     1.5903810 | 3.904455 | 3.997705 |
|      1 |       3 |             2 |        1 |   0.6286907 |   1.581924 |  -0.1216635 | -2.1170124 |  0.7081306 | -0.4040511 | -2.2524647 |  0.4718037 | -0.9879118 | -1.3947280 | -1.1853002 | -3.554075 | -0.8458631 | -1.4757981 | -3.6460532 |     -5.991728 |    -12.01457 |     -2.771137 |     -6.417428 |    -12.86597 |     -2.508061 |             0 |      2.7311010 |     2.0228298 |             0 |      2.7311010 |     2.0228298 | 3.997705 | 4.023328 |
|      1 |       3 |             3 |        1 |   0.5150515 |   1.587563 |  -0.2560318 | -2.3879169 |  0.2354767 | -1.5717726 | -2.4113265 | -0.0802018 | -2.1159101 | -0.8458631 | -1.4757981 | -3.646053 | -0.1461867 | -1.9713275 | -3.3979927 |     -6.417428 |    -12.86597 |     -2.508061 |     -8.383656 |    -16.79842 |     -2.709640 |             0 |      1.6414309 |     2.6000575 |             0 |      1.6414309 |     2.6000575 | 4.023328 | 3.931140 |
|      1 |       3 |             4 |        1 |   0.3991843 |   1.578083 |  -0.4834350 | -2.4347362 | -0.3958803 | -2.6600477 | -2.2250220 | -0.8369949 | -3.0761093 | -0.1461867 | -1.9713275 | -3.397993 |  1.3096085 | -2.7546420 | -2.5981932 |     -8.383656 |    -16.79842 |     -2.709640 |    -13.188503 |    -26.40812 |     -3.876606 |             0 |      0.2511693 |     3.5898634 |             0 |      0.2511693 |     3.5898634 | 3.931140 | 4.006711 |

\` For each sample, parameter and leapfrog algorithm update the
following information is currently extracted:

- `subtree`: which binary subtree of the NUTS algorithm the leapfrog
  step belongs to
- `tree_dir` indicating if the current subtree is grown in a positive or
  negative direction
- `g1` `g2`: first and second gradient update
- `p1`, `p2`: first and second momentum updates:
- `h1_diag`, `h2_diag`: diagonal of first and second Hessian:
- `h1_param1_param2`, `h2_param1_param2`: lower triangular Hessian
  components:
- `g1_l2`, `g2_l2`: $L^2$-norm of the first and second gradient:
