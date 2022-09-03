defmodule Vox.Consumer do
  @moduledoc false
  use Nostrum.Consumer

  alias Vox.{Commands, Utils.Voice}

  require Logger

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:READY, _data, _ws_state}) do
    Commands.register_commands()
  end

  def handle_event({:INTERACTION_CREATE, interaction, _ws_state}) do
    Commands.handle_interaction(interaction)
  end

  def handle_event({:VOICE_STATE_UPDATE, %{channel_id: nil, guild_id: guild_id}, _ws_state}) do
    Logger.metadata(guild_id: guild_id)
    Voice.purge_inactive_voice_channels(guild_id)
  end

  def handle_event(_data) do
    :ok
  end
end
