{
  inputs = {
    # Unstable needed for Emacs+Org with citation support
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages."${system}";
      mkShellNoCC = pkgs.mkShell.override {
        stdenv = pkgs.stdenvNoCC;
      };
      tex = pkgs.texlive.combine {
        # inherit (pkgs.texlive) scheme-minimal latex-bin latexmk
        #   topiclongtable;
        inherit (pkgs.texlive)
          # Bare minimum working packages
          # scheme-basic
          scheme-minimal
          # Compiler binaries
          latexmk latex-bin
          # Org dependencies
          # - default packages and their dependencies
          amsmath wrapfig ulem hyperref capt-of infwarerr epstopdf-pkg
          # Bibliography
          biblatex
          # Other utility packages
          geometry xcolor tocbibind
          # Generating PDF/A-2U
          hyperxmp ifmtarg luacode luatexbase oberdiek colorprofiles;
      };
      env = {
        TEXMFHOME = ".cache";
        TEXMFVAR = ".cache/texmf-var";
      };
    in
    {
      devShells.x86_64-linux.default = mkShellNoCC {
        inherit env;
        name = "diploma-thesis";
        packages = [ tex pkgs.biber ];
      };

      packages.x86_64-linux.default = pkgs.stdenvNoCC.mkDerivation {
        inherit env;
        name = "diploma-thesis.pdf";

        src = ./.;

        buildInputs = [ tex pkgs.biber pkgs.emacs29-nox ];

        buildPhase = ''
          make Thesis.pdf
        '';

        installPhase = ''
          cp Thesis.pdf $out
        '';
      };
    };
}
