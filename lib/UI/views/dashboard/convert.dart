import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConvertPage extends StatefulWidget {
  const ConvertPage({super.key});

  @override
  _ConvertPageState createState() => _ConvertPageState();
}

class _ConvertPageState extends State<ConvertPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();

  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';

  final Map<String, double> _conversionRates = {
    'USD_EUR': 0.92,
    'USD_DZD': 134.00,
    'USD_JPY': 149.50,
    'USD_CAD': 1.35,
    'EUR_USD': 1.09,
    'DZD_USD': 0.0075,
    'JPY_USD': 0.0067,
    'CAD_USD': 0.74,
  };

  final List<String> _currencies = ['USD', 'EUR', 'DZD', 'JPY', 'CAD'];

  void _convertCurrency() {
    double? amount = double.tryParse(_amountController.text);

    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    String rateKey = '${_fromCurrency}_${_toCurrency}';

    double? rate = _conversionRates[rateKey];

    if (rate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Conversion not supported')));
      return;
    }

    double result = amount * rate;

    setState(() {
      _resultController.text = result.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = Color(0xFF1A5F7A);
    final Color lightBlue = Color(0xFF159895);
    final Color backgroundBlue = Color(0xFFE3F4F4);

    return Scaffold(
      backgroundColor: backgroundBlue,
      appBar: AppBar(
        title: Text(
          'Currency Converter',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryBlue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      spreadRadius: 3,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Amount',
                              labelStyle: TextStyle(color: primaryBlue),
                              prefixIcon: Icon(
                                Icons.attach_money,
                                color: primaryBlue,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: lightBlue),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: primaryBlue,
                                  width: 2,
                                ),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: lightBlue),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _fromCurrency,
                                dropdownColor: Colors.white,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: primaryBlue,
                                ),
                                items:
                                    _currencies.map((String currency) {
                                      return DropdownMenuItem(
                                        value: currency,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                          ),
                                          child: Text(
                                            currency,
                                            style: TextStyle(
                                              color: primaryBlue,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _fromCurrency = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Icon(Icons.swap_vert, color: primaryBlue, size: 36),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _resultController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Converted Amount',
                              labelStyle: TextStyle(color: primaryBlue),
                              prefixIcon: Icon(
                                Icons.monetization_on_outlined,
                                color: primaryBlue,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: lightBlue),
                              ),
                              filled: true,
                              fillColor: backgroundBlue.withOpacity(0.5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: lightBlue),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _toCurrency,
                                dropdownColor: Colors.white,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: primaryBlue,
                                ),
                                items:
                                    _currencies.map((String currency) {
                                      return DropdownMenuItem(
                                        value: currency,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                          ),
                                          child: Text(
                                            currency,
                                            style: TextStyle(
                                              color: primaryBlue,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _toCurrency = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _convertCurrency,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Convert Currency',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _resultController.dispose();
    super.dispose();
  }
}
