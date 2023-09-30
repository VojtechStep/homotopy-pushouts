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
          scheme-minimal
          # Compiler binaries
          latexmk latex-bin
          # Org dependencies
          # - for longtable
          tools
          # - default packages
          amsmath wrapfig ulem hyperref capt-of infwarerr epstopdf-pkg
          # Bibliography
          biblatex;
      };
      env = {
        SOURCE_DATE_EPOCH = self.lastModified;
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
