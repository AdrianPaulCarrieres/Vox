defmodule Vox.Commands.Help do
  @moduledoc false
  @behaviour Vox.Command
  require Logger

  alias Vox.Utils.Help

  @impl Vox.Command
  def spec(name) do
    %{
      name: name,
      description: "Send help message"
    }
  end

  @impl Vox.Command
  def handle_interaction(interaction) do
    %{guild_id: guild_id, member: member} = interaction
    user_id = member.user.id

    Logger.metadata(user_id: user_id, guild_id: guild_id)

    Logger.debug("Responding to help interaction")

    Help.send_help(user_id)

    Vox.Command.send_ephemeral(interaction, "Help was sent in your DM!")
  end
end
