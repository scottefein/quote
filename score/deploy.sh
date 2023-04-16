#!/usr/bin/env bash
set -e

source "deploy_helper.sh"
export HUMANITEC_FROM_ENVIRONMENT="development"
humanitec_create_app_environment
sleep 3

score-humanitec delta --api-url $HUMANITEC_URL --token $HUMANITEC_TOKEN --org $HUMANITEC_ORG --app $HUMANITEC_APP --env $HUMANITEC_ENVIRONMENT -f ../score.yaml --extensions extensions.yaml --overrides overrides.yaml --deploy
WORKLOAD="quote"
humanitec_wait_for_deployment