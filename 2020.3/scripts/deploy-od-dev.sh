NAMESPACE=od-dev

oc new-project $NAMESPACE

oc get secret ibm-entitlement-key -n cp4i -o yaml | sed 's/\$NAMESPACE/od-dev/g' | oc create -n $NAMESPACE -f -

oc create -f yaml/$NAMESPACE.yaml