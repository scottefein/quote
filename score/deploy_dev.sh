#!/usr/bin/env bash
set -e

source "deploy_helper.sh"

score-humanitec delta --api-url $HUMANITEC_URL --token $HUMANITEC_TOKEN --org $HUMANITEC_ORG --app $HUMANITEC_APP --env $HUMANITEC_ENVIRONMENT -f ../score.yaml --extensions extensions.yaml --overrides overrides.yaml --deploy
WORKLOAD="quote"
humanitec_wait_for_deployment

# score-humanitec delta --api-url $HUMANITEC_URL --token $HUMANITEC_TOKEN --org $HUMANITEC_ORG --app $HUMANITEC_APP --env $HUMANITEC_ENVIRONMENT -f score.backend.yaml --extensions extensions.backend.yaml --deploy
# WORKLOAD="backend"
# humanitec_wait_for_deployment

# score-humanitec delta --api-url $HUMANITEC_URL --token $HUMANITEC_TOKEN --org $HUMANITEC_ORG --app $HUMANITEC_APP --env $HUMANITEC_ENVIRONMENT -f score.frontend.yaml --extensions extensions.frontend.yaml --deploy
# WORKLOAD="frontend"
# humanitec_wait_for_deployment
