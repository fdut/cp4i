
oc create -f yaml/cp4i-navigator.yaml
oc create -f yaml/od-dev.yaml
oc create -f yaml/ar-dev.yaml 
oc create -f yaml/mq-dev.yaml
oc create -f yaml/ace-dev.yaml
oc create secret generic datapower-admin-credentials --from-literal=password=ThePa5sw0rdp10 -n apic
oc create -f yaml/apic.yaml
oc create -f yaml/es-dev.yaml 
oc create -f yaml/dsg-dev.yaml 