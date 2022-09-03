defmodule Vox.Commands.CreateChannel do
  @moduledoc """
  Create text channels in both groups
  """

  @behaviour Vox.Command

  alias Nostrum.{Api, Cache.GuildCache}
  alias Vox.{Command, Utils.InteractionResponse}

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
    %{value: name} = Command.get_option(interaction, "name")

    %{guild_id: guild_id, member: member} = interaction
    user_id = member.user.id

    Logger.metadata(guild_id: guild_id, user_id: user_id)

    with {:ok, guild} <- GuildCache.get(guild_id),
         guild_roles <- Map.values(guild.roles),
         true <- is_admin?(guild_roles, member.roles),
         {:ok, categories} <- groups_categories(guild) do
      Enum.each(categories, fn c ->
        Api.create_guild_channel(guild_id,
          name: name,
          type: 0,
          parent_id: c.id
        )
      end)

      InteractionResponse.send_ephemeral(interaction, "Channels created")
    else
      {:guild_error, error} ->
        Logger.warn("Guild error: #{error}")
        InteractionResponse.send_response(interaction, error)

      {:user_error, error} ->
        Logger.warn("User error: #{error}")
        InteractionResponse.send_ephemeral(interaction, error)

      {_, error} ->
        Logger.error(inspect(error))
        InteractionResponse.send_response(interaction, "Error: #{inspect(error)}")
    end
  end

  defp is_admin?(guild_roles, member_roles)
  defp is_admin?([], _), do: {:guild_error, "No roles in guild"}
  defp is_admin?(_, []), do: {:user_error, "Not authorized"}

  defp is_admin?(roles, member_roles) do
    admin_role = Enum.find(roles, fn role -> role.name == @admin_role_name end)
    admin_role.id in member_roles
  end

  defp groups_categories(guild) do
    categories_name = 1..2 |> Enum.map(&"#{@category_prefix} #{&1}")

    categories =
      guild
      |> Map.get(:channels)
      |> Map.values()
      |> Enum.filter(fn channel -> channel.name in categories_name end)

    case categories do
      [] ->
        Logger.warn("Groups categories not found")
        {:guild_error, "Groups categories not found"}

      categories ->
        Logger.debug("Categories found")
        {:ok, categories}
    end
  end
end
