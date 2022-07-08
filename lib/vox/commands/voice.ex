defmodule Vox.Commands.Voice do
  use Bitwise
  @moduledoc false

  @behaviour Vox.Command

  alias Nostrum.{Api, Cache.GuildCache, Struct.Overwrite}
  alias Vox.Command

  require Logger

  @category_name "📢 Voice Channels"

  @impl Command
  def spec(name) do
    %{
      name: name,
      description: "Create voice channel",
      options: [
        %{
          type: 3,
          name: "privacy",
          description:
            "Create a public or private voice channel. If private, you will need to use !invite",
          required: true,
          autocomplete: false,
          choices: [
            %{
              name: "private",
              value: "private"
            },
            %{
              name: "public",
              value: "public"
            }
          ]
        }
      ]
    }
  end

  @impl Command
  def handle_interaction(interaction) do
    # Get data
    %{guild_id: guild_id, member: member} = interaction
    user_id = member.user.id

    Logger.metadata(guild_id: guild_id, user_id: user_id)

    # We won't handle voice channel privacy for now
    # privacy = Command.get_option(interaction, "privacy")
    privacy = "public"

    with {:ok, guild} <- GuildCache.get(guild_id),
         {:ok, _} <- voice_channel_of_user(guild, user_id),
         {:ok, category} <- voice_category(guild),
         channel_name <- channel_name(privacy, member),
         permissions <- author_permissions(user_id) |> Enum.map(&Map.from_struct/1),
         {:ok, v} <- create_voice_channel(guild.id, channel_name, category.id, permissions) do
      Logger.debug("Moving user #{member.user.username} to their new vocal channel")
      Api.modify_guild_member!(guild_id, user_id, channel_id: v.id)

      Vox.Utils.Command.send_ephemeral(
        interaction,
        "You've been moved to your new #{channel_name} channel"
      )

         else
          {:error, error} ->
            Vox.Utils.Command.send_response(interaction, "Error: #{error}")
    end
  end

  defp voice_channel_of_user(guild, user_id) do
    voice_channel =
      guild
      |> Map.get(:voice_states)
      |> Enum.find(fn voice_state -> voice_state.user_id == user_id end)

    case voice_channel do
      nil ->
        Logger.warn("User not in voice channel")
        {:error, "You need to join a voice channel first."}

      v ->
        Logger.debug("User found in voice channel")
        {:ok, v}
    end
  end

  defp voice_category(guild) do
    category =
      guild
      |> Map.get(:channels)
      |> Map.values()
      |> Enum.find(fn channel -> channel.name == @category_name end)

    case category do
      nil ->
        Logger.warn(@category_name <> " not found")
        {:error, @category_name <> " not found"}

      category ->
        {:ok, category}
    end
  end

  defp channel_name(privacy, member) do
    prefixe = member.nick || member.user.username

    emoji =
      if privacy == "public" do
        "🔓"
      else
        "🔒"
      end

    "#{emoji}·#{prefixe}'s voice"
  end

  defp author_permissions(user_id) do
    [%Overwrite{type: 1, id: user_id, allow: "30408704"}]
  end

  defp create_voice_channel(guild_id, channel_name, parent_id, permissions) do
    Api.create_guild_channel(guild_id,
      name: channel_name,
      type: 2,
      parent_id: parent_id,
      permission_overwrites: permissions
    )
  end
end
