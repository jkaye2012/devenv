{ pkgs, pkgs-unstable }:
with pkgs;
[
  bazel
  pkgs-unstable.claude-code
  ghostty
  glab
  just
  lsp-ai
  nixgl.nixGLIntel
  starpls
  tree
  xclip
  yazi
]
