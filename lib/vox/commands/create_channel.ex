defmodule Vox.Commands.CreateChannel do
  @moduledoc """
  Create text channels in both groups
  """

  @behaviour Vox.Command

  use Bitwise

  alias Nostrum.{Api, Cache.GuildCache, Struct.Overwrite}
  alias Vox.Command

  require Logger

  @category_prefix "📖 Groupe"
  @admin_role_name "Admin"

  @impl Command
  def spec(name) do
    %{
      name: name,
      description: "Create channels in both groups.",
      options: [
        %{
          type: 3,
          name: "name",
          description: "Name of the channel",
          required: true
        }
      ]
    }
  end

  @impl Command
  def handle_interaction(interaction) do
    %{guild_id: guild_id, member: member} = interaction
    user_id = member.user.id

    Logger.metadata(guild_id: guild_id, user_id: user_id)

    dbg(interaction)

    Command.send_ephemeral(interaction, "hihi")
  end
end
