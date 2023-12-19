
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
model <- get_model(model_name, model_seed = 1234, data=TRUE, bridgestan_path=BS_PATH)
#> Loading Bridgestan model
#> Models loaded!
```

Setting `data=TRUE` here indicates that the data.json file featured in
the model folder should be used when loading the model.

### Sampling

Having loaded the model object, we can now sample from the loaded model
using the following code:

``` r
bs_fit <- NUTS(model = model, n_samples = 4000, warm_up = 2000)
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
stan_fit <- model$stan_model$sample(data = model$data, chains = 1, iter_sampling = 4000)
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

| sample | subtree | leapfrog_iter | tree_dir | theta_alpha | theta_beta | theta_sigma |   p1_alpha |    p1_beta |   p1_sigma |  p2_alpha |    p2_beta |   p2_sigma |   g1_alpha |   g1_beta |   g1_sigma |   g2_alpha |    g2_beta |   g2_sigma | h1_diag_alpha | h1_diag_beta | h1_diag_sigma | h2_diag_alpha | h2_diag_beta | h2_diag_sigma | h1_alpha_beta | h1_alpha_sigma | h1_beta_sigma | h2_alpha_beta | h2_alpha_sigma | h2_beta_sigma |     g1_l2 |     g2_l2 |
|-------:|--------:|--------------:|---------:|------------:|-----------:|------------:|-----------:|-----------:|-----------:|----------:|-----------:|-----------:|-----------:|----------:|-----------:|-----------:|-----------:|-----------:|--------------:|-------------:|--------------:|--------------:|-------------:|--------------:|--------------:|---------------:|--------------:|--------------:|---------------:|--------------:|----------:|----------:|
|      1 |       1 |             1 |       -1 |   0.2869001 |  0.8910415 |  -0.1461120 |  2.9754421 |   1.518554 |  3.4504193 |  2.623649 |  -0.417154 |  3.1730462 |  0.1161143 |  3.208823 | -2.7230189 |  1.4156572 |   7.789523 |  1.1161830 |     -3.051444 |    -6.134000 |     -5.229628 |     -6.737015 |   -13.505140 |    -11.977259 |             0 |     -0.2686600 |     -6.624328 |             0 |     -0.2686600 |     -6.624328 |  4.210090 |  7.995413 |
|      1 |       2 |             1 |        1 |   0.6271549 |  1.0100882 |   0.4963878 |  3.0331512 |   3.113349 |  2.0970707 |  2.968374 |   3.518161 |  1.0884789 |  0.1161143 |  3.208823 | -2.7230189 | -0.2606703 |   1.629011 | -4.0586953 |     -3.051444 |    -6.134000 |     -5.229628 |     -1.892734 |    -3.816579 |     -3.055734 |             0 |     -0.2686600 |     -6.624328 |             0 |     -0.2686600 |     -6.624328 |  4.210090 |  4.381168 |
|      1 |       2 |             2 |        1 |   0.7915798 |  1.1109143 |   0.5056402 |  2.9035973 |   3.922972 |  0.0798870 |  2.763945 |   4.225927 | -0.9810332 | -0.2606703 |  1.629011 | -4.0586953 | -0.5619783 |   1.219125 | -4.2692708 |     -1.892734 |    -3.816579 |     -3.055734 |     -1.858765 |    -3.748641 |     -2.651173 |             0 |      0.4711682 |     -3.482486 |             0 |      0.4711682 |     -3.482486 |  4.381168 |  4.475350 |
|      1 |       3 |             1 |       -1 |   0.1582494 |  0.9515135 |  -0.4814833 |  2.2718562 |  -2.352862 |  2.8956730 |  1.161136 |  -5.766713 |  1.4407219 |  1.4156572 |  7.789523 |  1.1161830 |  4.4696737 |  13.737748 |  5.8548989 |     -6.737015 |   -13.505140 |    -11.977259 |    -13.137279 |   -26.305670 |    -20.786097 |             0 |     -2.8542665 |    -15.777056 |             0 |     -2.8542665 |    -15.777056 |  7.995413 | 15.587929 |
|      1 |       3 |             2 |       -1 |   0.1553945 |  1.1874674 |  -0.4798353 |  0.0504149 |  -9.180564 | -0.0142293 | -1.065935 | -11.045718 | -0.2101712 |  4.4696737 | 13.737748 |  5.8548989 |  4.4923276 |   7.505606 |  0.7884937 |    -13.137279 |   -26.305670 |    -20.786097 |    -13.094182 |   -26.219475 |    -10.656085 |             0 |     -8.9520074 |    -27.686943 |             0 |     -8.9520074 |    -27.686943 | 15.587929 |  8.782759 |
|      1 |       3 |             3 |       -1 |   0.2789730 |  1.5192958 |  -0.4328001 | -2.1822854 | -12.910873 | -0.4061130 | -2.832146 | -12.636863 |  0.2199185 |  4.4923276 |  7.505606 |  0.7884937 |  2.6151195 |  -1.102648 | -2.5192263 |    -13.094182 |   -26.219475 |    -10.656085 |    -11.922159 |   -23.875429 |     -4.122696 |             0 |     -8.9970867 |    -15.275093 |             0 |     -8.9970867 |    -15.275093 |  8.782759 |  3.794889 |
|      1 |       3 |             4 |       -1 |   0.4761522 |  1.8370392 |  -0.5307764 | -3.4820076 | -12.362853 |  0.8459500 | -3.562934 |  -9.747224 |  0.6320515 |  2.6151195 | -1.102648 | -2.5192263 |  0.3256570 | -10.525607 |  0.8607535 |    -11.922159 |   -23.875429 |     -4.122696 |    -14.494282 |   -29.019675 |    -10.716517 |             0 |     -5.2525568 |      1.867675 |             0 |     -5.2525568 |      1.867675 |  3.794889 | 10.565763 |

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
