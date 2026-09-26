# PRD — Health Leveling
Versi 1.0 · 2026-09-26 · Owner: Kris (criss10x) · Platform: Android (Flutter)

## 1. Ringkasan

Health Leveling adalah app Android yang membuat pengguna **membayar waktu layar dengan kesehatan**: selesaikan habit/challenge terverifikasi → dapat koin → pakai koin untuk membuka app pilihan (TikTok, IG, YouTube, game). App yang belum dibuka dengan koin tetap terkunci.

- **Pitch**: "Earn your screen time with your health."
- **Referensi produk**: Unrot (iOS, 4.67★, ~$40K/bln) — konsep sama, Health Leveling berbeda di: verifikasi otomatis via Health Connect (anti-curang), challenge program terstruktur multi-hari, dan ekonomi koin yang lebih granular.
- **Monetisasi**: freemium — challenge pertama gratis penuh, sisanya premium.
- **Pasar**: global, bahasa Inggris (localize menyusul dengan pola ARB 4 locale).
- **Nama**: Health Leveling. Tagline kandidat: "Do the healthy thing. Then scroll."

## 2. Keputusan inti (hasil grill, 3 round — final)

| # | Keputusan | Pilihan |
|---|---|---|
| 1 | Mekanisme reward | Blokir app sungguhan (bukan sekadar poin) |
| 2 | Verifikasi habit | Health Connect untuk data terukur; timer+foto untuk sisanya |
| 3 | Konten | Challenge program terstruktur (utama) + habit custom (pelengkap) |
| 4 | Platform | Android dulu, Flutter |
| 5 | Monetisasi | Freemium: challenge #1 gratis, sisanya premium |
| 6 | Pasar | Global, EN |
| 7 | Mesin blokir | AccessibilityService (deteksi launch instan) |
| 8 | Ekonomi koin | Granular & simpel: aktivitas kecil → koin kecil (lihat §4) |
| 9 | Katalog launch | 4 challenge: Fitness Starter, Dopamine Detox, 10K Steps, Sleep Reset |
| 10 | Maskot | Non-otak: **"Ember"** — spark/api energik, oranye, ekspresif |
| 11 | Streak | Bisa miss; shield melindungi; **streak memberi multiplier koin** |
| 12 | Paywall | Soft: di akhir onboarding (skip-able) + saat tap challenge premium |
| 13 | Storage | Local-only v1 (arsitektur siap sync v2: satu sumber state) |
| 14 | Onboarding | Ringkas 8–10 layar; pola chat-buddy menyusul v2 |
| 15 | Target | MVP 3–4 minggu; polish & konten tambahan setelah rilis |

## 3. User journey v1

1. **Onboarding (8–10 layar)**: hero maskot → masalah (scrolling tanpa sadar) → cara kerja 3 langkah (Move → Earn → Unlock) → pilih challenge pertama → kriteria harian → permission notif → permission Accessibility → setup progress → paywall soft (skip-able).
2. **Home**: hari ini dalam challenge aktif — kartu kriteria harian (progress bar per tier), saldo koin, streak + multiplier, tombol "Start session" per habit.
3. **Earn**: user mengerjakan habit (Health Connect menghitung langkah/workout otomatis; timer/foto untuk habit non-sensor). Koin masuk saat kriteria tercapai.
4. **Unlock**: user membuka app pilihan dengan koin → timer screen time berjalan → habis, app terkunci lagi.
5. **Progres**: kalender challenge, tier harian (bronze/silver/gold), streak, riwayat koin.

## 4. Ekonomi koin (v1 — flat & granular)

Prinsip: **aktivitas kecil yang mudah dimulai memberi koin kecil** — ambang mulai sangat rendah (permintaan Kris: "yang penting memulai").

### 4.1 Sumber koin

| Aktivitas | Verifikasi | Koin |
|---|---|---|
| 2.000 langkah | Health Connect | +10 |
| Push-up ×5 | timer/counter manual | +2 |
| Squat ×5 | timer/counter manual | +2 |
| Workout terdeteksi (HC) ≥ 15 menit | Health Connect | +15 |
| Meditasi/breathing 5 menit | timer | +5 |
| Air minum 1 gelas | tap | +1 |
| Tidur ≥ 7 jam (bonus pagi) | Health Connect | +10 |

### 4.2 Belanja koin

| Paket unlock | Harga |
|---|---|
| 10 menit app pilihan | 20 koin |
| 30 menit | 50 koin |
| 1 jam | 90 koin |

### 4.3 Streak multiplier (keputusan Kris)

Streak harian (≥1 habit selesai) memberi bonus di SEMUA koin yang didapat hari itu:

| Streak | Multiplier |
|---|---|
| 1–2 hari | ×1.0 |
| 3–6 hari | ×1.2 |
| 7–13 hari | ×1.5 |
| 14–29 hari | ×2.0 |
| 30+ hari | ×2.5 |

Miss sehari tanpa shield → streak reset ke 0 (multiplier hilang = penalti natural). Shield tidak melindungi multiplier — hanya melindungi progres challenge (§5).

### 4.4 Anti-abuse v1 (sederhana)

- Langkah/workout hanya dari Health Connect (tidak bisa input manual angka).
- Tap air minum dibatasi 8/hari; push-up/squat counter dibatasi total 100 rep/hari.
- Koin kedaluwarsa: tidak ada di v1 ( evaluasi di v2).

## 5. Challenge system

- **Durasi**: 7–30 hari, kriteria harian bertingkat **bronze/silver/gold** (hari tetap ✅ walau bronze; gold memberi koin lebih).
- **Shield**: tiap challenge memberi 2 shield. Bolong sehari → shield terpakai otomatis (hari dihitung ✅-dengan-shield, streak pribadi challenge tetap). Shield habis + bolong → hari gagal (di kalender: merah) — challenge tetap berjalan, badge "Perfect" hangus.
- **Selesai**: ringkasan + badge + koin bonus (lihat tabel).

### Katalog launch

| Challenge | Durasi | Bronze | Silver | Gold | Koin bonus selesai |
|---|---|---|---|---|---|
| Fitness Starter | 21 hari | 15 push-up + 15 squat | 30+30 | 50+50 | +100 |
| Dopamine Detox | 7 hari | 2 jam tanpa app terlarang | 4 jam | 6 jam | +150 |
| 10K Steps | 30 hari | 6.000 | 8.000 | 10.000 langkah | +200 |
| Sleep Reset | 14 hari | tidur 6.5 jam | 7 jam | 7.5 jam | +100 |

- Fitness Starter = **challenge gratis** (onboarding membawa user ke sini).
- Dopamine Detox dipasangkan dengan fitur blokir: kriterianya adalah durasi tanpa app terkunci.
- Progress langkah/tidur dari Health Connect otomatis; push-up/squat via counter cepat di app; detox dihitung dari mesin blokir.

## 6. App blocking (mesin inti)

- **AccessibilityService** mendeteksi foreground app; bila app ada di daftar terkunci dan user tidak punya unlock aktif → overlay "App locked — earn coins to unlock" dengan tombol ke Health Leveling.
- Daftar app terkunci dipilih user saat onboarding (grid app installed).
- **Unlock session**: beli paket → timer berjalan per app atau global (v1: global). Habis → lock otomatis kembali.
- Sesi detox (§5) memakai mekanisme sama: selama kriteria harian belum terpenuhi, app terlarang dikunci.
- Deklarasi Play Console: accessibility usage disclosure wajib (isAccessibilityTool=false, alasan core-functionality).

## 7. Onboarding (8–10 layar)

1. Hero maskot Ember + tagline
2. Masalah: "Your apps are free. Your health pays for them." (bagan waktu scroll)
3. Cara kerja: 3 kartu — Move (habit) → Earn (koin) → Unlock (screen time)
4. Pilih challenge pertama (Fitness Starter ditonjolkan, gratis)
5. Kriteria harian + reminder time
6. Permission: notifikasi
7. Permission: Accessibility + pilih app untuk dikunci
8. Setup progress (ring + checklist, pola Unrot)
9. Paywall soft (skip-able): "Go Premium — all challenges unlocked"
10. Home pertama (empty state → mulai hari 1)

## 8. Design system

- **Tema**: terang, latar putih/ivory; ink near-black `#1A1D1F`.
- **Primer**: oranye energi `#FF6B35`; support teal `#14B8A6`; abu `#F4F4F5`/`#E4E4E7`/`#9CA3AF`.
- **Maskot**: Ember (spark oranye, ekspresif, flat illustration).
- **Struktur layar mengikuti pola Unrot** (metadata Appllama app 6746537171): Centered Mascot, Rounded CTA pill, Back Icon, option rows (radio/emoji), progress ring, kartu ringkas; satu aksen utama, aksen fungsional langka (merah gagal, kuning streak, teal support).
- Tipografi: Inter (atau system) — bold besar untuk angka, weight ringan untuk body.
- Riset visual per layar dilakukan via Appllama MCP sebelum implement UI (screen ref tersimpan di `research/unrot-analysis.md`).

## 9. Teknis

- **Flutter**, minSdk 26 (Health Connect butuh 24+; wear OS tidak di v1).
- **Paket**: health (Health Connect), flutter_local_notifications, shared_preferences/Isar (local store), google_fonts, url_launcher (paywall/IAP).
- **Arsitektur siap-sync v2**: satu sumber state (Isar), semua perubahan sebagai event yang bisa direplay; tidak ada derived state yang disimpan.
- **IAP**: RevenueCat (atau in_app_purchase) — weekly $4.99 / annual $29.99; premium = semua challenge + habit custom unlimited.
- **Data sensitif**: Health Connect data tidak pernah keluar device (v1 local-only) — jadikan selling point privasi.
- **CI**: GitHub Actions build APK (pola flutter-android-ci-publishing), analysis tanpa warning (1 warning = merah).

## 10. Scope v1 vs Later

**V1 (3–4 minggu)**: onboarding, blokir + unlock koin, 4 challenge, ekonomi §4, streak+multiplier, shield, paywall, Health Connect, maskot Ember dasar, home + progress kalender.

**Later**: pola chat-with-buddy (v2), rank/tier XP ala GymLevels, leaderboard/sosial, AI coach, soundscape focus, widget, sync cloud, challenge tambahan (hidrasi, mindful scrolling), remote config ekonomi.

## 11. Metrik sukses (post-launch 30 hari)

- D1 retention ≥ 25%; D7 ≥ 12% (benchmark wellness).
- ≥ 40% user baru menyelesaikan onboarding sampai challenge pertama dimulai.
- Rasio unlock: ≥ 3 unlock session/minggu/user aktif.
- Konversi premium ≥ 2%.

## 12. Risiko

| Risiko | Mitigasi |
|---|---|
| Play Store menolak AccessibilityService | Disclosure sesuai kebijakan; fallback overlay + usage access; siapkan rilis tanpa blokir (poin-only) bila perlu |
| Bypass mudah (uninstall app, disable accessibility) | v1 terima; v2: deteksi + "lockdown" streak-safe |
| Health Connect dirasa ribet | Onboarding: default timer/foto, HC opsional dengan insentif koin pertama |
| Ekonomi koin tidak balance | Angka §4 di satu file konstanta; siap tune tanpa refactor |
