import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../home/home_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  static const String routeName = '/create_account';

  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  int _selectedYear = 1;
  String? userType;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is String) {
      userType = args;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _idController.dispose();
    _passwordController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    bool success = false;

    if (userType == 'student') {
      success = await authProvider.registerStudent(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        studentId: _idController.text.trim(),
        phone: _phoneController.text.trim(),
        department: _departmentController.text.trim(),
      );
    } else {
      success = await authProvider.registerTeacher(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        teacherId: _idController.text.trim(),
        phone: _phoneController.text.trim(),
        department: _departmentController.text.trim(),
      );
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.isOfflineMode
              ? 'تم إنشاء الحساب بنجاح! يمكنك الآن تسجيل الدخول (وضع محلي)'
              : 'تم إنشاء الحساب بنجاح! يمكنك الآن تسجيل الدخول'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'فشل في إنشاء الحساب'),
          backgroundColor: authProvider.errorMessage?.contains('وضع محلي') == true
              ? Colors.orange
              : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  child: Text(
                    userType == 'student' ? 'حساب طالب' : 'حساب دكتور',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 24),

                _buildLabel('الاسم الكامل'),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'أدخل الاسم الكامل',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال الاسم الكامل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildLabel('البريد الإلكتروني'),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'أدخل البريد الإلكتروني',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال البريد الإلكتروني';
                    }
                    if (!value.contains('@')) {
                      return 'يرجى إدخال بريد إلكتروني صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildLabel('رقم الهاتف'),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'أدخل رقم الهاتف',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال رقم الهاتف';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Student Code or Teacher ID
                _buildLabel(userType == 'student' ? 'كود الطالب' : 'كود الدكتور'),
                TextFormField(
                  controller: _idController,
                  decoration: InputDecoration(
                    hintText: userType == 'student' ? 'أدخل كود الطالب' : 'أدخل كود الدكتور',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return userType == 'student' ? 'يرجى إدخال كود الطالب' : 'يرجى إدخال كود الدكتور';
                    }
                    return null;
                  },
                ),

                // Student Year or Teacher Department
                if (userType == 'student') ...[
                  const SizedBox(height: 16),
                  _buildLabel('السنة الدراسية'),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<int>(
                      value: _selectedYear,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(child: Text('السنة الأولى'), value: 1),
                        DropdownMenuItem(child: Text('السنة الثانية'), value: 2),
                        DropdownMenuItem(child: Text('السنة الثالثة'), value: 3),
                        DropdownMenuItem(child: Text('السنة الرابعة'), value: 4),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedYear = value ?? 1;
                        });
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                _buildLabel('القسم/التخصص'),
                TextFormField(
                  controller: _departmentController,
                  decoration: const InputDecoration(
                    hintText: 'أدخل القسم أو التخصص',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال القسم أو التخصص';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildLabel('كلمة المرور'),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'أدخل كلمة المرور',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال كلمة المرور';
                    }
                    if (value.length < 6) {
                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 1,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('رجوع'),
                  ),
                ),
                const SizedBox(width: 8),

                Expanded(
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _register,
                        child: authProvider.isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Text('إنشاء الحساب'),
                      );
                    },
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