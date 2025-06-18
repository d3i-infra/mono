defmodule Systems.Storage.Encryption do
  @moduledoc """
  Documentation for `Systems.Storage.Encryption`.
  """

  @doc """
  Encrypt file with AES-256-CBC 

  The hashed passphrase is the encryption key
  The hash function is there to guarantee the key consists of 256 bits
  The hasing function does not offer protection.
  If you know the hash or the passphrase you can decrypt the data

  Decryption can be done with:
  openssl enc -d -aes-256-cbc -in <(tail -c +17 file.enc) \
    -out file.txt \
    -K <sha256 of passphrase> \
    -iv <base16 encode of first 16 bytes of file.enc>
  """
  def encrypt(content, passphrase) do
    # generate key and iv
    key = :crypto.hash(:sha256, passphrase)
    iv = :crypto.strong_rand_bytes(16)

    padded_content = pad(content, 16)

    # Encrypt content
    cipher_text = :crypto.crypto_one_time(:aes_256_cbc, key, iv, padded_content, true)

    # Prepend IV and write the result
    iv <> cipher_text
  end

  @doc """
  Applies PKCS7 padding to the given binary.
  """
  def pad(data, block_size) do
    padding_size = block_size - rem(byte_size(data), block_size)
    data <> :binary.copy(<<padding_size>>, padding_size)
  end
end

