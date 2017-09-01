#!/bin/sh

export KUBECONFIG=/tmp/.kube

set -e

DEFAULT_NAMESPACE=$(eval cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)

oc login https://$KUBERNETES_PORT_443_TCP_ADDR:$KUBERNETES_SERVICE_PORT_HTTPS \
  --token `cat /var/run/secrets/kubernetes.io/serviceaccount/token` \
  --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
oc get jobs -n ${DEFAULT_NAMESPACE} > /tmp/jobs
tail -n +2 /tmp/jobs > /tmp/jobs-without-header

while read JOB_WITH_STATS
do
    JOB=$(eval echo "${JOB_WITH_STATS}" | awk '{print $1}')
    SUCCESSFUL_RUN=$(eval echo "${JOB_WITH_STATS}" | awk '{print $3}')
    if [ ${SUCCESSFUL_RUN} == "1" ]; then
      echo "Successfully ended job \"${JOB}\", delete it"
      oc delete job ${JOB} -n ${DEFAULT_NAMESPACE}
    else
      echo "\"${JOB}\" not successfully ended"
    fi
done < /tmp/jobs-without-header

echo "Start - Deleting pods in error state"
oc get pods -n ${DEFAULT_NAMESPACE} | grep "Error" > /tmp/pods-in-error
while read ERROR_POD
do
    POD=$(eval echo "${ERROR_POD}" | awk '{print $1}')
    oc delete pod ${POD} -n ${DEFAULT_NAMESPACE}
    echo "Successfully deleted pod \"${POD}\""
done < /tmp/pods-in-error
echo "Done - Deleting pods in error state"
