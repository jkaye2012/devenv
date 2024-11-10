# A composable development environment in pure Nix

This repository holds my personal, portable development environment. I use a consistent set of tools for all
of my engineering work, and Nix makes it easy to keep this environment up to date across different projects
and machines.

Currently, the flake is structured such that:

* A default set of packages is exposed so that the entire environment can be relied upon in downstream flakes as a build input
* An isolated package per individually configured tool is exposed so that packages can be used piecemeal in downstream flakes
  if necessary
* A default `devShell` is exposed that can be relied upon in downstream flakes via `mkShell.inputsFrom`

# Tools

The following tools are configured and exposed by the development environment.

## [Helix](https://helix-editor.com/)

The Helix text editor along with my customized configuration and any tools that are required for standard operation.

## [Lazygit](https://github.com/jesseduffield/lazygit)

A thin Git client that simplifies standard usage.

## [Zellij](https://zellij.dev/)

A terminal multiplexer with a modern UI and sensible defaults.

The keybindings are heavily customized to make the tool more compatible with standard Unix keybindings.

# Shell customizations

The `devShell` exposed by the flake includes customizations that are propagated to downstream shells using `mkShell.inputsFrom`.

## Aliases

* `lz`: `lazygit`
