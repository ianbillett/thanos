# Problem Statement

This tutorial will extend the `Thanos Receive` setup we built in the previous tutorial, by imposing extra requirements that make this infrastructure more suitable for a production environment.

<details>
  <summary>Click here for a brief recap of the previous tutorial</summary>
  <br>

  You are responsible for monitoring at `Wayne Enterprises`. You are required to monitor, in real time, two sites (`batcave` & `batcomputer`) that are sensitive and cannot receive external requests.
  <br>

  The solution that satisfied our requirements was to configure each of the Prometheus instances to `remote_write` their metrics data to an instance of `Thanos Receive` in our infrastructure.
  <br>

</details>

## Requirements

`Wayne Enterprises` is becoming increasingly successful and is starting to ingest metrics data from an increasing number of sensitive sites. To ensure that we provide our customers with a good experience, we are seeking to satisfy the following requirements:  

* **Scalability**. As the number of sites we monitor increases, our infrastructure must be resilient to changes and operationally stable under increasingly large workloads. 
* **High-Availability**. The data we ingest from downstream sites must be replicated, and must not reside on one machine only.

Before moving on - can you think how you would achieve these requirements with Thanos Receive?

