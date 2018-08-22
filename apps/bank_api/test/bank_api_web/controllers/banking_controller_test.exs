defmodule BankApiWeb.BankingControllerTest do
  use BankApiWeb.ConnCase, async: true

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

      assert response == %{
               "error" => "Access Denied",
               "info" => "You don't have credentials to access this resource."
             }
    end

    test "empty list when there are no accounts", %{conn: conn, path: path} do
      conn =
        conn
        |> authenticate
        |> get(path)

      response = json_response(conn, 200)["data"]

      assert response == []
    end
  end
end
