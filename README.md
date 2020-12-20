# crw-install-cli
Deploy CodeReady Workspaces on OpenShift using the CRW Operator.

## Setup Procedure

Ensure that the CRW operator exists in the channel catalog.
```shell script
oc get packagemanifests -n openshift-marketplace | grep codeready-workspaces
```

Query the available channels for CRW operator
```shell script
oc get packagemanifest -o jsonpath='{range .status.channels[*]}{.name}{"\n"}{end}{"\n"}' -n openshift-marketplace codeready-workspaces
```

Discover whether the operator can be installed cluster-wide or in a single namespace
```shell script
oc get packagemanifest -o jsonpath='{range .status.channels[*]}{.name}{" => cluster-wide: "}{.currentCSVDesc.installModes[?(@.type=="AllNamespaces")].supported}{"\n"}{end}{"\n"}' -n openshift-marketplace codeready-workspaces
```

Check the CSV information for additional details
```shell script
oc describe packagemanifests/codeready-workspaces -n openshift-marketplace | grep -A36 Channels
```

## Install an operator in a namespace using the CLI

To install an operator in a specific project (in case of cluster-wide false), you need to create first an OperatorGroup in the target namespace. An OperatorGroup is an OLM resource that selects target namespaces in which to generate required RBAC access for all Operators in the same namespace as the OperatorGroup.

### Create a Project
[crw-namespace.yaml](crw-namespace.yaml)
```yaml
apiVersion: v1
kind: Namespace
metadata:
  annotations:
    openshift.io/description: "A collaborative Kubernetes-native development solution that delivers OpenShift workspaces and in-browser IDE for rapid cloud application development."
    openshift.io/display-name: "Red Hat CodeReady Workspaces"
  name: codeready-workspaces
```
```shell script
oc apply -f crw-namespace.yaml
```
or
```shell script
oc new-project codeready-workspaces
```

### Create an OperatorGroup
[crw-og.yaml](crw-og.yaml)
```yaml
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: crw-og #name of your OperatorGroup. free choice
  namespace: codeready-workspaces #the namespace in which you want to deploy your operator
spec:
  targetNamespaces:
  - codeready-workspaces #the namespace in which you want to deploy your operator (again)
```
```shell script
oc apply -f crw-og.yaml
```

### Create a Subscription
[crw-sub.yaml](crw-sub.yaml)
```yaml
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: codeready-workspaces
  namespace: codeready-workspaces
spec:
  channel: <Output of the query for the available channels>
  installPlanApproval: Automatic
  name: codeready-workspaces
  source: redhat-operators
  sourceNamespace: openshift-marketplace
```
```shell script
oc apply -f crw-sub.yaml
```

### Deploy CheCluster CR example

You can get details about the Custom Resource Definitions (CRD) supported by the operator or retrieve some sample CRDs.

Get the CSV name of the installed CRW operator
```shell script
oc get csv #get operator name
CSV=$(oc get csv -o name |grep crwoperator) #store the CSV data
```
Query the ClusterServiceVersion (CSV)
```shell script
oc get $CSV -o json |jq -r '.spec.customresourcedefinitions.owned[]|.name' #query the CRDs enabled by the operator
oc get $CSV -o json |jq -r '.metadata.annotations["alm-examples"]' #retrieve the sample CRDs if you need some help to get started
```
Crate a CheCluster instance using the provided sample CRD
```shell script
oc get $CSV -o json |jq -r '.metadata.annotations["alm-examples"]' |jq '.[0]' |oc apply -n codeready-workspaces -f -
```
or using the example [che-ephemeral-cr.yaml](che-ephemeral-cr.yaml)
```yaml
apiVersion: org.eclipse.che/v1
kind: CheCluster
metadata:
  name: codeready-workspaces
spec:
  server:
    cheImageTag: ''
    cheFlavor: codeready
    devfileRegistryImage: ''
    pluginRegistryImage: ''
    tlsSupport: true
    selfSignedCert: false
  database:
    externalDb: false
    chePostgresHostName: ''
    chePostgresPort: ''
    chePostgresUser: ''
    chePostgresPassword: ''
    chePostgresDb: ''
  auth:
    openShiftoAuth: true
    identityProviderImage: ''
    externalIdentityProvider: false
    identityProviderURL: ''
    identityProviderRealm: ''
    identityProviderClientId: ''
  storage:
    pvcStrategy: per-workspace
    pvcClaimSize: 1Gi
    preCreateSubPaths: true
  metrics:
    enable: true
```
```shell script
oc apply -f che-ephemeral-cr.yaml
```

### Access CRW GUI
```shell script
oc get routes -n codeready-workspaces
```
You should see 4 routes:
- codeready — is for connecting to the workspace
- devfile-registry
- keycloak
- plugin-registry

connect to the route named **codeready** using your browser
and login using your openshift credentials

## Setting up a Workspace (devfile)
Workspaces mimic the environment of a PC, an operating system, programming language support, the tools needed, and an editor. The real power comes by defining a workspace using a YAML file—a text file that can be stored and versioned in a source control system such as Git. This file, called devfile.yaml, is powerful and complex.

[Blog: CodeReady Workspaces devfile, demystified](https://developers.redhat.com/blog/2019/12/09/codeready-workspaces-devfile-demystified/)

