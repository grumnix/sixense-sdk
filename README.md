Sixense SDK
===========

This Nix flake will put the Sixense SDK into the Nix store, so it can
be used in other flakes. There doesn't seem to be any HTTP download
for the SDK and Steam seems to be the only way to download the SDK in
2022, so a bit of manual work is required is required before this
flake become usable.


Installing
----------

1. Download SixenseSDK from Steam:

    steam://install/42300

2. Add SDK to /nix/store:

    nix store add-path "~/.local/share/Steam/steamapps/common/Sixense SDK/SixenseSDK/"


Usage
-----

A small demo app to check that the Razer Hydra works properly is
included, execute with:

    nix run github:grumnix/sixense-sdk

The flake can be used in other flakes as usual.
