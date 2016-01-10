defmodule Reporter do
  def render(result, num_of_workers) do
    successful_results = Enum.filter(result, fn(x) -> elem(x, 0) == 200 end)
    print_success_rate(successful_results, result)

    if length(successful_results) > 0 do
      print_times(successful_results)
      if num_of_workers > 1 do
        print_concurrency(successful_results)
      end
    end
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
    IO.puts "   Max: #{format_number(max)} ms"
    IO.puts "   Min: #{format_number(min)} ms"
    IO.puts "   Avg: #{format_number(avg)} ms"
  end

  defp print_concurrency(result) do
    times = Enum.map(result, fn(x) -> elem(x, 1) end) |> Enum.map(fn(x) -> x/1000 end)
    start = Enum.map(result, fn(x) -> elem(x, 2) end) |> Enum.map(fn(x) -> x/1000 end) |> Enum.min
    finish = Enum.map(result, fn(x) -> elem(x, 3) end) |> Enum.map(fn(x) -> x/1000 end) |> Enum.max
    total_duration = finish - start
    sum_of_times = Enum.sum(times)
    requests = length(result)
    IO.puts "Concurrency:"
    IO.puts "   Time of all requests:  #{format_number(sum_of_times)} ms"
    IO.puts "   Total duration:        #{format_number(total_duration)} ms"
    IO.puts "   Concurrency level:     #{format_number(sum_of_times/total_duration)}"
    IO.puts "   Requests per second:   #{format_number((total_duration*1000)/requests)} req/s"
  end

  defp format_number(num) do
    Float.round(num, 2)
  end
end
