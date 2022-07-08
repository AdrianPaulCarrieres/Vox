#!/bin/bash
# docker entrypoint script.

bin="/app/bin/vox"
# start the elixir application
exec "$bin" "start"
