defmodule Nordnetex.Session.Crypto do
  @doc """
  https://api.test.nordnet.se/projects/api/wiki/Erlang_example
  """
  def encrypt_auth_parameter(user, password, filename) do
    # Convert to Base64
    now_str = DateTime.utc_now() |> DateTime.to_unix(:millisecond) |> Integer.to_string()

    login_msg =
      Base.encode64(user) <> ":" <> Base.encode64(password) <> ":" <> Base.encode64(now_str)

    # Use public key to encode message
    raw_p_key = File.read!(filename)
    [enc_p_key] = :public_key.pem_decode(raw_p_key)
    p_key = :public_key.pem_entry_decode(enc_p_key)
    enc_msg = :public_key.encrypt_public(login_msg, p_key)
    # Base 64 encode the encrypted string
    Base.encode64(enc_msg)
  end
end
