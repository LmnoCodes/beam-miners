{
  # beam-miners.nix
  description = "beam-miners for special week";

  inputs = {
    # erlang 27 / elixir 1.18.1 commit hash
    spw-nixpkgs.url = "github:NixOS/nixpkgs/9096a6de6613138f94b809bc0408ffd7d4a1817c";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      spw-nixpkgs,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      spw-pkgs = spw-nixpkgs.legacyPackages.${system};

    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          spw-pkgs.beam27Packages.erlang
          spw-pkgs.beam27Packages.elixir_1_18
          git
          inotify-tools
          cacert
        ];

        MIX_HOME = toString ./._mix;
        HEX_HOME = toString ./._hex;

        shellHook = ''
          echo "🚀 Lade Beam Miners Dev-Umgebung (Nix)..."

          export MIX_HOME="$PWD/._mix"
          export HEX_HOME="$PWD/._hex"
          mkdir -p "$MIX_HOME" "$HEX_HOME"

          # Erlang & Elixir Versionen ausgeben
          echo "Erlang: $(erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell)"
          echo "Elixir: $(elixir --version)"

          # Automatische Installation/Aktualisierung von Hex und Rebar in den lokalen Ordner
          echo "📦 Hole Hex über git und Rebar über curl..."
          mix archive.install github hexpm/hex branch latest --force
          curl -L -o "$MIX_HOME/rebar3" https://s3.amazonaws.com/rebar3/rebar3
          chmod +x "$MIX_HOME/rebar3"

          echo "✨ Bereit! Du kannst jetzt 'mix deps.get' oder 'iex -S mix arena.local' ausführen."
        '';
      };
    };
}
