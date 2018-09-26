defmodule BankApiWeb.BankingControllerTest do
  use BankApiWeb.ConnCase, async: true

  alias Ecto.Adapters.SQL.Sandbox

  @transfer BankLogic.Schemas.Transaction.operations().transfer
  @cash_out BankLogic.Schemas.Transaction.operations().cash_out

  @authorization_error %{"errors" => "authentication required"}

  setup %{conn: conn} do
    Sandbox.checkout(BankLogic.Repo)
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  defp authenticate(conn) do
    put_req_header(conn, "authorization", "Basic YmFja29mZmljZTpiYWNrb2ZmaWNl")
  end

  describe "/api" do
    setup %{conn: conn} do
      {:ok, conn: conn, path: banking_path(conn, :index)}
    end

    test "authorization required", %{conn: conn, path: path} do
      conn =
        conn
        |> get(path)

      response = json_response(conn, 401)

      assert response == @authorization_error
    end

    test "empty list when there are no accounts", %{conn: conn, path: path} do
      conn =
        conn
        |> authenticate
        |> get(path)

      response = json_response(conn, 200)

      assert response == []
    end

    test "list items when there are accounts", %{conn: conn, path: path} do
      BankLogic.open()
      BankLogic.open()

      conn =
        conn
        |> authenticate
        |> get(path)

      response = json_response(conn, 200)

      assert Enum.count(response) == 2
    end
  end

  describe "/api/open" do
    setup %{conn: conn} do
      {:ok, conn: conn, path: banking_path(conn, :create)}
    end

    test "authorization required", %{conn: conn, path: path} do
      conn =
        conn
        |> post(path)

      response = json_response(conn, 401)

      assert response == @authorization_error
    end

    test "creates new account", %{conn: conn, path: path} do
      conn =
        conn
        |> authenticate
        |> post(path)

      response = json_response(conn, 200)

      assert response == %{
               "amount" => "R$1.000,00",
               "number" => response["number"],
               "id" => response["id"]
             }
    end
  end

  describe "/api/balance/:number" do
    test "authorization required", %{conn: conn} do
      path = banking_path(conn, :balance, "16ec49e5")

      conn =
        conn
        |> get(path)

      response = json_response(conn, 401)

      assert response == @authorization_error
    end

    test "account does not exist", %{conn: conn} do
      path = banking_path(conn, :balance, "16ec49e5")

      conn =
        conn
        |> authenticate
        |> get(path)

      response = json_response(conn, 422)["errors"]
      assert response == "account does not exist"
    end

    test "shows account", %{conn: conn} do
      {:ok, source} = BankLogic.open()

      path = banking_path(conn, :balance, source.number)

      conn =
        conn
        |> authenticate
        |> get(path)

      response = json_response(conn, 200)

      assert response == %{
               "amount" => "R$1.000,00",
               "id" => response["id"],
               "number" => source.number
             }
    end
  end

  describe "/api/statement/:number" do
    test "authorization required", %{conn: conn} do
      path = banking_path(conn, :statement, "16ec49e5")

      conn =
        conn
        |> get(path)

      response = json_response(conn, 401)

      assert response == @authorization_error
    end

    test "account does not exist", %{conn: conn} do
      path = banking_path(conn, :statement, "16ec49e5")

      conn =
        conn
        |> authenticate
        |> get(path)

      response = json_response(conn, 422)["errors"]
      assert response == "account does not exist"
    end

    test "shows statements", %{conn: conn} do
      {:ok, source} = BankLogic.open()

      data = %{
        source: source.number,
        amount: 12_931
      }

      BankLogic.cash_out(data)

      path = banking_path(conn, :statement, source.number)

      conn =
        conn
        |> authenticate
        |> get(path)

      response = json_response(conn, 200)

      assert Enum.count(response) === 1
    end
  end

  describe "/api/transfer/:source/:destination/:amount" do
    test "authorization required", %{conn: conn} do
      path = banking_path(conn, :transfer, "16ec49e5", "17ec49e5", 10)

      conn =
        conn
        |> post(path)

      response = json_response(conn, 401)

      assert response == @authorization_error
    end

    test "one of the accounts does not exist", %{conn: conn} do
      path = banking_path(conn, :transfer, "16ec49e5", "17ec49e5", 10)

      conn =
        conn
        |> authenticate
        |> post(path)

      response = json_response(conn, 422)["errors"]
      assert response == "one of the accounts does not exist"
    end

    test "accounts are equals", %{conn: conn} do
      path = banking_path(conn, :transfer, "16ec49e5", "16ec49e5", 10)

      conn =
        conn
        |> authenticate
        |> post(path)

      response = json_response(conn, 422)["errors"]
      assert response == %{"accounts" => ["source and destination are equals"]}
    end

    test "there's no enough money", %{conn: conn} do
      {:ok, source} = BankLogic.open()
      {:ok, destination} = BankLogic.open()

      path = banking_path(conn, :transfer, source.number, destination.number, 100_100)

      conn =
        conn
        |> authenticate
        |> post(path)

      response = json_response(conn, 422)["errors"]
      assert response == "there's no enough money"
    end

    test "transfers money", %{conn: conn} do
      {:ok, source} = BankLogic.open()
      {:ok, destination} = BankLogic.open()

      path = banking_path(conn, :transfer, source.number, destination.number, 65_00)

      conn =
        conn
        |> authenticate
        |> post(path)

      response = json_response(conn, 200)

      assert response == %{
               "amount" => "R$65,00",
               "destination" => destination.number,
               "source" => source.number,
               "operation" => @transfer
             }
    end
  end

  describe "/api/cash_out/:source/:amount" do
    test "authorization required", %{conn: conn} do
      path = banking_path(conn, :cash_out, "16ec49e5", 10)

      conn =
        conn
        |> post(path)

      response = json_response(conn, 401)

      assert response == @authorization_error
    end

    test "account does not exist", %{conn: conn} do
      path = banking_path(conn, :cash_out, "16ec49e5", 10)

      conn =
        conn
        |> authenticate
        |> post(path)

      response = json_response(conn, 422)["errors"]
      assert response == "account does not exist"
    end

    test "there's no enough money", %{conn: conn} do
      {:ok, source} = BankLogic.open()

      path = banking_path(conn, :cash_out, source.number, 100_001)

      conn =
        conn
        |> authenticate
        |> post(path)

      response = json_response(conn, 422)["errors"]

      assert response == "there's no enough money"
    end

    test "cashs out", %{conn: conn} do
      {:ok, source} = BankLogic.open()

      path = banking_path(conn, :cash_out, source.number, 25_00)

      conn =
        conn
        |> authenticate
        |> post(path)

      response = json_response(conn, 200)

      assert response == %{
               "amount" => "R$25,00",
               "source" => source.number,
               "operation" => @cash_out
             }
    end
  end

  describe "/api/report/:start_date/:end_date" do
    test "authorization required", %{conn: conn} do
      path = banking_path(conn, :report, "2018-08-23", "2018-08-24")

      conn =
        conn
        |> get(path)

      response = json_response(conn, 401)

      assert response == @authorization_error
    end

    test "shows empty report", %{conn: conn} do
      path = banking_path(conn, :report, "2018-08-23", "2018-08-24")

      conn =
        conn
        |> authenticate
        |> get(path)

      response = json_response(conn, 200)

      assert response == %{"report" => [], "total" => "R$0,00"}
    end

    test "shows full report", %{conn: conn} do
      {:ok, source} = BankLogic.open()
      {:ok, destination} = BankLogic.open()

      data = %{
        source: source.number,
        destination: destination.number,
        amount: 12_550
      }

      BankLogic.transfer(data)
      BankLogic.transfer(data)
      BankLogic.cash_out(data)

      start_date =
        Date.utc_today()
        |> Date.to_string()

      end_date =
        Date.utc_today()
        |> Date.add(1)
        |> Date.to_string()

      path = banking_path(conn, :report, start_date, end_date)

      conn =
        conn
        |> authenticate
        |> get(path)

      response = json_response(conn, 200)

      assert response["total"] == "R$376,50"
      assert Enum.count(response["report"]) == 3
    end
  end
end
