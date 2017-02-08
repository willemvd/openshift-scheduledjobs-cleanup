FROM willemvd/openshift-oc-docker:1.0.0

COPY oc.sh /tmp/oc.sh

CMD /tmp/oc.sh