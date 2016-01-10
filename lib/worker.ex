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
