defmodule Vox.Commands.Planning do
  @moduledoc """
  Sends the URL to MyEfrei planning page
  """

  @behaviour Vox.Command

  alias Vox.Utils.InteractionResponse

  require Logger

  @impl Vox.Command
  def spec(name) do
    %{name: name, description: "Send MyEfrei planning page's URL"}
  end

  @impl Vox.Command
  def handle_interaction(interaction) do
    %{guild_id: guild_id, member: member} = interaction
    user_id = member.user.id

    Logger.metadata(user_id: user_id, guild_id: guild_id)

    Logger.debug("Responding to planning interaction")

    InteractionResponse.send_response(
      interaction,
      "https://www.myefrei.fr/portal/student/planning"
    )
  end
end
