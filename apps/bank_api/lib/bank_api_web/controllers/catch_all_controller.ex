defmodule BankApiWeb.CatchAllController do
  @moduledoc """
  This controller is useful to catch any request that was not defined
  into router.ex
  """

  use BankApiWeb, :controller

  def index(conn, _params) do
    json(conn, %{errors: %{message: "Endpoint not found!"}})
  end
end
