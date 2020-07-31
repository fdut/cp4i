# Modernization Existing Integration Stack

# Install  Cloud Pack for Integration 2020.2

Documentation available here : https://www.ibm.com/support/knowledgecenter/en/SSGT7J_20.2/welcome.html

## Prepare

- Create a OCP cluster: mini 5x 16cpu-32G
- Add IBM Common Services operators and IBM Cloud pack operators for online catalog
https://www.ibm.com/support/knowledgecenter/SSGT7J_20.2/install/install_online_catalog_sources.html



## Install IBM Common Services

https://cloudpak8s.io/common_services/cs_install/

With the current version, Common services (CS) needs to be installed on the same scope as the Platform Navigator (PN).
It seems that if PN is at NS scope, it will try to install another CS operator in its NS.

The **CS** is installed in all Namespaces scope.

CS operator needs to have the right to access the namespace where the CP4I software will be deployed.
If CS is at namespace scope, you will need to create an operator on each namespace. This is usually done when you create a CP4I capability. However the default behaviour of the capability (like ACE) is to create a CS at cluster level if it is not found. You will end with two CS, one at namespace and one at cluster level and possibly with two different versions !

- From the navigation pane, click **Operators** > **OperatorHub**. The OperatorHub page is displayed.

- In the All Items field, enter **IBM Common Service Operator**. The IBM Common Service Operator is displayed.

- Click the **IBM Common Service Operator** tile. The IBM Common Service Operator window is displayed.
- Click on the operator and **install**
- Use default value
  - scope = **all namespaces**
  - version: **stable-v1**
  - Approval: automatic

- Click **Subscribe**

Subscribe means that an operator will be created and OLM will monitor for new versions.

Two operators are created 
- IBM Common Service Operator
- Operand Deployment Life Cycle Manager

IBM Common Service Operator
APIs: **CommonService**

Operand Deployment Life Cycle Manager
APIs:
- OperandBindInfo
- OperandConfig
- OperandRegistry
- OperandRequest

The custom service definition of the two operators are deployed in all namespaces.
`oc get csv -n default `

```
NAME                                          DISPLAY                                VERSION   REPLACES   PHASE
ibm-common-service-operator.v3.4.3            IBM Common Service Operator            3.4.3                Succeeded
operand-deployment-lifecycle-manager.v1.2.3   Operand Deployment Lifecycle Manager   1.2.3                Succeeded
```

The operator ICSO creates the ODLM in all namespaces and creates ODLM CR that will be used to install common services:
- an OperandConfig CR with default the common services config
- an OperandRegistry CR with default values

The operator creates a namespace **ibm-common-services** with 
- two pods
  - webhook
  - secretshare
- CR 
  - one default OperandConfig **common-service**: defines specific parameters for the CS components that will be created
  - one default OperandRegistry **common-service**: defines what operators should be used to execute the operandRequest.


### Customizing the CS installation :


- From the Project drop-down list, select the **ibm-common-services namespace**. You see the **Operand Deployment Lifecycle Manager Operator**.

- Click the **OperandConfig** and then select the existing common-services OperandConfig. S

- Select the YAML Tab.

Add the following parameters to the ibm-iam-operator.spec.authentication.config section.

```
  authentication:
  replicas: 3
  config:
    roksEnabled: true
    roksURL: 'https://<openshift_server_endpoint'
    roksUserPrefix: 'IAM#'

```

For example :

```
 authentication: 
          replicas: 3
          config:
            roksEnabled: true
            roksURL: 'https://c101-e.eu-de.containers.cloud.ibm.com:32207'
            roksUserPrefix: 'IAM#'
        securityonboarding: {}
```
- ** Save **
- Select the **OperandRequest** tab and click Create Operand Request. Paste the following content in the YAML editor (overwrite the existing content):

```
apiVersion: operator.ibm.com/v1alpha1
kind: OperandRequest
metadata:
  labels:
    app.kubernetes.io/instance: operand-deployment-lifecycle-manager
    app.kubernetes.io/managed-by: operand-deployment-lifecycle-manager
    app.kubernetes.io/name: odlm
  name: common-service
  namespace: ibm-common-services
spec:
  requests:
    - operands:
        - name: ibm-cert-manager-operator
        - name: ibm-mongodb-operator
        - name: ibm-iam-operator
        - name: ibm-monitoring-exporters-operator
        - name: ibm-monitoring-prometheusext-operator
        - name: ibm-monitoring-grafana-operator
        - name: ibm-healthcheck-operator
        - name: ibm-management-ingress-operator
        - name: ibm-licensing-operator
        - name: ibm-metering-operator
        - name: ibm-commonui-operator
        - name: ibm-ingress-nginx-operator
        - name: ibm-auditlogging-operator
        - name: ibm-platform-api-operator
        - name: ibm-helm-api-operator
        - name: ibm-helm-repo-operator
        - name: ibm-catalog-ui-operator
      registry: common-service
```

- Click **Create**

Wait 12 min and 66 pods are running

```
oc get po -n ibm-common-services
NAME                                                     READY   STATUS      RESTARTS   AGE
alertmanager-ibm-monitoring-alertmanager-0               3/3     Running     0          9m59s
audit-logging-fluentd-ds-8vcp6                           1/1     Running     0          11m
audit-logging-fluentd-ds-f46wx                           1/1     Running     0          11m
audit-logging-fluentd-ds-xhdzs                           1/1     Running     0          11m
audit-policy-controller-848ff87d4c-fnbbg                 1/1     Running     0          11m
auth-idp-74bf7d9bdb-8bxrj                                4/4     Running     0          8m37s
auth-idp-74bf7d9bdb-ctcgf                                4/4     Running     0          8m37s
auth-idp-74bf7d9bdb-km82w                                4/4     Running     0          8m37s
auth-pap-77dd56bdbf-mhqtn                                2/2     Running     0          8m58s
auth-pdp-84d9f69b4b-xl4fb                                2/2     Running     0          8m59s
catalog-ui-557787bffd-cnb85                              1/1     Running     0          11m
cert-manager-cainjector-54774d6bf5-fcb5d                 1/1     Running     0          12m
cert-manager-controller-5dffff5cb7-n9t8z                 1/1     Running     0          12m
cert-manager-webhook-8b6d4bbcd-k5tf2                     1/1     Running     0          12m
common-web-ui-8spgc                                      1/1     Running     0          11m
common-web-ui-dd7r4                                      1/1     Running     0          11m
common-web-ui-dwg6v                                      1/1     Running     1          11m
configmap-watcher-fc55ff478-ft8d4                        1/1     Running     0          12m
default-http-backend-cff9967f6-z74mg                     1/1     Running     0          11m
helm-api-777b986fd7-qnd5t                                2/2     Running     0          11m
helm-repo-b9b45994-848l9                                 1/1     Running     0          11m
iam-onboarding-pbkbf                                     0/1     Completed   0          8m56s
iam-policy-controller-7bf656d5c6-75q7x                   1/1     Running     0          9m2s
ibm-auditlogging-operator-b95d6c465-tgmlv                1/1     Running     0          12m
ibm-catalog-ui-operator-ff4c567-6wh8h                    1/1     Running     0          12m
ibm-cert-manager-operator-7474446655-sp9xm               1/1     Running     0          13m
ibm-common-service-webhook-7d94655cd4-s5dxd              1/1     Running     1          27m
ibm-commonui-operator-6fdbcd6459-lln4r                   1/1     Running     0          11m
ibm-healthcheck-operator-794bbfd9ff-h6bdb                1/1     Running     0          11m
ibm-helm-api-operator-54b447cf7d-725rh                   1/1     Running     0          11m
ibm-helm-repo-operator-6ffdd7bcd8-fqrcn                  1/1     Running     0          12m
ibm-iam-operator-cc45f8d7f-j8886                         1/1     Running     0          11m
ibm-ingress-nginx-operator-97db7564c-vzkrf               1/1     Running     0          12m
ibm-licensing-operator-756674f8f8-8kgp4                  1/1     Running     0          12m
ibm-licensing-service-instance-6bd9d6d795-d89xk          1/1     Running     0          11m
ibm-management-ingress-operator-7cc767566f-bxtm2         1/1     Running     0          12m
ibm-metering-operator-6b49cfcf9f-rxrb4                   1/1     Running     0          12m
ibm-mongodb-operator-d49c9c76c-64k6r                     1/1     Running     0          12m
ibm-monitoring-collectd-694dd7868-rj69r                  2/2     Running     0          11m
ibm-monitoring-exporters-operator-7dfbd75b9f-gbbs2       1/1     Running     0          11m
ibm-monitoring-grafana-7cbc65885f-4llj2                  3/3     Running     0          11m
ibm-monitoring-grafana-operator-7f44d69449-l79ms         1/1     Running     0          11m
ibm-monitoring-kube-state-6f588b8dfd-7pfhr               2/2     Running     0          11m
ibm-monitoring-mcm-ctl-84d879cdcd-6qn66                  1/1     Running     0          11m
ibm-monitoring-nodeexporter-jnbzm                        2/2     Running     0          11m
ibm-monitoring-nodeexporter-k4dmr                        2/2     Running     0          11m
ibm-monitoring-nodeexporter-rcw58                        2/2     Running     0          11m
ibm-monitoring-prometheus-operator-6bbb48d8cb-qmw4z      1/1     Running     0          11m
ibm-monitoring-prometheus-operator-ext-755b69dcc-ktwwk   1/1     Running     0          12m
ibm-platform-api-operator-6c47894c4f-v6phq               1/1     Running     0          12m
icp-memcached-7f5589d655-z7p8l                           1/1     Running     0          11m
icp-mongodb-0                                            2/2     Running     0          11m
icp-mongodb-1                                            2/2     Running     0          8m3s
icp-mongodb-2                                            2/2     Running     0          3m33s
management-ingress-8546c9d4b9-bhdxr                      1/1     Running     0          11m
metering-dm-59b56849bc-tbxgn                             1/1     Running     0          11m
metering-reader-5bdf844bb5-2wwff                         1/1     Running     0          11m
metering-report-6799d4f485-t6p8l                         1/1     Running     0          11m
metering-ui-69cd56dbb-pnl8x                              1/1     Running     0          11m
nginx-ingress-controller-786c58dfbf-4hf6m                1/1     Running     0          11m
oidc-client-registration-nclzv                           0/1     Completed   0          8m52s
oidcclient-watcher-b99fdf987-mvw4s                       1/1     Running     0          9m2s
platform-api-5df5db76f8-wqggx                            2/2     Running     0          11m
prometheus-ibm-monitoring-prometheus-0                   4/4     Running     1          9m57s
secret-watcher-84fb694fc7-h4z5n                          1/1     Running     0          9m3s
secretshare-5b6dd4c5df-gnrc4                             2/2     Running     0          27m
security-onboarding-svh7k                                0/1     Completed   0          8m59s
system-healthcheck-service-84ff95b7cf-q85tz              1/1     Running     0          11m
tiller-deploy-8659b8f7c6-m5dm7                           1/1     Running     0          11m
```


```
oc -n ibm-common-services get csv
NAME                                            DISPLAY                                        VERSION   REPLACES   PHASE
ibm-auditlogging-operator.v3.6.2                IBM Audit Logging Operator                     3.6.2                Succeeded
ibm-catalog-ui-operator.v3.6.1                  IBM Catalog UI Operator                        3.6.1                Succeeded
ibm-cert-manager-operator.v3.6.3                IBM Cert Manager Operator                      3.6.3                Succeeded
ibm-common-service-operator.v3.4.3              IBM Common Service Operator                    3.4.3                Succeeded
ibm-commonui-operator.v1.2.4                    Ibm Common UI Operator                         1.2.4                Succeeded
ibm-healthcheck-operator.v3.6.1                 IBM Health Check Operator                      3.6.1                Succeeded
ibm-helm-api-operator.v3.6.1                    IBM Helm API Operator                          3.6.1                Succeeded
ibm-helm-repo-operator.v3.6.2                   IBM Helm Repo Operator                         3.6.2                Succeeded
ibm-iam-operator.v3.6.5                         IBM IAM Operator                               3.6.5                Succeeded
ibm-ingress-nginx-operator.v1.2.3               IBM Ingress Nginx Operator                     1.2.3                Succeeded
ibm-licensing-operator.v1.1.3                   IBM Licensing Operator                         1.1.3                Succeeded
ibm-management-ingress-operator.v1.2.1          Management Ingress Operator                    1.2.1                Succeeded
ibm-metering-operator.v3.6.3                    IBM Metering Operator                          3.6.3                Succeeded
ibm-mongodb-operator.v1.1.3                     IBM Mongodb Operator                           1.1.3                Succeeded
ibm-monitoring-exporters-operator.v1.9.1        IBM Monitoring Exporters Operator              1.9.1                Succeeded
ibm-monitoring-grafana-operator.v1.9.2          IBM Monitoring Grafana Operator                1.9.2                Succeeded
ibm-monitoring-prometheus-operator-ext.v1.9.1   IBM Monitoring Prometheus Extension Operator   1.9.1                Succeeded
ibm-platform-api-operator.v3.6.2                IBM Platform API Operator                      3.6.2                Succeeded
operand-deployment-lifecycle-manager.v1.2.3     Operand Deployment Lifecycle Manager           1.2.3                Succeeded
```

- Login to console

Retrieve Console Endpoint :

`oc get route -n ibm-common-services cp-console -o jsonpath=‘{.spec.host}`

‘cp-console.mvp-par01-01-103ddb1cc6249867b4ed037d4a50c9fb-0000.par01.containers.appdomain.cloud'

Retrieve password :

`oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 --decode`


Use default Authentication with : **admin** / `the_password_you_retrieve_before`


## Install IBM Cloud Pak for Integration Platform Navigator
https://cloudpak8s.io/integration/cp4i-install-latest/#adding-the-platform-navigator

- In **OperatorHub**, search `IBM Cloud Pak for Integration Platform Navigator`
- Click `IBM Cloud Pak for Integration Platform Navigator` icon
- Click `Install`
- Installation mode : **All namespaces on the cluster (default)**

In our case we will accept all of the defaults and Subscribe to the operator. In a few moments this operator will appear under the Installed Operators for all projects.

- Click **Subscribe** (wait 2min)

```
oc get po -n openshift-operators -w
NAME                                                    READY   STATUS    RESTARTS   AGE
ibm-common-service-operator-78d7dcdd74-4f6ms            1/1     Running   0          52m
ibm-integration-platform-navigator-75c694c8bf-7fhbc     1/1     Running   0          102s
operand-deployment-lifecycle-manager-5dcbdfccdb-kdn4p   1/1     Running   0          51m
```

### Create Platform Navigator instance

- Create NameSpace for Platform Navigator (For example : cp4i)

  `oc new-project cp4i`

- Log in to MyIBM Container Software Library ( https://myibm.ibm.com/products-services/containerlibrary ) with the IBM ID and password that are associated with the entitled software. In the Entitlement Keys section, copy the entitlement key. This key will be used in future steps.
- Create the secret in the new project to hold the entitlement key

  `oc create secret -n <namespace> docker-registry ibm-entitlement-key --docker-server=cp.icr.io --docker-username=cp --docker-password=<your IBM Entitled registry key>`

  For example : 
  `oc create secret -n cp4i docker-registry ibm-entitlement-key --docker-server=cp.icr.io --docker-username=cp --docker-password=XXXXXXXXXX.XXXXXXXWFya2V0cGxhY2UiLCJpYXQiOjE1ODAyMDcwOTMsImp0aSI6ImM1NTY1MTcyNmY3OTQ5ZmE4MTE5MDZhOWRjMDYyMjkxIns-FqWzomsEZQ`

- Navigate to the **OCP Administrative UI** - Installed Operators from within your prepared project `cp4i`
- Open the **IBM Cloud Pak for Integration Platform Navigator** operator. From the Details tab choose `Create Instance`
- The Create PlatformNavigator YAML allows for configuration of the instance. The only required change is to accept the license agreement by changing `false` to `true`. (Other changes can be made here such as namespace or the name of the deployment or replica)

```
apiVersion: integration.ibm.com/v1beta1
kind: PlatformNavigator
metadata:
  name: cp4i-navigator
  namespace: cp4i
spec:
  license:
    accept: true
  mqDashboard: true
  replicas: 3
  version: 2020.2.1
```
- Click `Create`
- Check Events in the Platform Navigator namespace

>The Platform Navigator is deployed to your cp4i project. If you didn’t pre-deploy the IBM Common Services, the Platform Navigator operator would have done this deployment using defaults for you. In fact, it will check for all the required services and add any that may have been omitted and deploy them. The deployment may take a few minutes as the images that are required must be downloaded from the public registry.
```
oc -n cp4i get po
NAME                                                              READY   STATUS    RESTARTS   AGE
cp4i-navigator-ibm-integration-platform-navigator-deploymeg47l7   2/2     Running   0          5m16s
cp4i-navigator-ibm-integration-platform-navigator-deploymetrz4w   2/2     Running   0          5m16s
cp4i-navigator-ibm-integration-platform-navigator-deploymezpscx   2/2     Running   0          5m16s
```

```
oc get PlatformNavigator
NAME             REPLICAS   VERSION      READY   LASTUPDATE   AGE
cp4i-navigator   3          2020.2.1-0   True    7s           3m12s
```

- Once deployed you can find the URL for your Platform Navigator from within the Installed Operators interface. Navigate to the Platform Navigator tab within the Platform Navigator Operator and open the deployed instance and find the link under Platform Navigator UI.


- You can log into the Cloud Pak UI using the admin secret that was created by that operator. Find the secret by running:

  `oc get secrets -n ibm-common-services platform-auth-idp-credentials -ojsonpath='{.data.admin_password}' | base64 --decode && echo "" `




# Cloud Pack for Integration instance installation

## Install the different CP4I operators

Prereq
- PN is installed
- CS is installed 

Install the following operators with scope set at the same level as the CS : **all namespaces**.

- Navigate in the openshift console to the operator hub and search for the operator
- Create a subscription at scope level set to **all namespaces**

Operators:
- AppConnect Enterprise: *IBM App Connect*  
  You might for this operator look at the detailed installation section
- Operational dashboard:  *IBM Cloud Pak for Integration Operations Dashboard*
- Datapower: *IBM DataPower Gateway*
- API Connect: *IBM API Connect*
- MQ: *IBM MQ*.
- Aspera: *IBM Aspera HSTS*

### ACE operator

- Open the openshit console
- Navigate to the **operator hub** 
- search for **App Connect operator** 
- create a subscription for **all namespaces** scope 
- leave the rest as default

The installation will install 
- two CSV in all namespace (if operator scope was all ns)
  - couchdb
  - ibm-appconnect
- two operator in openshift-operators (if operator scope was all ns) defined by the two CSV.

The provided APIs are
- Integration Server Configuration
- App Connect Dashboard
- App Connect Designer Authoring
- App Connect Integration Server
- App Connect Switch Server

You might for example been able to call when integration servers are deployed
```
oc get integrationserver
```

### MQ Operator

Install Operator IBM MQ (Cluster scoped : all namespaces)
Subscribe with default entries (All namespaces on the cluster (default) , Update Channel: v1.1, Approval Strategy: Automatic)

> If When the operator is deployed, the operator pod can be left in state **CrashLoopBackOff**.

>The operator is created with a network policies that is not correct.
The operator pod readiness is expecting to be reached at a specific port.
The network policy restrict ingress call.

>Get the MQ network policy:
>```
>oc get networkpolicies | grep mq
>```

>Edit the networkpolicy:
>```
>oc edit networkpolicies ibm-mq 
>```
>remove
>- the egress spec
>- the egress policytype sped

>MQ networkpolicy created by default:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ibm-mq
  namespace: openshift-operators
  ownerReferences:
  - apiVersion: apps/v1
    blockOwnerDeletion: false
    controller: true
    kind: Deployment
    name: ibm-mq
    uid: e25b6bbd-9c61-49f5-b273-894332bca512
spec:
  egress:
  - to:
    - namespaceSelector: {}
      podSelector:
        matchLabels:
          apiserver: "true"
  ingress:
  - from:
    - namespaceSelector: {}
    ports:
    - port: 8443
      protocol: TCP
  podSelector:
    matchLabels:
      name: ibm-mq
  policyTypes:
  - Ingress
  - Egress

```

### Aspera operator installation

The Exit code 137 is important because it means that the system terminated the container as it tried to use more memory than its limit.

Aspera install the redis operator but set a bad value for the memory limit.

Update the redis mem limit:
```
oc get deploy | grep redis
```
Then edit
```
oc edit deploy ibm-cloud-databases-redis-operator
```
Set in the memory container spec:
```yaml
        name: ibm-cloud-databases-redis-operator
        resources:
          limits:
            cpu: 100m
            memory: 1G
          requests:
            cpu: 100m
            memory: 128M
```



```
 oc get po -n openshift-operators -w
NAME                                                    READY   STATUS    RESTARTS   AGE
couchdb-operator-6655cd4c9b-5cgc8                       1/1     Running   0          43m
datapower-operator-5db55bc5c9-nfrdf                     1/1     Running   0          23m
ibm-apiconnect-8479fdb9b4-4sqz6                         1/1     Running   1          23m
ibm-appconnect-7b6fffb5fd-ntdbf                         1/1     Running   0          43m
ibm-common-service-operator-78d7dcdd74-4f6ms            1/1     Running   0          169m
ibm-integration-platform-navigator-75c694c8bf-7fhbc     1/1     Running   0          119m
ibm-mq-78cb74d595-rrnqj                                 1/1     Running   0          2m14s
operand-deployment-lifecycle-manager-5dcbdfccdb-kdn4p   1/1     Running   0          169m
```

## Create Cloud Pack for Integration instances
For each instance you will need to create a secret for the IBM entitlement key.
Please ref. to the entitlement key section.

## APIC Instance

- namespace where to install (`oc new-project apic`)
- A secret that hold a valid entitlement key (refer to the ibm entitlement key section) to get the images
  you might copy the key from another ns like for example:
  ```
  oc get secret ibm-entitlement-key -n cp4i -o yaml | sed 's/cp4i/apic/g' | oc create -n apic -f -
  ```

- Installation can be done using default values.
The only required parameters that need to be provided are:
- namespace where to install

	- accept the license 
	- If it has to be production or non-production
	- the name of your deployment : **apicv10**
	- deployment profile : **n1xc4.m16** for dev instead n3xc4.m16

- By default the native gateway will be installed.


>If Issue:  apicv10-a7s-mtls-gw-66f66f74-g668s  **CrashLoopBackOff**
>
>2020/07/22 11:05:22 [emerg] 1#1: could not build server_names_hash, you should increase server_names_hash_bucket_size: 128
>nginx: [emerg] could not build server_names_hash, you should increase server_names_hash_bucket_size: 128
>
>Update configmaps **apicv10-a7s-mtls-gw**
>```
>   ...
>    http {
>      client_max_body_size 768M;
>      client_body_buffer_size 128M;
>      server_names_hash_bucket_size 256;
>      server_names_hash_max_size 512;
> ```

- List all endpoints

	`oc get route -n apic`

```
NAME                          HOST/PORT                                                                                                              PATH   SERVICES                   PORT   TERMINATION          WILDCARD
apicv10-a7s-ac-endpoint       apicv10-a7s-ac-endpoint-apic.mvp-par01-02-103ddb1cc6249867b4ed037d4a50c9fb-0000.par01.containers.appdomain.cloud              apicv10-a7s-mtls-gw        4443   passthrough          None
apicv10-a7s-ai-endpoint       apicv10-a7s-ai-endpoint-apic.mvp-par01-02-103ddb1cc6249867b4ed037d4a50c9fb-0000.par01.containers.appdomain.cloud              apicv10-a7s-mtls-gw        4443   passthrough          None
apicv10-gw-gateway            apicv10-gw-gateway-apic.mvp-par01-02-103ddb1cc6249867b4ed037d4a50c9fb-0000.par01.containers.appdomain.cloud                   apicv10-gw-datapower       9443   passthrough          None
apicv10-gw-gateway-manager    apicv10-gw-gateway-manager-apic.mvp-par01-02-103ddb1cc6249867b4ed037d4a50c9fb-0000.par01.containers.appdomain.cloud           apicv10-gw-datapower       3000   passthrough          None
apicv10-mgmt-admin            apicv10-mgmt-admin-apic.mvp-par01-02-103ddb1cc6249867b4ed037d4a50c9fb-0000.par01.containers.appdomain.cloud                   apicv10-mgmt-juhu          2005   reencrypt/Redirect   None
apicv10-mgmt-api-manager      apicv10-mgmt-api-manager-apic.mvp-par01-02-103ddb1cc6249867b4ed037d4a50c9fb-0000.par01.containers.appdomain.cloud             apicv10-mgmt-juhu          2006   reencrypt/Redirect   None
apicv10-mgmt-consumer-api     apicv10-mgmt-consumer-api-apic.mvp-par01-02-103ddb1cc6249867b4ed037d4a50c9fb-0000.par01.containers.appdomain.cloud            apicv10-mgmt-juhu          2001   reencrypt/Redirect   None
apicv10-mgmt-platform-api     apicv10-mgmt-platform-api-apic.mvp-par01-02-103ddb1cc6249867b4ed037d4a50c9fb-0000.par01.containers.appdomain.cloud            apicv10-mgmt-juhu          2000   reencrypt/Redirect   None
apicv10-ptl-portal-director   apicv10-ptl-portal-director-apic.mvp-par01-02-103ddb1cc6249867b4ed037d4a50c9fb-0000.par01.containers.appdomain.cloud          apicv10-ptl-nginx          4443   passthrough          None
apicv10-ptl-portal-web        apicv10-ptl-portal-web-apic.mvp-par01-02-103ddb1cc6249867b4ed037d4a50c9fb-0000.par01.containers.appdomain.cloud               apicv10-ptl-f959979c-www   4443   reencrypt/Redirect   None
```

So the API Connect Cloud Manager is available at this url : https://apicv10-mgmt-admin-apic.mvp-par01-02-103ddb1cc6249867b4ed037d4a50c9fb-0000.par01.containers.appdomain.cloud

### APIC Cloud setup
To setup of the APIC Cloud is already setup with all ell components (Gateway, Manager, Analytics, Portal) and fake email Server

You need to change the email server with your own.




## ACE dashboard Instances


- PN is installed (with CS)
- App Connect operator is installed 
- A namespace to hold the dashboard (f.e. ace). This is optional, you might install it on the cp4i ns.

  `oc new-project ace`
 
- A secret that hold a valid entitlement key (refer to the ibm entitlement key section) to get the images
  you might copy the key from another ns like for example:

  `oc get secret ibm-entitlement-key -n cp4i -o yaml | sed 's/cp4i/ace/g' | oc create -n ace -f -`
  
- Persistent file storage.  
  You might get the list of storage class using **oc get sc**
  For the dashboard the bronze will be used: *ibmc-file-bronze-gid*
  > Note that you need to have a **gid** type of storage. The non-gid one is owned by root which means you can't write to it without being root

- Navigate to the PN 
- Select capability
- Create a new AppConnect Dashboard capability
  You should see the following UI:
  ![](./img/ace_dash_cap.png)  
  If you don't see such dashboard this means that the ACE operator is not installed.

- Select quick start
- Configuration
  - Name: acedb
  - Namespace: ace
  - Accept the license and leave the default for the license
  - For the storage class provide: **ibmc-file-gold-gid** and storage type to persistent-claim

```
apiVersion: appconnect.ibm.com/v1beta1
kind: Dashboard
metadata:
  name: acedb
  namespace: ace
spec:
  license:
    accept: true
    license: L-AMYG-BQ2E4U
    use: CloudPakForIntegrationNonProduction
  replicas: 1
  storage:
    class: ibmc-file-gold-gid
    type: persistent-claim
  useCommonServices: true
  version: 11.0.0
```

Status of the creation can be get using:
```
oc get dashboard
NAME            RESOLVEDVERSION   REPLICAS   CUSTOMIMAGES   STATUS    URL       AGE
acedb   11.0.0.9-r2       1          false          Pending             17s
```

The creation might take some time as a storage need to be created.

## ACE Designer

- PN is installed (with CS)
- App Connect operator is installed 
- Using the same namespace of ACE Dashboard

- Navigate to the PN 
- Select capability
- Create a new AppConnect Designer capability
  You should see the following UI:
  ![](./img/ace_dash_cap.png)  
  If you don't see such dashboard this means that the ACE operator is not installed.

- Select quick start
- Configuration
	- Name: acedesigner
	- Namespace: ace
	- Connector: local
	- Storage: **ibmc-file-gold-gid**
	- Accept the license and leave the default for the license
	- For the storage class provide: **ibmc-file-gold-gid** and storage type to persistent-claim


## MQ Instance

- PN is installed (with CS)
- MQ operator is installed 
- A namespace to hold the dashboard (f.e. mq). This is optional, you might install it on the cp4i ns.
  ```
  oc new-project mq
  ```
- A secret that hold a valid entitlement key (refer to the ibm entitlement key section) to get the images
  you might copy the key from another ns like for example:
  ```
  oc get secret ibm-entitlement-key -n cp4i -o yaml | sed 's/cp4i/mq/g' | oc create -n mq -f -
  ```
- Accept License
- If you have Operational Dashboard (OD) installed, you can active tracing and namespace of the Operational Dashboard instance. You need also approve tracing request in OD menu **Manage / Registration Request**



## EventStream (Kafka) Instance

- PN is installed (with CS)
- EventStream operator is installed 
- A namespace to hold the dashboard (f.e. eventstream). This is optional, you might install it on the cp4i ns.
  ```
  oc new-project eventstream
  ```
- A secret that hold a valid entitlement key (refer to the ibm entitlement key section) to get the images
  you might copy the key from another ns like for example:
  ```
  oc get secret ibm-entitlement-key -n cp4i -o yaml | sed 's/cp4i/eventstream/g' | oc create -n eventstream -f -
  ```

In PN console 

- Type profile : Dev
- Name : es-dev
- Namespace : evenstream


## Operations Dashboard Instance

- IBM CS is installed (All namespace scoped)
- IBM Cloud Pak for Integration Operations Dashboard operator installed ( cluster scope )

- A namespace to hold the Operational Dashboard

`oc new-project od --description="Operation Dashboard" --display-name="Operation Dashboard"`

- A secret that hold a valid entitlement key (refer to the ibm entitlement key section) to get the images
  
  you might copy the key from another ns like for example:
  ```
  oc get secret ibm-entitlement-key -n cp4i -o yaml | sed 's/cp4i/od/g' | oc create -n od -f -
  ```

- In CloudPack Platform Navigator > **Create Capability**
- Click **Operation Dashboard**
- Select the option available 


- name : **od1**
- namespace : **od**
- Config DB storage class name : (IBM Cloud) **ibmc-block-bronze**
- Change or not stockage value
- Store storage class name : (IBM Cloud)  **ibmc-block-gold**
- Change or not stockage value



# ibm entitlement key

**Create the key**
- login to [ MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary)
- copy the key
- execute
```
oc create secret docker-registry ibm-entitlement-key --docker-username=cp --docker-password=<entitlement-key> --docker-server=cp.icr.io --namespace=<yourNs>
```

**Copy a secret / key**
You may want to copy a secret that has already been created in another namespace to a new namespace.
Here is the command for the secret *ibm-entitlement-key* :
```
oc get secret ibm-entitlement-key -n <OriginNs> -o yaml | sed 's/<OriginNs>/<TargetNs>/g' | oc create -n <targetNs> -f -
```


# Install & Configure OpenLDAP

>Note: those instructions are based on recipe https://developer.ibm.com/recipes/tutorials/configuring-openldap-with-cloud-pak-for-integration-2019-4/ adapted for using local OpenShift registry



Get openldap

- Download openldap image from git

$ git clone https://github.com/jdiggity22/openldap.git

This should create a directory called openldap and create the content within it.
Create required users and groups

- Change directory to openldap/bootstrap/ldif

$ cd openldap/bootstrap/ldif

- Edit the openldap-default.ldif file

$vi openldap-default.ldif

Edit the ldif file to create users and groups as per your requirements

Navigate to the base folder and run makefile to build a docker image
```
cd ../.
make    
```
Verify
```
docker images | grep openldap
```

In your we are using IBM Cloud registry


## Push the image to IBM Cloud container Registry

Login to IBM Cloud

`ibmcloud login`

 Check if there are namespace that exist

`ibmcloud cr namespace-list`

If no suitable namespace exists, create a namespace to push the image

Also note down the registry of the format “de.icr.io”

`ibmcloud cr namespace-add cp4i`

Tag the image

Remember to substitute the registry name as per the output in the previous step

$ docker tag osixia/extend-osixia-openldap:0.1.0 de.icr.io/cp4i/openldap:1.0.0

Login to the IBMCloud conainer registry

$ ibmcloud cr login

Push the docker image

$ docker push de.icr.io/cp4i/openldap:1.0.0



- Create openldap project

`oc new-project openldap`

- Apply security setting for the project

`oc adm policy add-scc-to-group anyuid system:serviceaccounts:openldap`

- Add ibm registry secret

`oc create secret docker-registry default-de-icr-io --docker-server=de.icr.io --docker-username=iamapikey --docker-password=API_KEY --docker-email=frederic_dutheil@fr.ibm.com -n openldap`

(more information to create API_KEY available here: https://cloud.ibm.com/docs/Registry?topic=Registry-registry_access#registry_access_user_apikey)

- Prepare `openldap.yaml` file with Deployment and Service definition

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
 name: openldap
 namespace: openldap
 labels:
   app: openldap
spec:
  replicas: 1
  selector:
    matchLabels:
      app: openldap
  template:
   metadata:
     labels:
       app: openldap
   spec:
     imagePullSecrets:
       - name: default-de-icr-io
     containers:
       - image: de.icr.io/cp4i-ldap/openldap:1.0.0
         imagePullPolicy: Always
         name: openldap
         ports:
           - containerPort: 389
             protocol: TCP
---
apiVersion: v1
kind: Service
metadata:
 labels:
   app: openldap
 name: ldap-service
spec:
 ports:
   - name: openldap
     port: 389
 selector:
   app: openldap

```

- And apply it

`oc create -f openldap.yaml`

Check the service IP address and port.
This information will be needed for the "Cloud Pak Foundation" setup.

`oc describe svc ldap-service`

The result will look similar to this:
```
Name:              ldap-service
Namespace:         openldap
Labels:            app=openldap
Annotations:       <none>
Selector:          app=openldap
Type:              ClusterIP
IP:                172.30.241.184
Port:              openldap  389/TCP
TargetPort:        389/TCP
Endpoints:         10.128.4.24:389
Session Affinity:  None
Events:            <none>    
```
Note the *Endpoints* property. In this case the value is 10.128.4.24:389, in your case it will be different.

### Setup "Cloud Pak Foundation" LDAP

- Open the Cloud Pak Navigator

- Click on the menu and select "Cloud Pak Foundation".
Authentication page with "No LDAP connection found" message appears.
Click on the **Create Connection** button.

Enter the following values:
* Connection name: `LocalOpenLDAP`
* Server Type: `Custom`
* Base DN: `dc=corporate,dc=com`
* Bind DN: `cn=admin,dc=corporate,dc=com`
* Bind DN password: `Passw0rd`
* URL: `ldap://10.128.4.24:389`, (The url you have determined in the previous step. In your case it will be different)
* Group filter: `(&(cn=%v)(objectclass=groupOfUniqueNames))`
* User filter: `(&(uid=%v)(objectclass=inetOrgPerson))`
* Group ID map: `*:cn`
* User ID map: `*:uid`
* Group member ID map: `groupOfUniqueNames:uniqueMember`

- Click on **Test connection**
- Click on **Create** button to save the configuration.


