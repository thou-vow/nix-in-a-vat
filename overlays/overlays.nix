{
  graalvm-oracle_21 = final: prev: {
    graalvm-oracle_21 = let
      src = {
        "x86_64-linux" = final.fetchurl {
          # To get the hash, run the following (in bash):
          # nix hash convert --hash-algo sha256 --to sri $(curl -s <replace with url>.sha256)
          hash = "sha256-Z6yFh2tEAs4lO7zoXevRrFFcZQUw7w7Stkx9dUB46CE=";
          url = "https://download.oracle.com/graalvm/21/archive/graalvm-jdk-21.0.7_linux-x64_bin.tar.gz";
        };
      };
    in
      final.graalvmPackages.graalvm-oracle.overrideAttrs (finalAttrs: {
        version = "21";
        src = src.${final.system};
      });
  };

  linux-llvm = final: prev: {
    linux-llvm = final.callPackage ./linux-llvm/linux-llvm.nix {};
  };
}

