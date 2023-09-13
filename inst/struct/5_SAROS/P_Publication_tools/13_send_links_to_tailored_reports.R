#### Send ut ferdiggenererte respondent/institusjonsspesifikke nettsteder


# En respondent er egentlig bare en institusjon med n_gruppe = 1. Så snitt og alt annet bør fungere som før.
# bortsett fra at kontrollsjekk om at det er for få respondenter per gruppe (mtp Statistical Disclosure Control) droppes.



### Send ut med Outlook (outbox først)
# Hvis problemer med å autentisere med get_business_outlook() så kjør vignette("auth", package = "Microsoft365R")
library(Microsoft365R)
my_outlook <- get_business_outlook()
my_email <- 
  my_outlook$
  create_email("Body text I want in my email", 
                                    subject = "Her kjem en test", to = "stephus.daus@gmail.com")$
  send()
