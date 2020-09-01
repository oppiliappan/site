{ pkgs ? import <nixpkgs> {} }:

with pkgs;
mkShell {
  buildInputs = [ miniserve ];
  shellHook = ''
    source ~/.bash_prompt
    export PS1="$PS1(site) "
    '';
}
