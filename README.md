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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/katafrakt/locust.

## License

This software is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
