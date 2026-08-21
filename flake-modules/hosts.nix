{ self, inputs, ... }: let
  inherit (import ../env) env pkgList;

  # Load all modules across the modules/ folder
  # We will manually import them or write a small walker in flake-parts, or just use builtins.readDir
  # But actually we can just point to modules/default.nix
  sharedArgs = env // {
    inherit inputs self pkgList env;
  };
in {
  flake.nixosConfigurations = {
    # -------------------------------------------------------------------------
    # 🔴 AMD Host Profile
    # -------------------------------------------------------------------------
    "amd" = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = sharedArgs;
      modules = [
        ../hosts/amd
        ../modules
        inputs.stylix.nixosModules.stylix
        inputs.nix-index-database.nixosModules.default
        
        inputs.home-manager.nixosModules.home-manager
        {
          programs.nix-index-database.comma.enable = true;
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = sharedArgs;
            sharedModules = [
              inputs.nix-index-database.homeModules.default
            ];
          };
        }
      ];
    };

    # -------------------------------------------------------------------------
    # 🔵 Intel Host Profile
    # -------------------------------------------------------------------------
    "intel" = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = sharedArgs;
      modules = [
        ../hosts/intel
        ../modules
        inputs.stylix.nixosModules.stylix
        inputs.nix-index-database.nixosModules.default
        
        inputs.home-manager.nixosModules.home-manager
        {
          programs.nix-index-database.comma.enable = true;
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = sharedArgs;
            sharedModules = [
              inputs.nix-index-database.homeModules.default
            ];
          };
        }
      ];
    };
  };
}
