defmodule Translator.HTTPClient do
  @base_url Application.compile_env(:translator, __MODULE__)[:base_url]

  def base_url(), do: @base_url

  def new(opts \\ []) do
    default_headers = [
      {"content-type", "application/json"}
    ]

    Req.new(
      base_url: @base_url,
      headers: default_headers ++ Keyword.get(opts, :headers, []),
      receive_timeout: 5_000,
      connect_options: [timeout: 5_000],
      retry: :transient,
      max_retries: 2
    )
  end

  def get(client, path, opts \\ []) do
    client
    |> Req.get(Keyword.merge([url: path], opts))
    |> handle_response()
  end

  def post(client, path, body, opts \\ []) do
    client
    |> Req.post(Keyword.merge([url: path, json: body], opts))
    |> handle_response()
  end

  defp handle_response({:ok, %{status: status, body: body}})
       when status in 200..299 do
    {:ok, body}
  end

  defp handle_response({:ok, %{status: status, body: body}}) do
    {:error, {:http_error, status, body}}
  end

  defp handle_response({:error, exception}) do
    {:error, {:request_failed, exception}}
  end
end
