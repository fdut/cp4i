
CURRENT_ENV=dev
REGISTRY_KEY=eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1ODAyMDcwOTMsImp0aSI6ImM1NTY1MTcyNmY3OTQ5ZmE4MTE5MDZhOWRjMDYyMjkxIn0.WTHhUJPB-qfoaZ8BwaGd6aiXpsXoBFSs-FqWzomsEZQ

prepare_project () {
        echo "Create project $1"
        oc new-project $1
        oc create secret -n $1 docker-registry ibm-entitlement-key --docker-server=cp.icr.io --docker-username=cp --docker-password=$REGISTRY_KEY
    }

# ES
prepare_project es-$CURRENT_ENV
exit


# Datapower
prepare_project dp-$CURRENT_ENV
exit

# DESIGNER
prepare_project ace-$CURRENT_ENV

# CP4i
prepare_project cp4i

# OD
prepare_project od-$CURRENT_ENV

# APIC
prepare_project apic-$CURRENT_ENV

# ACE 
prepare_project ace-$CURRENT_ENV

# DESIGNER
prepare_project dsg-$CURRENT_ENV

# MQ
prepare_project mq-$CURRENT_ENV

# ES
prepare_project es-$CURRENT_ENV

# AR
prepare_project ar-$CURRENT_ENV