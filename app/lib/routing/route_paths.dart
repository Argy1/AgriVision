abstract final class RoutePaths {
  static const login = '/login';
  static const forgotPassword = '/lupa-password';
  static const verifyCode = '/verifikasi-kode';

  static const beranda = '/beranda';
  static const unggah = '/unggah';
  static const riwayat = '/riwayat';
  static const profil = '/profil';

  static const diagnosisResult = '/diagnosis/:id';
  static const zonaDetail = '/zona/:id';
  static const panduanPenyakit = '/panduan-penyakit';
  static const notifikasi = '/notifikasi';

  static String diagnosisResultPath(String id) => '/diagnosis/$id';
  static String zonaDetailPath(String id) => '/zona/$id';
}
