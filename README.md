# 🪐 **Quizverse**

### by *Andini Andaresta (124230084)*

Selamat datang di **Quizverse**! 🎉
Aplikasi kuis interaktif berbasis **Flutter** yang dirancang untuk mengasah pengetahuanmu di berbagai kategori menarik. Kamu bisa menjawab pertanyaan dari banyak tema, melihat progres belajar, dan membuka beragam *achievement* seru seiring waktu.

Aplikasi ini terhubung langsung dengan **Open Trivia Database API** untuk mendapatkan soal-soal terbaru, lalu menyimpannya secara **lokal di SQLite**, jadi kamu tetap bisa melihat riwayat permainanmu kapan pun.

---

## ✨ **Fitur Unggulan**

* 🔐 **Login & Register** – Setiap pengguna punya akun sendiri, jadi progres dan pencapaiannya aman tersimpan.
* 🧠 **Kuis Dinamis** – Pilih dari berbagai kategori (Olahraga, Film, Sejarah, dll) dengan tiga tingkat kesulitan: *Mudah*, *Sedang*, dan *Sulit*.
* ⏰ **Timer 15 Detik** – Setiap pertanyaan punya batas waktu biar makin menantang.
* 📊 **Statistik Pengguna** – Lihat total kuis yang sudah kamu mainkan, skor rata-rata, dan durasi total bermain.
* 🏅 **Sistem Achievement** – Buka pencapaian spesial seperti:

  * *First Steps* – Selesaikan kuis pertamamu
  * *Perfectionist* – Raih skor 100%
  * *Quiz Master* – Tuntaskan 50 kuis
  * *Explorer* – Coba semua kategori
* 📜 **Riwayat Kuis Lengkap** – Semua hasil permainan disimpan di database lokal. Kamu bahkan bisa lihat lokasi tempat kamu mengerjakan kuis lewat fitur **geolokasi**.
* 🔔 **Notifikasi Lokal** – Dapatkan pengingat dan ucapan selamat setelah menyelesaikan sejumlah kuis tertentu.

---

## 🧩 **Teknologi yang Digunakan**

| Komponen               | Teknologi                                                                                          | Fungsi                                        |
| ---------------------- | -------------------------------------------------------------------------------------------------- | --------------------------------------------- |
| **Framework**          | [Flutter](https://flutter.dev/)                                                                    | Pembangun aplikasi lintas platform            |
| **Bahasa**             | [Dart](https://dart.dev/)                                                                          | Bahasa pemrograman utama                      |
| **Database Lokal**     | [sqflite](https://pub.dev/packages/sqflite)                                                        | Menyimpan data pengguna, kuis, dan pencapaian |
| **State Management**   | `setState`                                                                                         | Mengelola perubahan UI sederhana              |
| **API Client**         | [http](https://pub.dev/packages/http)                                                              | Mengambil soal dari Open Trivia DB            |
| **Manajemen Sesi**     | [shared_preferences](https://pub.dev/packages/shared_preferences)                                  | Menyimpan status login pengguna               |
| **Lokasi & Geocoding** | [geolocator](https://pub.dev/packages/geolocator), [geocoding](https://pub.dev/packages/geocoding) | Melacak lokasi saat bermain kuis              |
| **Notifikasi**         | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)                | Menampilkan notifikasi lokal                  |
| **Animasi**            | [confetti](https://pub.dev/packages/confetti)                                                      | Efek perayaan setelah kuis selesai            |

---

## 🚀 **Cara Menjalankan Proyek**

1. **Clone repositori**

   ```bash
   git clone https://github.com/kanochiiyo/quizverse.git
   ```
2. **Masuk ke direktori proyek**

   ```bash
   cd quizverse
   ```
3. **Install semua dependency**

   ```bash
   flutter pub get
   ```
4. **Jalankan aplikasi**

   ```bash
   flutter run
   ```

---

💡 **Quizverse** dibuat untuk menghadirkan pengalaman kuis yang seru, edukatif, dan menantang — semua dalam satu aplikasi ringan. Siap jadi *Quiz Master* berikutnya? 🌟

---
