/// Konfigurasi environment, dibaca dari --dart-define saat build/run.
///
/// Contoh menjalankan app:
/// flutter run \
///   --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=xxxx \
///   --dart-define=ML_API_URL=https://ml-service-production-xxxx.up.railway.app
class Env {
  Env._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );
  static const String mlApiUrl = String.fromEnvironment('ML_API_URL');

  static const String storageBucket = 'plant-photos';

  static void assertConfigured() {
    assert(
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty && mlApiUrl.isNotEmpty,
      'Env belum dikonfigurasi. Jalankan dengan --dart-define=SUPABASE_URL=... '
      '--dart-define=SUPABASE_ANON_KEY=... --dart-define=ML_API_URL=...',
    );
  }
}
