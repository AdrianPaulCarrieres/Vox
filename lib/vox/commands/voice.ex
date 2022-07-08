defmodule Vox.Commands.Voice do
  use Bitwise
  @moduledoc false

  @behaviour Vox.Command

  alias Nostrum.{Api, Cache.GuildCache, Struct.Overwrite}
  alias Vox.Command

  require Logger

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

    result =
      case get_voice_channel_of_user(guild_id, user_id) do
        nil ->
          Logger.warn("User should join voice channel first")
          "You need to join a voice channel first."

        _ ->
          Logger.debug("Collecting guild's data")
          parent_id = get_voice_category(guild_id) |> Map.get(:id)
          channel_name = channel_name(privacy, member)

          permissions = author_permissions(user_id) |> Enum.map(&Map.from_struct/1)

          Logger.debug("Creating voice channel")

          new_voice_channel =
            Api.create_guild_channel!(guild_id,
              name: channel_name,
              type: 2,
              parent_id: parent_id,
              permission_overwrites: permissions
            )

          Logger.debug("Moving user #{member.user.username} to their new vocal channel")
          Api.modify_guild_member!(guild_id, member.user.id, channel_id: new_voice_channel.id)
          "You've been moved to your new #{privacy} vocal channel"
      end

    Logger.debug(inspect(result))

    response = %{
      type: 4,
      data: %{
        content: result,
        # For ephemeral message
        flags: 1 <<< 6
      }
    }

    Api.create_interaction_response(interaction, response)
  end

  defp get_voice_channel_of_user(guild_id, user_id) do
    guild_id
    |> GuildCache.get!()
    |> Map.get(:voice_states)
    |> Enum.find(%{}, fn v -> v.user_id == user_id end)
    |> Map.get(:channel_id)
  end

  defp get_voice_category(guild_id) do
    guild_id
    |> GuildCache.get!()
    |> Map.get(:channels)
    |> Map.values()
    |> Enum.find(fn channel -> channel.name == "📢 Voice Channels" end)
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
end
