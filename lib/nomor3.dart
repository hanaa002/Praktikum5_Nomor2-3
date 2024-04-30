import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class University {
  final String name;
  final String website;

  University({required this.name, required this.website});

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'],
      website: json['web_pages']
          [0], // Mengambil situs pertama dari array web_pages
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:
          const UniversityListPage(), // Menetapkan halaman utama sebagai UniversityListPage
    );
  }
}

class UniversityListPage extends StatefulWidget {
  const UniversityListPage({Key? key}) : super(key: key);

  @override
  State<UniversityListPage> createState() => _UniversityListPageState();
}

class _UniversityListPageState extends State<UniversityListPage> {
  late Future<List<University>> futureUniversities;

  @override
  void initState() {
    super.initState();
    futureUniversities =
        fetchUniversities(); // Memanggil fungsi untuk mengambil daftar universitas
  }

  Future<List<University>> fetchUniversities() async {
    final response = await http.get(Uri.parse(
        'http://universities.hipolabs.com/search?country=Indonesia')); // Mengambil data universitas dari API

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body); // Mendecode data JSON
      List<University> universities = data
          .map((json) => University.fromJson(json))
          .toList(); // Mengonversi JSON menjadi objek University
      return universities; // Mengembalikan daftar universitas
    } else {
      throw Exception(
          'Failed to load universities'); // Melemparkan pengecualian jika gagal mengambil data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Universities in Indonesia'), // Judul aplikasi
      ),
      body: Center(
        child: FutureBuilder<List<University>>(
          future:
              futureUniversities, // Menggunakan FutureBuilder untuk menampilkan data yang diambil
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Menampilkan indikator loading saat data sedang diambil
            } else if (snapshot.hasError) {
              return Text(
                  'Error: ${snapshot.error}'); // Menampilkan pesan kesalahan jika terjadi kesalahan
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length * 2 -
                    1, // Jumlah item ditambah jumlah pemisah
                itemBuilder: (context, index) {
                  // Jika index ganjil, tampilkan kotak pemisah
                  if (index.isOdd) {
                    return Divider(
                      thickness: 1.5,
                      color: Colors.grey[300],
                      indent: 20,
                      endIndent: 20,
                    );
                  }
                  // Jika index genap, tampilkan item universitas
                  final universityIndex = index ~/ 2;
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
                    title: Center(
                      child: Text(
                        snapshot.data![universityIndex].name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    subtitle: Center(
                      child: Text(
                        snapshot.data![universityIndex].website,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    trailing: Icon(Icons
                        .arrow_forward), // Ikon panah ke kanan di ujung kanan
                    onTap: () {
                      // Aksi ketika item universitas diklik
                      // Misalnya, buka situs universitas
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
