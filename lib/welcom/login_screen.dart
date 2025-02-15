import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePass = true; // لإظهار/إخفاء كلمة المرور

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // يمكن استخدام CustomPaint أو صورة خلفية لإعطاء شكل علوي مميز
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
                // // جزء علوي (مكان الشعار أو الشكل الديكوري)
                // Container(
                //   height: 160,
                //   width: double.infinity,
                //   decoration: BoxDecoration(
                //     color: Theme.of(context).primaryColor.withOpacity(0.05),
                //   ),
                //   child: Center(
                //     child: Column(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         // مثال: صورة أو أيقونة
                //         const Icon(
                //           Icons.school,
                //           size: 48,
                //           color: Colors.grey,
                //         ),
                //         const SizedBox(height: 8),
                //         Text(
                //           'Future Academy',
                //           style: TextStyle(
                //             fontSize: 20,
                //             color: Theme.of(context).primaryColor,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),

              // الفورم
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عنوان الشاشة
                    SizedBox(
                      height: 100,
                    ),
                    Center(
                      child: Text(
                        'login',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    // const SizedBox(height: 18),
                    // const Text(
                    //   'enter your user name and password',
                    //   style: TextStyle(color: Colors.grey, fontSize: 14),
                    // ),
                    const SizedBox(height: 24),

                    // user name
                    Text(
                      'user name',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                     SizedBox(height: 8),

                     TextField(
                      controller: _userNameController,
                      decoration: const InputDecoration(
                        hintText: 'user name',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // كلمة المرور
                    Text(
                      'password',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePass,
                      decoration: InputDecoration(
                        hintText: 'enter password',
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              _obscurePass = !_obscurePass;
                            });
                          },
                          child: Icon(
                            _obscurePass ? Icons.lock : Icons.lock_open,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    // هل نسيت كلمة السر؟

                    const SizedBox(height: 40),

                    // زر تسجيل الدخول
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // منطق تسجيل الدخول
                        },
                        child: const Text('login'),
                      ),
                    ),
                    const SizedBox(height: 150),

                    // تسجيل حساب جديد
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'don\'t have an account?',
                          style: TextStyle(color: Colors.black54),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Navigator.pushNamed(context, '/register');
                          },
                          child: const Text('create account'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
