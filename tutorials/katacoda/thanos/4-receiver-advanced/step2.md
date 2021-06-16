# Increasing Data Ingest Volumes

Helpfully, `Thanos Receive` includes features to scale data ingest volumes beyond a single instance.

It does this by enabling users to configure `Thanos Receive` instances to participate in a `hashring`.

<details>
  <summary> What is a hashring? </summary>
  A `hashring` is a way of allocating `N` things between `M` slots.
  
  By using [consistent hashing](https://en.wikipedia.org/wiki/Consistent_hashing), it ensures that when the number of `M` slots changes, the minimum possible things `N` are re-allocated between slots.

  Crucially, this avoids the situation where _everything_ is re-allocated when the number of underlying workers changes.

  This is a common technique in distributed data storage and load-balancing, and is an interesting topic in Computer Science. There are lots of good resources out there you can read up on.
</details>


The following two functions must be performed by participants to form a `hashring`:
* `routing` - Decide which member(s) of the `hashring` should process the request and forward it to them.
* `ingesting` - Receive a request containing metrics data, store it in our local TSDB instance, and provide a Store API for querying data.

A single `Thanos Receive` instance can perform **one or both** of the above functions.

Before diving into running these instances, let's think about the implications of running in these different modes.

## Architecture

How should we architect our `hashring` to best satisfy our scalability requirement?

Broadly, there are two ways of approaching this decision:

1. Combined - participants perform **both** `routing` and `ingesting`.
1. Separate - participants perform **either** `routing` or `ingesting`.

Let's consider how each approach responds in the following two scenarios...

### #1 Configuration Reloading

`hashring` participants know about each other via a configuration file (we'll see this in the next page).

When this file changes, `Thanos Receiver` flushes its TSDB head blocks to disk during which, the component refuses to process any requests.

<details>
  <summary>What do you think happens under a combined and separate architecture?</summary>
  <br>

  With **combined** routing & ingesting, every participant has a local TSDB instance. When the head block (RAM) holds a lot of data, and the configuration file is changed, the whole hashring can become unresponsive for a prolonged period while the TSDB is flushed.
  <br>
  <br>

  With **separate** routing & ingesting, only the 'routing' components are watching the configuration file for changes. Since these do not store data locally, there is no TSDB to flush. When a configuration change is made, the 'ingesters' are unaffected, and the 'routers' are only unavailable for a very short period.
  <br>
  <br>

</details>

### #2 Network Overhead

`Routing` participants forward data to `ingesting` via `gRPC` network connections.

<details>
  <summary>What happens when the number participants gets large?</summary>
  <br>

  With **combined** routing & ingesting, every participant can route to every other participant. Therefore, if we have `n` participants in the `hashring` we will have `n²` open network connections, which can saturate networks.
  <br>

  With **separate** routing & ingesting, each `routing` component maintains a connection to each of the `ingesting` components. If we have `n` routers and `m` ingesters, we will have `nm` maximum connections. Routing is generally a low overhead activity, so `n` tends to be comparatively small to `m`.
  <br>

</details>

## Conclusion

Start the next chapter and we will build out this infrastructure!