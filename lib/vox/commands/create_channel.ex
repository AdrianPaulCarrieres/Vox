defmodule Vox.Commands.CreateChannel do
  use Bitwise

  @moduledoc """
  Create channels for the user in the two groups
  """

  @behaviour Vox.Command

  alias Nostrum.{Api, Cache.GuildCache, Struct.Overwrite}
  alias Vox.Command

  require Logger

  @category_prefix "📖 Groupe"
  @admin_role_name "Admin"

  @impl Command
  def spec(name) do
    %{
      name: name,
      description: "Create a channel with the given name in both groups",
      options: [
        %{
          type: 3,
          name: "Channel's name",
          description: "Create a channel in both categories. Must have #{@admin_role_name} role",
          required: true,
          autocomplete: false,
        }
      ]
    }
  end

  @impl Command
  def handle_interaction(interaction) do
    %{guild_id: guild_id, member: member} = interaction
  end
end
