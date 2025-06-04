import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DataPenyuluh extends StatefulWidget {
  const DataPenyuluh({super.key});

  @override
  State<DataPenyuluh> createState() => _DataPenyuluhState();
}

class _DataPenyuluhState extends State<DataPenyuluh> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> penyuluhList;

  Future<List<Map<String, dynamic>>> _fetchPenyuluh() async {
  try {
    final response = await supabase
        .from('users')
        .select('id, username, email') // Ambil hanya kolom penting
        .eq('is_admin', false); // Filter: hanya penyuluh

    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    debugPrint('Gagal mengambil data penyuluh: $e');
    return [];
  }
}


  Future<void> _refreshData() async {
    setState(() {
      penyuluhList = _fetchPenyuluh();
    });
  }

  Future<void> _showEditForm(String userId, Map<String, dynamic> penyuluhData) async {
    final _usernameController = TextEditingController(text: penyuluhData['username']);
    final _emailController = TextEditingController(text: penyuluhData['email']);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Penyuluh'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Simpan'),
              onPressed: () async {
                try {
                  await supabase.from('users').update({
                    'username': _usernameController.text,
                    'email': _emailController.text,
                  }).eq('id', userId);

                  Navigator.of(context).pop();
                  _refreshData();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data berhasil diperbarui')),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal memperbarui data: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePenyuluh(String userId) async {
    try {
      await supabase.from('users').delete().eq('id', userId);
      _refreshData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Penyuluh berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus penyuluh: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    penyuluhList = _fetchPenyuluh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: penyuluhList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan'));
          }

          final data = snapshot.data;
          if (data == null || data.isEmpty) {
            return const Center(child: Text('Tidak ada data penyuluh'));
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final penyuluh = data[index];
                return ListTile(
                  title: Text(penyuluh['username'] ?? 'No Username'),
                  subtitle: Text(penyuluh['email'] ?? 'No Email'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditForm(penyuluh['id'], penyuluh),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePenyuluh(penyuluh['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
