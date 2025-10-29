import 'dart:convert';
import 'dart:math'; // Diperlukan untuk Random()
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz; // Import timezone

class ConversionService {
  // --- Bagian Mata Uang ---
  final String _currencyApiUrl =
      'https://v6.exchangerate-api.com/v6/54d9aaec75a7f6531106d463/latest/IDR'; // Base IDR

  Future<Map<String, dynamic>> _getExchangeRates() async {
    final url = Uri.parse(_currencyApiUrl);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] == 'success') {
          if (data.containsKey('conversion_rates')) {
            return data['conversion_rates'];
          } else {
            throw Exception(
              'Format API tidak sesuai: key "conversion_rates" tidak ditemukan.',
            );
          }
        } else {
          throw Exception(
            'API Error: ${data.containsKey('error-type') ? data['error-type'] : 'Unknown error'}',
          );
        }
      } else {
        throw Exception('HTTP Error: Status Code ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching exchange rates: $e");
      throw Exception('Gagal mendapatkan kurs mata uang.');
    }
  }

  // Fungsi membuat fakta mata uang (IDR base)
  Future<String> getCurrencyFact() async {
    try {
      final rates = await _getExchangeRates();
      final targetCurrencies = {
        'USD': 1.0,
        'EUR': 1.0,
        'JPY': 100.0,
        'KRW': 1000.0,
      };
      final randomCurrencyCode = targetCurrencies.keys.elementAt(
        Random().nextInt(targetCurrencies.length),
      );
      final amount = targetCurrencies[randomCurrencyCode]!;
      final rate = rates[randomCurrencyCode];

      if (rate == null) {
        return "Info kurs untuk $randomCurrencyCode tidak tersedia saat ini.";
      }

      final idrValue = amount / (rate as num);
      final formattedAmount = NumberFormat("#,##0", "en_US").format(amount);
      final formattedIdrValue = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(idrValue);

      return "Tahukah kamu? $formattedAmount $randomCurrencyCode saat ini setara dengan sekitar $formattedIdrValue! 💰";
    } catch (e) {
      return "Gagal memuat fakta mata uang: ${e.toString().replaceFirst("Exception: ", "")}";
    }
  }

  // --- Bagian Waktu ---
  // Helper untuk mendapatkan nama zona waktu IANA dari singkatan umum
  String _getTimezoneName(String zoneAbbreviation) {
    switch (zoneAbbreviation.toUpperCase()) {
      case 'WIB':
        return 'Asia/Jakarta';
      case 'WITA':
        return 'Asia/Makassar';
      case 'WIT':
        return 'Asia/Jayapura';
      case 'LONDON':
        return 'Europe/London';
      // Tambahkan zona lain jika perlu
      default:
        try {
          // Coba dapatkan lokasi jika nama sudah valid (misal "Asia/Tokyo")
          tz.getLocation(zoneAbbreviation);
          return zoneAbbreviation;
        } catch (_) {
          // Fallback jika tidak dikenali
          print(
            "Warning: Timezone abbreviation '$zoneAbbreviation' not recognized, falling back to WIB.",
          );
          return 'Asia/Jakarta';
        }
    }
  }

  // Fungsi membuat fakta waktu (tidak perlu async)
  String getTimeFact() {
    try {
      // Zona waktu sumber (menggunakan tz.local yang sudah di-set di main.dart)
      final sourceLocation = tz.local;
      final nowInSource = tz.TZDateTime.now(sourceLocation);

      // Zona waktu target acak (pilih dari daftar yang diinginkan)
      final targetZones = [
        'WITA',
        'WIT',
        'London',
        'Asia/Tokyo',
      ]; // Tambahkan target lain jika mau
      final randomTargetAbbreviation =
          targetZones[Random().nextInt(targetZones.length)];
      final targetZoneName = _getTimezoneName(
        randomTargetAbbreviation,
      ); // Dapatkan nama IANA
      final targetLocation = tz.getLocation(targetZoneName);

      // Konversi waktu
      final timeInTarget = tz.TZDateTime.from(nowInSource, targetLocation);

      // Format waktu (misal: 14:30)
      final sourceTimeString = DateFormat('HH:mm').format(nowInSource);
      final targetTimeString = DateFormat('HH:mm').format(timeInTarget);

      // Dapatkan singkatan zona waktu sumber (misal WIB, WITA)
      final sourceAbbreviation = nowInSource.timeZoneName;

      return "Tahukah kamu? Pukul $sourceTimeString $sourceAbbreviation saat ini sama dengan pukul $targetTimeString di $randomTargetAbbreviation! 🌍⏰";
    } catch (e) {
      print("Error generating time fact: $e");
      // Jika terjadi error saat konversi waktu (misal timezone name salah)
      return "Gagal memuat fakta waktu.";
    }
  }

  // --- Fungsi Utama untuk Fakta (dengan Randomisasi) ---
  Future<String> getRandomFact() async {
    // Pilih secara acak (50/50 chance) antara fakta mata uang atau waktu
    bool showCurrencyFact = Random().nextBool();

    if (showCurrencyFact) {
      // Jika terpilih mata uang (perlu await karena async)
      return await getCurrencyFact();
    } else {
      // Jika terpilih waktu (tidak perlu await karena sync)
      return getTimeFact();
    }
  }
}
