defmodule Vox.Utils.Voice do
  @moduledoc """
  Utils for voice channels
  """

  alias Nostrum.{Api, Cache.GuildCache}

  require Logger

  def purge_inactive_voice_channels(guild_id) do
    guild = GuildCache.get!(guild_id)

    temp_voice_channels = all_temp_voice_channels_id(guild.channels)
    active_voice_channels = active_voice_channels_id(guild.voice_states)

    temp_voice_channels
    |> Enum.filter(fn temp_chan_id -> temp_chan_id not in active_voice_channels end)
    |> tap(&Logger.info("Chans #{inspect(&1)} will be deleted"))
    |> Enum.map(&Api.delete_channel!(&1, "No activity"))
  end

  defp all_temp_voice_channels_id(channels) do
    channels
    |> Map.values()
    |> Enum.filter(fn chan -> chan.type == 2 && chan.name != "General" end)
    |> Enum.map(fn chan -> chan.id end)
  end

  defp active_voice_channels_id(voice_states) do
    voice_states
    |> Enum.dedup_by(fn v -> v.channel_id end)
    |> Enum.map(fn chan -> chan.channel_id end)
  end
end
