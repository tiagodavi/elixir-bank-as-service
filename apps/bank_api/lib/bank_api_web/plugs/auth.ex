defmodule BankApiWeb.Plugs.Auth do
  @moduledoc """
  This plug is responsible for authenticating any request to the /api
  using Basic Auth
  """

  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  @backoffice "backoffice"

  def init(_params) do
  end

  def call(conn, _params) do
    token = get_req_header(conn, "authorization")

    if valid_token?(token) do
      conn
    else
      data = %{"errors" => "authentication required"}

      conn
      |> put_status(401)
      |> json(data)
      |> halt()
    end
  end

  defp valid_token?(["Basic " <> token]) do
    decoded_token = Base.decode64!(token)

    [email, password] =
      decoded_token
      |> String.split(":")

    email === @backoffice && password === @backoffice
  end

  defp valid_token?(_), do: false
end
