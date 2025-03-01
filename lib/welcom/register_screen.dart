import 'package:flutter/material.dart';

import '../home/home_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  static const String routeName = '/create_account';

  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

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

  int _selectedYear = 1; // Dropdown for student's year

  String? userType; // 'student' or 'doctor', etc.

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
      // No AppBar here, just a SafeArea with scroll
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen title
              Center(
                child: Text(
                  'Create New Account',
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // SubTitle
              const Center(
                child: Text(
                  'Subtitle',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('Name'),
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('Email'),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                ),
              ),
              const SizedBox(height: 16),

              // Student Code (if userType == student)
              if (userType == null || userType == 'student') ...[
                _buildLabel('Student Code'),
                TextField(
                  controller: _studentCodeController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your student code',
                  ),
                ),
              ],

              // If userType == student => show Year dropdown
              if (userType == 'student') ...[
                const SizedBox(height: 16),
                _buildLabel('Year'),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<int>(
                    value: _selectedYear,
                    items: const [
                      DropdownMenuItem(child: Text('Year 1'), value: 1),
                      DropdownMenuItem(child: Text('Year 2'), value: 2),
                      DropdownMenuItem(child: Text('Year 3'), value: 3),
                      DropdownMenuItem(child: Text('Year 4'), value: 4),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value ?? 1;
                      });
                    },
                  ),
                ),
              ] else ...[
                // Otherwise, it's doctor => Specialization
                const SizedBox(height: 16),
                _buildLabel('Specialization'),
                TextField(
                  controller: _specializationController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your specialization',
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Password
              _buildLabel('Password'),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Enter your password',
                ),
              ),
              const SizedBox(height: 16),

              // If you want to re-enable Confirm Password:
              // _buildLabel('Confirm Password'),
              // TextField(
              //   controller: _confirmPassController,
              //   obscureText: true,
              //   decoration: const InputDecoration(
              //     hintText: 'Re-enter your password',
              //   ),
              // ),
              // const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // Bottom bar with Next/Previous buttons
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Previous
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 1,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 8),

                // Next
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        HomeScreen.routeName,
                        arguments: userType,
                      );
                    },
                    child: const Text('Next'),
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

  /// Helper to build a text label
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
