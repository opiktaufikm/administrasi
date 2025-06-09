import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DataClient extends StatefulWidget {
  const DataClient({super.key});

  @override
  State<DataClient> createState() => _DataClientState();
}

class _DataClientState extends State<DataClient> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> petaniList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPetani();
  }

  Future<void> _fetchPetani() async {
    setState(() => isLoading = true);

    try {
      final response = await supabase
          .from('petani')
          .select('id, username, email, created_at')
          .order('created_at', ascending: false);

      setState(() {
        petaniList = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        petaniList = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data petani: $e')),
      );
    }
  }

  void _showEditForm(int index) {
    final petani = petaniList[index];
    final TextEditingController _usernameController =
        TextEditingController(text: petani['username']);
    final TextEditingController _emailController =
        TextEditingController(text: petani['email']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Petani'),
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
                  await supabase.from('petani').update({
                    'username': _usernameController.text,
                    'email': _emailController.text,
                  }).eq('id', petani['id']);

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data berhasil diperbarui')),
                  );
                  _fetchPetani();
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

  void _deletePetani(int index) async {
    final petani = petaniList[index];

    try {
      await supabase.from('petani').delete().eq('id', petani['id']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Petani berhasil dihapus')),
      );
      _fetchPetani();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus petani: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : petaniList.isEmpty
              ? const Center(child: Text('Tidak ada data petani'))
              : ListView.builder(
                  itemCount: petaniList.length,
                  itemBuilder: (context, index) {
                    final petani = petaniList[index];

                    return ListTile(
                      title: Text(petani['username'] ?? 'No Username'),
                      subtitle: Text(petani['email'] ?? 'No Email'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditForm(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deletePetani(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}