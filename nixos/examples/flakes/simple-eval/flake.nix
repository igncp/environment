# # In this case it just evaluates the flake, `nix develop` would fail

# nix eval .#foo
{
  outputs = { self }: {
    foo = "bar";
  };
}
