#install.packages(c("httr", "Rcurl")) #"openssl"), 
# repos = "https://cran.ncc.metu.edu.tr")
library(httr)
library(RCurl)
#library(openssl)

#httr::httr_options()
#reset_config()
## Trust between httr and Conjur
# httr::set_config(httr::config(ssl_verifypeer = TRUE ))
httr::set_config(httr::config(ssl_verifypeer = FALSE ))

##To trust SSL read within script or read from ConfigMap
#conjurssl <- download_ssl_cert(conjurhostname)

###################################################################################
# Secret fetch with REST-API
###################################################################################

#### Following information hardcoded here.
#### Consider sending them to container via Config Map, ENV in deployment
### or as kubernetes secrets.
##secret1path <- '/secrets/swo-uat/variable/secrets/connection_str?version=1' #first secret set. Latest 20 version retained.
##secret1path <- '/secrets/swo-uat/variable/secretsdev/app_user'
##secret2path <- '/secrets/swo-uat/variable/secretsdev/app_pass'
##secret0path <- '/secrets/swo-uat/variable/secrets/connection_str' #latest
##secret0path <- '/secrets/swo-uat/variable/secrets/connection_str?version=1'
##secret0path <- '/secrets/swo-uat/variable/secrets/connection_str?version=19'
##follower_url <- 'https://conjur-follower.conjur-uat.svc.cluster.local'
##conjuraccesstoken <- '/run/conjur/access-token'

follower_url <- Sys.getenv("CONJUR_APPLIANCE_URL")
conjuraccesstoken <- Sys.getenv("CONJUR_AUTHN_TOKEN_FILE")
secret0path <- Sys.getenv("SECRET0_PATH")
secret1path <- Sys.getenv("SECRET1_PATH")
secret2path <- Sys.getenv("SECRET2_PATH")

## Wait and Read Conjur Auth Token
      while (!file.exists(conjuraccesstoken)) {
        Sys.sleep(1)
      }
      conjuraccesstoken <- read.delim(conjuraccesstoken,
      header = FALSE, sep = "")[[1]]
      conjuraccesstoken <- base64(conjuraccesstoken)

## Retrieve secrets with Conjur access-token, print and sleep 5 sec
while (TRUE) {

  # Test access-token validity on dummy fetch
  tokentest <- GET(url = follower_url,
                 path = secret0path,
                 add_headers("Authorization" = paste("Token token=", '"',
                 conjuraccesstoken, '"', sep = "")))
  statuscode <- tokentest$status_code

  # If authorized fetch secrets
  if (statuscode == 200) {

      secret0 <- GET(url = follower_url,
                     path = secret0path,
                     add_headers("Authorization" = paste("Token token=", '"',
                     conjuraccesstoken, '"', sep = "")))

      secret0 <- content(secret0, as=c("text"), encoding = "UTF-8")
      print(paste("Secret URL is:",secret0))

      secret1 <- GET(url = follower_url,
                     path = secret1path,
                     add_headers("Authorization" = paste("Token token=", '"',
                     conjuraccesstoken, '"', sep = "")))

      secret1 <- content(secret1, as=c("text"), encoding = "UTF-8")
      print(paste("Username is:",secret1))

      secret2 <- GET(url = follower_url,
                     path = secret2path,
                     add_headers("Authorization" = paste("Token token=", '"',
                     conjuraccesstoken, '"', sep = "")))

      secret2 <- content(secret2, as=c("text"), encoding = "UTF-8")
      print(paste("Password is:",secret2))

      Sys.sleep(5)
      } else
  # If unauthorized against conjur, read access-token again.
   if (statuscode == 401) {
    conjuraccesstoken <- read.delim(conjuraccesstoken,
    header = FALSE, sep = "")[[1]]
    conjuraccesstoken <- base64(conjur.access.token)
    }

}