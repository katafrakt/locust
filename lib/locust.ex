defmodule Locust do
  def main(args) do
    args |> parse_args |> process
  end

  defp parse_args(args) do
    {options, url, _} = OptionParser.parse(args,
      switches: [number: :integer, concurrency: :integer],
      aliases: [n: :number, c: :concurrency]
    )
    {options, url}
  end

  defp process(args) do
    url = elem(args, 1)
    opts = elem(args, 0)
    num_of_workers = opts[:concurrency] || 1
    num_of_requests = opts[:number] || 10

    result = run_workers(url, num_of_workers, num_of_requests)

    successful_results = Enum.filter(result, fn(x) -> elem(x, 0) == 200 end)
    print_success_rate(successful_results, result)

    if length(successful_results) > 0 do
      print_times(successful_results)
      if num_of_workers > 1 do
        print_concurrency(successful_results)
      end
    end
  end

  defp run_workers(url, num_of_workers, num_of_requests) do
    {:ok, agent} = Agent.start_link(fn -> [] end)
    workers = for _ <- 1..num_of_workers, do: spawn fn -> Worker.call(agent, url, num_of_requests) end
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

  defp print_success_rate(successful, result) do
    all = length(result)
    success = length(successful)
    IO.puts "Success: #{success}/#{all} (#{success/all * 100}%)"
  end

  defp print_times(result) do
    times = Enum.map(result, fn(x) -> elem(x, 1) end) |> Enum.map(fn(x) -> x/1000 end)
    max = Enum.max(times)
    min = Enum.min(times)
    avg = Enum.sum(times)/length(times)
    IO.puts "Times:"
    IO.puts "   Max: #{max} ms"
    IO.puts "   Min: #{min} ms"
    IO.puts "   Avg: #{avg} ms"
  end

  defp print_concurrency(result) do
    times = Enum.map(result, fn(x) -> elem(x, 1) end) |> Enum.map(fn(x) -> x/1000 end)
    start = Enum.map(result, fn(x) -> elem(x, 2) end) |> Enum.map(fn(x) -> x/1000 end) |> Enum.min
    finish = Enum.map(result, fn(x) -> elem(x, 3) end) |> Enum.map(fn(x) -> x/1000 end) |> Enum.max
    total_duration = finish - start
    sum_of_times = Enum.sum(times)
    requests = length(result)
    IO.puts "Concurrency:"
    IO.puts "   Time of all requests:  #{sum_of_times}"
    IO.puts "   Total duration:        #{total_duration}"
    IO.puts "   Concurrency level:     #{sum_of_times/total_duration}"
    IO.puts "   Requests per second:   #{(total_duration*1000)/requests}"
  end
end

defmodule Worker do
  def call(agent, url, num_of_requests) do
    work(url, agent, num_of_requests)
  end

  defp work(_, _, 0) do
  end

  defp work(url, agent, requests_to_do) do
    try do
      start = :erlang.system_time()/1000
      response = HTTPotion.get(url)
      finish = :erlang.system_time()/1000
      time = finish - start
      Agent.update(agent, fn list -> [{response.status_code, time, start, finish}|list] end)
    rescue
      HTTPotion.HTTPError -> Agent.update(agent, fn(list) -> [{0, 0, 0, 0}|list] end)
    end
    work(url, agent, requests_to_do - 1)
  end
end
