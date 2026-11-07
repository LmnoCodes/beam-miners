{
  # beam-miners.nix
  description = "beam-miners for special week";

  inputs = {
    # erlang 27 / elixir 1.18.1 commit hash
    spw-nixpkgs.url = "github:NixOS/nixpkgs/21808d22b1cda1898b71cf1a1beb524a97add2c4";
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

          # Erlang & Elixir Versionen ausgeben
          echo "Erlang: $(erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell)"
          echo "Elixir: $(elixir --version)"

          # Automatische Installation/Aktualisierung von Hex und Rebar in den lokalen Ordner
          echo "📦 Überprüfe Hex und Rebar..."
          export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
          export HEX_UNSAFE_HTTPS=0
          mix local.hex --force
          mix local.rebar --force

          echo "✨ Bereit! Du kannst jetzt 'mix deps.get' oder 'iex -S mix arena.local' ausführen."
        '';
      };
    };
}
