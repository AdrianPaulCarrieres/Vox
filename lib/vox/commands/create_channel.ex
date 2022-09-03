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

    with {:ok, guild} <- GuildCache.get(guild_id),
        guild_roles <- Map.values(guild.roles),
         true <- is_admin?(guild_roles, member.roles) do

    else
      {:guild_error, error} ->
        Logger.warn("Guild error: #{error}")
        Command.send_response(interaction, error)

      {:user_error, error} ->
        Logger.warn("User error: #{error}")
        Command.send_ephemeral(interaction, error)

      {_, error} ->
        Logger.error(inspect(error))
        Command.send_response(interaction, "Error: #{inspect(error)}")
    end

    Command.send_ephemeral(interaction, "hihi")
  end

  defp is_admin?(guild_roles, member_roles)
  defp is_admin?([], _), do: {:guild_error, "No roles in guild"}
  defp is_admin?(_, []), do: {:user_error, "Not authorized"}

  defp is_admin?(roles, member_roles) do
    admin_role = Enum.find(roles, fn role -> role.name == @admin_role_name end)
    admin_role.id in member_roles
  end
end
