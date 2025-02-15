import 'package:cmp/welcom/register_screen.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class ChooseRoleScreen extends StatelessWidget {
  static const String routeName = '/choose_role';

  const ChooseRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // أبعاد ثابتة للاستخدام
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 80,
                ),
                // add logo
                Image.asset('asset/images/logo_cmp.png',height: 100,),
                const SizedBox(height: 22),

                Text(
                  'choose your role',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                // const SizedBox(height: 8),

                const SizedBox(height: 30),

                // بطاقة الطالب
                _roleCard(
                  context: context,
                  title: 'student',
                  subtitle: 'subTitle',
                  icon: Icons.person,
                  onTap: () {
                    // اذهب إلى شاشة إنشاء حساب مثلاً
                    Navigator.pushNamed(
                      context,
                        CreateAccountScreen.routeName,
                      arguments: 'student',
                    );
                  },
                  color: const Color(0xFFA9B5DF),
                ),
                const SizedBox(height: 16),



                // بطاقة معلم
                _roleCard(
                  context: context,
                  title: 'teacher',
                  subtitle: 'subTitle',
                  icon: Icons.school,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      CreateAccountScreen.routeName,
                      arguments: 'teacher',
                    );
                  },
                  color: const Color(0xFFA9B5DF),
                ),
              //   const SizedBox(height: 90),
              //
              //   // زر رئيسي في الأسفل
              //   ElevatedButton(
              //     onPressed: () {
              //       // مثال: ادخل مباشرة إلى شاشة تسجيل الدخول
              //       Navigator.pushNamed(context, LoginScreen.routeName);
              //     },
              //     child: const Text('start now'),
              //   ),
              //   const SizedBox(height: 24),
              //
              //
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar:
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // رابط تسجيل دخول
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'already have an account?',
                style: TextStyle(color: Colors.black54),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  LoginScreen.routeName,
                ),
                child: const Text('login'),
              ),
            ],
          ),
          const SizedBox(height: 40),

        ],
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
                        fontSize: 16, fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54
                    ),
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
