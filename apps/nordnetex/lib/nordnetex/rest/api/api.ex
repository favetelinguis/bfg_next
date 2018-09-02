defmodule Nordnetex.Rest.Api do
  @moduledoc false
  use HTTPoison.Base
  require Logger

  @base_url Application.get_env(:nordnetex, :base_url)
  @api_version Application.get_env(:nordnetex, :api_version)

  def process_url(resource) do
    @base_url <> @api_version <> resource
  end

  def process_request_headers(headers) do
    headers ++
    [
      "Accept": "application/json",
      "Accept-Encoding": "gzip, deflate",
      "Connection": "keep-alive",
      "Accept-Language": "en"
    ]
  end

  def process_response_body(body) when not is_nil(body) do
    # TODO this is brittle, I should really look at headers
    # Also looks like betfair response with 400 if not valid so could i get status code that would be ok
    # Easiest way to check error is to supply a faulty appkey
    case String.valid?(body) do
      true -> Poison.Parser.parse!(body)
      false -> body |> :zlib.gunzip() |> Poison.Parser.parse!()
    end
  end

  def process_request_body(body) do
    body
    |> Poison.encode!()
  end

  def process_request_options(options) do
    auth = case Keyword.get(options, :session_key) do
      nil -> []
      session_key ->
        [basic_auth: {session_key, session_key}]
    end
    [
      hackney: [pool: :default] ++ auth,
      ssl: [{:versions, [:'tlsv1.2']}],
      recv_timeout: 5000
    ]
  end
end
