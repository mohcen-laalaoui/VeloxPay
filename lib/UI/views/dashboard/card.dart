import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key});

  @override
  _CardPageState createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  final List<Map<String, dynamic>> _cards = [
    {
      'cardNumber': '4532 1234 5678 9012',
      'cardHolder': 'Mouhcen Laalaoui',
      'expiryDate': '12/28',
      'cardType': 'Visa',
      'cvc': 175,
      'backgroundColor': Color.fromARGB(255, 0, 65, 135),
    },
    {
      'cardNumber': '5412 7534 8901 2345',
      'cardHolder': 'Mouhcen Laalaoui',
      'expiryDate': '06/26',
      'cardType': 'Mastercard',
      'cvc': 207,
      'backgroundColor': Colors.black,
    },
  ];

  void _copyCardNumber(String cardNumber) {
    Clipboard.setData(ClipboardData(text: cardNumber));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Card number copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            color: Colors.white,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final card = _cards[index];
                return GestureDetector(
                  onLongPress: () => _copyCardNumber(card['cardNumber']),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: card['backgroundColor'],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Image.asset(
                                  'assets/logo/${card['cardType'].toLowerCase()}.png',
                                  height: 40,
                                  width: 60,
                                  fit: BoxFit.contain,
                                ),
                              ),

                              SizedBox(width: 10),
                              Image.asset(
                                'assets/logo/${card['cardType'].toLowerCase()}.png',
                                height: 40,
                                width: 60,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                          SizedBox(height: 20),

                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              card['cardNumber'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Card Holder',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      card['cardHolder'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Expiry Date',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    card['expiryDate'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 10),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'CVC',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      card['cvc'].toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Card management feature coming soon')),
          );
        },
        backgroundColor: Colors.black87,
        child: Icon(Icons.settings, color: Colors.white),
      ),
    );
  }
}
