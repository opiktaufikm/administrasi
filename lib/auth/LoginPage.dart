import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin/auth/RegisterPage.dart';
import 'package:admin/home/HomePageAdmin.dart';
import 'package:admin/home/HomePagePenyuluh.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  String selectedRole = 'admin'; // Default dropdown value
  final List<String> roles = ['admin', 'penyuluh'];

  Future<void> _saveUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  Future<void> _login() async {
  final username = usernameController.text.trim();
  final password = passwordController.text.trim();
  final isAdminSelected = selectedRole == 'admin';

  if (username.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Username dan password tidak boleh kosong.')),
    );
    return;
  }

  try {
    // 1. Ambil email berdasarkan username
    final userQuery = await Supabase.instance.client
        .from('users')
        .select('email')
        .eq('username', username)
        .maybeSingle();

    if (userQuery == null || userQuery['email'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username tidak ditemukan.')),
      );
      return;
    }

    final email = userQuery['email'];

    // 2. Login pakai Supabase Auth (bukan query password langsung!)
    final authResponse = await Supabase.instance.client.auth
        .signInWithPassword(email: email, password: password);

    if (authResponse.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login gagal.')),
      );
      return;
    }

    final userId = authResponse.user!.id;

    // 3. Cek role user dari tabel `users`
    final userData = await Supabase.instance.client
        .from('users')
        .select('id, is_admin')
        .eq('user_id', userId)
        .maybeSingle();

    if (userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data pengguna tidak ditemukan.')),
      );
      return;
    }

    final isAdmin = userData['is_admin'] ?? false;
    final localUserId = userData['id'];

    // 4. Bandingkan role dengan dropdown yang dipilih
    if (isAdmin != isAdminSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Peran tidak sesuai dengan akun.')),
      );
      return;
    }

    // 5. Simpan user id lokal
    await _saveUserId(localUserId);

    // 6. Navigasi
    if (isAdmin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePageAdmin()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePagePenyuluh()),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login gagal: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Image.asset('assets/login_img.png', height: 270),
              const SizedBox(height: 20),
              const Text(
                'Selamat Datang Kembali!',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              /// 🔽 DROPDOWN UNTUK ROLE
              DropdownButtonFormField<String>(
                value: selectedRole,
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
                items: roles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.toUpperCase()),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Login sebagai',
                  filled: true,
                  fillColor: const Color.fromARGB(255, 223, 223, 223),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              /// Username
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  filled: true,
                  fillColor: const Color.fromARGB(255, 223, 223, 223),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              /// Password
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: const Color.fromARGB(255, 223, 223, 223),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              /// Button Login
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text('Login',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              const SizedBox(height: 16),

              /// Daftar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum punya akun?', style: TextStyle(fontSize: 14)),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    ),
                    child: const Text('Daftar',
                        style: TextStyle(fontSize: 14, color: Colors.green)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
