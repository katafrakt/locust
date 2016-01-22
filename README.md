# Locust

Locust is a simple tool to swarm your server with requests. It's written in Elixir, thus heavily relying on Erlang's threads.

Currently it only supports GET requests.

## Running

 Compile:
```
mix deps.get
mix escript.build
```

Run:
```
./locust http://localhost:3000 -c 10 -n 100
```

## Options

Host is a first parameter passed to locust. Note that it technically does not require to put well-formed URI, this might change in future and it's generally a good idea to do so. So better use `http://localhost:3000` instead of a version omitting protocol.

Locust accepts those as options:

* `-h --help` – Print help
* `-n --number` – Number of requests to perform by each worker. Default is 10.
* `-c --concurrency` – Number of workers to spawn. This is one by default. Be careful with large values as it might induce heavy load of your system (not to mention server). In my experience setting values higher than **1000** might be risky.
* `--keep-alive` _(experimental)_ –  Use `Connection: keep-alive` header instead of default `Connection: close`. This does not make much sense as simulation of real-life situation, as real people usually take time before making following requests. This also proved to cause locust unstable with high concurrency level (even lower than **1000** mentioned above).

## Sample output

```
➜  locust git:(master) ✗ ./locust http://127.0.0.1:8080 -n 100 -c 100
Spawning locust swarm...
|=================================================================================================| 100%
Success: 10000/10000 (100.0%)
Times:
   Max:      74.99 ms
   Min:      1.08 ms
   Avg:      19.07 ms
   IQR mean: 17.83 ms
Concurrency:
   Time of all requests:  190673.3 ms
   Total duration:        1976.14 ms
   Concurrency level:     96.49
   Requests per second:   197.61 req/s
```

What do those mean:

* Min, Max and Avg should be pretty straightforward
* IQR mean (inter-quartile mean) is there for better understanding the results. It calculates the mean while rejecting unusually high and unusually low values that may skew the normal mean.
* Time of all requests is a sum of all requests made by all workers
* Total duration is a time elapsed between start of first requests made and the end of last request made
* Concurrency level is a quotient of the two above (time of all / total duration)
* Requests per second is time of all / number of successful requests

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/katafrakt/locust.

## License

This software is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
