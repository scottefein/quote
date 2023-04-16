#!/usr/bin/env bash
humanitec_wait_for_deployment () {
    echo "Attempting to deploy: $HUMANITEC_ORG/$HUMANITEC_APP/$HUMANITEC_ENVIRONMENT/$WORKLOAD/$DEPLOYMENT_ID"
    while :
    do
        sleep 10
        curl $HUMANITEC_URL/orgs/$HUMANITEC_ORG/apps/$HUMANITEC_APP/envs/$HUMANITEC_ENVIRONMENT/deploys -H "Authorization: Bearer $HUMANITEC_TOKEN" -o /tmp/deploys.json -s -k
        DEPLOYMENT_STATUS=`cat /tmp/deploys.json | jq '.[0]["status"]' -r`
        DEPLOYMENT_ID=`cat /tmp/deploys.json | jq '.[0]["id"]' -r`
        if [[ $DEPLOYMENT_STATUS == "failed" ]]
        then
            echo "DEPLOYMENT ERROR: $HUMANITEC_ORG/$HUMANITEC_APP/$HUMANITEC_ENVIRONMENT/$WORKLOAD/$DEPLOYMENT_ID"
       
            humanitec_rollback

            exit 1
        fi
        if [[ $DEPLOYMENT_STATUS == "succeeded" ]]
        then
            echo "DEPLOYMENT OK: $HUMANITEC_ORG/$HUMANITEC_APP/$HUMANITEC_ENVIRONMENT/$WORKLOAD/$DEPLOYMENT_ID"
            DEPLOYMENT_ID=""
            break
        fi
        echo $DEPLOYMENT_STATUS
    done
}

humanitec_rollback() {
    echo "Trying to rollback to a successful deployment..."

    curl $HUMANITEC_URL/orgs/$HUMANITEC_ORG/apps/$HUMANITEC_APP/envs/$HUMANITEC_ENVIRONMENT/deploys -H "Authorization: Bearer $HUMANITEC_TOKEN" -o /tmp/deploys.json -s -k

    DEPLOYMENT_ID=`cat /tmp/deploys.json | jq -c 'map( select( .status == "succeeded" ) ) | .[0]["id"]' -r`
    DELTA_ID=`cat /tmp/deploys.json | jq -c 'map( select( .status == "succeeded" ) ) | .[0]["delta_id"]' -r`
    COMMENT=`cat /tmp/deploys.json | jq -c 'map( select( .status == "succeeded" ) ) | .[0]["comment"]' -r`
    CREATED_AT=`cat /tmp/deploys.json | jq -c 'map( select( .status == "succeeded" ) ) | .[0]["created_at"]' -r`
    ENV_ID=`cat /tmp/deploys.json | jq -c 'map( select( .status == "succeeded" ) ) | .[0]["env_id"]' -r`

    if [[ $DEPLOYMENT_ID  == "null" ]]
    then
        echo "Could not found a successful deployment - doing nothing."
    else
        echo "Found a successful deployment: $DEPLOYMENT_ID, rollback requested."
cat <<-EOF > /tmp/rollback.json
{
"comment": "Rollback to $DEPLOYMENT_ID, $COMMENT, $CREATED_AT",
"delta_id": "$DELTA_ID"
}
EOF
        curl -X POST $HUMANITEC_URL/orgs/$HUMANITEC_ORG/apps/$HUMANITEC_APP/envs/$HUMANITEC_ENVIRONMENT/deploys -H "Authorization: Bearer $HUMANITEC_TOKEN"  -d @/tmp/rollback.json -s -k
    fi

}

humanitec_create_app_environment () {
    echo "Attempting to create a new environment: $HUMANITEC_ENVIRONMENT from $HUMANITEC_FROM_ENVIRONMENT"

    curl $HUMANITEC_URL/orgs/$HUMANITEC_ORG/apps/$HUMANITEC_APP/envs/$HUMANITEC_FROM_ENVIRONMENT/deploys -H "Authorization: Bearer $HUMANITEC_TOKEN" -o /tmp/deploys.json -s -k

    DEPLOYMENT_ID=`cat /tmp/deploys.json | jq -c 'map( select( .status == "succeeded" ) ) | .[0]["id"]' -r`

    if [[ $DEPLOYMENT_ID  == "null" ]]
    then
        DEPLOYMENT_ID=`cat /tmp/deploys.json | jq '.[0]["id"]' -r`;
        echo "Could not found a successful deployment for the new environment, trying anything available: $DEPLOYMENT_ID"
    else
        echo "Found a successful deployment for the new environment: $DEPLOYMENT_ID"
    fi


cat <<-EOF > /tmp/new_environment.json
    {
    "from_deploy_id": "$DEPLOYMENT_ID",
    "id": "$HUMANITEC_ENVIRONMENT",
    "name": "$HUMANITEC_ENVIRONMENT",
    "type": "$HUMANITEC_ENVIRONMENT",
    "namespace": "$HUMANITEC_APP-$HUMANITEC_ENVIRONMENT-namespace"
    }
EOF

    STATUSCODE=$(curl -X POST -k --silent --output /dev/stderr --write-out "%{http_code}" $HUMANITEC_URL/orgs/$HUMANITEC_ORG/apps/$HUMANITEC_APP/envs -H "Authorization: Bearer $HUMANITEC_TOKEN"  -d @/tmp/new_environment.json)
    
    if [[ $STATUSCODE  == 200 ]] || [[ $STATUSCODE  == 201 ]] || [[ $STATUSCODE == 409 ]] ; then
        echo "Environment creation OK: $STATUSCODE"
    else
        echo "Environment creation failure: $STATUSCODE"
        exit 1
    fi

}
