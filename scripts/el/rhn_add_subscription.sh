#!/bin/bash -eu
source /etc/os-release

if [[ "${RHN_SUBSCRIPTION_KEY}" != "" && "${RHN_SUBSCRIPTION_ORG}" != "" ]]; then
    subscription-manager register --org="${RHN_SUBSCRIPTION_ORG}" --activationkey="${RHN_SUBSCRIPTION_KEY}"
else


    if [[ "${RHN_USERNAME}" == "" ]]; then
        echo "RHN_USERNAME not set"
        exit 1
    fi

    if [[ "${RHN_PASSWORD}" == "" ]]; then
        echo "RHN_PASSWORD not set"
        exit 1
    fi

    subscription-manager register --username "$RHN_USERNAME" --password "$RHN_PASSWORD" --auto-attach
fi

# 
subscription-manager release --set="${VERSION_ID}"

# el 8.10 does not have extended support so we need to disable it
if [[ "${VERSION_ID}" == "8.10" ]]; then
    subscription-manager repos --disable=rhel-8-for-x86_64-baseos-eus-rpms
    subscription-manager repos --disable=rhel-8-for-x86_64-appstream-eus-rpms
fi
