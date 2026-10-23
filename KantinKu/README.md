# KantinKu — Figma → Flutter (work in progress)

**Status: 5 of 16 frames implemented.** The Figma MCP hit its Starter-plan limit (20 read calls/month), so the other 11 frames could not be read. Nothing was invented for them; they open a blank "belum diimplementasikan" screen.

## Run

```sh
flutter create --project-name KantinKu .   # generates android/ ios/ web/ (keeps lib/ and pubspec.yaml)
sh tool/download_assets.sh                 # food photos; Figma links expire ~2026-10-15
flutter pub get
flutter run
```

I could not run the Flutter SDK where this was written, so the code has **not been compiled**. Expect to fix a few small errors. If an icon name differs in your `lucide_icons_flutter` version, change it in `lib/core/icons.dart` only.

## Implemented frames

| Frame | File | Data source |
|---|---|---|
| Beranda | `screens/beranda_screen.dart` | full design context + screenshot |
| Semua Menu | `screens/semua_menu_screen.dart` | full design context + screenshot |
| Order — Pesanan | `screens/order_screen.dart` | full node tree + prototype links |
| Checkout | `screens/checkout_screen.dart` | full node tree + prototype links |
| Payment — Pembayaran | `screens/payment_screen.dart` | full node tree + prototype links |

## Not implemented (Figma data not readable yet)

Detail Promo, Riwayat, Rekomendasi, QRIS Payment, Order Status, Browse — Direktori Warung, Warung Detail — Menu, Me — Profil, Profil Saya, Metode Pembayaran, Voucher Saya.
Their routes already exist in `lib/navigation/routes.dart` (`AppScreen`), so each only needs its screen file once the design data is available.

## Working behavior

- Cart (add / +/− / delete / totals), favorites, payment-method choice and the order note are real state (`state/app_state.dart`) and persist with `shared_preferences`.
- Totals are computed, not hardcoded. Figma's numbers are reproduced by the seed cart: 18.000 + 5.000 + 2 × 16.000 = 55.000, + 5.000 delivery + 2.000 service − 5.000 discount = 57.000.
- Semua Menu: category chips and the search box filter the grid.
- Bottom navigation switches the whole screen; active tab and the two Figma label sets (Home/Orders/Browse/Me vs Beranda/Pesanan/Jelajah/Saya) are kept per frame.

## Prototype links

Read from Figma (verified): Order → Checkout button → Checkout; Checkout back → Order; Checkout "Bayar Sekarang" → Payment; Payment back → Checkout; Payment "Ganti Metode" → Metode Pembayaran; Payment "Bayar dengan QRIS" → QRIS Payment; Order bottom tabs → Beranda / Browse / Me.

**Inferred, please verify** (the code export marks these as clickable but does not give the target): Beranda search pill and "All" chip → Semua Menu; History "See all" → Riwayat; Rekomendasi "See all" → Rekomendasi; "Claim now" → Detail Promo; Beranda tab "Orders" → Order; Semua Menu back → previous screen.
No prototype link in Figma, so no navigation: address "Ubah", voucher card, Beranda History tiles and recommendation cards.

## Deviations from Figma

1. iOS mock status bar (9:41 + signal icons) and the 24 px home-indicator strip are not drawn; the real OS provides them (SafeArea is used instead).
2. Icons come from `lucide_icons_flutter` (Figma layer names are Lucide names) instead of the exported SVGs, which could not be downloaded here.
3. Colors that live inside SVG assets could not be read and are approximated from the screenshot: star amber, notification dot, coffee icon, heart/trash/chevron strokes on Order. Everything else uses exact Figma values.
4. Favorited state (♥ / navy heart) is not in Figma; the design only shows the ♡ state.
5. Payment shows the QRIS card regardless of the method picked on Checkout (Figma only designs QRIS); the "Metode · …" label follows the selection.
6. Mie Ayam Special unit price (16.000) is derived from Figma's own totals.
7. Not yet compared against Figma frame-by-frame; I make no pixel-perfect claim.
# Kantinku
