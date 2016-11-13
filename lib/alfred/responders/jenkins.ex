defmodule Alfred.Responders.Jenkins do

  use Hedwig.Responder

  @base_url Application.get_env(:alfred, :jenkins_url)

  @usage """
  hedwig: jenkins jobs - Get the list of jobs.
  """
  hear ~r/jenkins jobs/i, msg do
    case fetch_jobs do
      {:ok, jobs} ->
        response = jobs
          |> Enum.map(&format_job/1)
          |> Enum.join("\n")
        reply msg, "Here is the list of jobs\n" <> response
      {:error, reason} ->
        reply msg, "An error ocurred: #{reason}"
    end
  end

  @usage """
  hedwig: jenkins build <job_name> - Trigger a build.
  """
  hear ~r/jenkins build (.*)/i, msg do
    case trigger_build(msg.matches[1]) do
      {:ok, _} ->
        reply msg, "build triggered!"
      {:error, reason} ->
        reply msg, reason
    end
  end

  defp auth do
    username = Application.get_env(:alfred, :jenkins_user_id)
    password = Application.get_env(:alfred, :jenkins_api_token)
    Base.encode64("#{username}:#{password}")
  end

  def fetch_crumb do
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

  defp trigger_build(job) do
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

  defp fetch_jobs do
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

  defp format_job(%{"name" => _name, "url" => url, "color" => _color}) do
    ">#{url}"
  end

end
