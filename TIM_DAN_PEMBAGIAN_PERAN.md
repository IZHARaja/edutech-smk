# 👥 Tim Pengembang & Pembagian Peran Proyek EduTech SMK

Dokumen ini memuat informasi lengkap mengenai susunan tim pengembang, rincian kontribusi teknis masing-masing anggota dalam pembangunan aplikasi **EduTech SMK**, serta panduan pembagian presentasi / video demonstrasi (10 Menit) untuk tugas akhir mata kuliah **Mobile Cross-Platform Development**.

---

## 🌟 Susunan Tim & Kontribusi Pengembangan

| No | Nama Anggota | NIM | Peran Utama | Fokus Kontribusi & Modul Proyek |
|---|---|---|---|---|
| **1** | **IZHAR** | **105841109023** | **Project Leader & Core Full-Stack Architect** | **Arsitektur Utama, Firebase Core (Auth, Firestore, Hosting), Role Router, Modul Siswa & Guru Mapel, Seeder Data, Live Deployment** |
| 2 | MUH RAFLI | 105841108723 | Lead Feature Developer | Modul Wali Kelas, Smart Alert System (Alpha >3x & Drop Nilai), Rekap Absensi Kelas |
| 3 | M Erwin Khusnaedy | 105841120623 | Backend & Feature Developer | Modul Bimbingan Konseling (BK), Sistem Aduan Dua Arah & Form Tindak Lanjut |
| 4 | NAWAT SAKTI AL'AGASI | 105841108823 | Feature Developer | Modul Guru Piket, Log Kejadian Harian (Keterlambatan/Izin) & Sistem Filter Tanggal |
| 5 | Muh. Rizki Aqil Az-zikra Alimuddin | 105841109623 | UI/UX Specialist & QA Engineer | Portal Admin (Web Responsive Layout), Material 3 Theming, Quality Assurance & Testing |

---

## 🛠️ Rincian Tugas & Kontribusi Teknis (Work Breakdown Structure)

### 👑 1. IZHAR (105841109023) — *Project Leader & Core Full-Stack Architect*
Sebagai penanggung jawab utama dan arsitek sistem, Izhar merancang dan membangun fondasi serta modul-modul inti aplikasi:
- **Perancangan Arsitektur Aplikasi**: Menginisiasi dan menyusun struktur folder berbasis *Feature-First Pattern* serta manajemen state menggunakan *Provider Pattern*.
- **Firebase Backend & Security Architecture**:
  - Mengonfigurasi Firebase Authentication (Email/Password) dan integrasi platform Web.
  - Merancang skema database Cloud Firestore dan menyusun `firestore.rules` berbasis keamanan per-role (6 peran pengguna).
  - Melakukan setup dan deployment production live ke **Firebase Hosting** ([https://edutech-smk-dd479.web.app](https://edutech-smk-dd479.web.app)).
- **Core Authentication & Automatic Role-Based Routing**:
  - Membangun `AuthService`, `AppAuthProvider`, dan widget `AuthWrapper` yang secara otomatis mengarahkan user ke dashboard peran masing-masing setelah login.
  - Membangun halaman `LoginScreen` lengkap dengan validasi form, show/hide password, dan tombol jalan pintas akun demo.
- **Modul Siswa (Student Feature)**:
  - Mengembangkan antarmuka `StudentDashboard` dengan navigasi *BottomNavigationBar* (Materi & Tugas, Jadwal & Presensi, Layanan BK).
  - Membangun `StudentProvider` yang mendengarkan stream data materi dan tugas dari Firestore secara real-time.
  - Mengimplementasikan fitur interaksi pengumpulan tugas (`Tandai Dikumpulkan`) dan fitur absensi mandiri siswa.
  - Membuat modal detail berkas materi dan detail tugas kelas.
- **Modul Guru Mapel (Teacher Feature)**:
  - Membangun antarmuka `TeacherDashboard` dengan aksi cepat (*Quick Actions*).
  - Mengembangkan `UploadMaterialScreen` yang mendukung unggah file berkas serta fallback tautan eksternal (Google Drive/URL publik).
  - Mengembangkan `TaskManagementScreen` untuk publikasi tugas dan kuis baru ke kelas target.
  - Membangun `AttendanceScreen` terintegrasi dengan data dinamis siswa dari Firestore.
- **Database Seeder Otomatis**:
  - Merancang `SeederService` yang mampu mendaftarkan akun demo untuk 6 role secara otomatis dan membuat 30 akun siswa demo yang terdistribusi ke berbagai kelas (`XII RPL 1`, `XI RPL 1`, `XII TKJ 1`).

---

### 📌 2. MUH RAFLI (105841108723) — *Lead Feature Developer (Modul Wali Kelas)*
- **Dashboard Wali Kelas**: Membangun `WaliKelasDashboard` dengan tata letak pemantauan terpusat untuk kelas binaan.
- **Smart Alert System**: Mengimplementasikan logika deteksi dini pada `WaliKelasProvider` untuk mendeteksi siswa bermasalah (Alpha > 3x dan penurunan nilai rata-rata > 20%).
- **Integrasi Rekap Absensi & Catatan Siswa**:
  - Menghubungkan rekapitulasi kehadiran siswa harian berdasarkan kelas perwalian.
  - Menampilkan ringkasan kejadian ketertiban siswa dari Guru Piket dan pengaduan konseling dari Guru BK.
- **Sistem Filter & Indikator Visual**: Memberikan badge status tegas (Normal, Waspada, Kritis) serta border visual merah pada siswa yang memicu alert.

---

### 📌 3. M Erwin Khusnaedy (105841120623) — *Backend & Feature Developer (Modul BK)*
- **Dashboard Guru BK**: Membangun `BKDashboard` dengan sistem navigasi *TabBar* (Jadwal Konseling / Aduan Masuk dan Tracking Kasus).
- **Sistem Pengaduan Siswa Dua Arah**: Merancang alur pengiriman laporan aduan dari siswa ke koleksi `reports` di Firestore.
- **Formulir Tindak Lanjut Kasus**:
  - Membuat modal penanganan kasus bagi Guru BK untuk memperbarui status kasus (`Menunggu Tindak Lanjut`, `Diproses`, `Selesai`).
  - Mengintegrasikan kolom respons Guru BK agar solusi penanganan dapat langsung dibaca oleh siswa terkait.
- **Optimasi Keamanan Data Rahasia**: Memastikan rules Firestore untuk data konseling dan pengaduan hanya dapat diakses oleh siswa bersangkutan, Guru BK, dan Admin.

---

### 📌 4. NAWAT SAKTI AL'AGASI (105841108823) — *Feature Developer (Modul Guru Piket)*
- **Dashboard Guru Piket**: Membangun `PiketDashboard` sebagai pos pencatatan ketertiban dan kehadiran harian gerbang sekolah.
- **Presensi Harian Terpusat**: Mengarahkan aksi absensi piket ke form `AttendanceScreen` tanpa ketergantungan QR scanner agar alur pengoperasian lebih cepat.
- **Pencatatan Kejadian Harian (Incident Logs)**:
  - Merancang form input kejadian harian (Nama Siswa, Jenis Catatan: Keterlambatan / Izin Pulang, dan Keterangan).
  - Menyimpan catatan ke koleksi `incident_logs` di Firestore lengkap dengan metadata tanggal.
- **Filtering Log Kejadian**: Menambahkan filter dinamis berdasarkan jenis catatan dan tanggal kejadian pada riwayat log piket.

---

### 📌 5. Muh. Rizki Aqil Az-zikra Alimuddin (105841109623) — *UI/UX Specialist & QA Engineer*
- **Portal Web Admin**: Membangun antarmuka `AdminDashboard` dengan *Sidebar Navigation* responsif untuk desktop/web dan *Drawer* untuk layar mobile.
- **Desain Sistem & Konsistensi UI**:
  - Menyusun palet warna peran di `AppColors` (Student, Teacher, Wali Kelas, BK, Piket, Admin).
  - Mengonfigurasi `AppTheme` dengan Google Fonts (*Plus Jakarta Sans*) dan standardisasi widget Material 3.
- **Quality Assurance & Testing**:
  - Melakukan pengujian alur navigasi lintas role (*smoke testing* dan *black-box testing*).
  - Memverifikasi tidak adanya error kompilasi dan linting pada `flutter analyze`.
  - Menguji responsivitas tampilan pada berbagai ukuran layar browser (Chrome Web).

---

## 🎬 Skenario & Naskah Presentasi Video Demo (Durasi Total: 10 Menit)

Alur video presentasi disusun secara terstruktur di mana **IZHAR** memimpin pembukaan, mendemonstrasikan autentikasi serta dua modul utama (Siswa & Guru Mapel), dilanjutkan oleh rekan tim untuk modul spesifik masing-masing, dan ditutup kembali oleh Izhar.

---

### ⏱️ Menit 00:00 - 02:00 | Pembukaan, Arsitektur & Login Multi-Role
**Presenter: IZHAR (105841109023)**

> **[Tampilan Layar: Halaman Login & Slide Pembuka]**
> 
> *"Halo semuanya dan selamat pagi/siang kepada Bapak/Ibu Dosen penguji. Saya **IZHAR** selaku Project Leader dari kelompok kami, bersama 4 rekan saya: **Muh Rafli, M Erwin Khusnaedy, Nawat Sakti, dan Muh Rizki Aqil**.*
> 
> *Hari ini kami mempersembahkan **EduTech SMK**, aplikasi Learning Management System dan monitoring disiplin siswa berbasis Flutter dan Firebase. Aplikasi ini dibangun dengan satu codebase multi-platform dan saat ini sudah dideploy secara live di Firebase Hosting.*
> 
> *Aplikasi ini menerapkan arsitektur **Feature-First Pattern** dan state management **Provider**. Sistem ini memiliki 6 role utama dengan hak akses terisolasi. Mari kita mulai dari sistem autentikasi.*
> 
> *Di halaman login, kami menyediakan fitur **Generate Demo Data** otomatis yang menginjeksi 30 akun siswa ke 3 kelas berbeda serta akun untuk semua role. Ketika kita login, sistem Firebase Auth akan memverifikasi kredensial, lalu AuthWrapper akan membaca role dari Firestore dan langsung mengarahkan user ke dashboard yang tepat secara otomatis."*

---

### ⏱️ Menit 02:00 - 04:00 | Demo Fitur Guru Mapel & Fitur Siswa
**Presenter: IZHAR (105841109023)**

> **[Tampilan Layar: Dashboard Guru Mapel (`guru@edutech.sch.id`) $\rightarrow$ Dashboard Siswa (`siswa@edutech.sch.id`)]**
> 
> *"Sekarang saya masuk sebagai **Guru Mapel (Dimas Pratama)**. Pada dashboard ini terdapat 3 aksi cepat utama:*
> 1. ***Upload Materi***: Guru dapat menerbitkan materi baru untuk kelas tertentu, lengkap dengan upload berkas PDF atau tautan materi eksternal seperti Google Drive jika penyimpanan cloud belum diaktifkan.
> 2. ***Kelola Tugas & Kuis***: Guru dapat membuat tugas baru lengkap dengan deadline.
> 3. ***Input Absensi Real-time***: Guru memilih kelas, misalnya XII RPL 1, dan sistem akan menampilkan seluruh daftar siswa asli dari database untuk ditandai hadir, izin, sakit, atau alpha.*
> 
> *Setelah materi dan tugas dipublikasikan, mari kita beralih ke peran **Siswa (Ahmad Fauzi)**.*
> 
> *Di dashboard Siswa, kita melihat materi yang baru saja diunggah langsung muncul secara real-time via Firestore stream. Siswa dapat mengklik kartu materi untuk membaca ringkasan dan membuka file. Pada bagian Tugas Kelas, siswa dapat membuka detail tugas lalu menekan tombol **Tandai Dikumpulkan**, dan status di kartu tugas akan otomatis berubah hijau.*
> 
> *Pada tab **Jadwal & Presensi**, siswa juga bisa melakukan **Absen Mandiri** yang langsung mencatat kehadiran dan menampilkan riwayat rekap absensi harian mereka.*
> 
> *Selanjutnya, rekan saya Erwin akan mendemonstrasikan sistem pengaduan dan konseling ke Guru BK."*

---

### ⏱️ Menit 04:00 - 05:30 | Demo Modul Bimbingan Konseling (Guru BK)
**Presenter: M Erwin Khusnaedy (105841120623)**

> **[Tampilan Layar: Tab BK di Siswa $\rightarrow$ Dashboard Guru BK (`bk@edutech.sch.id`)]**
> 
> *"Terima kasih Izhar. Saya **M Erwin Khusnaedy** akan menjelaskan alur pengaduan dan konseling.*
> 
> *Di sisi siswa, terdapat tab **Layanan BK**. Siswa dapat menekan tombol **Kirim Pengaduan ke Guru BK**, memilih kategori masalah (Akademik, Sosial, Pribadi, Pelanggaran), dan mengirim pesan secara rahasia.*
> 
> *Sekarang kita beralih login ke akun **Guru BK (Maya Kusuma)**. Di dashboard Guru BK, aduan yang dikirim siswa tadi langsung masuk ke daftar **Jadwal & Aduan Masuk** dan **Tracking Kasus**.*
> 
> *Guru BK dapat mengklik tombol **Tindak Lanjut**, mengubah status kasus menjadi 'Diproses' atau 'Selesai', serta menuliskan respons bimbingan. Begitu disimpan, respons ini langsung muncul di layar siswa pengirim. Hal ini menjaga kerahasiaan dan mempercepat penanganan masalah siswa.*
> 
> *Selanjutnya, rekan saya Muh Rafli akan menjelaskan dashboard Wali Kelas."*

---

### ⏱️ Menit 05:30 - 07:00 | Demo Modul Wali Kelas & Smart Alert System
**Presenter: MUH RAFLI (105841108723)**

> **[Tampilan Layar: Dashboard Wali Kelas (`walikelas@edutech.sch.id`)]**
> 
> *"Terima kasih Erwin. Saya **MUH RAFLI** akan mendemonstrasikan fitur **Wali Kelas**.*
> 
> *Wali Kelas berfungsi sebagai pusat pemantauan kelas binaan. Saat login sebagai **Wali Kelas XII RPL 1 (Rina Suryani)**, dashboard langsung menampilkan ringkasan kelas:*
> 1. ***Statistik Agregat***: Jumlah hadir, izin, sakit, alpha, aduan aktif, dan catatan keterlambatan hari ini.
> 2. ***Smart Alert System***: Sistem kami secara otomatis menandai siswa yang memerlukan perhatian khusus dengan **border merah tegas** dan badge 'Kritis' atau 'Waspada', misalnya jika siswa mengalami Alpha > 3x atau terjadi penurunan nilai lebih dari 20%.
> 3. ***Rekap Lintas Modul***: Wali kelas dapat melihat rekap absensi harian, aduan BK dari siswa kelasnya, serta catatan ketertiban dari Guru Piket hanya dalam satu halaman.*
> 
> *Wali kelas juga bisa menginput absensi khusus perwalian melalui tombol **Input Absensi Kelas**.*
> 
> *Selanjutnya, rekan saya Nawat Sakti akan menjelaskan fitur Guru Piket."*

---

### ⏱️ Menit 07:00 - 08:30 | Demo Modul Guru Piket & Catatan Kejadian
**Presenter: NAWAT SAKTI AL'AGASI (105841108823)**

> **[Tampilan Layar: Dashboard Guru Piket (`piket@edutech.sch.id`)]**
> 
> *"Terima kasih Rafli. Saya **NAWAT SAKTI AL'AGASI** akan mendemonstrasikan peran **Guru Piket**.*
> 
> *Guru Piket bertanggung jawab mencatat kehadiran dan ketertiban di gerbang sekolah. Fitur utama yang kami sediakan:*
> 1. ***Buka Form Absensi Piket***: Memungkinkan pencatatan absensi cepat seluruh kelas tanpa perlu pemindaian QR code yang rumit.
> 2. ***Catatan Kejadian Harian***: Guru Piket dapat menginput kejadian khusus, seperti siswa terlambat atau siswa yang meminta izin pulang lebih awal.*
> 3. ***Filter Log Kejadian***: Riwayat log dapat difilter secara fleksibel berdasarkan tanggal maupun kategori kejadian (Keterlambatan / Izin Pulang).*
> 
> *Setiap catatan yang disimpan otomatis terhubung ke ringkasan di dashboard Wali Kelas.*
> 
> *Selanjutnya, rekan saya Rizki Aqil akan menjelaskan Portal Admin dan UI System."*

---

### ⏱️ Menit 08:30 - 09:30 | Demo Portal Admin & Desain UI Responsif
**Presenter: Muh. Rizki Aqil Az-zikra Alimuddin (105841109623)**

> **[Tampilan Layar: Dashboard Admin (`admin@edutech.sch.id`)]**
> 
> *"Terima kasih Nawat. Saya **Muh. Rizki Aqil Az-zikra Alimuddin** akan menjelaskan **Portal Admin** dan desain antarmuka.*
> 
> *Dashboard Admin dirancang khusus dengan layout responsif web portal:*
> - Pada layar lebar/desktop, sidebar navigasi akan selalu terbuka di sisi kiri untuk memudahkan manajemen data pengguna, master data sekolah, dan konfigurasi Firebase.
> - Pada layar mobile/tablet, sidebar otomatis bertransformasi menjadi Drawer.*
> 
> *Seluruh tema aplikasi menggunakan standar Material 3 dengan tipografi Plus Jakarta Sans dan warna aksen tematik per role untuk memberikan pengalaman visual yang intuitif dan profesional.*
> 
> *Saya kembalikan kepada Izhar untuk kesimpulan dan penutup."*

---

### ⏱️ Menit 09:30 - 10:00 | Rangkuman & Penutup
**Presenter: IZHAR (105841109023)**

> **[Tampilan Layar: Ringkasan Sistem & Tautan Live Demo / GitHub]**
> 
> *"Terima kasih rekan-rekan.*
> 
> *Sebagai kesimpulan, proyek **EduTech SMK** telah berhasil mengintegrasikan seluruh alur kebutuhan sekolah digital mulai dari manajemen materi, absensi multi-peran, pengaduan konseling BK, monitoring cerdas wali kelas, catatan piket harian, hingga portal admin dalam satu basis kode Flutter yang terhubung ke Firebase.*
> 
> *Proyek ini dapat langsung diakses publik pada tautan live demo: **https://edutech-smk-dd479.web.app** dan kode sumber lengkap tersedia di GitHub kami: **https://github.com/IZHARaja/edutech-smk**.*
> 
> *Sekian presentasi dari kelompok kami. Terima kasih atas perhatian Bapak/Ibu Dosen penguji, kami siap untuk sesi tanya jawab."*

---

*Dokumen disusun oleh Tim Pengembang EduTech SMK — 2026.*
