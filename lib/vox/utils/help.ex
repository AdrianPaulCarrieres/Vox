defmodule Vox.Utils.Help do
  @moduledoc """
  Utils for sending help DM
  """

  use Nostrum.Struct.Embed

  alias Nostrum.Api
  alias Nostrum.Struct.Embed

  require Logger

  defstruct []

  @impl Embed
  def title(_), do: "Help"

  @impl Embed
  def author(_),
    do: %Embed.Author{
      name: "Vox",
      icon_url:
        "https://cdn.discordapp.com/attachments/916634152038715465/916759757442936852/BotEfrei.png",
      url: "https://github.com/AdrianPaulCarrieres/Vox"
    }

  @impl Embed
  def description(_), do: "Help command"
  @impl Embed
  def url(_), do: "https://github.com/AdrianPaulCarrieres/Vox/issues"
  @impl Embed
  def color(_), do: 0xFFBB00

  @impl Embed
  def footer(_),
    do: %Embed.Footer{
      text: "Contact: Adrian Black Hawk#9687 / Sunland#7954 | Profile pic : @Qaqelol"
    }

  @impl Embed
  def fields(_) do
    [
      %Embed.Field{
        name: "Voice interaction",
        value:
          "Create a voice channel and move you to it. Options are public and private, but only public has been implemented."
      }
    ]
  end

  def send_help(user_id) do
    embed = Embed.from(%Vox.Utils.Help{})

    Logger.debug("Sending help DM")

    user_id
    |> Api.create_dm!()
    |> Map.get(:id)
    |> Api.create_message(embed: embed)
  end
end
