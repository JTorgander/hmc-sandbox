mm_gs_mu_prior <- "

  functions {

    real gumbel_centered_lpdf(vector y, int K, vector x){
    vector[K] u;
    u[1:K-1] = y;
    u[K] = 0;

    return lgamma(K) + sum(x - u) - K * log_sum_exp(x - u);
  }

  }

  data {
    int<lower=1> K;  // Number of categories

    int N; // Sample size
    int M; // Dimension
    simplex[K] pi;   // Probability vector
    real tau;        // Temperature parameter
    matrix[N, M] y;    //Data

  }

  transformed data {

    vector[K] pi_log = log(pi);

  }

  parameters {
   matrix[K, M] mu;
    matrix[N, K-1] u;


  }

  transformed parameters {

     matrix[N, K] u_softmax;
     matrix[N, K] u_transformed;

     real u_max;
     real sum_y;
     vector[N] sum_u;

     for (i in 1:N){
       // Inverse GS -> CS transformation
       u_transformed[i, 1:K-1] = u[i]/tau;
       u_transformed[i, K] = 0;
       u_max = max(u_transformed[i]);

       sum_y = sum(exp(u_transformed[i] - u_max));
       sum_u[i] = log_sum_exp(u_transformed[i]);
       u_softmax[i, K] = 0;

       for (k in 1:K-1) {
            u_softmax[i, k] = exp(u_transformed[i, k] - u_max)/sum_y;


       }

        u_softmax[i, K] = 1 - sum(u_softmax[i]);

     }
  }

 model {

      vector[K] mixture;

      row_vector[M] y_current;
     matrix[M,M] sigma = diag_matrix(rep_vector(1, M));
      for (i in 1:N){

        y_current = y[i];
        for (j in 1:K-1){


        mixture[j] = u_transformed[i, j] - sum_u[i] + multi_normal_lpdf(to_vector(y_current) | to_vector(mu[j]), sigma) ;

        }
        mixture[K] =  (-1)*sum_u[i] + multi_normal_lpdf(to_vector(y_current) | to_vector(mu[K]),  sigma);
        target += log_sum_exp(mixture) + gumbel_centered_lpdf(to_vector(u[i]) | K, pi_log);

      }
 }

 generated quantities {

 matrix[N,K] u_softmax_rounded;

  for (i in 1:N){
    u_softmax_rounded[i] = round(u_softmax[i]);

  }
 }



"


mixture_multi_gs <- "

  functions {

    real gumbel_centered_lpdf(vector y, int K, vector x){
    vector[K] u;
    u[1:K-1] = y;
    u[K] = 0;

    return lgamma(K) + sum(x - u) - K * log_sum_exp(x - u);
  }

  }

  data {
    int<lower=1> K;  // Number of categories
    int M; // Dimension of response
    simplex[K] pi;   // Probability vector
    real tau;        // Temperature parameter
    matrix[K, M] mu;
  }

  transformed data {

    vector[K] pi_log = log(pi);
  }

  parameters {
    vector[K-1] u;
    vector[M] y;

  }

  transformed parameters {

     vector[K] u_softmax;
     vector[K] u_transformed;
     vector[K] mixture;
     matrix[K,K] sigma = diag_matrix(rep_vector(1, K));
     real u_max;
     real sum_y;
     real sum_u;

     // Transforming CS -> GS
     u_transformed[1:K-1] = u/tau;
     u_transformed[K] = 0;
     u_max = max(u_transformed);

     sum_y = sum(exp(u_transformed - u_max));
     sum_u = log_sum_exp( u_transformed);

     u_softmax[K] = 0;
     for (k in 1:K-1) {
          u_softmax[k] = exp(u_transformed[k] - u_max)/sum_y;
          mixture[k] = u_transformed[k] - sum_u + multi_normal_lpdf(y | mu[k], sigma) ;

     }

     u_softmax[K] = 1 - sum(u_softmax);
        mixture[K] =  (-1)*sum_u + multi_normal_lpdf(y | mu[K],  sigma);

  }

 model {

      u ~ gumbel_centered_lpdf(K, pi_log);
      target += log_sum_exp(mixture);

 }

 generated quantities {

 vector[K] u_softmax_rounded;

 u_softmax_rounded = round(u_softmax);

 }



"
