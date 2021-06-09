



# Setup Receiver

docker run -d --rm \
    -v $(pwd)/receive-data:/receive/data \
    -v $(pwd)/hashring.json:/receive/hashring.json \
    --net=host \
    --name receive \
    quay.io/thanos/thanos:v0.21.0 \
    receive \
    --tsdb.path "/receive/data" \
    --grpc-address 0.0.0.0:10907 \
    --http-address 0.0.0.0:10909 \
    --receive.replication-factor 1 \
    --receive.hashrings-file "/receive/hashring.json" \
    --label "receive_replica=\"0\"" \
    --label "receive_cluster=\"eu1\"" \
    --receive.local-endpoint 127.0.0.1:10907 \
    --remote-write.address 0.0.0.0:10908

# Setup Querier

docker run -d --rm \
    --net=host \
    --name query \
    quay.io/thanos/thanos:v0.21.0 \
    query \
    --http-address "0.0.0.0:39090" \
    --store "0.0.0.0:10907"

# Setup Prometheus

docker run -d --rm \
    --net=host \
    -v $(pwd)/prometheus-eu.yaml:/etc/prometheus/prometheus.yaml \
    -v $(pwd)/prometheus-eu-data:/prometheus \
    -u root \
    --name prometheus-eu \
    quay.io/prometheus/prometheus:v2.27.0 \
    --config.file=/etc/prometheus/prometheus.yaml \
    --storage.tsdb.path=/prometheus \
    --web.listen-address=:9090 \
    --web.enable-lifecycle \
    --web.enable-admin-api

