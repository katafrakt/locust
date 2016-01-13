defmodule Locust do
  require Worker
  require Reporter

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

    results = run_workers(url, num_of_workers, num_of_requests, opts)
    Reporter.render(results, num_of_workers)
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
end
