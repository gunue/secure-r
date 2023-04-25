#install.packages(c("httr", "Rcurl")) #"openssl"), repos = "https://cran.ncc.metu.edu.tr")
library(httr)
library(RCurl)
#library(openssl)

#httr::httr_options()
#reset_config()
# httr::set_config(httr::config(ssl_verifypeer = TRUE )) Trust between httr and Conjur
httr::set_config(httr::config(ssl_verifypeer = FALSE ))

##To trust SSL read within script or read from ConfigMap
#conjurssl <- download_ssl_cert(conjurhostname)

###################################################################################
# Secret fetch with REST-API
###################################################################################

#secret1path <- '/secrets/swo-uat/variable/secrets/username?version=1' #first secret set
#secret2path <- '/secrets/swo-uat/variable/secrets/password?version=4'
secret1path <- '/secrets/swo-uat/variable/secrets/username'
secret2path <- '/secrets/swo-uat/variable/secrets/password'
secret0path <- '/secrets/swo-uat/variable/secrets/endpoint' #latest
follower_url <- 'https://conjur-follower.cyberark-conjur-jwt.svc.cluster.local'
conjuraccesstoken <- '/run/conjur/access-token'

## Wait and Read Conjur Auth Token
      while (!file.exists(conjuraccesstoken)) {
        Sys.sleep(1)
      }
      #conjur.access.token <- read.delim(conjuraccesstoken, header = FALSE)[[1]]
      conjur.access.token <- read.delim(conjuraccesstoken, header = FALSE, sep = "")[[1]]
      conjur.access.token <- base64(conjur.access.token)
      
## Retrieve secrets with Conjur access-token, print and sleep 5 sec 
while (TRUE) {
  
  # Test access-token validity on dummy fetch
  tokentest <- GET(url = follower_url, 
                 path = secret0path, 
                 add_headers("Authorization"=paste("Token token=", '"',conjur.access.token, '"', sep = "")))
  statuscode <- tokentest$status_code
  
  # If authorized fetch secrets
  if (statuscode==200) {
  
      secret0 <- GET(url = follower_url, 
                     path = secret0path, 
                     add_headers("Authorization"=paste("Token token=", '"',conjur.access.token, '"', sep = "")))
      
      secret0 <- content(secret0, as=c("text"), encoding = 'UTF-8')
      print(paste("Secret URL is:",secret0))
      
      secret1 <- GET(url = follower_url, 
                     path = secret1path, 
                     add_headers("Authorization"=paste("Token token=", '"',conjur.access.token, '"', sep = "")))
      
      secret1 <- content(secret1, as=c("text"), encoding = 'UTF-8')
      print(paste("Username is:",secret1))
      
      secret2 <- GET(url = follower_url, 
                     path = secret2path, 
                     add_headers("Authorization"=paste("Token token=", '"',conjur.access.token, '"', sep = "")))
      
      secret2 <- content(secret2, as=c("text"), encoding = 'UTF-8')
      print(paste("Password is:",secret2))

      Sys.sleep(5)
      }
  # If unauthorized read access-token again.
  else if (statuscode==401){
    conjur.access.token <- read.delim(conjuraccesstoken, header = FALSE, sep = "")[[1]]
    conjur.access.token <- base64(conjur.access.token)
    }
   
}
