set shell := ["bash", "-uc"]


default:
  @just --list

test:
  echo {{invocation_directory()}}

podman-rm-vol:
  podman volume rm zmk-config
  podman volume rm zmk-modules

podman-setup-vol:
  podman volume create --driver local -o o=bind -o type=none -o device="{{invocation_directory()}}" zmk-config
  podman volume create --driver local -o o=bind -o type=none -o device="{{invocation_directory()}}/../zmk/app/keymap-module/modules" zmk-modules

podman-vol: podman-rm-vol podman-setup-vol

podman-setup-cont:
  podman build -t zmkbuild -f Dockerfile {{invocation_directory()}}/../zmk/.devcontainer

podman-run:
  podman run -it --rm \
  --security-opt label=disable \
  --workdir /workspaces/zmk \
  -v {{invocation_directory()}}/../zmk:/workspaces/zmk \
  -v {{invocation_directory()}}:/workspaces/zmk-config \
  -v {{invocation_directory()}}/../zmk/app/keymap-module/modules:/workspaces/zmk-modules \
  -p 3000:3000 \
  zmkbuild /bin/bash

