defmodule BankLogic do
  @moduledoc """
  Public interface to access Bank Logic
  """

  alias BankLogic.Models.{Account}

  def all do
    Account.all()
  end

  def open(attrs) do
    Account.create_account(attrs)
  end

  def info do
  end

  def report do
  end

  def transfer(attrs) do
    Account.transfer(attrs)
  end

  def cash_out(attrs) do
    Account.cash_out(attrs)
  end
end
