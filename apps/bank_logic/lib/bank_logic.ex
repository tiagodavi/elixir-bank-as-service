defmodule BankLogic do
  @moduledoc """
  Module that implements Bank's public interface
  """

  alias BankLogic.Account

  @doc """
  Returns all accounts

  ## Examples
  iex> BankLogic.all()

  {:ok, [%BankLogic.Schemas.Account{
     __meta__: #Ecto.Schema.Metadata<:loaded, "accounts">,
     amount: %Money{amount: 95000, currency: :BRL},
     id: 1,
     inserted_at: ~N[2018-09-19 00:06:49.530550],
     number: "1282ccff",
     updated_at: ~N[2018-09-19 00:13:35.703990]
   }]}
  """
  @spec all() :: {:ok, [map()]}
  def all do
    Account.all()
  end

  @doc """
  Opens a new account

  ## Examples
  iex> BankLogic.open

  {:ok,
  %BankLogic.Schemas.Account{
   __meta__: #Ecto.Schema.Metadata<:loaded, "accounts">,
   amount: %Money{amount: 100000, currency: :BRL},
   id: 1,
   inserted_at: ~N[2018-09-19 00:06:49.530550],
   number: "1282ccff",
   updated_at: ~N[2018-09-19 00:06:49.530577]
  }}
  """
  @spec open() :: {:ok, map()}
  def open do
    Account.create()
  end

  @doc """
  Returns account's balance

  ## Parameters
  - number: Account's number

  ## Examples
  iex> BankLogic.balance(%{number: "1282ccff"})

  {:ok,
   %BankLogic.Schemas.Account{
     __meta__: #Ecto.Schema.Metadata<:loaded, "accounts">,
     amount: %Money{amount: 100000, currency: :BRL},
     id: 1,
     inserted_at: ~N[2018-09-19 00:06:49.530550],
     number: "1282ccff",
     updated_at: ~N[2018-09-19 00:06:49.530577]
   }}
  """
  @spec balance(%{number: String.t()}) ::
          {:ok, map()}
          | {:error, String.t()}
  def balance(attrs) do
    Account.balance(attrs)
  end

  @doc """
  Returns Bank's report

  ## Parameters
  - start_date: a date in american format
  - end_date: a date in american format

  ## Examples
  iex> BankLogic.report(%{start_date: "2018-09-18", end_date: "2018-09-19"})

  {:ok,
  %{
   report: [
     %{
       amount: %Money{amount: 5000, currency: :BRL},
       destination: "3db1beb4",
       operation: 1,
       source: "1282ccff"
     },
     %{
       amount: %Money{amount: 5000, currency: :BRL},

       destination: nil,
       operation: 2,
       source: "1282ccff"
     }
   ],
   total: %Money{amount: 10000, currency: :BRL}
  }}
  """
  @spec report(%{start_date: String.t(), end_date: String.t()}) :: {:ok, map()}
  def report(attrs) do
    Account.report(attrs)
  end

  @doc """
  Returns account's statement

  ## Parameters
  - number: Account's number

  ## Examples
  iex> BankLogic.statement(%{number: "1282ccff"})

  {:ok,
  [
   %{
     amount: %Money{amount: 10000, currency: :BRL},
     balance: %Money{amount: 90000, currency: :BRL},
     operation: "transfer"
   },
   %{
     amount: %Money{amount: 10000, currency: :BRL},
     balance: %Money{amount: 80000, currency: :BRL},
     operation: "transfer"
   },
   %{
     amount: %Money{amount: 10000, currency: :BRL},
     balance: %Money{amount: 70000, currency: :BRL},
     operation: "cash out"
   }
  ]}
  """
  @spec statement(%{number: String.t()}) :: {:ok, []} | {:error, String.t()}
  def statement(attrs) do
    Account.statement(attrs)
  end

  @doc """
  Transfers money between accounts

  ## Parameters
  - source: Account's number
  - destination: Account's number
  - amount: Amount to transfer

  ## Examples
  iex> BankLogic.transfer(%{source: "1282ccff", destination: "3db1beb4", amount: 50_00})

    {:ok,
   %{
     amount: %Money{amount: 5000, currency: :BRL},
     destination: "3db1beb4",
     operation: 1,
     source: "1282ccff"
   }}
  """
  @spec transfer(%{source: String.t(), destination: String.t(), amount: integer()}) ::
          {:ok, map()}
          | {:error, map()}
          | {:error, String.t()}
  def transfer(attrs) do
    Account.transfer(attrs)
  end

  @doc """
  Cashs out money from source

  ## Parameters
  - source: Account's number
  - amount: Amount to cash out

  ## Examples
  iex> BankLogic.cash_out(%{source: "1282ccff", amount: 50_00})

    {:ok,
   %{
     amount: %Money{amount: 5000, currency: :BRL},
     operation: 2,
     source: "1282ccff"
   }}
  """
  @spec cash_out(%{source: String.t(), amount: integer()}) ::
          {:ok, map()}
          | {:error, map()}
          | {:error, String.t()}
  def cash_out(attrs) do
    Account.cash_out(attrs)
  end
end
