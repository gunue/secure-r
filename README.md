# secure-secrets-restapi
This repo provides sample configuration for both Conjur and Openshift environment to deploy your app to securely retrieve secrets using Conjur REST API. .

R script makes API call to the Follower using access-token retrieved via K8s auth client. Deployment method is sidecar therefore it supports secret rotation on the fly.
