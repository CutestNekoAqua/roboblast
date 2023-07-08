{
  description = "config of the roboblast raspi4";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/f00994e78cd39e6fc966f0c4103f908e63284780";
    nixos-hardware.url = "github:NixOS/nixos-hardware/3006d2860a6ed5e01b0c3e7ffb730e9b293116e2";
  };
  outputs = { self, nixpkgs, nixos-hardware }: {
    nixosConfigurations.roboblast = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        nixos-hardware.nixosModules.raspberry-pi-4
        ./configuration.nix
      ];
    };
  };
}
