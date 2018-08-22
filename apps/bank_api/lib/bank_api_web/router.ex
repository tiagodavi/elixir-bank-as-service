defmodule BankApiWeb.Router do
  use BankApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BankApiWeb do
    pipe_through :api
  end

  scope "/", BankApiWeb do
    get("/*path", CatchAllController, :index)
  end
end
