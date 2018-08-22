defmodule BankApiWeb.Router do
  use BankApiWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(BankApiWeb.Plugs.Auth)
  end

  scope "/api", BankApiWeb do
    pipe_through(:api)

    get("/", BankingController, :index)
    get("/report", BankingController, :report)
    post("/open/:email", BankingController, :open)
    get("/info/:email", BankingController, :info)
    put("/transfer/:source/:destination/:amount", BankingController, :transfer)
    put("/cash-out/:email/:amount", BankingController, :cash_out)
  end

  scope "/", BankApiWeb do
    get("/*path", CatchAllController, :index)
  end
end
