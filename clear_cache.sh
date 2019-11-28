#! /bin/bash

CUSTOM_MIN_TIME="23:00"
CUSTOM_MAX_TIME="23:50"
CURRENT_TIME=$(date +%H:%M)


CUSTOM_RISKSERVER_MANAGERS=("CUSTOM-CsRiskMgr:csmars1")
SHARED_RISKSERVER_MANAGERS=("SCENARIOS-CsRiskMgr:csmars71" \
                            "HISTORIC-CsRiskSrvrMgr:csmars8")


function riskservermgr_clearcache {
  SERVICE_NAME=$(echo $1 | cut -f1 -d:)
  HOST_ALIAS=$(echo $1 | cut -f2 -d:)
  echo "riskservermanger $SERVICE_NAME $HOST_ALIAS clear_cache"
}

# MAIN SECTION:
if [[ "$CURRENT_TIME" > "$MIN_TIME" ]] && [[ "$CURRENT_TIME" < "$MAX_TIME" ]]
then
  for risk_server_mgr in ${CUSTOM_RISKSERVER_MANAGERS[@]}; do
    riskservermgr_clearcache $risk_server_mgr
  done
else
  for risk_server_mgr in ${SHARED_RISKSERVER_MANAGERS[@]}; do
    riskservermgr_clearcache $risk_server_mgr
  done
fi
