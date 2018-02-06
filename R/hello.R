library(googleAuthR)
library(jlR)
library(tidyverse)
library(stringr)

gar_api_generator(baseURI = "")

scopes %>%
  filter(str_detect(api_name, "(P|p)age"))
