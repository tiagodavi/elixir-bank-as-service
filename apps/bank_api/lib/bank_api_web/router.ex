defmodule BankApiWeb.Router do
  use BankApiWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(BankApiWeb.Plugs.Auth)
  end

  scope "/api", BankApiWeb do
    pipe_through(:api)

    get("/", BankingController, :index)
    get("/balance/:number", BankingController, :balance)
    get("/report/:start_date/:end_date", BankingController, :report)
    post("/open", BankingController, :create)
    post("/transfer/:source/:destination/:amount", BankingController, :transfer)
    post("/cash-out/:source/:amount", BankingController, :cash_out)
  end

  scope "/", BankApiWeb do
    match(:*, "/*path", CatchAllController, :index)
  end
end
