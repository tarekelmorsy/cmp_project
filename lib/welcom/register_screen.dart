import 'package:flutter/material.dart';

import '../home/home_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  static const String routeName = '/create_account';

  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}
const double verticalSpacing = 16.0;

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _studentCodeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  int _selectedYear = 1;

  String? userType; // 'student' or 'teacher' ...الخ

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is String) {
      userType = args;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عنوان الشاشة
              Center(
                child: Text(
                  'إنشاء حساب جديد',
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: const Text(
                  'subTitle',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('الاسم  '),
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  hintText: 'الاسم',
                ),
              ),
              const SizedBox(height: 16),
 _buildLabel('الاميل   '),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'الاميل',
                ),
              ),
              const SizedBox(height: 16),

              // كود الطالب
              if (userType == null || userType == 'student') ...[
                _buildLabel('كود الطالب'),
                TextField(
                  controller: _studentCodeController,
                  decoration: const InputDecoration(
                    hintText: 'كود الطالب',
                  ),
                ),
                // const SizedBox(height: 16),
              ],
              // عرض الحقول حسب النوع
              if (userType == 'student') ...[

                const SizedBox(height: verticalSpacing),

                // الفرقة (من الأولى للرابعة)
                _buildLabel('الفرقة:  '),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    // border: Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                       DropdownButton<int>(

                        value: _selectedYear,
                        items: const [
                          DropdownMenuItem(child: Text('الأولى'), value: 1),
                          DropdownMenuItem(child: Text('الثانية'), value: 2),
                          DropdownMenuItem(child: Text('الثالثة'), value: 3),
                          DropdownMenuItem(child: Text('الرابعة'), value: 4),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedYear = value ?? 1;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: verticalSpacing),
              ] else ...[
                // حقل التخصص للدكتور
                _buildLabel('التخصص'),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'أدخل التخصص',
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
              // كلمة المرور
              _buildLabel('كلمة المرور'),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'أدخل كلمة المرور',
                ),
              ),
              const SizedBox(height: 16),

              // // تأكيد كلمة المرور
              // _buildLabel('تأكيد كلمة المرور'),
              // TextField(
              //   controller: _confirmPassController,
              //   obscureText: true,
              //   decoration: const InputDecoration(
              //     hintText: 'أعد كتابة كلمة المرور',
              //   ),
              // ),
              // const SizedBox(height: 24),

              // الأزرار السفلية (السابق – التالي)

            ],
          ),
        ),
      ),
      bottomNavigationBar:     Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    // color: Colors.red,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(
                            color: Theme.of(context).primaryColor, width: 1),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('السابق'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        HomeScreen.routeName,
                        arguments: 'studendt',
                      );
                      // منطق التحقق أو الانتقال للخطوة التالية
                    },
                    child: const Text('التالي'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
