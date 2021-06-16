# Advanced: Scaling Data Ingest & High Availability in Thanos Receive

This tutorial builds on what we learnt in tutorial #3 [Ingesting metrics data from unreachable sources with Thanos Receive](https://www.katacoda.com/thanos/courses/thanos/3-receive), and dives into more complex topics aimed at preparing your Thanos metrics infrastructure for running in production. 

In this tutorial, you will learn:

* How to achieve high-availability in Thanos Receive by replicating data.
* How to efficiently scale Thanos Receive using 'router' and 'ingester' modes.

> NOTE: This course uses docker containers with pre-built Thanos, Prometheus, and Minio Docker images available publicly.

### Prerequisites

This tutorial directly follows tutorial #3 [Ingesting metrics data from unreachable sources with Thanos Receive](https://www.katacoda.com/thanos/courses/thanos/3-receive) - so please make sure you have completed that first 🤗

### Feedback

Do you see any bug, typo in the tutorial or you have some feedback for us?
Let us know on https://github.com/thanos-io/thanos or #thanos slack channel linked on https://thanos.io

### Contributed by:

* Ian Billett [@ianbillett](http://github.com/ianbillett)