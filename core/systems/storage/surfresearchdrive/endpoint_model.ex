defmodule Systems.Storage.SurfResearchDrive.EndpointModel do
  use Ecto.Schema
  use Frameworks.Utility.Schema

  import Ecto.Changeset
  alias Systems.Storage.SurfResearchDrive

  @fields ~w(user password url folder passphrase)a
  @required_fields ~w(user password url folder)a
  @derive {Jason.Encoder, only: @fields}
  @derive {Inspect, except: [:user, :password, :passphrase]}
  schema "storage_endpoints_surfresearchdrive" do
    field(:user, :string)
    field(:password, :string)
    field(:url, :string)
    field(:folder, :string)
    field(:passphrase, :string, default: nil)

    timestamps()
  end

  def changeset(endpoint, params) do
    endpoint
    |> cast(params, @fields)
  end

  def validate(changeset) do
    changeset
    |> validate_required(@required_fields)
  end

  def ready?(endpoint) do
    changeset =
      changeset(endpoint, %{})
      |> validate()

    changeset.valid?()
  end

  def preload_graph(:down), do: []

  defimpl Frameworks.Concept.ContentModel do
    alias Systems.Storage.SurfResearchDrive
    def form(_), do: SurfResearchDrive.EndpointForm
    def ready?(endpoint), do: SurfResearchDrive.EndpointModel.ready?(endpoint)
  end
end
