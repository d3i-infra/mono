defmodule Systems.Storage.BuiltIn.SurfResearchDrive do
  @behaviour Systems.Storage.BuiltIn.Special

  alias Systems.Storage.Encryption

  require Logger

  def store(
      _folder,
      filename,
      data
    ) do
    config = get_config()
    file_url = url([config.url, config.folder, filename])

    credentials = Base.encode64("#{config.user}:#{config.password}")

    headers = [
      {"Authorization", "Basic #{credentials}"}
    ]

    data =
      if config.passphrase != nil do
        Encryption.encrypt(data, config.passphrase)
        data
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

  def list_files(_folder) do
    []
  end

  def delete_files(_folder) do
    {:error, :not_implemented}
  end

  defp url(components) do
    URI.encode(Enum.join(components, "/"))
  end

  defp get_config do
    %{
      :user => Application.get_env(:core, __MODULE__)[:user],
      :password => Application.get_env(:core, __MODULE__)[:password],
      :url => Application.get_env(:core, __MODULE__)[:url],
      :folder => Application.get_env(:core, __MODULE__)[:folder],
      :passphrase => Application.get_env(:core, __MODULE__)[:passphrase]
    }
  end
end
