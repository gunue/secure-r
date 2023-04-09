# secure-secrets-restapi
This repo provides sample configuration for both Conjur and Openshift environment to deploy your app to securely retrieve secrets using Conjur REST API. JWT based authentication is configured for both app and Conjur Follower deployed on Openshift.

R script makes API call to the Follower using access-token retrieved via JWT authentication process. Deployment method is sidecar therefore it supports secret rotation on the fly.
