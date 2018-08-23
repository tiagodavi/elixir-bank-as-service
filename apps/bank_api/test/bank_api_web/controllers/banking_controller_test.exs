defmodule BankApiWeb.BankingControllerTest do
  use BankApiWeb.ConnCase, async: true

  @authorization_error %{
    "error" => "Access Denied",
    "info" => "You don't have credentials to access this resource."
  }

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
end
