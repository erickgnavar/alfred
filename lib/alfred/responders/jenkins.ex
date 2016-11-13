defmodule Alfred.Responders.Jenkins do

  use Hedwig.Responder
  alias Alfred.JenkinsAPI

  @usage """
  hedwig: jenkins jobs - Get the list of jobs.
  """
  hear ~r/jenkins jobs/i, msg do
    case JenkinsAPI.fetch_jobs do
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
    case JenkinsAPI.trigger_build(msg.matches[1]) do
      {:ok, _} ->
        reply msg, "build triggered!"
      {:error, reason} ->
        reply msg, reason
    end
  end

  defp format_job(%{"name" => _name, "url" => url, "color" => _color}) do
    ">#{url}"
  end

end
