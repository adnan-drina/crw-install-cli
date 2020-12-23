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
sleep 30
CRW="$(oc get pods -o name -n codeready-workspaces | grep codeready-operator)"
oc -n codeready-workspaces wait --for=condition=Ready ${CRW}
echo "CRW Subscription created!"
echo " "
echo "Deploying CheCluster CR"
oc apply -f che-ephemeral-cr.yaml
echo "CheCluster CR created!"
echo " "
#echo "Searching for available routes"
#oc get routes -n codeready-workspaces
#echo "connect to the route named codeready using your browser \
#and login using your openshift credentials"

