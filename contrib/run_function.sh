#!/bin/bash

export KUBECONFIG="$(kind get kubeconfig-path)"

kubectl rollout status deploy/gateway -n openfaas
kubectl port-forward deploy/gateway -n openfaas 8080:8080 &

# Check if Openfaas GW is Up
for i in {1..60};
do
    curl -if 127.0.0.1:8080
    if [ $? == 0 ];
    then
        break
    fi
    sleep 1
done

# Login in OpenFaas
export OPENFAAS_URL=http://127.0.0.1:8080
PASSWORD="something_random" # Set to predetermined value from ./contrib/deploy.sh
faas-cli login --username admin --password $PASSWORD

faas-cli deploy --image=functions/alpine:latest --fprocess=cat --name echo

# Call echo function
for i in {1..60};
do
    curl -if http://127.0.0.1:8080/function/echo
    if [ $? == 0 ];
    then
        exit 0
    fi
    sleep 1
done

exit 1