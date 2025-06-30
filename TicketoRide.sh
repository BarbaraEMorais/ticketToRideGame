#!/bin/sh
echo -ne '\033c\033]0;TicketoRide\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/TicketoRide.x86_64" "$@"
