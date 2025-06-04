import 'package:flutter/material.dart';
import 'ProfilePage.dart'; 
import 'package:admin/auth/LoginPage.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 30),
          // Menu Data Pribadi
          _buildMenuItem(
            context,
            icon: Icons.person,
            title: 'Data Pribadi',
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => ProfilePage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const beginOffset = Offset(1.0, 0.0);
                    const endOffset = Offset.zero;
                    const curve = Curves.easeInOut;

                    var offsetTween = Tween(begin: beginOffset, end: endOffset).chain(CurveTween(curve: curve));
                    var fadeTween = Tween(begin: 0.0, end: 1.0);

                    var offsetAnimation = animation.drive(offsetTween);
                    var fadeAnimation = animation.drive(fadeTween);

                    return FadeTransition(
                      opacity: fadeAnimation,
                      child: SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      ),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 260), // Durasi animasi lebih cepat
                ),
              );
            },
          ),
          // Tombol Logout
          _buildLogoutMenuItem(
            context,
            title: 'Logout',
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => LoginPage(), // Ganti dengan halaman login Anda
                  transitionDuration: const Duration(milliseconds: 260), // Durasi animasi lebih cepat
                ),
              );
            },
            textColor: Colors.red,
            icon: Icons.logout,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap,
      Color iconColor = Colors.black,
      Color textColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutMenuItem(BuildContext context,
      {required String title,
      required VoidCallback onTap,
      Color textColor = Colors.black,
      required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}