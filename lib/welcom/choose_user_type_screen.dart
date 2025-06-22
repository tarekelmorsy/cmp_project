import 'package:cmp/welcom/register_screen.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';

class ChooseRoleScreen extends StatelessWidget {
  static const String routeName = '/choose_role';

  const ChooseRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 80),
                Image.asset('asset/images/logo_cmp.png', height: 100),
                const SizedBox(height: 22),
                Text(
                  'Choose Your Role',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Student Card
                _roleCard(
                  context: context,
                  title: 'Student',
                  subtitle: 'Access your courses and attendance',
                  icon: Icons.person,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      LoginScreen.routeName,
                      arguments: 'student',
                    );
                  },
                  color: const Color(0xFFA9B5DF),
                ),
                const SizedBox(height: 16),

                // Teacher Card
                _roleCard(
                  context: context,
                  title: 'Teacher',
                  subtitle: 'Manage courses and attendance',
                  icon: Icons.school,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      LoginScreen.routeName,
                      arguments: 'teacher',
                    );
                  },
                  color: const Color(0xFFA9B5DF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(icon, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}