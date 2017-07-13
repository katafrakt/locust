defmodule Locust do
  require Worker
  require Reporter

  def main(args) do
    args |> parse_args |> process
  end

  defp parse_args(args) do
    {options, url, _} = OptionParser.parse(args,
      switches: [number: :integer, concurrency: :integer, header: :keep],
      aliases: [n: :number, c: :concurrency, h: :help, H: :header]
    )
    {options, url}
  end

  defp process(args) do
    url = List.first(elem(args, 1))
    opts = elem(args, 0)
    num_of_workers = opts[:concurrency] || 1
    num_of_requests = opts[:number] || 10
    headers = opts |>  Keyword.get_values(:header) |> parse_headers
    if opts[:help] do
      print_help()
    end

    opts = Keyword.put(opts, :total_requests, num_of_requests * num_of_workers)
    |> Keyword.put(:headers, headers)

    IO.puts "Spawning locust swarm..."
    results = run_workers(url, num_of_workers, num_of_requests, opts)
    Reporter.render(results, num_of_workers)
  end

  defp parse_headers(headers_array) do
    Enum.map(headers_array, fn(h) ->
      [key, value] = String.split(h, ":")
      {String.to_atom(key), value}
    end)
    |> Keyword.new
  end

  defp run_workers(url, num_of_workers, num_of_requests, opts) do
    {:ok, agent} = Agent.start_link(fn -> [] end)
    workers = for _ <- 1..num_of_workers, do: spawn fn -> Worker.call(agent, url, num_of_requests, opts) end
    wait_for_workers(workers, agent, num_of_requests * num_of_workers)
    Agent.get(agent, fn list -> list end)
  end

  defp wait_for_workers(workers, agent, total) do
    print_progress_bar(agent, total)
    aliveness = Enum.map(workers, fn(x) -> Process.alive?(x) end)
    if Enum.any?(aliveness, fn(x) -> x == true end) do
      :timer.sleep(20)
      wait_for_workers(workers, agent, total)
    end
  end

  defp print_progress_bar(agent, total) do
    results = Agent.get(agent, fn(list) -> list end)
    format = [
      bar_color: [IO.ANSI.white, IO.ANSI.green_background],
      blank_color: IO.ANSI.yellow_background,
    ]
    ProgressBar.render(length(results), total, format)
  end

  defp print_help() do
    IO.puts """
      Usage:
        locust [host] [options]

        Example: locust http://localhost:8080 -c 20 -n 200

      Options:
        -h --help             Print help (this message)
        -n --number           Number of requests to perform by each worker.
                              Default: 10
        -c --concurrency      Number of workers to spawn. Default: 1.
        --keep-alive          (experimental) use 'Connection: keep-alive' header
                              instead of default 'Connection: close'
    """
    System.halt(0)
  end
end
