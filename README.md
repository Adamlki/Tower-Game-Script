# Tower Game — Roblox

Game tower climb sederhana tapi punya banyak sistem di baliknya. Dibuat pakai Rojo biar script-nya bisa di-manage langsung dari VSCode dan di-push ke GitHub, tanpa harus buka-tutup Roblox Studio terus.

---

## Tools yang Dipakai

- **Rojo** — buat sync file Lua ke Roblox Studio
- **Aftman** — package manager buat Rojo-nya
- **Roblox Studio** — bikin map, GUI, dan Part-nya
- **Git + GitHub** — version control

---

## Struktur Project

```
src/
├── client/
│   ├── MainClient.client.lua 
│   └── Controllers/
│       ├── UIManager.lua       
│       ├── CheckpointController.lua
│       ├── JumpController.lua
│       ├── TrollController.lua
│       ├── SpectateController.lua
│       ├── ShopController.lua
│       ├── WinnerController.lua
│       ├── AdminUIController.lua
│       ├── MenuKananController.lua
│       ├── HideUIController.lua
│       ├── UfoController.lua
│       └── GroupController.lua
│
├── server/
│   ├── MainServer.server.lua  
│   └── Modules/
│       ├── AdminSystem.lua
│       ├── CheckpointSystem.lua
│       ├── DataSystem.lua
│       ├── LeaderstatSystem.lua
│       ├── PurchaseSystem.lua
│       ├── ShopSystem.lua
│       └── TrollSystem.lua
│
└── shared/
    └── Config.lua              
```

---

## Sistem yang Sudah Ada

### Checkpoint System
Player bisa menyentuh Part bernama `CP1`, `CP2`, dst. untuk menyimpan progress. Kalau jatuh, otomatis respawn di checkpoint terakhir. Ada beberapa opsi:
- **Skip Checkpoint** — langsung teleport ke checkpoint yang sudah dicapai (bayar Robux)
- **Skip Next Stage** — loncat ke checkpoint berikutnya
- **Skip to Finish** — langsung ke FinishPart

Kalau player pilih "Cancel" waktu mau respawn otomatis, checkpoint-nya diturunkan satu level dan ada timer 30 detik sebelum reset paksa.

Di sisi client, ada panah 3D (`panah` dari ReplicatedStorage) yang berputar dan naik-turun, ngarah ke checkpoint berikutnya. Checkpoint yang sudah diinjak warnanya berubah jadi hijau pakai TweenService.

---

### Jump System
Player bisa upgrade kemampuan loncat dari 1x sampai maksimal 5x (Penta Jump) lewat Developer Product. Level jump disimpan di DataStore (`JumpLevel_v1`) jadi persistent.

Cara kerjanya pakai `AssemblyLinearVelocity` di HumanoidRootPart biar loncatannya berasa fisik dan nggak nge-bug. Ada cooldown kecil supaya jump ke-2 nggak langsung kepake pas baru angkat dari tanah.

Di GUI ada tombol untuk upgrade ke level berikutnya, harganya diambil otomatis dari MarketplaceService. Kalau sudah max level, tombol-nya disable dan tulisannya ganti jadi "MAXED OUT".

---

### Troll System
Admin atau player yang beli Developer Product bisa nge-troll player lain. Troll yang tersedia:

| Troll | Efek |
|---|---|
| Kill | Langsung matiin karakter target |
| Fling | Lempar karakter ke arah random dengan kecepatan tinggi |
| Kick | Kick dari server |
| Slow | WalkSpeed jadi 5 selama 10 detik |
| Earthquake | Guncang kamera target selama 10 detik |
| Jumpscare | Tampilkan JumpscareGui di layar target |
| Freeze | Anchor HumanoidRootPart selama 15 detik |
| SetFire | Pasang efek api, damage 15 HP per detik selama 10 detik |
| KillAll | Kill semua player kecuali pembeli |
| SlowAll | Slow semua player kecuali pembeli |

Sebelum eksekusi muncul ConfirmationFrame dulu biar nggak salah pencet. Ada notifikasi warna **hijau** kalau berhasil troll, dan **merah** buat player yang kena.

---

### Admin System
List admin disimpan di DataStore (`AdminList_v1`). Owner (berdasarkan `OwnerId` di Config) otomatis dapet akses admin dan nggak bisa dihapus dari list.

Admin dapat:
- Semua troll gratis (nggak perlu beli Developer Product)
- Jump langsung max level (5x)
- Skip checkpoint gratis
- Akses Admin UI panel

---

### Data & Leaderboard
Data win player disimpan di dua tempat:
- `PlayerWinsData_v1` — untuk load/save personal
- `GlobalWinsLeaderboard_v1` — OrderedDataStore untuk papan ranking

Leaderboard di Workspace (`WinnerLeaderboard > Papan > SurfaceGui`) diupdate otomatis setiap 30 detik. Menampilkan top 50 player beserta foto profil dan total win-nya.

Nama dan foto profil di-cache di memori server supaya nggak spam API call tiap kali refresh.

---

### Shop System
Player bisa beli Gamepass untuk dapat Tools (Speed Coil, Gravity Coil, dll.). Tool diberikan ke Backpack dan StarterGear supaya tetap ada setelah respawn. Admin otomatis dapat semua item tanpa perlu beli.

---

### UI System (UIManager)
Semua animasi UI dipusatkan di `UIManager.lua`:
- `AnimateFrameIn` / `AnimateFrameOut` — slide animasi masuk/keluar frame
- `ApplyButtonAnimation` — hover scale effect di semua tombol
- `ApplyShakeEffect` — efek getar loop untuk elemen tertentu
- `ShowNotification` — notifikasi popup yang muncul di layar, bisa hijau (sukses) atau merah (error)

---

### Winner GUI
Ada GUI kecil yang menampilkan total win player saat ini. Setiap kali win bertambah, ada animasi "pop" di text-nya. Kalau panel Troll dibuka, GUI ini disembunyikan dulu dan muncul lagi waktu panel ditutup.

---

## Setup Awal

1. Install [Aftman](https://github.com/LPGhatguy/aftman) lalu jalankan:
   ```
   aftman install
   ```
2. Jalankan Rojo server:
   ```
   rojo serve
   ```
3. Di Roblox Studio, connect ke Rojo server lewat plugin Rojo.
4. Isi semua ID di `src/shared/Config.lua`:
   - `OwnerId` — UserId kamu
   - `GroupId` — ID grup
   - `Products.*` — ID Developer Product dari Creator Dashboard
   - `ShopGamepasses.*` — ID Gamepass

5. Buat Part-part berikut di Workspace Studio:
   - Folder `Checkpoints` berisi `CP1`, `CP2`, ..., `FinishPart`, `ResetPart`
   - Model `WinnerLeaderboard` berisi `Papan > SurfaceGui > Frame > MainFrame`
   - Object `panah` di ReplicatedStorage (Union 3D panah arah)

6. Buat GUI di StarterGui:
   - `MenuUtama`, `SelectTrollGui`, `JumpUpgradeGui`
   - `NotificationGui`, `WinnerGui`, `JumpscareGui`, `HideGui`
   - Dan GUI lainnya sesuai kebutuhan controller

---

## Catatan

- Semua ID di `Config.lua` masih placeholder, harus diganti dengan ID yang valid sebelum publish.
- `FilteringEnabled` aktif, jadi semua validasi penting ada di server.
- Script bisa berkembang — sistem ini dibuat modular supaya gampang nambah fitur baru tanpa harus ubah banyak file.