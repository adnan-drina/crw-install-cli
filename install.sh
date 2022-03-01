#!/bin/bash

#Make sure you're connected to your OpenShift cluster with admin user before running this script
echo " "
echo "Creating CRW namespace"
oc apply -f crw-namespace.yaml
echo "CRW namespace created!"
echo " "
echo "Creating CRW OperatorGroup"
oc apply -f crw-og.yaml
echo "CRW OperatorGroup created!"
echo " "
echo "Creating CRW Subscription"
oc apply -f crw-sub.yaml
sleep 20
CRW="$(oc get sub -o name -n codeready-workspaces | grep codeready-workspaces)"
oc -n codeready-workspaces wait --timeout=120s --for=condition=CatalogSourcesUnhealthy=False ${CRW}
echo "CRW Subscription created!"
echo " "
sleep 10
echo "Deploying CheCluster CR"
#oc apply -f che-ephemeral-cr.yaml
oc apply -f che-cr.yaml
echo "CheCluster CR created!"
echo " "
#echo "Searching for available routes"
#oc get routes -n codeready-workspaces
#echo "connect to the route named codeready using your browser \
#and login using your openshift credentials"

