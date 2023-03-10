#!/bin/sh -eu

if [[ "${RHN_SUBSCRIPTION_KEY}" != "" && "${RHN_SUBSCRIPTION_ORG}" != "" ]]; then
    subscription-manager register --org=${RHN_SUBSCRIPTION_ORG} --activationkey=${RHN_SUBSCRIPTION_KEY}
    exit 0 
fi


if [[ "${RHN_USERNAME}" == "" ]]; then
    echo "RHN_USERNAME not set"
    exit 1
fi

if [[ "${RHN_PASSWORD}" == "" ]]; then
    echo "RHN_PASSWORD not set"
    exit 1
fi

subscription-manager register --username $RHN_USERNAME --password $RHN_PASSWORD --auto-attach
