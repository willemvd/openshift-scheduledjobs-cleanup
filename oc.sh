#!/bin/sh

KUBECONFIG=/tmp/.kube

set -e

oc login https://$KUBERNETES_PORT_443_TCP_ADDR:$KUBERNETES_SERVICE_PORT_HTTPS --token `cat /var/run/secrets/kubernetes.io/serviceaccount/token`
oc get jobs > /tmp/jobs
tail -n +2 /tmp/jobs > /tmp/jobs-without-header

while read JOB_WITH_STATS
do
    JOB=$(eval echo "${JOB_WITH_STATS}" | awk '{print $1}')
    SUCCESSFUL_RUN=$(eval echo "${JOB_WITH_STATS}" | awk '{print $3}')
    if [ ${SUCCESSFUL_RUN} == "0" ]; then
      echo "Successfully ended job ${JOB}, delete it"
      oc delete job ${JOB}
    else
      echo "${JOB} not successfully ended"
    fi
done < /tmp/jobs-without-header