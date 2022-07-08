defmodule Vox.Commands.Greet do
  @moduledoc false

  @behaviour Vox.Command

  alias Nostrum.Api
  alias Vox.Command

  @impl Command
  def spec(name) do
    %{
      name: name,
      description: "Greets someone",
      options: [
        %{
          type: 3,
          name: "name",
          description: "Who do you want to greet?",
          required: true
        }
      ]
    }
  end

  @impl Command
  def handle_interaction(interaction) do
    %{value: name} = Command.get_option(interaction, "name")

    Api.create_interaction_response(interaction, %{
      type: 4,
      data: %{content: "Hello, #{name}!"}
    })
  end
end
