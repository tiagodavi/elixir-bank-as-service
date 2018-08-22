defmodule BankApiWeb.CatchAllController do
  use BankApiWeb, :controller

  def index(conn, _params) do
    json(conn, %{errors: %{message: "Endpoint not found!"}})
  end
end
