# symfony4 on kubernetes (container orchestration demo) 

## Overview

container orchestration - kubernetes

Demo

    build symfony4 docker image
    upload to gce container repository
    create kubernetes cluster
    deploy application
    expose application 
    dashboard


## Container orchestration 

Management of linux containers, (auto-)scaling, restarting, balancing and more.

    docker-compose
    swarm
    rancher
    titus (netflix)
    kubernetes (google)
    ...

### kubernetes (k8s)

    master - main controlling unit
    nodes - workers (handles workload)
    pods - a collections 1..n container
    deployment - replicas, scaling (will create in pods) 
    service - load-balancing, service-discovery, dns
    
everything is a container on kubernetes
It's supported by

    GCE: Native Support, KOPS
    AWS: Native Support (to come), KOPS
    Custom Setup on any other provider

## Prerequisites

Install

    docker
    gcloud
    kubectl
    
Sign up to
    
    gcloud auth login (google cloud engine)
    Create project (meineapp)
    Create container repository (eu.gcr.io/meineapp)

### Clone project

    git clone git@github.com:thomaswiener/sf4-kube.git

### Build image

    docker build -t eu.gcr.io/meineapp/sf4:v1 .
    
### Run image locally
    
    docker run -d -p 4001:80 eu.gcr.io/meineapp/sf4:v1

### Push image to repository

    gcloud docker -- push eu.gcr.io/meineapp/sf4:v1

### Create kubernetes cluster

    gcloud container clusters create symfony4-demo \
        --num-nodes 3 \
        --machine-type g1-small \
        --zone europe-west1-b
    
    gcloud compute instances list
    
### Register cluster in kubectl
    
    gcloud container clusters get-credentials symfony4-demo --zone europe-west1-b --project meineapp

### Connect to dashboard
   
    kubectl proxy
    http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login
    
### Create User and Token

    kubectl create serviceaccount dashboard -n default
    kubectl create clusterrolebinding dashboard-admin -n default --clusterrole=cluster-admin --serviceaccount=default:dashboard
    kubectl get secret $(kubectl get serviceaccount dashboard -n default -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode
    

### Create deployment

    kubectl apply -f kube/deployment.yaml
    kubectl get deployment
 
### Create service (Allow external traffic)

    kubectl apply -f kube/service.yaml
    kubectl get svc

### Delete service

    kubectl delete svc sf4-service
    
### Delete deployment

    kubectl delete deployment sf4-deployment

### Get Cluster info

    kubectl cluster-info
    

### Cleanup

    gcloud container clusters delete symfony4-demo --zone europe-west1-b

### Switch between cluster contexts

    kubectl config get-contexts
    kubectl config use-context {context-name}
