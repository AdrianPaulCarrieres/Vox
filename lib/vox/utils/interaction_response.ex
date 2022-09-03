defmodule Vox.Utils.InteractionResponse do
  @moduledoc """
  Utils for Interaction responses
  """

  import Bitwise

  alias Nostrum.{Api, Struct.Interaction}

  require Logger

  @spec send_ephemeral(Interaction.t(), binary()) :: {:ok}
  def send_ephemeral(%Interaction{} = interaction, content) do
    Logger.debug("Sending ephemeral response")

    response = %{
      type: 4,
      data: %{
        content: content,
        # For ephemeral message
        flags: 1 <<< 6
      }
    }

    Api.create_interaction_response(interaction, response)
  end

  @spec send_response(Interaction.t(), binary()) :: {:ok}
  def send_response(%Interaction{} = interaction, content) do
    Logger.debug("Sending response")

    response = %{
      type: 4,
      data: %{
        content: content
      }
    }

    Api.create_interaction_response(interaction, response)
  end
end
