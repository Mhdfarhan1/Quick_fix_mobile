class Task {
  final int id;
  final String kodePemesanan;
  final String namaPelanggan;
  final String deskripsi;
  final String statusPekerjaan;
  final double harga;
  final DateTime? tanggalBooking;
  final String? jamBooking;
  final String? alamatLengkap;
  final String? kota;
  final double? latitude;
  final double? longitude;
  final String? namaKategori;
  final String? namaKeahlian;
  final String? provinsi;    
  final String? namaTeknisi;
  final int? idTeknisi;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.kodePemesanan,
    required this.namaPelanggan,
    required this.deskripsi,
    required this.statusPekerjaan,
    required this.harga,
    this.tanggalBooking,
    this.jamBooking,
    this.alamatLengkap,
    this.kota,
    this.latitude,
    this.longitude,
    this.namaKategori,
    this.provinsi,
    this.namaTeknisi,
    this.namaKeahlian,
    this.idTeknisi,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] != null
          ? int.parse(json['id'].toString())
          : int.parse(json['id_pemesanan'].toString()),

      kodePemesanan: json['kode_pemesanan'] ?? '-',

      namaPelanggan: json['nama_pelanggan'] ?? '-',

      deskripsi: json['keluhan'] ?? json['deskripsi'] ?? '-',

      statusPekerjaan: json['status_pekerjaan'] ?? '-',

      harga: json['harga'] != null
          ? double.parse(json['harga'].toString())
          : 0.0,

      alamatLengkap: json['alamat_lengkap'],
      kota: json['kota'],
      provinsi: json['provinsi'], 
      namaTeknisi: json['nama_teknisi'],

      tanggalBooking: json['tanggal_booking'] != null
          ? DateTime.tryParse(json['tanggal_booking'])
          : null,

      jamBooking: json['jam_booking'],

      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,

      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,

      namaKategori: json['nama_kategori'],
      namaKeahlian: json['nama_keahlian'],

      idTeknisi: json['id_teknisi'] != null
          ? int.tryParse(json['id_teknisi'].toString())
          : null,

      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id_pemesanan": id,
      "kode_pemesanan": kodePemesanan,
      "nama_pelanggan": namaPelanggan,
      "keluhan": deskripsi,
      "status_pekerjaan": statusPekerjaan,
      "harga": harga,
      "tanggal_booking": tanggalBooking?.toIso8601String(),
      "jam_booking": jamBooking,
      "alamat_lengkap": alamatLengkap,
      "kota": kota,
      "provinsi": provinsi,
      "latitude": latitude,
      "longitude": longitude,
      "nama_kategori": namaKategori,
      "nama_keahlian": namaKeahlian,
      "nama_teknisi": namaTeknisi,
      "id_teknisi": idTeknisi,
      "created_at": createdAt.toIso8601String(),
    };
  }

}
