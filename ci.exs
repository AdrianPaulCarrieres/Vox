Mix.install([
  {:dagger, "~> 0.9.7"}
])

defmodule Ci do
  alias Dagger.{Client, Container, Directory, Host}

  require Logger

  @workdir "/app"

  def run do
    client = Dagger.connect!()

    project =
      client
      |> Client.host()
      |> Host.directory(".")

    deps_cache = Client.cache_volume(client, "deps")
    dev_cache = Client.cache_volume(client, "_build/dev")
    test_cache = Client.cache_volume(client, "_build/test")

    source =
      client
      |> Client.container()
      |> Container.from("hexpm/elixir:1.15.6-erlang-26.1.1-debian-bullseye-20230612-slim")
      |> Container.with_workdir(@workdir)
      |> Container.with_file("mix.exs", Directory.file(project, "mix.exs"))
      |> Container.with_file("mix.lock", Directory.file(project, "mix.lock"))
      |> Container.with_exec(~w"mix local.rebar --force")
      |> Container.with_exec(~w"mix local.hex --force")
      |> Container.with_mounted_cache("deps", deps_cache)
      |> Container.with_exec(~w"mix deps.get")
      |> Container.with_directory("config", Directory.directory(project, "/config"))
      |> Container.with_directory(
        "lib",
        Directory.directory(project, "/lib")
      )

    hex_audit =
      source
      |> Container.with_exec(~w"mix hex.audit")
      |> Container.stdout()

    unused_deps =
      source
      |> Container.with_exec(~w"mix deps.unlock --check-unused")
      |> Container.stdout()

    dev =
      source
      |> Container.with_env_variable("MIX_ENV", "dev")
      |> Container.with_mounted_cache("_build/dev", dev_cache)
      |> Container.with_exec(~w"mix compile")

    test =
      source
      |> Container.with_env_variable("MIX_ENV", "test")
      |> Container.with_mounted_cache("_build/test", test_cache)
      |> Container.with_exec(~w"mix test")
      |> Container.stdout()

    doctor =
      dev
      |> Container.with_exec(~w"mix doctor")
      |> Container.stdout()

    credo =
      dev
      |> Container.with_file(".credo.exs", Directory.file(project, ".credo.exs"))
      |> Container.with_exec(~w"mix credo")
      |> Container.stdout()

    sobelow =
      dev
      |> Container.with_file(".sobelow-conf", Directory.file(project, ".sobelow-conf"))
      |> Container.with_exec(~w"mix sobelow --config")
      |> Container.stdout()

    format =
      dev
      |> Container.with_file(".formatter.exs", Directory.file(project, ".formatter.exs"))
      |> Container.stdout()

    Dagger.close(client)

    steps = %{
      "hex_audit" => hex_audit,
      "credo" => credo,
      "unused_deps" => unused_deps,
      "doctor" => doctor,
      "sobelow" => sobelow,
      "format" => format,
      "tests" => test
    }
    
    failed = Enum.reduce(steps, [], fn
      {step, {:ok, _results}}, acc ->
        Logger.info(step <> " was a success")
        acc
      {step, {:error, _error}}, acc ->
        Logger.warning(step <> " errored")
        [step | acc]
    end)

    Logger.error("Failed steps: " <> inspect(failed))
  end
end

Ci.run()
