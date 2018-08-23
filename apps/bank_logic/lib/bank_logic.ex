defmodule BankLogic do
  @moduledoc """
  Public interface to access Bank Logic
  """

  alias BankLogic.Models.{Account}

  def all do
    []
  end

  def open(params) do
    Account.create_account(params)
  end

  def info do
  end

  def report do
  end

  def transfer do
  end

  def cash_out do
  end
end
