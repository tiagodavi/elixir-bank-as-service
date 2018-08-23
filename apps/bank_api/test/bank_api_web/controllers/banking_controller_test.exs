defmodule BankApiWeb.BankingControllerTest do
  use BankApiWeb.ConnCase, async: true

  @authorization_error %{"errors" => "authentication required"}

  setup %{conn: conn} do
    Ecto.Adapters.SQL.Sandbox.checkout(BankLogic.Repo)
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

      response = json_response(conn, 200)["data"]

      assert response == []
    end

    test "list items when there are accounts", %{conn: conn, path: path} do
      BankLogic.open(%{email: "email01@gmail.com"})
      BankLogic.open(%{email: "email02@gmail.com"})

      conn =
        conn
        |> authenticate
        |> get(path)

      response = json_response(conn, 200)["data"]

      assert Enum.count(response) == 2
    end
  end

  describe "/api/open/:email" do
    setup %{conn: conn} do
      {:ok, conn: conn, path: banking_path(conn, :create, "tiago.asp.net@gmail.com")}
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
               "amount" => 1.0e3,
               "email" => "tiago.asp.net@gmail.com",
               "id" => response["id"]
             }
    end
  end

  describe "/api/transfer/:source/:destination/:amount" do
    test "authorization required", %{conn: conn} do
      path = banking_path(conn, :transfer, "email01@gmail.com", "email02@gmail.com", 10)

      conn =
        conn
        |> put(path)

      response = json_response(conn, 401)

      assert response == @authorization_error
    end

    test "one of the accounts does not exist", %{conn: conn} do
      path = banking_path(conn, :transfer, "email01@gmail.com", "email02@gmail.com", 10)

      conn =
        conn
        |> authenticate
        |> put(path)

      response = json_response(conn, 422)["errors"]

      assert response == %{"message" => "one of the accounts does not exist"}
    end

    test "accounts are equals", %{conn: conn} do
      path = banking_path(conn, :transfer, "email01@gmail.com", "email01@gmail.com", 10)

      conn =
        conn
        |> authenticate
        |> put(path)

      response = json_response(conn, 422)["errors"]

      assert response == %{"message" => %{"accounts" => ["source and destination are equals"]}}
    end

    test "there's no enough money", %{conn: conn} do
      BankLogic.open(%{email: "email01@gmail.com"})
      BankLogic.open(%{email: "email02@gmail.com"})

      path = banking_path(conn, :transfer, "email01@gmail.com", "email02@gmail.com", 1001)

      conn =
        conn
        |> authenticate
        |> put(path)

      response = json_response(conn, 422)["errors"]

      assert response == %{"message" => "there's no enough money"}
    end

    test "transfers money", %{conn: conn} do
      BankLogic.open(%{email: "email01@gmail.com"})
      BankLogic.open(%{email: "email02@gmail.com"})

      path = banking_path(conn, :transfer, "email01@gmail.com", "email02@gmail.com", 100)

      conn =
        conn
        |> authenticate
        |> put(path)

      response = json_response(conn, 200)

      assert response == %{
               "amount" => 100.0,
               "destination" => "email02@gmail.com",
               "source" => "email01@gmail.com"
             }
    end
  end

  describe "/api/cash_out/:source/:amount" do
    test "authorization required", %{conn: conn} do
      path = banking_path(conn, :cash_out, "email01@gmail.com", 10)

      conn =
        conn
        |> put(path)

      response = json_response(conn, 401)

      assert response == @authorization_error
    end

    test "account does not exist", %{conn: conn} do
      path = banking_path(conn, :cash_out, "email01@gmail.com", 10)

      conn =
        conn
        |> authenticate
        |> put(path)

      response = json_response(conn, 422)["errors"]
      assert response == %{"message" => "account does not exist"}
    end

    test "there's no enough money", %{conn: conn} do
      BankLogic.open(%{email: "email01@gmail.com"})

      path = banking_path(conn, :cash_out, "email01@gmail.com", 1001)

      conn =
        conn
        |> authenticate
        |> put(path)

      response = json_response(conn, 422)["errors"]

      assert response == %{"message" => "there's no enough money"}
    end

    test "cashs out", %{conn: conn} do
      BankLogic.open(%{email: "email01@gmail.com"})

      path = banking_path(conn, :cash_out, "email01@gmail.com", 100)

      conn =
        conn
        |> authenticate
        |> put(path)

      response = json_response(conn, 200)

      assert response == %{
               "amount" => 100.0,
               "source" => "email01@gmail.com"
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
      assert response == %{"data" => %{"report" => [], "total" => 0}}
    end

    test "shows full report", %{conn: conn} do
      BankLogic.open(%{email: "email01@gmail.com"})
      BankLogic.open(%{email: "email02@gmail.com"})

      data = %{
        source: "email01@gmail.com",
        destination: "email02@gmail.com",
        amount: 125.50
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

      response = json_response(conn, 200)["data"]

      assert response["total"] == 376.50
      assert Enum.count(response["report"]) == 3
    end
  end
end
