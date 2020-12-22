#!/bin/bash

#Make sure you're connected to your OpenShift cluster with admin user before running this script

echo "Creating CRW namespace"
oc apply -f crw-namespace.yaml
echo "CRW namespace created!"

echo "Creating CRW OperatorGroup"
oc apply -f crw-og.yaml
echo "CRW OperatorGroup created!"

echo "Creating CRW Subscription"
oc apply -f crw-sub.yaml
echo "CRW Subscription created!"
wait 10

echo "Deploying CheCluster CR"
oc apply -f che-ephemeral-cr.yaml
echo "CheCluster CR created!"

echo "Searching for available routes"
oc get routes -n codeready-workspaces
echo "connect to the route named codeready using your browser \
and login using your openshift credentials"

