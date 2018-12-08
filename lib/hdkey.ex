defmodule Hdkey do
  @moduledoc """
  Documentation for Hdkey.
  """

  defstruct [:private_key, :public_key, :chain_code, :depth, :index, :parent]

  @master_key "Bitcoin seed"
  @order String.to_integer("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", 16)

  alias Hdkey.{Base58, Utils}

  defdelegate decode_hex(hex), to: Utils
  defdelegate encode_hex(hex), to: Utils

  @doc """
  Generate master key from seed.
  """
  def from_master_seed(hex_seed) do
    <<private_key::bytes-size(64), chain_code::bytes-size(64)>> =
      hex_seed
      |> Utils.decode_hex()
      |> Utils.hmac_sha512(@master_key)

    %__MODULE__{
      private_key: private_key,
      public_key: Utils.private_to_pub(private_key),
      chain_code: chain_code,
      depth: 0,
      index: 0
    }
  end

  @doc """
  Key to json.
  """
  def to_json(%{chain_code: chain_code, public_key: public_key} = hdkey, network \\ "mainnet") do
    {prv_version, pub_version} = version_pub_pri(network)
    key_depth = key_depth(Map.get(hdkey, :depth))
    child_index = child_index(Map.get(hdkey, :index))
    parent_key_fp = parent_key_fp(hdkey)
    xpub = pub_version <> key_depth <> parent_key_fp <> child_index <> chain_code <> public_key

    case Map.get(hdkey, :private_key) do
      nil ->
        %{xpub: Utils.encode_base58(xpub)}

      private_key ->
        xprv =
          prv_version <>
            key_depth <> parent_key_fp <> child_index <> chain_code <> "00#{private_key}"

        %{xpub: Utils.encode_base58(xpub), xprv: Utils.encode_base58(xprv)}
    end
  end

  @doc false
  defp version_pub_pri("mainnet"), do: {"0488ade4", "0488b21e"}
  defp version_pub_pri(_), do: {"04358394", "043587cf"}

  @doc false
  defp key_depth(depth) do
    depth
    |> Integer.to_string(16)
    |> String.pad_leading(2, "0")
    |> String.downcase()
  end

  @doc false
  defp child_index(index) do
    index
    |> Integer.to_string(16)
    |> String.pad_leading(8, "0")
    |> String.downcase()
  end

  @doc false
  defp parent_key_fp(%{depth: 0}), do: "00000000"
  defp parent_key_fp(hdkey), do: Utils.fingerprint(hdkey.parent.public_key)

  @doc """

  """
  def from_json(obj) do
    <<_::bytes-size(8), depth::bytes-size(2), _::bytes-size(8), child_index::bytes-size(8),
      chain_code::bytes-size(64), key::bytes-size(66),
      _::binary>> =
      "0"
      |> Kernel.<>(Integer.to_string(Base58.decode(obj), 16))
      |> String.slice(0..-9)
      |> String.downcase()

    {private_key, public_key} =
      case key do
        "00" <> tail_key ->
          {tail_key, Utils.private_to_pub(tail_key)}

        _ ->
          {nil, key}
      end

    %__MODULE__{
      private_key: private_key,
      public_key: public_key,
      chain_code: chain_code,
      depth: String.to_integer(depth, 16),
      index: String.to_integer(child_index, 16)
    }
  end

  @doc """

  """
  def derive_child(%{private_key: private_key} = hdkey, index \\ 0, only_public \\ false) do
    <<child_private_key::bytes-size(64), child_chain_code::bytes-size(64)>> =
      build_one_way_hash(private_key, hdkey.public_key, hdkey.chain_code, index)

    child_private_key_hex =
      child_private_key
      |> String.to_integer(16)
      |> Kernel.+(String.to_integer(private_key, 16))
      |> rem(@order)
      |> Integer.to_string(16)
      |> String.downcase()
      |> String.pad_leading(64, "0")

    child_chain_code_hex =
      child_chain_code
      |> String.downcase()
      |> String.pad_leading(64, "0")

    %__MODULE__{
      private_key: if(only_public, do: nil, else: child_private_key_hex),
      public_key: Utils.private_to_pub(child_private_key_hex),
      chain_code: child_chain_code_hex,
      depth: hdkey.depth + 1,
      index: index,
      parent: hdkey
    }
  end

  @doc false
  defp build_one_way_hash(nil, _, _, i) when i >= 0x80000000, do: raise("private key missing!")

  defp build_one_way_hash(private_key_hex, _, chain_code_hex, i) when i >= 0x80000000 do
    message = <<0>> <> Utils.decode_hex(private_key_hex) <> Utils.i_as_bytes(i)
    Utils.hmac_sha512(message, Utils.decode_hex(chain_code_hex))
  end

  defp build_one_way_hash(_, public_key_pub, chain_code_hex, i) when i >= 0 and i < 0x80000000 do
    message = Utils.decode_hex(public_key_pub) <> Utils.i_as_bytes(i)
    Utils.hmac_sha512(message, Utils.decode_hex(chain_code_hex))
  end

  @doc """

  """
  def derive_descendant_by_path(hdkey, path) do
    case String.split(path, "/") do
      ["m" | tail] -> derive(hdkey, tail)
      ["M" | tail] -> derive(hdkey, tail, true)
    end
  end

  @doc false
  defp derive(hdkey, [head | tail], only_public \\ false) do
    index =
      case String.ends_with?(head, "'") do
        true ->
          head
          |> String.slice(0..-2)
          |> String.to_integer()
          |> Kernel.+(0x80000000)

        false ->
          String.to_integer(head)
      end

    if length(tail) == 0 do
      derive_child(hdkey, index, only_public)
    else
      derive(derive_child(hdkey, index, false), tail, only_public)
    end
  end

  # __end_of_module__
end
