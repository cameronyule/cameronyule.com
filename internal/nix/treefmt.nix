_: {
  projectRootFile = "flake.nix";

  programs = {
    # keep-sorted start block=yes
    actionlint = {
      enable = true;
      priority = 6;
    };
    alejandra = {
      enable = true;
      priority = 4;
    };
    deadnix = {
      enable = true;
      excludes = [
        "flake.nix"
      ];
      priority = 0;
    };
    keep-sorted = {
      enable = true;
      priority = 3;
    };
    pinact = {
      enable = true;
      priority = 5;
      update = false;
    };
    ruff-check = {
      enable = true;
      priority = 8;
    };
    ruff-format = {
      enable = true;
      priority = 7;
    };
    statix = {
      enable = true;
      priority = 1;
    };
    # keep-sorted end
  };

  settings = {
    allow-missing-formatter = false;
    on-unmatched = "fatal";
    verbose = 2;
    global.excludes = [
      ".editorconfig"
    ];
  };
}
