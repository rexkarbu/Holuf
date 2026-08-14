HOLUF — NUMERICAL BALANCE PASS V1
1. Target Progression Level

Untuk main story ±10 jam, saya rekomendasikan:

Bagian	Expected Level
Prologue	Lv 1–2
Lorel	Lv 2–5
Alexandria	Lv 5–8
Mongreaux	Lv 8–12
Kamikoto	Lv 12–17
Aetherion	Lv 17–21
Final Boss	sekitar Lv 20–22

Max level tetap 99, tetapi main story sama sekali tidak diarahkan ke sana.

Dengan EXP formula yang sudah ada:

EXP required =
100 + ((level - 1) × 50)

Lv20–22 cukup masuk akal untuk campaign 10 jam dan memberi ruang progression tanpa grinding berlebihan.

Recommended: 🔒 target progression.

2. Baseline Character Stats

Ini saya anggap reference Lv1, bukan berarti semua karakter benar-benar join pada Lv1.

| Char    |      HP |     MP |    ATK |    DEF | MAG |   MDEF |    SPD |
| ------- | ------: | -----: | -----: | -----: | --: | -----: | -----: |
| Aren    |     120 |     35 |     18 |     14 |  10 |     12 |     14 |
| Aelia   |      80 |     60 |      8 |      9 |  21 |     18 |     16 |
| Lyra    |      90 |     38 |     16 |     10 |  12 |     12 |     22 |
| Doran   |     145 |     25 |     23 |     16 |   7 |      9 |      8 |
| Neria   |      85 |     70 |      7 |      9 |  20 |     21 |     11 |
| Torga   |     160 |     30 |     18 |     22 |   8 |     15 |      9 |
| Katsura |     105 |     35 |     19 |     13 |  10 |     12 |     17 |
| Kaelis  |     100 |     34 |     20 |     11 |   9 |     10 |     21 |
| Sylven  |      95 |     42 |     16 |     11 |  14 |     14 |     18 |
| Orin    |     135 |     32 |     21 |     17 |   8 |     13 |     13 |

Ini langsung menghasilkan identitas:

Torga → HP/DEF tertinggi.
Doran → ATK tertinggi tetapi sangat lambat.
Lyra/Kaelis → SPD tertinggi.
Aelia/Neria → MAG/MP tinggi.
Orin → tahan + kuat.
Aren → tidak ekstrem di mana pun.

Baseline ini cocok dipakai sebagai initial .tres values selama belum ada final tuning.

3. Growth Philosophy

Tidak perlu semua karakter mendapat growth yang sama.

Arahnya:

Character	Growth utama
Aren	ATK / HP balanced
Aelia	MAG / MP / SPD
Lyra	SPD / ATK
Doran	ATK / HP
Neria	MAG / MP / MDEF
Torga	HP / DEF
Katsura	ATK / SPD
Kaelis	ATK / SPD
Sylven	SPD / mixed stats
Orin	ATK / HP / DEF

Yang penting:

Level tidak menghapus identitas awal karakter.

Lv20 Doran tetap jauh lebih lambat daripada Lyra. Torga tetap lebih tahan daripada Kaelis.

Jangan membuat semua stat akhirnya converging.

4. Damage Power Scale

Kita punya Attack normal sebagai baseline:

Attack = 1.00×

Kemudian skill dibagi:

Skill type	Recommended Power
Fast / utility attack	0.85–1.10×
Standard offensive skill	1.20–1.40×
Strong attack	1.45–1.65×
Heavy attack	1.70–1.85×
Major finisher	1.90–2.00×
AoE	0.80–1.15× per target
Damage + strong debuff	1.00–1.25×
Beast signature	±1.60–1.80× + utility

Jangan terlalu cepat memberi skill 2.5× atau 3× karena Boost3 sendiri sudah memberikan:

×2.00.

Contoh:

1.8× finisher
× Boost3 2.0
= 3.6× base power

belum termasuk Weakness dan Broken.

Itu sudah sangat kuat.

5. Existing Fire Slash

Placeholder sekarang:

MP8 / Fire / 1.4×

Nilainya ternyata cukup sehat sebagai standard elemental skill.

Jadi secara balance philosophy:

1.4× = upper standard attack.

Tidak perlu diubah drastis sekarang.

Nama/fungsi final nanti menyesuaikan skill kit Aren.

6. Healing Scale

Existing Heal sekitar:

1.2× MAG

juga cukup bagus sebagai baseline single heal.

Recommended:

Single Heal

1.10–1.30× MAG

Target praktis:

memulihkan sekitar 30–45% HP karakter rata-rata.

Party Heal

0.65–0.85× MAG per ally

Target:

sekitar 20–30% HP party.

Kenapa group heal lebih lemah?

Karena satu action memulihkan hingga empat karakter.

7. MP Economy

Karena MP persisten antarbattle, cost harus terasa tetapi tidak terlalu pelit.

Recommended bands:

Action	MP
Cheap skill	4–6
Standard skill	7–9
Utility/debuff	7–10
Strong skill	10–14
AoE	10–15
High-tier spell	15–22
Single Heal	8–10
Party Heal	14–18
BEAST	sekitar 16–20

Spirit Tonic tetap:

+20 MP

Jadi satu Tonic kira-kira mengembalikan:

satu expensive action atau beberapa cheap actions.

Itu sehat.

8. Aelia Spell MP Target

Contoh baseline:

Aeris       6 MP
Aeria      10 MP
Aeralis    12 MP
Aeralia    18 MP

Sehingga:

Aeris tidak menjadi obsolete.

Aeralis lebih kuat tetapi sekitar 2× cost.

AoE besar juga mahal.

9. Boost Balance

Multiplier sudah locked:

BP0 = 1.00
BP1 = 1.25
BP2 = 1.50
BP3 = 2.00

Dengan power skill:

Strong skill 1.6×
Boost3
= 3.2×

Broken normal enemy:

3.2 × 1.30
= 4.16×

Weakness jika applicable:

4.16 × 1.25
≈ 5.2×

Jadi kita tidak perlu skill coefficient ekstrem.

Core system sendiri sudah menciptakan burst tinggi.

10. Buff Standard

Saya rekomendasikan standard buff:

+20%

Untuk:

ATK Up
DEF Up
MAG Up
SPD Up

Standard debuff sedikit lebih konservatif:

-15%

Untuk:

ATK Down
DEF Down
MAG Down
SPD Down

Alasannya Break Bonus sendiri sudah mempunyai DEF/SPD debuff khusus.

11. Buff Duration

Recommended baseline:

2 natural turns milik target.

Contoh Tailwind:

SPD Up
Duration = 2 natural Aelia/ally turns

Extra action dari Deep Stagger:

tidak mempercepat countdown.

Ini konsisten dengan prinsip BP dan natural turns.

Beberapa self stance boleh 1 turn saja kalau effect-nya sangat kuat.

12. Stacking Rule

Ini perlu kita tentukan supaya tidak terjadi buff stacking liar.

Saya rekomendasikan:

Effect dari kategori sama

Tidak additive-stack.

Misalnya:

DEF Down 15%
+
DEF Down 15%

bukan menjadi -30%.

Yang lebih kuat menang dan duration bisa direfresh.

Normal debuff + Break Bonus

Boleh coexist.

Contoh:

Sylven DEF Down
+
Armor Shatter

Karena Armor Shatter merupakan reward sistem Break yang berbeda.

Ini membuat Break Bonus tetap spesial.

13. Torga Defensive Numbers

Torga tidak boleh menjadi immortal.

Initial direction:

Iron Stance

sekitar 20–25% additional damage reduction.

Defend tetap:

50%.

Jika keduanya aktif bersamaan, gunakan multiplicative, bukan additive.

Jangan:

50% + 25% = 75%

Lebih sehat seperti:

Damage ×0.50
then ×0.75

= sekitar 62.5% total reduction.

Itu kuat tetapi tidak absurd.

14. Counter Balance

Counter harus membutuhkan action/setup.

Initial target:

Torga

counter sekitar 0.9–1.1× ATK

karena defensive value-nya juga besar.

Katsura

counter sekitar 1.2–1.4× ATK

karena precision response adalah core identity-nya.

Counter sebaiknya terbatas pada:

1 successful trigger per stance, setidaknya pada baseline.

Ini mencegah satu AoE enemy menghasilkan 8 retaliations.

15. Kaelis Initiative Bonus

Gimmick:

target belum bertindak → bonus.

Saya rekomendasikan bonus awal:

+20–25% damage

bukan ×2.

Contoh:

First Thrust
1.3× base

Target belum bertindak:
1.3 × 1.25
= 1.625×

Sudah cukup memberi alasan kuat mengejar SPD.

16. Doran Broken Bonus

Doran memang harus punya Broken payoff terbesar.

Recommended personal bonus:

sekitar +20–25% terhadap target Broken.

Ini di atas global Broken multiplier.

Tetapi hanya pada skill tertentu seperti Execution Swing.

Jangan semua serangan Doran mendapat bonus itu.

17. Orin Sustain

Self-heal jangan terlalu tinggi.

Target:

sekitar 10–15% max HP

untuk skill sustain.

Tujuannya:

memperpanjang kemampuan bertarung.

Bukan menggantikan Neria.

18. Regular Enemy Damage

Target baseline:

Normal physical attack enemy terhadap karakter rata-rata:

15–25% max HP.

Heavy attack:

25–40%.

Artinya pemain tidak mati karena dua random scratch, tetapi mengabaikan beberapa enemy tetap berbahaya.

19. Boss Damage

Normal boss action:

20–30% HP karakter rata-rata.

Strong attack:

35–45%.

Telegraphed major attack:

bisa mencapai 45–60% jika tidak Defend/mitigate.

Ini memberi fungsi nyata untuk:

Defend,
Torga,
healing,
queue manipulation.

Tetapi tidak menjadikan boss one-shot machine.

20. Enemy HP Philosophy

Daripada menentukan satu angka universal, gunakan attack-equivalent.

Weak regular enemy

sekitar 2–3 basic attacks.

Standard regular

3–5 attacks.

Elite

6–10 attacks.

Boss

kira-kira 18–30 average unboosted attack-equivalents, kemudian disesuaikan berdasarkan mechanic.

Dengan party 4:

boss 6–10 rounds masih masuk akal karena tidak setiap action digunakan untuk damage.

21. Break Value

Break count jangan terlalu tinggi.

Baseline yang saya rekomendasikan:

Normal enemies

2–4 BREAK

Elite

4–6

Mini-boss

5–7

Boss

6–9

Boss akhir mungkin lebih tinggi atau berubah antar-phase.

Kalau Break 15–20, Weakness mechanic mulai terasa seperti pekerjaan rutin daripada tactical opening.

22. Expected Encounter Length

Tetap sesuai philosophy:

Regular battle: 2–4 natural rounds.
Elite: 3–6 rounds.
Boss: 6–10 rounds.

Kalau playtest menunjukkan average wolf fight 7 round:

musuh terlalu tebal / damage party terlalu rendah.

Bukan berarti pemain harus grind.

23. EXP Progression

Existing:

Wolf  = 25 EXP
Beast = 40 EXP

Ini masih cocok sebagai early-game reward.

Future approximate enemy bands:

Arc	EXP per normal enemy
Lorel	25–45
Alexandria	40–65
Mongreaux	60–90
Kamikoto	90–130
Aetherion	120–170

Battle dengan beberapa enemy menjumlahkan rewards normal.

Boss memberikan reward jauh lebih besar.

Tujuan akhirnya:

main-route player mencapai ±Lv20–22 tanpa grinding.

24. Recruitment Levels

Karakter yang baru join jangan masuk jauh di bawah expected story level.

Contoh target:

Lyra/Doran    → early Lorel band
Aelia         → Alexandria band
Neria/Torga   → Mongreaux band
Katsura       → early Kamikoto band
Kaelis        → Kamikoto band
Sylven        → Kamikoto band
Orin          → late Kamikoto band

Exact join level lebih baik ditentukan berdasarkan pacing EXP setelah encounter count nyata tersedia.

Jangan memaksa player grind karakter baru hanya agar usable.

25. Reserve EXP

Rule tetap:

Reserve = 0 EXP.

Jadi balance game jangan mengasumsikan seluruh 10 karakter selalu setara level.

Final boss juga tidak boleh membutuhkan:

“semua 10 harus Lv20”.

Narrative contribution semua karakter ≠ semuanya harus bertarung di satu combat encounter.

26. Flee

Existing:

70% normal flee chance

tetap bagus.

Failed flee:

action consumed.

Tidak perlu scale flee berdasarkan level sekarang kecuali playtest menunjukkan masalah.

27. Item Economy

Existing:

Potion        +50 HP
Spirit Tonic  +20 MP

Ini sudah cocok dengan proposed character stats.

Early game Potion akan terasa sangat kuat.

Late game:

masih berguna tetapi tidak menggantikan Neria.

Itu bagus.

28. Balance Guardrails

Saya sangat menyarankan kita lock lima aturan ini:

1. Tidak ada mandatory grinding.

2. Tidak ada regular enemy HP sponge.

3. Tidak ada character yang wajib dibawa untuk boss tertentu.

4. Boost3 + Broken harus terasa sangat kuat.

5. Strong combo boleh menghasilkan angka besar, tetapi bukan infinite loop.

29. Apa yang Disebut “Final” di Numerical Balance?

Bukan berarti:

Doran ATK 23 tidak boleh menjadi 22.

Yang kita lock adalah:

Doran harus termasuk ATK tertinggi.
Doran harus termasuk SPD terendah.
Torga harus paling durable.
Lyra/Kaelis harus sangat cepat.
Aelia/Neria harus mendominasi magic.

Angka:

soft values.

Identity:

hard values.

Ini jauh lebih sehat untuk production.

30. Numerical Balance Status
Area	Status
Level progression target	🟢
Character stat ratios	🟢
Baseline stat v1	🟢
Damage tiers	🟢
Heal target	🟢
MP economy	🟢
Buff/debuff magnitude	🟢
Counter baseline	🟢
Break count targets	🟢
Enemy damage targets	🟢
Enemy HP targets	🟢
EXP pacing	🟢
No-grind philosophy	🔒
Exact final numbers	🟡 playtest-dependent