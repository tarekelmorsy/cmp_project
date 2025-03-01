import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // متغيرات تخزين بيانات البطاقة
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      child: Scaffold(
         // backgroundColor: Colors.grey[200],
        body: Column(
          children: [
            // 1️⃣ واجهة البطاقة التفاعلية
            CreditCardWidget(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              showBackView: isCvvFocused,
              onCreditCardWidgetChange: (CreditCardBrand brand) {},
            ),

            // 2️⃣ نموذج إدخال بيانات البطاقة
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CreditCardForm(
                      formKey: _formKey,
                      onCreditCardModelChange: (CreditCardModel data) {
                        setState(() {
                          cardNumber = data.cardNumber;
                          expiryDate = data.expiryDate;
                          cardHolderName = data.cardHolderName;
                          cvvCode = data.cvvCode;
                          isCvvFocused = data.isCvvFocused;
                        });
                      },
                      themeColor: Colors.blue,
                      obscureCvv: true,
                      obscureNumber: false,
                      cardNumberDecoration: _buildInputDecoration('Card Number'),
                      expiryDateDecoration: _buildInputDecoration('Expiry Date'),
                      cvvCodeDecoration: _buildInputDecoration('CVV'),
                      cardHolderDecoration: _buildInputDecoration('Card Holder Name'), cardNumber: '', expiryDate: '', cardHolderName: '', cvvCode: '',
                    ),

                    const SizedBox(height: 20),

                    // 3️⃣ زر الدفع (بدون تنفيذ فعلي)
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _showPaymentSuccessDialog();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text('Pay Now'),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة توليد تصميم حقول الإدخال
  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  // 4️⃣ نافذة تأكيد الدفع الوهمية
  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: const Text('Your payment has been processed successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
