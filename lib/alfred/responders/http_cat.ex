defmodule Alfred.Responders.HttpCat do

  use Hedwig.Responder

  @usage """
  hedwig: httpcat <status_code> - Get your status cat image
  """
  hear ~r/httpcat (\d+)/i, msg do
    url = "https://http.cat/#{msg.matches[1]}/"
    reply msg, url
  end

end
