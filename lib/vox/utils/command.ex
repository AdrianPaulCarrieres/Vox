defmodule Vox.Utils.Command do
  use Bitwise

  @moduledoc """
  Provides common functions for commands
  """

  alias Nostrum.{Api, Struct.Interaction}

  @spec send_ephemeral(Interaction.t(), binary()) :: {:ok}
  def send_ephemeral(%Interaction{} = interaction, content) do
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
    response = %{
      type: 4,
      data: %{
        content: content
      }
    }

    Api.create_interaction_response(interaction, response)
  end
end
