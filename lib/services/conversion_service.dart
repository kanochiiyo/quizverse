import 'dart:convert';
import 'dart:math'; // Diperlukan untuk Random()
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz; // Import timezon
import 'package:timezone/data/latest.dart' as tz_data;

class ConversionService {
  final String _currencyApiUrl =
      'https://v6.exchangerate-api.com/v6/54d9aaec75a7f6531106d463/latest/IDR'; // Base IDR

  static bool _timezoneInitialized = false;

  Future<void> _initializeTimezone() async {
    // Jika sudah diinisialisasi (mungkin oleh main.dart), lewati.
    if (_timezoneInitialized) return;

    try {
      // Muat data timezone
      tz_data.initializeTimeZones();
      // Set lokasi default (jika main.dart gagal)
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      _timezoneInitialized = true;
      print("Timezone initialized by ConversionService.");
    } catch (e) {
      print("Failed to initialize timezone in ConversionService: $e");
      // Fallback jika gagal
      if (!_timezoneInitialized) {
        // Hanya set fallback jika belum pernah di-set
        tz.setLocalLocation(tz.UTC);
        _timezoneInitialized = true; // Tandai tetap true agar tidak diulang
      }
    }
  }

  Future<Map<String, dynamic>> _getExchangeRates() async {
    // ... (Kode Anda di sini sudah benar)
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

  Future<String> getCurrencyFact() async {
    // ... (Kode Anda di sini sudah benar)
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

      return "Tahukah kamu? $formattedAmount $randomCurrencyCode saat ini setara dengan $formattedIdrValue! 💰";
    } catch (e) {
      return "Gagal memuat fakta mata uang: ${e.toString().replaceFirst("Exception: ", "")}";
    }
  }

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
      case 'ASIA/TOKYO': // <-- Tambahkan ini
        return 'Asia/Tokyo';
      default:
        try {
          // Coba dapatkan lokasi jika nama sudah valid
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

  Future<String> getTimeFact() async {
    try {
      // 1. Pastikan timezone sudah dimuat
      await _initializeTimezone();

      // 2. Zona waktu sumber (sekarang dijamin aman)
      final sourceLocation = tz.local;
      final nowInSource = tz.TZDateTime.now(sourceLocation);

      // 3. Zona waktu target acak
      final targetZones = ['WITA', 'WIT', 'London', 'Asia/Tokyo'];
      final randomTargetAbbreviation =
          targetZones[Random().nextInt(targetZones.length)];
      final targetZoneName = _getTimezoneName(randomTargetAbbreviation);

      // 4. Dapatkan lokasi (sekarang dijamin aman)
      final targetLocation = tz.getLocation(targetZoneName);

      // 5. Konversi waktu
      final timeInTarget = tz.TZDateTime.from(nowInSource, targetLocation);

      // 6. Format waktu
      final sourceTimeString = DateFormat('HH:mm').format(nowInSource);
      final targetTimeString = DateFormat('HH:mm').format(timeInTarget);

      // 7. Dapatkan singkatan zona waktu sumber (misal WIB, WITA, atau UTC jika gagal)
      final sourceAbbreviation = nowInSource.timeZoneName;

      return "Tahukah kamu? Pukul $sourceTimeString $sourceAbbreviation saat ini sama dengan pukul $targetTimeString di $randomTargetAbbreviation! 🌍⏰";
    } catch (e) {
      print("Error generating time fact: $e");
      // Jika terjadi error saat konversi waktu
      return "Gagal memuat fakta waktu.";
    }
  }

  Future<String> getRandomFact() async {
    // Pilih secara acak (50/50 chance) antara fakta mata uang atau waktu
    bool showCurrencyFact = Random().nextBool();

    if (showCurrencyFact) {
      // Jika terpilih mata uang (perlu await karena async)
      return await getCurrencyFact();
    } else {
      // Jika terpilih waktu (sekarang juga async)
      return await getTimeFact();
    }
  }
}
