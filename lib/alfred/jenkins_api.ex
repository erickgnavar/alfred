defmodule Alfred.JenkinsAPI do

  @base_url Application.get_env(:alfred, :jenkins_url)

  def trigger_build(job) do
    url = "#{@base_url}/job/#{job}/build/"
    case fetch_crumb do
      {:ok, crumb} ->
        data = {:form, [{"Jenkins-Crumb", crumb}]}
        case HTTPoison.post(url, data, [Authorization: "Basic #{auth}"]) do
          {:ok, %HTTPoison.Response{status_code: 201}} ->
            {:ok, "ok"}
          {:ok, %HTTPoison.Response{status_code: 404}} ->
            {:error, "job not found"}
          {:error, reason} ->
            {:error, reason}
        end
      {:error, reason} ->
        {:error, reason}
    end
  end

  def fetch_jobs do
    url = "#{@base_url}/api/json"
    case HTTPoison.get(url, [Authorization: "Basic #{auth}"]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Poison.decode(body) do
          {:ok, %{"jobs" => jobs}} ->
            {:ok, jobs}
          _ ->
            {:error, "decode error"}
        end
      _ ->
        {:error, "connection error"}
    end
  end

  defp auth do
    username = Application.get_env(:alfred, :jenkins_user_id)
    password = Application.get_env(:alfred, :jenkins_api_token)
    Base.encode64("#{username}:#{password}")
  end

  defp fetch_crumb do
    url = "#{@base_url}/crumbIssuer/api/json"
    case HTTPoison.get(url, [Authorization: "Basic #{auth}"]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Poison.decode(body) do
          {:ok, %{"crumb" => crumb}} ->
            {:ok, crumb}
          _ ->
            {:error, "decode error"}
        end
      _ ->
        {:error, "connection error"}
    end
  end

end
