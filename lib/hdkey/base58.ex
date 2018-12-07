defmodule Hdkey.Base58 do
  @moduledoc false

  @alphabet '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'

  @doc """
  Encodes the given term.
  """
  def encode(x), do: encode(x, [])

  defp encode(0, []), do: "1"
  defp encode(0, acc), do: acc |> to_string

  defp encode(x, acc) do
    encode(div(x, 58), [Enum.at(@alphabet, rem(x, 58)) | acc])
  end

  @doc """
  Decodes the given string.
  """
  def decode(enc), do: decode(enc |> to_charlist, 0)

  defp decode([], acc), do: acc

  defp decode([c | cs], acc) do
    decode(cs, acc * 58 + Enum.find_index(@alphabet, &(&1 == c)))
  end
end
