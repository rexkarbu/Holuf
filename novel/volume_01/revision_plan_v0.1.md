# Beyond Elaris — Volume 1 Revision Plan v0.1

**Sumber:** draf naratif Volume 1 v0.1  
**Cakupan:** Prolog, Bab 1–8, dan Epilog  
**Target keluaran:** naskah revisi v0.2 dan 30 episode Fizzo yang dinormalisasi  
**Prinsip:** memperjelas prosa tanpa mengubah canon, urutan kejadian, POV, atau hasil konflik

---

## 1. Sasaran Revision Pass

Revision Pass ini mempunyai lima sasaran berurutan:

1. menyatukan sumber Chapter 5 dan membuat arsip episode Fizzo 1–30 dengan pola nama berkas yang sama;
2. mengurangi repetisi informasi, respons fisik, dan dialog prosedural yang tidak menambah bukti;
3. mempertajam suara Aren, Lyra, Doran, Aelia, Lloyd, dan Maro tanpa menambah POV;
4. menyeragamkan terminologi alat tulis dari `arang` menjadi pena/tinta serta membersihkan ejaan dan tanda baca;
5. menghasilkan paket beta-reading yang dapat dinilai tanpa membuka dokumen perencanaan.

Revision Pass tidak bertujuan memperpanjang volume, menambah interlude, memperkenalkan antagonis utama, atau menyiapkan Volume 2 melalui teaser baru.

---

## 2. Canon yang Dikunci

- POV tetap orang ketiga terbatas-dekat melalui Aren.
- Kalender tetap Hari 0–8.
- Aelia terakhir terlihat hidup pada Hari 1 dan bergerak ke utara atas pilihannya.
- Bibi Aelia hidup, tetapi nama dan settlement-nya belum diungkap.
- Lloyd dan Glaisa tetap belum ditemukan.
- Maro tetap antagonis kriminal lokal dan tidak terhubung dengan penyebab displacement.
- Tavin dan enam belas korban rescue membuat seluruh tujuh belas korban operasi Maro hidup serta terhitung.
- Dua arus dokumen Epilog tetap terpisah: pesan pesisir untuk bibi Aelia dan paket registry utara.
- Rombongan belum tiba di Alexandria pada akhir volume.
- Tidak ada interlude, POV shift, atau flashback penuh pada Volume 1.
- Penyebab cahaya, mekanisme displacement, identitas mage, dan antagonis besar tetap ditahan.

Perubahan yang bertentangan dengan daftar ini harus ditolak, bukan dianggap line edit.

---

## 3. Urutan Kerja

### Pass A — Normalisasi artefak

- Gabungkan tiga sumber Chapter 5 menjadi `chapter_05_v0.2.md`.
- Salin delapan bab lain, Prolog, dan Epilog ke direktori revisi v0.2.
- Pecah naskah menjadi 30 episode sesuai turn adegan yang sudah lulus audit.
- Pastikan setiap episode lebih dari 1.000 kata dan judul kurang dari 70 karakter.
- Pertahankan `***` hanya ketika satu episode memuat lebih dari satu adegan.

### Pass B — Revisi prosa

- Hapus rangkuman ulang pada perpindahan bab.
- Kurangi pengulangan konstruksi `bukan ... tetapi ...`, `tidak ... hanya ...`, dan respons fisik yang sama jika berdekatan.
- Pertahankan prosedur hanya ketika mengubah status bukti, kewenangan, atau pilihan karakter.
- Bedakan dialog: Aren langsung, Lyra presisi dengan humor kering, Doran berbasis batas dan tanggung jawab, Lloyd formal, Aelia tenang tetapi tegas, Maro transaksional.
- Jaga deskripsi tetap ringan dan konkret seperti light novel.

### Pass C — Istilah dan copy-edit

- Ganti penggunaan alat tulis `arang` dengan pena/tinta sesuai konteks.
- Gunakan kapitalisasi nama tempat dan institusi secara konsisten.
- Pertahankan istilah dunia yang sudah disengaja; jangan menambah padanan baru di tengah volume.
- Periksa pasangan tanda kutip, spasi, elipsis, tanda pisah, Markdown, placeholder, dan judul.

### Pass D — Audit final

- Hitung ulang kata prosa per bagian dan per episode.
- Audit kalender, korban, luka, barang, custody, registry, dan reveal.
- Bandingkan pembuka/penutup setiap bab untuk memastikan transisi tidak mengulang informasi.
- Catat seluruh perubahan material dalam revision report.

### Pass E — Beta-reading

- Sediakan naskah gabungan tanpa catatan produksi.
- Sediakan panduan pertanyaan mengenai hook, pacing, kejelasan misteri, agency Aelia, karakter Aren, dan kepuasan klimaks.
- Perlakukan umpan balik beta reader sebagai data; canon tidak berubah otomatis hanya karena satu pembaca meminta penjelasan lebih cepat.

---

## 4. Struktur Fizzo yang Dikunci

| Episode | Bagian manuskrip | Jumlah |
|---|---|---:|
| 1–3 | Prolog | 3 |
| 4–6 | Bab 1 | 3 |
| 7–9 | Bab 2 | 3 |
| 10–12 | Bab 3 | 3 |
| 13–15 | Bab 4 | 3 |
| 16–18 | Bab 5 | 3 |
| 19–22 | Bab 6 | 4 |
| 23–26 | Bab 7 | 4 |
| 27–29 | Bab 8 | 3 |
| 30 | Epilog | 1 |
| **Total** |  | **30** |

Judul episode Prolog dinormalisasi berdasarkan isi karena arsip proyek tidak menyimpan keputusan judul Fizzo sebelumnya:

1. `Hari Terakhir Elaris I — Pagi yang Sudah Ditentukan`
2. `Hari Terakhir Elaris II — Paket yang Disita`
3. `Hari Terakhir Elaris III — Cahaya dari Utara`

Normalisasi arsip tidak mengharuskan pengguna mengganti judul yang sudah tayang di Fizzo selama isi dan urutannya sama.

---

## 5. Definition of Done

Revision Pass dinyatakan selesai hanya jika:

- [x] sepuluh bagian manuskrip tersedia sebagai v0.2;
- [x] Chapter 5 tersedia sebagai satu berkas penuh;
- [x] 30 episode Fizzo tersedia dengan nama berkas konsisten;
- [x] seluruh episode melewati minimum 1.000 kata;
- [x] tidak ada penggunaan alat tulis `arang` yang tersisa pada v0.2;
- [x] tidak ada perubahan canon atau reveal dini;
- [x] audit mekanis dan audit kontinuitas lulus;
- [x] revision report dan beta-reader guide tersedia;
- [x] seluruh artefak sudah diverifikasi pada branch GitHub.

**REVISION EXECUTION STATUS: COMPLETE — VERIFIED ON GITHUB.**
