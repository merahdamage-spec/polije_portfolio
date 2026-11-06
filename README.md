# POLIJE Student Portfolio (Flutter + PHP API + MySQL)

Arsitektur: Flutter -> REST API (PHP/PDO) -> MySQL

## 1. Backend (XAMPP)
1. Install & jalankan XAMPP -> start **Apache** dan **MySQL**.
2. Salin folder `polije_api` ke `C:\xampp\htdocs\polije_api`.
3. Buka http://localhost/phpmyadmin -> tab **Import** -> pilih `polije_api/database.sql` -> Go.
4. Tes API di browser: http://localhost/polije_api/portfolios.php  (harus tampil JSON 5 data).

## 2. Flutter
```bash
flutter create .
flutter pub get
flutter run -d chrome
```
Alamat API diatur di `lib/config.dart` (Chrome: localhost, emulator Android: 10.0.2.2, HP asli: IP laptop).

## Endpoint
| Method | URL | Fungsi |
|---|---|---|
| GET    | portfolios.php?category=&keyword= | Read (list + filter + cari) |
| GET    | portfolios.php?id=1 | Read satu data |
| POST   | portfolios.php | Create (body JSON) |
| PUT    | portfolios.php?id=1 | Update (body JSON) |
| DELETE | portfolios.php?id=1 | Delete |
| DELETE | portfolios.php?all=1 | Hapus semua |

## Foto profil (CRUD)
- Tabel `profile_photo` + endpoint `polije_api/profile_photo.php` (GET / PUT / DELETE).
- Di aplikasi: Profil -> ketuk avatar -> Lihat / Ganti (Tambah) / Hapus foto.
