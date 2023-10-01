plot_mu <- function(stan_sim){
  #Plotting mu samples from stan simulation
  stan_sim %>% select(contains("mu")) %>%
    pivot_longer(cols=everything()) %>%
    transmute(value,
              class = str_match(name, pattern = "\\d"),
              coord = case_when(str_detect(name, ",1]")~ "x", TRUE~"y")) %>%
    pivot_wider(names_from = coord, values_from = value) %>%
    unnest() %>%
    ggplot(aes(x = x, y = y, color = class)) + geom_point()
}
