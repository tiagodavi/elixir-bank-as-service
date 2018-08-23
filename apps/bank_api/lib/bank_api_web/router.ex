defmodule BankApiWeb.Router do
  use BankApiWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(BankApiWeb.Plugs.Auth)
  end

  scope "/api", BankApiWeb do
    pipe_through(:api)

    get("/", BankingController, :index)
    post("/open/:email", BankingController, :create)
    put("/transfer/:source/:destination/:amount", BankingController, :transfer)
    put("/cash-out/:source/:amount", BankingController, :cash_out)
    get("/report/:start_date/:end_date", BankingController, :report)
  end

  scope "/", BankApiWeb do
    get("/*path", CatchAllController, :index)
    post("/*path", CatchAllController, :index)
    put("/*path", CatchAllController, :index)
    delete("/*path", CatchAllController, :index)
  end
end
