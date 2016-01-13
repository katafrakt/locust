defmodule Worker do
  def call(agent, url, num_of_requests, opts) do
    work(url, agent, num_of_requests, opts)
  end

  defp work(_, _, 0, _) do
  end

  defp work(url, agent, requests_to_do, opts) do
    connection_header = if opts[:keep_alive], do: 'keep-alive', else: 'close'
    try do
      start = :erlang.system_time()/1000
      response = HTTPotion.get(url, [headers: ['Connection': connection_header]])
      finish = :erlang.system_time()/1000
      time = finish - start
      Agent.update(agent, fn list -> [{response.status_code, time, start, finish}|list] end)
    rescue
      HTTPotion.HTTPError -> Agent.update(agent, fn(list) -> [{0, 0, 0, 0}|list] end)
    end
    work(url, agent, requests_to_do - 1, opts)
  end
end
