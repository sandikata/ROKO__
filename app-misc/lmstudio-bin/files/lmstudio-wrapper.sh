#!/bin/sh
# Electron apps често искат --no-sandbox извън chromium sandbox env
exec /opt/lmstudio/lmstudio --no-sandbox "$@"

