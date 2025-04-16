import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'verification.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, String> userData;
  final String securityCode;

  const PaymentPage({
    super.key,
    required this.userData,
    required this.securityCode,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String cardNumber = '', expiryDate = '', cardHolderName = '', cvvCode = '';
  bool isCvvFocused = false;

  void _goToVerification() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => VerificationPage(
              expectedCode: widget.securityCode,
              firstName: widget.userData['firstName'] ?? 'User',
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/bg_payment.webp',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(0, 0, 0, 0.4), // semi-dark glass
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      children: [
                        CreditCardWidget(
                          cardNumber: cardNumber,
                          expiryDate: expiryDate,
                          cardHolderName: cardHolderName,
                          cvvCode: cvvCode,
                          showBackView: isCvvFocused,
                          onCreditCardWidgetChange: (_) {},
                        ),
                        CreditCardForm(
                          formKey: _formKey,
                          cardNumber: cardNumber,
                          expiryDate: expiryDate,
                          cardHolderName: cardHolderName,
                          cvvCode: cvvCode,
                          themeColor: Colors.blue,
                          textColor: Colors.white,
                          obscureCvv: true,
                          obscureNumber: false,
                          onCreditCardModelChange:
                              (model) => setState(() {
                                cardNumber = model.cardNumber;
                                expiryDate = model.expiryDate;
                                cardHolderName = model.cardHolderName;
                                cvvCode = model.cvvCode;
                                isCvvFocused = model.isCvvFocused;
                              }),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Future.delayed(
                                const Duration(seconds: 2),
                                _goToVerification,
                              );
                            }
                          },
                          child: const Text("Make Payment"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
