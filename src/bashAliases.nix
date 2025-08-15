/**
    Convenient shell aliases for common development tools and commands.

    Provides short aliases for frequently used development tools to improve
    workflow efficiency and reduce typing.

    # Type

    ```
    bashAliases :: attrs
    ```

    # Example

    ```nix
    programs.bash.shellAliases = bashAliases;
    ```
*/
{
  ghostty = "nixGLIntel ghostty";
  j = "just";
  jg = "just --justfile ${../just/justfile} --working-directory .";
  lz = "lazygit";
  z = "zellij";
}
