{ pkgs, pkgs-unstable }:
with pkgs;
[
  bazel
  pkgs-unstable.claude-code
  ghostty
  glab
  jujutsu
  just
  lsp-ai
  nixdoc
  nixgl.nixGLIntel
  python313Packages.llm-anthropic
  starpls
  tree
  xclip
  yazi
]
