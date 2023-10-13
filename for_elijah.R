fit_and_plot_interaction_models <- function(..., shape = "circle"){
  #load data and unnest trait data
  data <- unnest(...)
  
  #fit basic prec model
  res_prec <- lm(trait_value~log_Prec, data)
  
  #fit main effect model
  res_main <- lm(trait_value~log_Prec+Temp, data)
  
  #fit interaction model
  res <- lm(trait_value~log_Prec*Temp, data)
  browser()
  #create a in-sample dataset to predict from interaction model. Sampling across rainfall gradient for a given trait and the 33rd and 66th quantile of the temperature gradient
  newdf = expand_grid(log_Prec = seq(min(data$log_Prec, na.rm = T), max(data$log_Prec, na.rm = T), length.out = 100), Temp = c(quantile(data$Temp, 0.25, na.rm = T), quantile(data$Temp, 0.75, na.rm = T)))
  
  #predict from the model using predict.lm
  model_p <- predict.lm(res, newdf, se.fit = TRUE)
  
  #bind predictions back on the prediction dataset
  pred_data <-bind_cols(newdf, model_p)
  
  #for the original dataset, create a binary classification for the observations based on low or high temperature (based on the median value)
  data %>%
    mutate(temp_binary = ifelse(Temp < median(Temp, na.rm = T), "Low", "High")) -> data
  
  gg_color_hue <- function(n) {
    hues = seq(15, 375, length = n + 1)
    hcl(h = hues, l = 65, c = 100)[1:n]
  }
  
  n = 2
  cols = gg_color_hue(n)
  
  pred_data %>%
    ggplot(aes(x = log_Prec, y = fit)) +
    geom_point(data = data, aes(x = log_Prec, y = trait_value, colour = temp_binary), shape = shape) +
    new_scale_colour() + 
    geom_smooth_ci(Temp, size = 1) +
    scale_colour_manual(values = cols[c(2,1)]) +
    xlab("log(Prec) (mm)") +
    theme_classic() +
    theme(legend.position = "none",
          text=element_text(size=20)) -> plot_ex
  
  #add a y-label to the y-axis based on the current trait
  if(data$trait_name[1] == "log_height"){
    plot_ex + ylab(expression(paste("log(Maximum height) (m)")))-> plot_ex
  }
  if(data$trait_name[1] == "log_leaf_N_calc"){
    plot_ex + ylab(expression(paste("log(",N[area],") ","(kg ",m^{-2},")")))-> plot_ex
  }
  if(data$trait_name[1] == "log_huber"){
    plot_ex + ylab(expression(paste("log(SA:LA)")))-> plot_ex
  }
  if(data$trait_name[1] == "log_LMA"){
    plot_ex + ylab(expression(paste("log(LMA) (kg",m^{-2},")")))-> plot_ex
  }
  if(data$trait_name[1] == "log_leaf_area"){
    plot_ex + ylab(expression(paste("log(LA) ","(",mm^{-2},")")))-> plot_ex
  }
  if(data$trait_name[1] == "log_leaf_capital_delta13C"){
    plot_ex + ylab(expression(paste("log(",Delta^{13}," C",")"," (","\u2030",")")))-> plot_ex
  }
  if(data$trait_name[1] == "log_seed_mass"){
    plot_ex + ylab(expression(paste("log(Seed mass) (mg)")))-> plot_ex
  }
  if(data$trait_name[1] == "log_wood_dens"){
    plot_ex + ylab(expression(paste("log(Wood density) (",mg~mm^{-3},")")))-> plot_ex
  }
  list(plot = (plot_ex), r_squared = summary(res)[[8]], r_squared_prec = summary(res_prec)[[8]], r_squared_main = summary(res_main)[[8]], direction = ifelse(coef(res)[4] > 0, "up", "down"))
}
