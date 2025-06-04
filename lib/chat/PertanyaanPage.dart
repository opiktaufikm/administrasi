import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'JawabanPage.dart';

class PertanyaanPage extends StatefulWidget {
  const PertanyaanPage({super.key});

  @override
  State<PertanyaanPage> createState() => _PertanyaanPageState();
}

class _PertanyaanPageState extends State<PertanyaanPage> {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchQuestions() async {
    final response = await supabase
        .from('pertanyaan')
        .select('*')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  void _navigateToJawabanPage(Map<String, dynamic> item) async {
    final result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            JawabanPage(item: item),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );

    if (result != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchQuestions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat data: ${snapshot.error}'),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(child: Text("Belum ada pertanyaan."));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  onTap: () => _navigateToJawabanPage(item),
                  leading: (item['gambar_url'] != null &&
                          item['gambar_url'].toString().isNotEmpty)
                      ? Image.network(item['gambar_url'],
                          width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image),
                  title: Text(
                    item['judul'] ?? 'Tanpa Judul',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(item['detail'] ?? ''),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
