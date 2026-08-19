# EduTech SMK

EduTech SMK adalah aplikasi LMS dan monitoring sekolah berbasis Flutter + Firebase untuk kebutuhan proyek akhir mata kuliah Mobile Cross-Platform Development. Aplikasi ini dirancang untuk mendukung banyak peran dalam satu codebase: siswa, guru mapel, wali kelas, guru BK, guru piket, dan admin.

## Live Demo

- Live web app: https://edutech-smk-dd479.web.app
- Firebase project: `edutech-smk-dd479`

## Tech Stack

- Frontend: Flutter 3.47
- Backend: Firebase Authentication, Cloud Firestore, Firebase Hosting
- State Management: Provider
- Architecture: Feature-First Pattern

## Fitur Utama yang Sudah Aktif

### Authentication & Role Routing

- Login Firebase Authentication berbasis email/password
- Routing dashboard otomatis berdasarkan role pengguna
- Seeder akun demo untuk seluruh role

### Siswa

- Melihat materi dari koleksi `materi`
- Melihat tugas/kuis dari koleksi `tugas`
- Menandai tugas sebagai `Dikumpulkan`
- Melihat detail materi dan detail tugas
- Absensi mandiri dan melihat rekap absensi pribadi
- Mengirim pengaduan langsung ke Guru BK
- Melihat status dan tindak lanjut aduan BK

### Guru Mapel

- Unggah materi
- Fallback materi via tautan eksternal bila Firebase Storage belum dipakai penuh
- Input absensi kelas
- Membuat tugas/kuis baru

### Wali Kelas

- Monitoring daftar siswa perwalian
- Alert system untuk simulasi alpha dan penurunan nilai
- Rekap absensi kelas berdasarkan tanggal
- Ringkasan aduan BK terkait kelas
- Ringkasan catatan Guru Piket

### Guru BK

- Membaca aduan masuk dari siswa
- Mengubah status penanganan aduan
- Memberi respons atau tindak lanjut aduan

### Guru Piket

- Input absensi tanpa QR code
- Menyimpan catatan kejadian harian ke Firestore
- Filter catatan berdasarkan tanggal dan jenis kejadian

## Struktur Project

```text
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── constants/
│   ├── services/
│   └── theme/
└── features/
		├── auth/
		├── student/
		├── teacher/
		├── wali_kelas/
		├── bk/
		├── piket/
		└── admin/
```

## Akun Demo

Semua akun memakai password yang sama:

```text
password123
```

Role utama:

- Siswa utama: `siswa@edutech.sch.id`
- Guru mapel: `guru@edutech.sch.id`
- Wali kelas XII RPL 1: `walikelas@edutech.sch.id`
- Wali kelas XI RPL 1: `walikelas2@edutech.sch.id`
- Guru BK: `bk@edutech.sch.id`
- Guru Piket: `piket@edutech.sch.id`
- Admin: `admin@edutech.sch.id`

Seeder juga membuat 30 akun siswa demo yang tersebar ke beberapa kelas, termasuk:

- `XII RPL 1`
- `XI RPL 1`
- `XII TKJ 1`

Contoh email siswa tambahan:

- `siswa02@edutech.sch.id`
- `siswa03@edutech.sch.id`
- ...
- `siswa30@edutech.sch.id`

## Naskah Demo 10 Menit

Bagian ini disiapkan sebagai panduan presentasi singkat namun tetap padat. Alurnya dibuat agar dosen atau penguji langsung melihat nilai utama aplikasi: multi-role, integrasi Firebase, dan alur data antarpengguna.

### Tujuan Presentasi

Tujuan demo adalah menunjukkan bahwa EduTech SMK bukan hanya tampilan antarmuka, tetapi sudah memiliki alur kerja nyata antarperan sekolah, yaitu siswa, guru mapel, wali kelas, guru BK, guru piket, dan admin dalam satu sistem terintegrasi.

### Pembagian Waktu 10 Menit

- Menit 1: Pembukaan dan tujuan sistem
- Menit 2: Login dan routing multi-role
- Menit 3: Demo Guru Mapel
- Menit 4: Demo Siswa
- Menit 5: Demo Guru BK
- Menit 6: Demo Wali Kelas
- Menit 7: Demo Guru Piket
- Menit 8: Demo Admin / portal kontrol
- Menit 9: Penjelasan arsitektur dan Firebase
- Menit 10: Penutup dan nilai proyek

### Pembukaan Presentasi

Kalimat pembuka yang bisa digunakan:

"Pada presentasi ini saya akan mendemonstrasikan aplikasi EduTech SMK, yaitu sistem LMS dan monitoring sekolah berbasis Flutter dan Firebase. Aplikasi ini menggunakan satu codebase multi-platform dan mendukung banyak role pengguna dalam ekosistem sekolah, mulai dari siswa, guru mapel, wali kelas, guru BK, guru piket, hingga admin."

Lanjutkan dengan kalimat:

"Fokus utama sistem ini adalah integrasi data pembelajaran, absensi, aduan konseling, dan monitoring siswa agar komunikasi antarperan di sekolah menjadi lebih efisien, transparan, dan terdokumentasi secara digital."

### 1. Demo Login dan Role Routing

Halaman yang ditunjukkan:

- Halaman login
- Shortcut akun demo

Yang dijelaskan:

- Setiap akun login memiliki role berbeda
- Setelah login, sistem otomatis membaca profile user dari Firebase Authentication dan Firestore
- Berdasarkan role tersebut, pengguna diarahkan ke dashboard yang sesuai

Kalimat penjelasan:

"Pada halaman login, saya menyiapkan akun demo agar setiap peran dapat diuji langsung. Setelah pengguna berhasil login, aplikasi tidak hanya memverifikasi akun melalui Firebase Authentication, tetapi juga membaca profile dan role dari Cloud Firestore. Dari sana sistem melakukan routing otomatis ke dashboard yang sesuai."

### 2. Demo Guru Mapel

Gunakan akun:

- `guru@edutech.sch.id`

Halaman yang ditunjukkan:

- Dashboard Guru Mapel
- Upload Materi
- Kelola Tugas & Kuis
- Input Absensi Real-time

Yang dijelaskan:

- Guru bisa mengunggah materi untuk kelas target
- Jika Storage belum dipakai penuh, sistem tetap bisa memakai tautan eksternal
- Guru bisa membuat tugas atau kuis baru
- Guru bisa mengisi absensi siswa per kelas

Kalimat penjelasan:

"Pada dashboard Guru Mapel, fitur utamanya adalah publikasi materi, pembuatan tugas, dan input absensi. Materi disimpan ke Firestore dan secara otomatis akan muncul di dashboard siswa sesuai kelasnya. Selain itu, guru dapat membuat tugas/kuis baru dan data tersebut juga langsung terhubung ke sisi siswa. Untuk absensi, guru cukup memilih kelas lalu menandai status hadir, izin, sakit, atau alpha."

Jika ingin menunjukkan nilai teknis:

"Semua data ini dibaca ulang secara real-time menggunakan stream dari Firestore sehingga perubahan cepat terlihat di peran lain."

### 3. Demo Siswa

Gunakan akun:

- `siswa@edutech.sch.id`

Halaman yang ditunjukkan:

- Tab Materi & Tugas
- Detail materi
- Detail tugas
- Tombol tandai tugas `Dikumpulkan`
- Tab Jadwal & Presensi
- Tab Booking BK / Pengaduan

Yang dijelaskan:

- Siswa menerima materi yang dikirim guru sesuai kelas
- Siswa melihat tugas/kuis dan dapat mengubah status menjadi `Dikumpulkan`
- Siswa bisa absen mandiri dan melihat rekap kehadiran
- Siswa bisa mengirim pengaduan atau aduan ke Guru BK

Kalimat penjelasan:

"Di sisi siswa, halaman pertama berfungsi sebagai pusat pembelajaran. Materi yang diunggah guru otomatis muncul di sini. Tugas yang dibuat guru juga tampil, dan ketika salah satu tugas dibuka, siswa bisa melihat detailnya sekaligus menandai statusnya sebagai sudah dikumpulkan."

Lanjutkan:

"Pada tab Jadwal & Presensi, siswa dapat melihat jadwal harian, melakukan absensi mandiri, dan membaca rekap kehadiran mereka dari Firestore. Kemudian pada tab BK, siswa bisa mengirim pengaduan langsung kepada Guru BK dan memantau respons atau tindak lanjutnya."

### 4. Demo Guru BK

Gunakan akun:

- `bk@edutech.sch.id`

Halaman yang ditunjukkan:

- Dashboard BK
- Tab daftar aduan masuk
- Tab tracking kasus
- Modal tindak lanjut

Yang dijelaskan:

- Guru BK menerima laporan langsung dari siswa
- Guru BK dapat mengubah status kasus
- Guru BK dapat menulis respons atau tindak lanjut penanganan

Kalimat penjelasan:

"Dashboard Guru BK berfungsi sebagai pusat penanganan konseling dan aduan siswa. Semua pengaduan yang dikirim siswa masuk ke koleksi reports dan ditampilkan di dashboard BK. Di sini Guru BK dapat mengubah status penanganan, misalnya dari menunggu menjadi diproses atau selesai, lalu menuliskan tindak lanjut agar siswa dapat melihat respons tersebut secara langsung."

### 5. Demo Wali Kelas

Gunakan akun:

- `walikelas@edutech.sch.id`
- `walikelas2@edutech.sch.id`

Halaman yang ditunjukkan:

- Dashboard Wali Kelas
- Ringkasan perwalian
- Filter tanggal
- Rekap absensi
- Ringkasan aduan BK
- Catatan Guru Piket
- Monitoring siswa dengan alert

Yang dijelaskan:

- Wali kelas menjadi pusat pemantauan kelas binaan
- Wali kelas melihat agregasi absensi, aduan BK, dan catatan guru piket
- Alert system menunjukkan siswa yang butuh perhatian khusus

Kalimat penjelasan:

"Dashboard Wali Kelas saya rancang sebagai pusat pemantauan siswa. Di halaman ini wali kelas dapat melihat ringkasan absensi per tanggal, aduan BK dari siswa di kelasnya, catatan kejadian dari Guru Piket, serta alert system cerdas untuk siswa dengan kondisi tertentu, misalnya alpha berulang atau penurunan performa akademik. Dengan begitu, wali kelas tidak perlu membuka data satu per satu dari sumber terpisah."

### 6. Demo Guru Piket

Gunakan akun:

- `piket@edutech.sch.id`

Halaman yang ditunjukkan:

- Form Absensi Guru Piket
- Form Catatan Kejadian Harian
- Filter log kejadian berdasarkan tanggal dan jenis kejadian

Yang dijelaskan:

- QR sudah dihapus dan diganti proses input yang lebih praktis
- Guru piket bisa menyimpan kejadian harian langsung ke Firestore
- Data itu juga muncul sebagai rekap di dashboard wali kelas

Kalimat penjelasan:

"Di dashboard Guru Piket, saya menghilangkan ketergantungan pada QR agar skenario demo dan penggunaan lebih sederhana. Guru Piket dapat tetap menginput absensi dan juga menyimpan catatan kejadian harian seperti keterlambatan atau izin pulang. Data tersebut disimpan ke Firestore dan digunakan kembali oleh dashboard Wali Kelas sebagai bahan pemantauan."

### 7. Demo Admin

Gunakan akun:

- `admin@edutech.sch.id`

Halaman yang ditunjukkan:

- Dashboard Admin
- Menu role management, master data, dan pengaturan Firebase

Yang dijelaskan:

- Admin berfungsi sebagai portal kontrol sistem
- Admin menjadi role dengan hak akses tertinggi untuk pengelolaan data inti

Kalimat penjelasan:

"Role admin saya posisikan sebagai portal kontrol sistem. Di sini admin dapat menjadi pengelola data inti seperti role pengguna, master data sekolah, dan pengaturan sistem. Pada tahap ini antarmukanya masih berupa kerangka operasional, namun struktur dan routing-nya sudah siap dikembangkan lebih lanjut."

### 8. Penjelasan Arsitektur Teknis

Poin yang disampaikan:

- Satu codebase Flutter untuk banyak role
- Arsitektur Feature-First
- State management memakai Provider
- Backend memakai Firebase Authentication dan Cloud Firestore
- Hosting memakai Firebase Hosting

Kalimat penjelasan:

"Dari sisi teknis, aplikasi ini dibangun dengan Flutter menggunakan pola Feature-First agar pemisahan modul per role lebih rapi. Untuk state management saya menggunakan Provider. Autentikasi dilakukan oleh Firebase Authentication, sedangkan data utama seperti users, materi, tugas, attendance, reports, dan incident logs disimpan di Cloud Firestore. Untuk publikasi web, aplikasi ini dideploy ke Firebase Hosting."

### 9. Penutup Presentasi

Kalimat penutup yang bisa dipakai:

"Kesimpulannya, EduTech SMK sudah berhasil menunjukkan konsep sistem sekolah digital terintegrasi dengan banyak peran dalam satu aplikasi. Fitur utama seperti login multi-role, materi, tugas, absensi, aduan BK, catatan guru piket, dan monitoring wali kelas sudah saling terhubung melalui Firebase. Ke depan, sistem ini masih dapat dikembangkan lagi ke fitur penilaian penuh, notifikasi, serta laporan akademik yang lebih mendalam."

### 10. Tips Saat Presentasi

- Gunakan akun demo yang sudah disediakan agar perpindahan peran cepat.
- Mulai dari Guru Mapel lalu pindah ke Siswa agar hubungan sebab-akibat fitur terlihat.
- Setelah itu tunjukkan Guru BK dan Wali Kelas untuk memperlihatkan integrasi data lintas role.
- Siapkan dua akun wali kelas jika penguji ingin melihat perbedaan data antar kelas.
- Jika waktu mepet, fokuskan demo pada 4 role utama: Guru Mapel, Siswa, Guru BK, dan Wali Kelas.

## Cara Menjalankan Secara Lokal

### 1. Install dependency

```bash
flutter pub get
```

### 2. Jalankan aplikasi web

```bash
flutter run -d chrome
```

### 3. Generate akun demo

Di halaman login, klik tombol:

```text
Generate Demo Data
```

Tombol ini akan membuat akun demo di Firebase Authentication dan dokumen profile di koleksi `users`.

## Build Production Web

```bash
flutter build web
```

Output build akan berada di:

```text
build/web
```

## Firebase Rules & Hosting

Deploy Firestore rules:

```bash
firebase deploy --only firestore:rules --project edutech-smk-dd479
```

Deploy Hosting:

```bash
firebase deploy --only hosting --project edutech-smk-dd479
```

## Catatan Implementasi

- Koleksi Firestore utama yang dipakai saat ini:
	- `users`
	- `materi`
	- `tugas`
	- `attendance`
	- `reports`
	- `incident_logs`
	- `pelanggaran`
	- `konseling`
- Sistem unggah materi mendukung fallback URL eksternal jika bucket Firebase Storage belum digunakan penuh.
- Deployment Hosting aktif dan dapat diakses publik.

## Status Pengembangan

Yang sudah selesai:

- Authentication & role-based routing
- Dashboard multi-role dasar
- Absensi lintas peran
- Pengaduan BK dua arah
- Tugas/kuis dasar
- Rekap wali kelas
- Seeder multi-role dan multi-kelas
- Firebase Hosting live

Yang masih bisa dikembangkan:

- Penilaian/remedial tugas
- Filter tanggal lanjutan untuk BK
- Integrasi Storage penuh
- Notifikasi push FCM
- Admin portal yang lebih lengkap

## Repository

- GitHub: https://github.com/IZHARaja/edutech-smk
