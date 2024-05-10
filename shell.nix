{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell rec {
  name = "ssh-exporter";

  buildInputs = with pkgs; [
    bundix
    git
    ruby
  ];

  shellHook = ''
    export GEM_HOME="$(pwd)/.gems"
    export PATH="$(ruby -e 'puts Gem.bindir'):$PATH"
    export RUBYLIB="$GEM_HOME"
    gem install --no-document bundler geminabox rubocop overcommit
    $GEM_HOME/bin/bundle install
  '';
}
