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
    times = result |> Enum.map(&elem(&1, 1)) |> Enum.map(&(&1/1000))
    max_val = Enum.max(times)
    min_val = Enum.min(times)
    avg_val = Enum.sum(times)/length(times)
    iqrm_val = Statistics.trimmed_mean(times, :iqr)
    IO.puts "Times:"
    IO.puts "   Max:      #{format_number(max_val)} ms"
    IO.puts "   Min:      #{format_number(min_val)} ms"
    IO.puts "   Avg:      #{format_number(avg_val)} ms"
    IO.puts "   IQR mean: #{format_number(iqrm_val)} ms"
  end

  defp print_concurrency(result) do
    times = result |> Enum.map(&elem(&1, 1)) |> Enum.map(&(&1/1000))
    start = result |> Enum.map(&elem(&1, 2)) |> Enum.map(&(&1/1000)) |> Enum.min
    finish = result |> Enum.map(&elem(&1, 3)) |> Enum.map(&(&1/1000)) |> Enum.max
    total_duration = finish - start
    sum_of_times = Enum.sum(times)
    requests = length(result)
    IO.puts "Concurrency:"
    IO.puts "   Time of all requests:  #{format_number(sum_of_times)} ms"
    IO.puts "   Total duration:        #{format_number(total_duration)} ms"
    IO.puts "   Concurrency level:     #{format_number(sum_of_times/total_duration)}"
    IO.puts "   Requests per second:   #{format_number(requests/(total_duration/1000))} req/s"
  end

  defp format_number(num) do
    Float.round(num, 2)
  end
end
