defmodule Systems.Storage.SurfResearchDrive.Backend do
  @behaviour Systems.Storage.Backend

  alias Systems.Storage.SurfResearchDrive.Encryption

  require Logger

  def store(
        %{
          "user" => username,
          "password" => password,
          "url" => url,
          "folder" => folder,
          "passphrase" => passphrase
        } = _endpoint,
        data,
        meta_data
      ) do
    filename = filename(meta_data)
    file_url = url([url, folder, filename])

    credentials = Base.encode64("#{username}:#{password}")

    headers = [
      {"Authorization", "Basic #{credentials}"}
    ]

    data =
      if passphrase != nil do
        Encryption.encrypt(data, passphrase)
      else
        data
      end

    case HTTPoison.put(file_url, data, headers) do
      {:ok, %{status_code: 201}} ->
        :ok

      {_, %{status_code: status_code, body: body}} ->
        {:error, "status_code=#{status_code},message=#{body}"}

      {:error, error} ->
        IO.inspect(error)
        {:error, error}
    end
  end

  def list_files(_endpoint) do
    Logger.error("Not yet implemented: list_files/1")
    {:error, :not_implemented}
  end

  def delete_files(_endpoint) do
    Logger.error("Not yet implemented: delete_files/1")
    {:error, :not_implemented}
  end

  def connected?(_), do: false

  defp filename(%{"identifier" => identifier}) do
    identifier
    |> Enum.map_join("_", fn [key, value] -> "#{key}-#{value}" end)
    |> then(&"#{&1}.json")
  end

  defp url(components) do
    URI.encode(Enum.join(components, "/"))
  end
end
