defmodule Hdkey.Utils do
  @moduledoc """
  Utils functions for hdkey.
  """

  alias Hdkey.Base58

  def decode_hex(hex) do
    hex
    |> String.length()
    |> rem(2)
    |> case do
      0 -> hex
      _ -> hex <> "0"
    end
    |> Base.decode16!(case: :mixed)
  end

  def encode_hex(term) do
    Base.encode16(term, case: :lower)
  end

  def hmac_sha512(text, key) do
    :sha512
    |> :crypto.hmac(key, text)
    |> Base.encode16(case: :lower)
  end

  def private_to_pub(private_key) do
    {:ok, public_key} =
      private_key
      |> decode_hex()
      |> :libsecp256k1.ec_pubkey_create(:compressed)

    encode_hex(public_key)
  end

  def encode_base58(hex) do
    checksum =
      hex
      |> sha256()
      |> sha256()
      |> String.slice(0..7)

    (hex <> checksum)
    |> String.to_integer(16)
    |> Base58.encode()
  end

  def sha256(hex) do
    :sha256
    |> :crypto.hash(decode_hex(hex))
    |> encode_hex()
  end

  def fingerprint(pub_key_hex) do
    pub_key_hex
    |> hash160()
    |> String.slice(0..7)
  end

  def hash160(hex) do
    hex
    |> sha256()
    |> ripemd160()
  end

  def ripemd160(hex) do
    :ripemd160
    |> :crypto.hash(decode_hex(hex))
    |> encode_hex()
  end

  def i_as_bytes(i) do
    i
    |> Integer.to_string(16)
    |> String.pad_leading(8, "0")
    |> Base.decode16!(case: :upper)
  end

  # __end_of_module__
end
