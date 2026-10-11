#!/bin/sh
# Downloads the Figma image assets used by the implemented screens.
# The Figma MCP asset URLs are temporary (valid 7 days from 2026-10-08, i.e.
# until about 2026-10-15). Run this from the project root, on a machine with
# internet access. If the links have expired, export the same images from
# Figma manually and save them under the same file names.
set -e
mkdir -p assets/images

P2="https://www.figma.com/api/mcp/asset/a18f3740-9228-4f77-bf77-bb47fdaf9b95"
P1="https://www.figma.com/api/mcp/asset/3cb30f02-47c9-4197-a383-13c02f53805a"

get() { curl -fL --retry 2 -o "assets/images/$2" "$1" && echo "ok  $2"; }

get "$P2/2da92.png" paket_hemat.png
get "$P2/21795.png" mie_ayam.png
get "$P2/7a2ed.png" ikan_goreng.png
get "$P2/378f1.png" nasi_goreng_kampung.png
get "$P2/11f86.png" ayam_bakar.png
get "$P2/8af69.png" telur_balado.png
get "$P1/e499b.png" promo_salad.png
