# Global View Architecture with Thanos Receive

With `prometheus-batcave` & `prometheus-batcomputer` now running, we need to think about how we satisfy our two requirements:
1. Implement a global view of this data.
1. Global view must be queryable in near real-time.

How are we going to do this?

## Thanos Sidecar

After completing [Tutorial #1: Global View](https://www.katacoda.com/thanos/courses/thanos/1-globalview), you may think of running the following architecture:

* Run Thanos Sidecar next to each of the Prometheus instances.
* Configure Thanos Sidecar to upload Prometheus data to an object storage (S3, GCS, Minio).
* Run Thanos Store connected to the data stored in object storage.
* Run Thanos Query to pull data from Thanos Store.

However! This setup **does not** satisfy our requirements above.

<details>
 <summary>Can you think why?</summary>

Thanos Sidecar only uploads `blocks` of metrics data that have been written to disk, which happens every 2 hours in Prometheus.

This means that the Global View would be at least 2 hours out of date, and does not satisfy requirement #2.
</details>

## Thanos Receive

Enter [Thanos Receive](https://thanos.io/tip/components/receive.md/).

`Thanos Receive` is a component that implements the [Prometheus Remote Write API](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#remote_write). This means that it will accept metrics data that is sent to it by other Prometheus instances. 

Prometheus can be configured to `Remote Write`. This means that Prometheus will send all of its metrics data to a remote endpoint as they are being ingested - useful for our requirements!

In its simplest form, when `Thanos Receive` receives data from Prometheus, it stores it locally and exposes a `Store API` server so this data can be queried by `Thanos Query`.

`Thanos Receive` has more features that we will touch on later, but let's keep things simple for now.

The architecture we are hoping to build is going to look like this:

//TODO: Put architecture diagram here.

## Run Thanos Receive

The first component we will run in our new architecture is `Thanos Receive`:

```
docker run -d --rm \
    -v $(pwd)/receive-data:/receive/data \
    --net=host \
    --name receive \
    quay.io/thanos/thanos:v0.21.0 \
    receive \
    --tsdb.path "/receive/data" \
    --grpc-address 0.0.0.0:10907 \
    --http-address 0.0.0.0:10909 \
    --label "receive_replica=\"0\"" \
    --label "receive_cluster=\"wayne-enterprises\"" \
    --remote-write.address 0.0.0.0:10908
```

Let's talk about some important parameters specifically:
* `--label` - `Thanos Receive` requires at least one label to be set. These are called 'external labels' and are used to uniquely identify this instance of `Thanos Receive`.
* `--remote-write.address` - This is the address that `Thanos Receive` is listening on for Prometheus' remote write requests.

Let's verify that this is running correctly. Since `Thanos Receive` does not expose a UI, we can check it is up by retrieving its metrics page.

```
curl http://127.0.0.1:10909/metrics
```

## Run Thanos Query

Next, let us run a `Thanos Query` instance:

```
docker run -d --rm \
    --net=host \
    --name query \
    quay.io/thanos/thanos:v0.21.0 \
    query \
    --http-address "0.0.0.0:39090" \
    --store "0.0.0.0:10907"
```

`Thanos Receive` exposes its GRPC endpoint at `0.0.0.0:10907`, so we need to tell `Thanos Query` to use this endpoint with the `--store` flag.

Verify that `Thanos Query` is working and configured correctly by looking at the 'stores' tab [here](https://[[HOST_SUBDOMAIN]]-39090-[[KATACODA_HOST]].environments.katacoda.com/stores).

Now we are done right? Try query for some data...

<details>
 <summary>Uh-oh! Why are we seeing 'Empty Query Result' responses?</summary>

We have correctly configured `Thanos Receive` & `Thanos Store`, but we have not yet configured Prometheus to write to remote write its data to the right place.

</details>

## Configure Prometheus Remote Write

We need to tell `prometheus-batcave` & `prometheus-batcomputer` to write their metrics data to our `Thanos Receive` component. 

<pre class="file" data-filename="prometheus-batcave.yml" data-target="replace">
global:
  scrape_interval: 5s
  external_labels:
    cluster: batcave
    replica: 0

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['0.0.0.0:9090']
remote_write:
- url: http://0.0.0.0:10908/api/v1/receive
</pre>

<pre class="file" data-filename="prometheus-batcomputer.yml" data-target="replace">
global:
  scrape_interval: 5s
  external_labels:
    cluster: batcomputer
    replica: 0

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['0.0.0.0:9090']
remote_write:
- url: http://0.0.0.0:10908/api/v1/receive
</pre>

Since we supplied the `--web.enable-lifecycle` flag in our Prometheus instances, we can dynamically reload the configuration by `curl`-ing the `/-/reload` endpoints.

```
curl http://0.0.0.0:9090/-/reload
curl http://0.0.0.0:9091/-/reload
```

Verify this has taken affect by checking the `/config` page on our Prometheus instances:
* `prometheus-batcave` [config page](https://[[HOST_SUBDOMAIN]]-39090-[[KATACODA_HOST]].environments.katacoda.com/config)
* `prometheus-batcomputer` [config page](https://[[HOST_SUBDOMAIN]]-39090-[[KATACODA_HOST]].environments.katacoda.com/config)

In both you should see our `remote_write` configuration.

## Verify Setup

With all of the pieces in place, we should now sense-check that everything working as expected.

<details>
 <summary>How are you going to check that the components are wired up correctly?</summary>

Let's make sure that we can query data from each of our Prometheus instances from our `Thanos Query` instance.

Navigate to the Thanos Query UI, and query for a metric like `up` - inspect the output and you should see something like this:

// TODO - insert picture here

</details>