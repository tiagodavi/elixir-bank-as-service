defmodule BankApiWeb.Router do
  use BankApiWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(BankApiWeb.Plugs.Auth)
  end

  scope "/api", BankApiWeb do
    pipe_through(:api)

    get("/", BankingController, :index)
    post("/open", BankingController, :create)
    put("/transfer/:source/:destination/:amount", BankingController, :transfer)
    put("/cash-out/:source/:amount", BankingController, :cash_out)
    get("/report/:start_date/:end_date", BankingController, :report)
  end

  scope "/", BankApiWeb do
    match(:*, "/*path", CatchAllController, :index)
  end
end
