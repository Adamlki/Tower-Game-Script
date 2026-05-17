# 🗼 Roblox Tower Game — Full Feature Setup Guide

> Game tower dengan sistem Troll, Jump Upgrade, Tools, Checkpoint, Admin, dan banyak lagi!
> Dibangun untuk **Antigravity** dengan UI React-style (Roact / ScreenGui).

---

## 📁 Struktur Folder di Roblox Studio

```
ReplicatedStorage/
├── Shared/
│   └── Config          ← ModuleScript

ServerScriptService/
├── MainServer          ← Script
└── Modules/
    ├── AdminSystem     ← ModuleScript
    ├── PurchaseSystem  ← ModuleScript
    ├── TrollSystem     ← ModuleScript
    └── CheckpointSystem← ModuleScript

StarterPlayerScripts/
├── MainClient          ← LocalScript
└── Controllers/
    ├── SpectateController   ← ModuleScript
    ├── TrollController      ← ModuleScript
    ├── JumpController       ← ModuleScript
    ├── CheckpointController ← ModuleScript
    ├── GroupController      ← ModuleScript
    └── AdminUIController    ← ModuleScript

StarterGui/
└── TowerGameGui (ScreenGui)
    └── UIScale (diinject otomatis oleh MainClient)
```

---

## ⚙️ Konfigurasi Awal (`Config.lua`)

Buka `ReplicatedStorage > Shared > Config` dan ubah:

| Field | Keterangan |
|-------|-----------|
| `Config.OwnerId` | UserId kamu (cek di roblox.com/users) |
| `Config.GroupId` | ID grup/community kamu |
| `Config.MapPlaceId` | Place ID map kamu (untuk favorite) |
| `Config.Products.*` | Product ID dari Developer Console |

### Cara dapat Product ID:
1. Buka **Creator Dashboard** → **Associated Items** → **Developer Products**
2. Buat produk baru untuk setiap fitur (Kill, Fling, DoubleJump, dll.)
3. Salin Product ID ke `Config.Products`

---

## 🗂️ Setup Workspace

### Checkpoints
Buat folder di `Workspace` bernama **`Checkpoints`**, lalu isi dengan Part:
```
Checkpoints/
├── Checkpoint1  ← Part
├── Checkpoint2  ← Part
├── Checkpoint3  ← Part
└── ...
```
> Nama harus mengandung angka urut (Checkpoint**1**, Checkpoint**2**, dst.)
> Script otomatis sort berdasarkan angka.

---

## 🎮 Fitur Lengkap

---

### 🎭 Troll System

**Cara kerja:**
1. Player klik tombol **"Troll"** di UI
2. Kamera berpindah ke mode **Spectate** → menampilkan nama player
3. Di panel kanan muncul daftar troll
4. Player pilih target dari **Player List UI**
5. Klik troll → otomatis prompt beli Product (kecuali admin)
6. Setelah beli, troll langsung dieksekusi ke target

**Daftar Troll:**

| Troll | Efek | Bisa Dibeli Berkali-kali |
|-------|------|--------------------------|
| Kill | Bunuh target | ✅ |
| Fling | Lempar target ke udara | ✅ |
| Kick | Keluarkan target dari server | ✅ |
| Slow Player | Kurangi WalkSpeed target selama 10 detik | ✅ |
| Earth Quake | Guncang posisi target selama 2 detik | ✅ |
| Jumpscare | Flash jumpscare di layar target | ✅ |
| Freeze | Bekukan target selama 15 detik | ✅ |
| Set Fire | Bakar target + damage over time | ✅ |
| Kill All | Bunuh semua player kecuali pembeli | ✅ |
| Slow All | Lambatkan semua player kecuali pembeli | ✅ |

> **Troll "All"** tidak perlu target, langsung eksekusi ke semua player.

---

### 📷 Spectate System

- Klik tombol **Troll** → mode spectate aktif otomatis
- Nama player yang di-spectate muncul di layar
- Tombol **◀ Prev** dan **▶ Next** untuk skip antar player
- Keluar dari spectate → kamera kembali ke player sendiri

---

### 🦘 Jump Upgrade System

**Urutan pembelian:**

| Level | Nama | Harga | Max Jump |
|-------|------|-------|----------|
| 1 | Default | Gratis | 1x |
| 2 | Double Jump | 5 Robux | 2x |
| 3 | Triple Jump | 25 Robux | 3x |
| 4 | Quad Jump | Beli lagi | 4x |
| 5 | Penta Jump | Beli lagi | 5x |

**Fitur input custom:**
- Setelah beli hingga level tertentu, player bisa **ketik angka** (1–max level)
- Contoh: punya 5 jump tapi mau pakai 3 → ketik `3` → apply
- Input dikirim ke server via `SetCurrentJump`

---

### 🛒 Tools Shop

4 tools yang bisa dibeli (sesuaikan di `Config.Tools`):

| Tools | Default Name | Keterangan |
|-------|-------------|-----------|
| Tool1 | Speed Coil | Bergerak lebih cepat |
| Tool2 | Gravity Coil | Gravitasi rendah |
| Tool3 | Rainbow Coil | Trail rainbow |
| Tool4 | God Sword | Senjata kuat |

> Ganti nama, deskripsi, dan Product ID di `Config.lua`
> Admin mendapat semua tools gratis.

---

### 🏁 Checkpoint System

**Cara kerja:**
1. Player menyentuh Part checkpoint → disimpan ke server
2. Jika player **jatuh** (Y < -50), popup muncul otomatis
3. Popup memberi pilihan:

| Pilihan | Efek |
|---------|------|
| **Ya (gratis)** | Countdown 15 detik → teleport ke last checkpoint |
| **Skip (5 Robux)** | Langsung teleport ke last checkpoint |
| **Tidak** | Mundur 1 checkpoint (CP-1) |

> Sesuaikan nilai `FALL_Y = -50` di `CheckpointController.lua` sesuai ketinggian map kamu.

**Struktur checkpoint di Workspace:**
- Folder: `Workspace > Checkpoints`
- Parts diberi nama `Checkpoint1`, `Checkpoint2`, dst.

---

### 👥 Group & Favorite Popup

**Group Popup:**
- Muncul otomatis 5 detik setelah join jika belum dalam grup
- Tombol **Join Group** → membuka halaman grup Roblox
- 10 detik setelah klik join → muncul popup **Claim Reward**
- Claim → server kasih free tools ke player

**Favorite Map Popup:**
- Muncul 13 detik setelah join
- Tombol **Favorite** → membuka halaman Place di Roblox
- Pakai `Config.MapPlaceId` (bukan item ID)

---

### 👑 Admin System

**Hierarki:**
```
Owner (Config.OwnerId)
  └── Admin (disimpan di DataStore)
        └── Player biasa
```

**Keuntungan admin:**
- ✅ Semua troll **gratis** (tidak perlu beli)
- ✅ Jump upgrade **gratis** (langsung max 5)
- ✅ Semua tools **gratis**
- ✅ Akses panel admin

**Cara tambah admin (Owner only):**
1. Buka panel admin di game
2. Masukkan **UserId** target di input box
3. Klik **Add Admin**

**Cara hapus admin:**
1. Masukkan UserId admin di input box
2. Klik **Remove Admin**

> Admin list disimpan di **DataStore** → permanen meski server restart.

---

### 📱 Responsive UI (UIScale)

Script UIScale sudah ada di `MainClient.lua`:

```lua
local baseX, baseY = 1366, 768
-- Scale otomatis menyesuaikan layar HP hingga PC
-- Range: 0.65 (HP kecil) hingga 1.5 (layar besar)
```

**Breakpoint:**
| Layar | Behavior |
|-------|----------|
| < 50% base | Scale × 1.2 (zoom in sedikit untuk HP kecil) |
| 50–80% base | Scale normal |
| > 120% base | Scale × 0.85 (shrink untuk layar besar) |

---

## 🖼️ UI Yang Perlu Dibuat di Studio

Buat di `StarterGui > TowerGameGui`:

### Frame/Popup yang dibutuhkan:
```
TowerGameGui (ScreenGui)
│
├── MainHUD              ← Frame utama
│   ├── TrollBtn         ← TextButton "Troll"
│   ├── AdminBtn         ← TextButton "Admin" (hidden default)
│   └── CPNotif          ← TextLabel notif checkpoint
│
├── SpectateUI           ← Frame spectate
│   ├── PlayerNameLabel  ← TextLabel nama player
│   ├── PrevBtn          ← TextButton "◀"
│   └── NextBtn          ← TextButton "▶"
│
├── TrollPanel           ← Frame panel troll (kanan layar)
│   ├── PlayerList       ← ScrollingFrame list player
│   └── TrollButtons/    ← Frame tombol-tombol troll
│       ├── KillBtn
│       ├── FlingBtn
│       ├── KickBtn
│       ├── SlowBtn
│       ├── EarthquakeBtn
│       ├── JumpscareBtn
│       ├── FreezeBtn
│       ├── SetFireBtn
│       ├── KillAllBtn
│       └── SlowAllBtn
│
├── JumpPanel            ← Frame upgrade jump
│   ├── BuyBtn           ← TextButton beli jump
│   ├── JumpInput        ← TextBox input angka
│   └── ApplyBtn         ← TextButton apply
│
├── ToolsPanel           ← Frame tools shop
│   ├── Tool1Btn
│   ├── Tool2Btn
│   ├── Tool3Btn
│   └── Tool4Btn
│
├── CheckpointPopup      ← Frame popup jatuh
│   ├── Label
│   ├── TimerLabel
│   ├── YesBtn
│   ├── SkipBtn          ← "Skip (5 Robux)"
│   └── NoBtn
│
├── GroupPopup           ← Frame popup join grup
│   ├── JoinBtn
│   └── CloseBtn
│
├── ClaimPopup           ← Frame popup claim reward
│   ├── ClaimBtn
│   └── CloseBtn
│
├── FavoritePopup        ← Frame popup favorite map
│   ├── FavBtn
│   └── CloseBtn
│
├── AdminPanel           ← Frame panel admin (hidden default)
│   ├── AdminIdInput     ← TextBox input UserId
│   ├── AddAdminBtn      ← hidden kecuali owner
│   └── RemoveAdminBtn   ← hidden kecuali owner
│
└── JumpscareFrame       ← Frame full screen hitam (jumpscare)
```

---

## 🔧 Tips & Troubleshooting

**Q: Troll tidak berfungsi?**
→ Pastikan `Config.Products` sudah diisi Product ID yang benar.
→ Cek Remote Events sudah terbuat di ReplicatedStorage.

**Q: Checkpoint tidak terdeteksi?**
→ Pastikan folder namanya tepat `Checkpoints` (huruf besar C).
→ Parts harus CanCollide = true.
→ Sesuaikan nilai `FALL_Y` di `CheckpointController.lua`.

**Q: Admin tidak bisa akses fitur gratis?**
→ Pastikan `Config.OwnerId` sudah diisi UserId yang benar.
→ Cek DataStore tidak error di Output.

**Q: UIScale tidak responsif?**
→ Pastikan `TowerGameGui` adalah nama ScreenGui yang benar di `MainClient.lua`.

**Q: Group popup tidak muncul?**
→ Pastikan `Config.GroupId` sudah diisi ID grup yang benar.

---

## 📝 Catatan Penting

- **DataStore** digunakan untuk menyimpan: list admin, data pembelian per player
- **Product ID** harus diisi sebelum publish — tanpa ini pembelian tidak berfungsi
- Semua **Remote Events/Functions** dibuat otomatis oleh script saat server start
- Script menggunakan `task.spawn` dan `task.delay` (modern Roblox API)
- Jumpscare menggunakan `RemoteEvent` server → client untuk keamanan

---

*Made for Antigravity Tower Game 🗼*