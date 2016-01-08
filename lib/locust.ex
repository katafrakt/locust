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

    print_success_rate(result)
    print_times(result)
  end

  defp run_workers(url, num_of_workers, num_of_requests) do
    {:ok, agent} = Agent.start_link(fn -> [] end)
    workers = for _ <- 1..num_of_workers, do: spawn fn -> Worker.call(agent, url, num_of_requests) end
    wait_for_workers(workers)
    Agent.get(agent, fn list -> list end)
  end

  defp wait_for_workers(workers) do
    aliveness = Enum.map(workers, fn(x) -> Process.alive?(x) end)
    if Enum.any?(aliveness, fn(x) -> x == true end) do
      :timer.sleep(20)
      wait_for_workers(workers)
    end
  end

  defp print_success_rate(result) do
    success = Enum.count(result, fn(x) -> elem(x, 0) == 200 end)
    all = length(result)
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
end

defmodule Worker do
  def call(agent, url, num_of_requests) do
    work(url, agent, num_of_requests)
  end

  defp work(_, _, 0) do
  end

  defp work(url, agent, requests_to_do) do
    {time, response} = :timer.tc(HTTPotion, :get, url)
    Agent.update(agent, fn list -> [{response.status_code, time}|list] end)
    work(url, agent, requests_to_do - 1)
  end
end
