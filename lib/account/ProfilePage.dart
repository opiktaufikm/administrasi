import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;

  String _userId = '';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = supabase.auth.currentUser;

    if (user != null) {
      _userId = user.id;

      final response = await supabase
          .from('users')
          .select()
          .eq('user_id', _userId)
          .single();

      if (response != null) {
        setState(() {
          _nameController.text = response['username'] ?? '';
          _emailController.text = response['email'] ?? '';
          _passwordController.text = ''; // kosongkan karena password tidak ditampilkan
        });
      }
    }
  }

  Future<void> _updateUserData() async {
    if (_userId.isNotEmpty) {
      try {
        final updates = {
          'username': _nameController.text.trim(),
          'email': _emailController.text.trim(),
        };

        if (_passwordController.text.trim().isNotEmpty) {
          updates['password'] = _passwordController.text.trim(); // ⚠️ simpan hash idealnya
        }

        await supabase
            .from('users')
            .update(updates)
            .eq('user_id', _userId);

        setState(() {
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui profil: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Nama', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              enabled: _isEditing,
              decoration: InputDecoration(
                filled: true,
                fillColor: _isEditing ? Colors.white : Colors.grey[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Email', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              enabled: _isEditing,
              decoration: InputDecoration(
                filled: true,
                fillColor: _isEditing ? Colors.white : Colors.grey[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Password (baru)', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              enabled: _isEditing,
              obscureText: true,
              decoration: InputDecoration(
                hintText: _isEditing ? 'Isi jika ingin mengganti password' : '',
                filled: true,
                fillColor: _isEditing ? Colors.white : Colors.grey[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_isEditing) {
                  _updateUserData();
                } else {
                  setState(() {
                    _isEditing = true;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _isEditing ? 'Simpan' : 'Edit',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
