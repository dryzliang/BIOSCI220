library(dplyr)
library(ggplot2)
library(gganimate)
library(magick)

## One sample t-test
## simulate data
dog <- data.frame(type = "Food",weight = rnorm(100,5,1), reps = rep(1:10,each = 10))

means_df <- dog %>%
    group_by(reps,type) %>%
    summarize(means = mean(weight),
              sem = sd(weight)/sqrt(length(weight)))

stats_df <- dog %>%
    group_by(reps) %>%
    summarize(ts = t.test(weight,mu = 5)$statistic)


a <- ggplot(means_df, aes(x = type, y = means)) +
    geom_bar(stat = "identity") +
    geom_point(aes(x = type, y = weight), data = dog, alpha = .25) +
    geom_errorbar(aes(ymin = means - sem, ymax = means + sem), width = .2) +
    theme(axis.title.x=element_blank(),
          axis.ticks.x=element_blank(),
          panel.background = element_blank(),
          panel.grid.minor = element_blank(),
          panel.grid.major = element_blank(),
          panel.border = element_rect(colour='black', fill=NA)) +
    geom_hline(yintercept = 5, col = "red") + 
    xlab("") + ylab("Weight of dog food (kg)") +
    transition_states(
        states = reps,
        transition_length = 2,
        state_length = 1) +
    geom_text(aes(0.5, 7.5,label = paste("Mean:", format(round(means, 3),"kg", nsmall = 2))),
              size = 4, hjust = 0, color = "black") +
    enter_fade() + 
    exit_shrink() +
    ease_aes('sine-in-out')
  
a_gif <- animate(a, width = 420, height = 420)

b <- ggplot(stats_df, aes(x = ts))+
  geom_vline(aes(xintercept = ts, frame = reps))+
  geom_line(aes(x=x,y=y),
            data = data.frame(x = seq(-5,5, .1),
                              y = dt(seq(-5,5, .1), df = 18))) +
    theme(panel.background = element_blank(),
          panel.grid.minor = element_blank(),
          panel.grid.major = element_blank(),
          panel.border = element_rect(colour='black', fill=NA)) +
  ylab("density") +
  xlab("t statistic") +
  transition_states(
    states = reps,
    transition_length = 2,
    state_length = 1
  ) +
    geom_text(aes(0.5, 7.5,label = paste("t-statistic:", format(round(ts, 2), nsmall = 2))),
              size = 4, hjust = 0, color = "black") +
  enter_fade() + 
  exit_shrink() +
  ease_aes('sine-in-out')

b_gif <- animate(b, width = 420, height = 420)

a_mgif <- image_read(a_gif)
b_mgif <- image_read(b_gif)

new_gif <- image_append(c(a_mgif[1], b_mgif[1]))
for(i in 2:100){
  combined <- image_append(c(a_mgif[i], b_mgif[i]))
  new_gif <- c(new_gif, combined)
}

new_gif

## independant t-test
## simulate data
A <-rnorm(100,50,10)
B <-rnorm(100,45,10)
DV <- c(A,B)
Student <- rep(c("Medics","Biologists"),each=100)
sims <- rep(rep(1:10,each=10),2)
df <- data.frame(sims, Student, DV)

means_df <- df %>%
               group_by(sims,Student) %>%
               summarize(means=mean(DV),
                         sem = sd(DV)/sqrt(length(DV)))
means_df$lab <- rep(1:2, times = 10)

stats_df <- df %>%
              group_by(sims) %>%
              summarize(ts = t.test(DV~Student,var.equal=TRUE)$statistic)

a <- ggplot(means_df, aes(x=Student,y=means, fill=Student))+
    geom_bar(stat="identity")+
    geom_point(data=df,aes(x=Student, y=DV), alpha=.25)+
    geom_errorbar(aes(ymin=means-sem, ymax=means+sem),width=.2) +
    ylab("Number of hours studied") +
    theme(axis.title.x=element_blank(),
          panel.background = element_blank(),
          panel.grid.minor = element_blank(),
          panel.grid.major = element_blank(),
          panel.border = element_rect(colour='black', fill=NA)) +
    transition_states(
        states = sims,
        transition_length = 2,
        state_length = 1
    ) +
    geom_text(aes(0.5, 80,label = paste("Sample mean Biologists:",
                                        format(round(means[c(sims[c(TRUE,TRUE,FALSE,FALSE)],
                                                             means_df$sims[c(TRUE,TRUE,FALSE,FALSE)] + 10)], 3),
                                               nsmall = 2))),
              size = 4, hjust = 0, color = "black") +
    geom_text(aes(0.5, 76,label = paste("Sample mean Medics:", format(round(means[sims*2], 3),
                                                                      nsmall = 2))),
              size = 4, hjust = 0, color = "black") +
    enter_fade() + 
    exit_shrink() +
    ease_aes('sine-in-out')

a_gif <- animate(a, width = 420, height = 420)

b <- ggplot(stats_df,aes(x=ts))+
    geom_vline(aes(xintercept=ts, frame=sims))+
    geom_line(data=data.frame(x=seq(-5,5,.1),
                              y=dt(seq(-5,5,.1),df=18)),
              aes(x=x,y=y)) +
    theme(panel.background = element_blank(),
          panel.grid.minor = element_blank(),
          panel.grid.major = element_blank(),
          panel.border = element_rect(colour='black', fill=NA)) +
    ylab("density")+
    xlab("t-statistic")+
    transition_states(
        states=sims,
        transition_length = 2,
        state_length = 1
    ) +
    geom_text(aes(-4, 0.5,label = paste("t-statistic:", format(round(ts, 2), nsmall = 2))),
              size = 4, hjust = 0, color = "black") +
    enter_fade() + 
    exit_shrink() +
    ease_aes('sine-in-out')

b_gif<-animate(b, width = 420, height = 420)


d<-image_blank(420*2,420)

the_frame<-d
for(i in 2:100){
  the_frame<-c(the_frame,d)
}

a_mgif<-image_read(a_gif)
b_mgif<-image_read(b_gif)

new_gif<-image_append(c(a_mgif[1], b_mgif[1]))
for(i in 2:100){
  combined <- image_append(c(a_mgif[i], b_mgif[i]))
  new_gif<-c(new_gif,combined)
}

new_gif