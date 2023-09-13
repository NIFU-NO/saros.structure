## Check first that all files exist before proceding

tmp <- list.files(path = "1 Initialization tools", pattern = "[012][0-9].*\\.R$")

lapply(X = tmp, FUN = source)
