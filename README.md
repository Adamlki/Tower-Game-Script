# 🗼 Roblox Tower Game Framework

Sebuah framework / script open-source untuk game tower di Roblox. Dilengkapi dengan berbagai sistem penting seperti Troll, Jump Upgrade, Custom Tools, Checkpoint, dan Admin Panel. Script ini didesain rapi dan modular menggunakan pola arsitektur yang mudah dipahami.

---

## 📁 Struktur Direktori

Pastikan kamu meletakkan script di tempat yang sesuai pada Roblox Studio:

```text
ReplicatedStorage/
└── Shared/
    └── Config          ← ModuleScript

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
```

*(Catatan: UI menggunakan ScreenGui biasa, script `MainClient` akan mengatur scaling secara otomatis).*

---

## ⚙️ Konfigurasi (`Config.lua`)

Semua pengaturan utama ada di `ReplicatedStorage > Shared > Config`. Sesuaikan variabel berikut dengan game-mu:

- `Config.OwnerId`: Masukkan UserId kamu untuk akses penuh ke admin.
- `Config.GroupId`: ID Roblox Group kamu (untuk fitur popup group reward).
- `Config.MapPlaceId`: Place ID game-mu (untuk fitur favorite).
- `Config.Products`: Kumpulan Product ID dari Developer Products yang sudah kamu buat (untuk fitur berbayar seperti Troll, Jump, dll).

**Tips:** Buat Developer Products di Creator Dashboard terlebih dahulu, lalu salin ID-nya ke bagian `Config.Products`.

---

## 🎮 Fitur Utama

### 1. 🎭 Troll System
Player bisa melakukan troll ke player lain dengan membeli Developer Products. 
- **Spectate Mode:** Saat memilih target, player akan masuk ke mode spectate.
- **Macam-macam Troll:** Kill, Fling, Kick, Slow, Earthquake, Jumpscare, Freeze, Set Fire, Kill All, dan Slow All.

### 2. 🦘 Jump Upgrade System
Player bisa membeli upgrade double jump hingga penta jump (5x loncat).
- Ada fitur input manual di mana player bisa menyesuaikan jumlah jump yang sedang aktif (misalnya punya max 5, tapi hanya mau pakai 3).

### 3. 🛒 Tools Shop
Sistem toko in-game untuk membeli perlengkapan:
- Speed Coil
- Gravity Coil
- Rainbow Coil
- God Sword

### 4. 🏁 Checkpoint System
Sistem checkpoint otomatis berbasis part di Workspace.
- Buat folder bernama `Checkpoints` di Workspace.
- Isi dengan part bernama `Checkpoint1`, `Checkpoint2`, dst.
- Jika player jatuh (sumbu Y < -50), akan muncul popup untuk respawn gratis (dengan delay), atau bayar Robux untuk skip delay, atau kembali ke checkpoint sebelumnya.

### 5. 👑 Admin System
Hierarki admin yang terintegrasi dengan DataStore.
- **Owner:** Dapat menambahkan/menghapus admin lain langsung dari dalam game.
- **Keuntungan Admin:** Bisa menggunakan semua troll secara gratis, jump upgrade maksimal, dan bebas biaya tools.

### 6. 📱 Responsive UI (UIScale)
Script dilengkapi dengan Auto-Scaling UI yang mendeteksi ukuran layar player (Mobile, Tablet, PC) dan menyesuaikan `UIScale` secara dinamis.

---

## 🖼️ Kebutuhan UI

Kamu perlu membuat kerangka UI di `StarterGui > TowerGameGui` agar script berfungsi dengan baik. Berikut struktur elemen yang dibutuhkan:

- `MainHUD` (Tombol Troll, Admin, Notifikasi)
- `SpectateUI` (Nama target, tombol Prev/Next)
- `TrollPanel` (List player dan list tombol troll)
- `JumpPanel` (Panel upgrade jump)
- `ToolsPanel` (Toko tools)
- `CheckpointPopup` (Popup konfirmasi saat jatuh)
- `GroupPopup`, `ClaimPopup`, `FavoritePopup`
- `AdminPanel` (Input tambah/hapus admin)
- `JumpscareFrame` (Frame layar penuh untuk troll Jumpscare)

Pastikan penamaan elemen sesuai dengan yang dipanggil di script Controller.

---

## 🔧 Troubleshooting Singkat

- **Troll/Pembelian tidak jalan?** Pastikan `Config.Products` sudah terisi dengan Product ID yang valid dan game sudah di-publish ke Roblox.
- **Checkpoint tidak respon?** Pastikan huruf "C" besar pada folder `Checkpoints` dan nama part sudah sesuai format `Checkpoint[angka]`.
- **Fitur admin terkunci untuk Owner?** Cek apakah `Config.OwnerId` sudah sama dengan UserId profil Roblox kamu.

---

*Open Source - Silakan dimodifikasi sesuai kebutuhan proyek game-mu!*