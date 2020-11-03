{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation
{
  name = "blog.jeaye.com";
  buildInputs = let pkgsUnstable = import
  (
    fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz
  )
  { };
  in
  [
    pkgsUnstable.ruby
    pkgsUnstable.bundler
    pkgsUnstable.libxml2
    pkgsUnstable.xz
    pkgsUnstable.gcc
  ];
}
