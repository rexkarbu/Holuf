BEAST SYSTEM — DESIGN PASS
1. Konsep Inti

Saya merekomendasikan command khusus Beast tetap bernama:

BEAST

Hanya karakter race Beast yang memiliki command ini.

Playable yang menggunakannya:

Torga
Orin

BEAST bukan menu summon monster koleksi dan bukan sistem seperti Pokémon.

Sebaliknya, Beast tertentu mampu menggunakan teknik bernama sementara:

Beast Manifestation

Mereka memproyeksikan kekuatan primal dari mana dan insting tubuh mereka dalam bentuk avatar beast spectral untuk satu aksi kuat.

Jadi secara visual terasa seperti summon:

karakter → manifestasi beast besar muncul → melakukan aksi → menghilang.

Tetapi secara lore bukan makhluk peliharaan yang dipanggil dari tempat lain.

Ini jauh lebih nyaman untuk scope Holuf.

2. Kenapa Hanya Beast?

Race Beast memiliki hubungan yang lebih kuat antara:

tubuh + instinct + mana.

Beast yang sudah berlatih dapat memproyeksikan sifat primal tersebut ke luar tubuh untuk sesaat.

Tidak semua warga Beast otomatis bisa melakukannya.

Ini merupakan teknik yang membutuhkan:

pengalaman + kontrol mana + pemahaman diri.

Torga dan Orin sudah memiliki kemampuan tersebut ketika mereka bergabung.

Jadi tidak ada:

chosen Beast,
bloodline rahasia,
summon god,
atau prophecy.

Ini hanya kemampuan racial yang tidak semua individu kuasai.

3. Tidak Ada Companion Permanen

Saya sangat menyarankan tidak membuat summon sebagai unit tambahan dalam battle.

Jangan:

Torga
↓
Summon monster
↓
monster masuk turn queue
↓
punya HP sendiri
↓
punya skill sendiri

Itu akan menambah banyak pekerjaan:

AI, UI, target system, queue, HP, animation, balancing, status, dan edge case.

Sebaliknya:

Torga memilih BEAST
↓
Manifestation muncul
↓
satu action terjadi
↓
Manifestation menghilang
↓
battle lanjut normal

Jauh lebih bersih.

4. Aturan Utama BEAST

Saya rekomendasikan:

Rule	Keputusan
Race	Beast only
Command	BEAST
Uses	1 kali per karakter per battle
Resource	MP
Extra gauge	❌ Tidak ada
Bisa Boost	✅ Ya
Persistent summon	❌ Tidak
Masuk turn queue	❌ Tidak
Break interaction	✅ Normal
Element affinity	✅ Normal
Reset	Setelah battle selesai

Jadi Torga dan Orin masing-masing punya:

1 Beast use per battle.

Kalau keduanya ikut battle:

Torga punya 1 penggunaan sendiri dan Orin punya 1 penggunaan sendiri.

Bukan shared resource.

5. Kenapa 1 Kali per Battle?

Supaya command BEAST terasa seperti:

signature action

bukan sekadar Skill menu kedua.

Dan ini menciptakan keputusan menarik dengan BP.

Misalnya Torga masuk battle dengan BP1.

Player bisa:

gunakan Beast sekarang dengan Boost1

atau:

simpan sampai BP3 untuk Beast yang jauh lebih kuat.

Karena BP hanya naik pada natural turn, keputusan timing menjadi penting.

Ini memanfaatkan sistem yang sudah ada daripada membuat sistem baru.

6. Beast Tetap Menggunakan MP

Walaupun hanya sekali per battle, saya tetap merekomendasikan Beast menggunakan MP.

Kenapa?

Karena HP/MP Holuf persisten antarbattle.

Jadi pemain tidak bisa selalu menggunakan Beast di setiap random encounter tanpa konsekuensi.

Beast menjadi:

powerful tactical resource.

Bukan free ultimate setiap battle.

Exact MP cost belum kita tentukan sekarang.

Itu masuk balance pass nanti.

7. Boost Interaction

BEAST termasuk kategori yang bisa menggunakan Boost, sesuai aturan yang sudah kita punya.

Multiplier tetap:

Boost 0 = x1.00
Boost 1 = x1.25
Boost 2 = x1.50
Boost 3 = x2.00

Tetapi:

Boost tidak menambah hit count.

Kalau animasinya memperlihatkan beast menyerang lima kali, secara mechanical bisa tetap dianggap:

1 damage instance / 1 hit.

Jadi kalau menyerang weakness:

BREAK -1.

Bukan -5.

Ini wajib supaya Beast tidak menghancurkan sistem Break.

8. Utility Beast Tidak Ikut Membesar Secara Berlebihan

Kalau sebuah Beast action mempunyai:

damage + buff,

Boost terutama meningkatkan damage/healing numeric utama.

Boost tidak:

menambah durasi buff,
menambah jumlah counter,
menambah hit,
menggandakan jumlah target,
atau membuat effect baru.

Contoh:

Beast Art
120 damage
+ ATK Up 2 turns

Boost3:

240 damage
+ ATK Up tetap 2 turns

Ini membuat Boost predictable.

9. Interaction dengan Break

Beast damage mengikuti aturan element normal.

Contoh Torga menggunakan Earth manifestation terhadap enemy Weak Earth:

Earth hit
↓
Weakness x1.25
↓
BREAK -1

Jika enemy sudah Broken:

Broken multiplier berlaku normal.

Tidak ada special Beast Break rule.

Ini penting.

Command-nya unik, tetapi tidak melanggar core combat rules.

10. Affinity

Future affinity juga berlaku normal:

Normal
Weak
Resist
Null
Absorb
Repel

Jadi Beast bukan damage type yang otomatis menembus semuanya.

Contohnya kalau enemy:

Absorb Fire

maka Fire Beast milik Orin juga harus mengikuti aturan tersebut.

Ini membuat pemain tetap harus berpikir.

11. Torga — Beast Identity

Torga:

Axe / Earth / Defensive Bruiser

Maka Beast Manifestation Torga harus memperkuat identitas itu.

Arah yang saya rekomendasikan:

Earth Defensive Manifestation

Visual:

avatar beast besar dan berat—misalnya beast bertanduk / massive land beast—muncul di belakang atau sekitar Torga.

Fungsinya:

Earth physical impact + defensive reinforcement.

Jadi bukan hanya damage.

Secara desain:

Torga BEAST
↓
Strong Earth physical action
+
temporary defensive/counter benefit

Exact effect belum perlu ditentukan.

Contohnya nanti bisa mengarah ke:

damage + temporary damage reduction

atau:

damage + counter preparation.

Tapi jangan dibuat pure nuke, karena itu wilayah Doran.

Identitas

Torga's Beast = “Stand your ground.”

12. Orin — Beast Identity

Orin:

Longsword / Fire / Sustained Bruiser

Maka Beast miliknya harus berbeda total dari Torga.

Arah:

Fire Sustained Manifestation

Visual:

fast/predatory spectral beast yang diliputi api.

Efek:

Orin BEAST
↓
Strong Fire physical action
+
temporary sustained-offense benefit

Misalnya nanti bisa berupa:

ATK enhancement beberapa turn

atau:

self-sustain setelah menyerang.

Yang penting hasilnya bukan:

satu angka damage absurd.

Karena burst terbesar tetap niche Doran.

Identitas

Orin's Beast = “Keep burning.”

13. Torga vs Orin

Dengan struktur ini:

	Torga	Orin
Element	Earth	Fire
Weapon	Axe	Longsword
Manifestation	Heavy / grounded	Predatory / aggressive
Fungsi	Defense → offense	Offense → sustain
Combat fantasy	Tidak mudah digeser	Tidak berhenti menekan

Jadi walaupun keduanya Beast, command mereka tidak terasa copy-paste.

14. Tidak Perlu Beast Collection

Saya sangat menyarankan jangan membuat sistem menangkap/mengumpulkan Beast.

Tidak perlu:

30 summon
monster collection
Beast equipment
summon level
summon evolution

Untuk game ±10 jam, itu akan menjadi game system besar sendiri.

Lebih kuat kalau:

Torga punya signature manifestation milik Torga.
Orin punya signature manifestation milik Orin.

Itu juga memperkuat karakter mereka.

15. Tidak Perlu Beast Level Terpisah

Manifestation berkembang otomatis melalui karakter.

Jadi kalau Torga level naik:

Beast action menggunakan stat Torga.

Tidak ada:

Torga Lv25
Beast Lv17

Tidak perlu XP kedua.

Tidak perlu equipment summon.

Tidak perlu menu management baru.

16. Stat Scaling

Karena Torga dan Orin physical fighter:

Beast offensive damage menggunakan ATK, bukan MAG.

Element tetap diterapkan:

Torga

Physical Earth.

Orin

Physical Fire.

Jadi mereka tetap terasa seperti martial Beast, bukan tiba-tiba mage ketika memilih BEAST.

17. Reserve / Party Swap

Beast use disimpan per character selama battle.

Contoh:

Torga uses BEAST
↓
Torga swapped to reserve
↓
Torga masuk lagi
↓
BEAST tetap sudah terpakai

Tidak refresh karena swap.

Tetapi jika Orin belum menggunakannya:

Orin masih punya Beast use miliknya sendiri.

18. KO

Kalau Torga KO sebelum menggunakan Beast:

Beast tidak dianggap terpakai.

Kalau suatu saat ada revive dan dia kembali:

dia masih bisa menggunakannya.

Kalau Beast sudah digunakan sebelum KO:

revive tidak mengembalikannya.

19. Multi-phase Boss

Kalau boss berubah Phase 1 → Phase 2 tetapi masih battle yang sama:

Beast use tidak reset.

Jadi player harus memutuskan:

gunakan sekarang atau simpan untuk phase berikutnya?

Ini sangat cocok untuk Final Boss.

20. Deep Stagger

Deep Stagger extra offensive action window boleh digunakan untuk BEAST jika:

Beast belum digunakan,
character punya MP,
dan action valid.

Tetapi sesuai aturan existing:

extra action tersebut tidak memberikan BP.

Jadi player bisa menggunakan BP yang sudah dimiliki, tetapi tidak menghasilkan BP baru.

21. Battle UI

Human/Elf tidak perlu mempunyai command BEAST yang abu-abu.

Lebih bersih:

Aren
Attack
Skill
Item
Defend
Flee
Boost
Torga
Attack
BEAST
Skill
Item
Defend
Flee
Boost

Urutan final UI nanti bisa kita sesuaikan.

Tapi BEAST hanya muncul pada Beast characters.

Ini langsung memberi race identity secara visual.

22. Tutorial Timing

Tutorial BEAST paling natural terjadi ketika Torga pertama kali playable di Arc 3.

Tidak perlu tutorial panjang.

Cukup memberi tahu:

Beast characters have access to BEAST, a powerful racial action usable once per battle. BEAST consumes MP and can be enhanced with Boost.

Kemudian Orin join Arc 4 dan pemain sudah mengerti sistemnya.

23. Lore Kharuun vs Ravaryn

Walaupun kemampuan racial sama, budaya mereka boleh memandangnya berbeda.

Kharuun / Torga

Manifestation bisa dianggap:

ekspresi alami hubungan antara tubuh, instinct, dan land.

Lebih terbuka dan tidak terlalu formal.

Ravaryn / Orin

Teknik itu mungkin diperlakukan lebih sebagai:

martial discipline / survival technique.

Jadi race ability sama, tetapi budaya penggunaannya berbeda.

Ini konsisten dengan prinsip:

race ≠ nationality.

24. Apakah Semua Beast Bisa Melakukannya?

Tidak.

Sama seperti tidak semua Human bisa menjadi master swordsman atau mage hebat.

Sebagian Beast memiliki potensi untuk Beast Manifestation tetapi:

membutuhkan latihan untuk menggunakannya dengan aman.

Torga dan Orin sudah terlatih.

Ini juga mencegah pertanyaan:

“Kenapa semua NPC Beast tidak summon setiap lima detik?”

25. Enemy Beast

Kita tidak wajib memberi setiap enemy Beast command yang sama.

Tapi secara lore, beberapa Beast enemy/NPC kuat nanti boleh mempunyai teknik serupa.

Implementasi player terlebih dahulu.

Jangan menambah scope hanya karena lore memungkinkan.

26. Nama Manifestation

Saya belum menyarankan kita lock nama summon sekarang.

Lebih baik nanti ketika kita membuat full skill kit, kita tentukan:

nama manifestation Torga,
nama manifestation Orin,
nama action,
animation fantasy,
exact effect.

Yang kita lock sekarang adalah system rules-nya.

27. Hal yang Jangan Dilakukan

Beast System sebaiknya tidak punya:

❌ summon collection
❌ summon party member
❌ summon HP bar
❌ summon turn queue
❌ Beast XP
❌ Beast equipment
❌ Beast-specific gauge
❌ random summon
❌ extra Break hit
❌ Boost menambah hit
❌ Beast bypass affinity

Semua itu membuat sistem jauh lebih besar daripada manfaatnya.

28. Kenapa Sistem Ini Cocok untuk Holuf?

Karena ia memakai sistem yang sudah ada:

MP
BP/Boost
weakness
Break
element
turn queue

BEAST hanya menambahkan:

satu signature racial action per Beast character.

Jadi player merasa race Beast benar-benar unik tanpa kita menciptakan battle system kedua.

29. Recommended Lock

Saya rekomendasikan kita lock:

BEAST SYSTEM

Available:
Beast race only

Playable users:
Torga
Orin

Battle command:
BEAST

Concept:
Temporary primal mana manifestation
with summon-like visual.

Not:
A permanent companion.

Uses:
1 use per character per battle.

Resource:
MP.

Extra gauge:
None.

Boost:
Allowed.

Boost rules:
Normal x1.00 / x1.25 / x1.50 / x2.00.
No additional hit count.
Utility duration does not increase.

Break:
Normal rules.
Weakness = BREAK -1.

Affinity:
Normal / Weak / Resist /
Null / Absorb / Repel all apply.

Scaling:
Uses character's own stats.
Torga/Orin primarily ATK scaling.

Torga:
Earth defensive manifestation.
Damage + defensive/counter direction.

Orin:
Fire sustained manifestation.
Damage + sustained-offense/self-sustain direction.

Summon entity:
Does not remain on field.
Does not enter turn queue.
Has no HP.

Party swap:
Does not refresh use.

KO/revive:
Does not refresh if already used.

Boss phase:
Does not refresh.

Deep Stagger:
Can use BEAST if still available.

Tutorial:
First introduced when Torga becomes playable.

Collection system:
None.
30. Status Setelah Ini

Kalau struktur ini cocok, maka:

Beast System Foundation → 🔒 LOCKED

dan seluruh fondasi playable roster menjadi:

Characters → 🔒
Weapons → 🔒
Elements → 🔒
Combat roles → 🔒
Break interaction → 🔒
Boost interaction → 🔒
Beast racial system → 🔒