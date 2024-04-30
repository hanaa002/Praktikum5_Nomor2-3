import 'package:flutter/material.dart'; // Impor pustaka flutter
import 'package:http/http.dart' as http; // Impor pustaka http dari package http
import 'dart:convert'; // Impor pustaka untuk encoding dan decoding JSON

void main() {
  runApp(const MyApp()); // Menjalankan aplikasi Flutter
}

// Kelas untuk menampung data hasil pemanggilan API
class Activity {
  String aktivitas; // Variabel untuk menampung aktivitas
  String jenis; // Variabel untuk menampung jenis aktivitas

  // Konstruktor kelas Activity
  Activity({required this.aktivitas, required this.jenis}); 

  // Metode factory untuk membuat objek Activity dari JSON
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      aktivitas: json['activity'], // Mengisi variabel aktivitas dari JSON
      jenis: json['type'], // Mengisi variabel jenis dari JSON
    );
  }
}

// Kelas MyApp, turunan dari StatefulWidget
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyAppState(); // Membuat instance MyAppState
  }
}

// Kelas MyAppState, turunan dari State<MyApp>
class MyAppState extends State<MyApp> {
  late Future<Activity> futureActivity; // Variabel untuk menampung hasil future

  String url = "https://www.boredapi.com/api/activity"; // URL endpoint API

  // Metode untuk inisialisasi future
  Future<Activity> init() async {
    return Activity(aktivitas: "", jenis: ""); // Mengembalikan objek Activity kosong
  }

  // Metode untuk mengambil data dari API
  Future<Activity> fetchData() async {
    final response = await http.get(Uri.parse(url)); // Mengirim GET request ke URL
    if (response.statusCode == 200) {
      // Jika respons dari server adalah 200 OK (berhasil)
      // Parse JSON dan buat objek Activity
      return Activity.fromJson(jsonDecode(response.body));
    } else {
      // Jika respons dari server tidak berhasil (bukan 200 OK)
      // Lemparkan exception
      throw Exception('Gagal load');
    }
  }

  @override
  void initState() {
    super.initState(); // Panggil metode initState dari superclass
    futureActivity = init(); // Inisialisasi futureActivity dengan metode init
  }

  @override
  Widget build(Object context) {
    return MaterialApp(
        home: Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  futureActivity = fetchData(); // Memperbarui futureActivity saat tombol ditekan
                });
              },
              child: Text("Saya bosan ..."), // Teks pada tombol
            ),
          ),
          FutureBuilder<Activity>(
            future: futureActivity, // Future yang akan diperbarui
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // Jika data sudah tersedia
                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Text(snapshot.data!.aktivitas), // Teks aktivitas
                      Text("Jenis: ${snapshot.data!.jenis}") // Teks jenis aktivitas
                    ]));
              } else if (snapshot.hasError) {
                // Jika terjadi error
                return Text('${snapshot.error}'); // Tampilkan pesan error
              }
              // Default: tampilkan loading spinner
              return const CircularProgressIndicator();
            },
          ),
        ]),
      ),
    ));
  }
}
