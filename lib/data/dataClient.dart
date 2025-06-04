import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DataClient extends StatefulWidget {
  const DataClient({super.key});

  @override
  State<DataClient> createState() => _DataClientState();
}

class _DataClientState extends State<DataClient> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> clients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  Future<void> _fetchClients() async {
    setState(() => isLoading = true);
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() {
        clients = [];
        isLoading = false;
      });
      return;
    }

    final response = await supabase
        .from('client')
        .select()
        .eq('user_id', user.id); // Ambil data berdasarkan user_id

    setState(() {
      clients = response;
      isLoading = false;
    });
  }

  void _showEditForm(int index) {
    final client = clients[index];
    final TextEditingController _usernameController =
        TextEditingController(text: client['username']);
    final TextEditingController _emailController =
        TextEditingController(text: client['email']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Client'),
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
                  await supabase.from('client').update({
                    'username': _usernameController.text,
                    'email': _emailController.text,
                  }).eq('id', client['id']);

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data berhasil diperbarui')),
                  );
                  _fetchClients();
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

  void _deleteClient(int index) async {
    final client = clients[index];

    try {
      await supabase.from('client').delete().eq('id', client['id']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client berhasil dihapus')),
      );
      _fetchClients();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus client: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : clients.isEmpty
              ? const Center(child: Text('Tidak ada data client'))
              : ListView.builder(
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    final client = clients[index];

                    return ListTile(
                      title: Text(client['username'] ?? 'No Username'),
                      subtitle: Text(client['email'] ?? 'No Email'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditForm(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteClient(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
