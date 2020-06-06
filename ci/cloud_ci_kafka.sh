#! /bin/bash

venv/bin/pip install -r test/requirements.txt
STACK_ID=`venv/bin/python ci/orca_create_splunk.py`
CI_SPLUNK_HOST="$STACK_ID.stg.splunkcloud.com"

chmod +x ci/install_splunk.sh && sh ci/install_splunk.sh $CI_SPLUNK_HOST

echo "=============install kafka=============="
docker build -t kafka_connect_image -f kafka-connect-splunk.dockerfile --build-arg ssh_prv_key="$(cat ~/.ssh/id_rsa)" --build-arg ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)" .
docker run -p 8083:8082 -d kafka_connect_image
sleep 300

#venv/bin/splunk_orca --cloud cloudworks destroy ${STACK_ID}