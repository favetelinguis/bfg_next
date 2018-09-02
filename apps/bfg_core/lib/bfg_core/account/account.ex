defmodule BfgCore.Account do
  @moduledoc  """
  Holds account information
  """

  def new(values) do
    %{
      account_id: Keyword.get(values, :account_id),
      total_balance: Keyword.get(values, :total_balance),
      avaliable_to_trade: Keyword.get(values, :avaliable_to_trade),
      currency: Keyword.get(values, :currency)
    }
  end
end