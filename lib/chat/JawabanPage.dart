import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JawabanPage extends StatefulWidget {
  final Map<String, dynamic> item;
  const JawabanPage({super.key, required this.item});

  @override
  State<JawabanPage> createState() => _JawabanPageState();
}

class _JawabanPageState extends State<JawabanPage> {
  late TextEditingController _jawabanController;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _jawabanController = TextEditingController(text: widget.item['jawaban'] ?? '');
  }

  @override
  void dispose() {
    _jawabanController.dispose();
    super.dispose();
  }

  Future<void> _submitJawaban() async {
    final jawaban = _jawabanController.text.trim();
    final id = widget.item['id'];

    if (jawaban.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jawaban tidak boleh kosong')),
      );
      return;
    }

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID pertanyaan tidak ditemukan')),
      );
      return;
    }

    try {
      final response = await supabase
          .from('pertanyaan')
          .update({'jawaban': jawaban})
          .eq('id', id)
          .select();

      if (response.isEmpty) {
        throw Exception("Update gagal atau ID tidak ditemukan");
      }

      // Perbarui lokal juga
      setState(() {
        widget.item['jawaban'] = jawaban;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jawaban berhasil disimpan')),
      );

      Navigator.pop(context, widget.item); // Kirim balik hasilnya
    } catch (e) {
      print("Gagal menyimpan jawaban: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan jawaban: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text("Jawab Pertanyaan")),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // dismiss keyboard
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Box Pertanyaan
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(12),
                ),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Judul: ${widget.item['judul'] ?? '-'}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(widget.item['detail'] ?? '-'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Gambar
              Container(
                width: double.infinity,
                height: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: widget.item['gambar_url'] != null &&
                        widget.item['gambar_url'].toString().isNotEmpty
                    ? Image.network(widget.item['gambar_url'], fit: BoxFit.contain)
                    : const Text("Tidak ada gambar"),
              ),
              const SizedBox(height: 16),

              // Input Jawaban
              TextField(
                controller: _jawabanController,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Masukkan jawaban penyuluh',
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                onPressed: _submitJawaban,
                child: const Text('Kirim Jawaban'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
