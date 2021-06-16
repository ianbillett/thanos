#!/usr/bin/env bash

docker pull quay.io/prometheus/prometheus:v2.27.0
docker pull quay.io/thanos/thanos:main-2021-06-11-7c6c5051

mkdir /root/editor
