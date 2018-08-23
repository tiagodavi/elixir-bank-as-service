defmodule BankApiWeb.FallBackController do
  @moduledoc """
  This controller intercepts any request that does not
  return a connection
  """
  use BankApiWeb, :controller

  def call(conn, {:error, msg}) do
    send_error(conn, 422, msg)
  end
end
