# 🪐 Quizverse

Selamat datang di Quizverse! Sebuah aplikasi kuis dinamis yang dibangun menggunakan Flutter. Uji pengetahuanmu di berbagai kategori, lacak statistik, dan kumpulkan semua *achievement*!

Aplikasi ini mengambil soal secara langsung dari Open Trivia Database API dan menyimpannya secara lokal di perangkatmu menggunakan SQLite.

## ✨ Fitur Utama

* **Autentikasi Pengguna**: Sistem *login* dan *register* yang aman untuk menyimpan progres pengguna.
* **Kuis Dinamis**: Ambil soal dari puluhan kategori (seperti Olahraga, Film, Sains, Sejarah) dengan 3 tingkat kesulitan (Mudah, Sedang, Sulit).
* **Timer Per Soal**: Setiap soal memiliki batas waktu 15 detik untuk menambah tantangan.
* **Statistik Profil**: Halaman profil pengguna menampilkan statistik lengkap seperti:
    * Total Kuis Selesai
    * Rata-rata Skor
    * Total Waktu Bermain
* **Sistem Achievement**: Buka beragam *achievement* (Pencapaian) seiring progresmu. Contoh:
    * `First Steps` (Selesaikan 1 kuis)
    * `Perfectionist` (Dapatkan skor 100%)
    * `Quiz Master` (Selesaikan 50 kuis)
    * `Explorer` (Coba semua kategori)
* **Riwayat Kuis Lokal**: Semua kuis yang pernah kamu ambil disimpan di database SQLite lokal.
* **Detail Riwayat**: Lihat kembali detail setiap kuis, termasuk di mana kamu mengambil kuis tersebut (menggunakan data Geolokasi).
* **Notifikasi**: Dapatkan notifikasi lokal setelah k quizzes.

## 🛠️ Teknologi yang Digunakan

* **Framework**: [Flutter](https://flutter.dev/)
* **Bahasa**: [Dart](https://dart.dev/)
* **Database Lokal**: [sqflite](https://pub.dev/packages/sqflite) (Untuk menyimpan riwayat kuis, data pengguna, dan progres achievement)
* **State Management**: `setState` (Digunakan secara internal di dalam setiap *view*)
* **API Client**: [http](https://pub.dev/packages/http) (Untuk mengambil data dari Open Trivia DB)
* **Manajemen Sesi**: [shared_preferences](https://pub.dev/packages/shared_preferences) (Untuk menyimpan token login)
* **Layanan Lokasi**: [geolocator](https://pub.dev/packages/geolocator) & [geocoding](https://pub.dev/packages/geocoding)
* **Notifikasi**: [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
* **Animasi**: [confetti](https://pub.dev/packages/confetti) (Untuk perayaan setelah kuis selesai)

## 🚀 Memulai

Untuk menjalankan proyek ini di komputermu, ikuti langkah-langkah berikut:

1.  **Clone repositori**
    ```sh
    git clone [https://github.com/kanochiiyo/quizverse.git](https://github.com/kanochiiyo/quizverse.git)
    ```

2.  **Pindah ke direktori proyek**
    ```sh
    cd quizverse
    ```

3.  **Install semua *dependency***
    ```sh
    flutter pub get
    ```

4.  **Jalankan aplikasi**
    ```sh
    flutter run
    ```

---
