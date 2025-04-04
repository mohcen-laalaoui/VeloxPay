import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:VeloxPay/UI/views/dashboard/benefits.dart';
import 'package:VeloxPay/UI/views/dashboard/card.dart';
import 'package:VeloxPay/UI/views/dashboard/hub.dart';
import 'package:VeloxPay/UI/views/dashboard/profile.dart';
import 'package:VeloxPay/UI/views/dashboard/notifications.dart ';
import 'package:VeloxPay/UI/views/dashboard/receive.dart';
import 'package:VeloxPay/UI/views/dashboard/send.dart';
import 'package:VeloxPay/UI/views/dashboard/convert.dart ';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    DashboardPageContent(),
    CardPage(),
    BenefitsPage(),
    HubPage(),
  ];

  final List<String> _titles = ["Dashboard", "My Cards", "Benefits", "Hub"];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'Card'),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Benefits',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Hub'),
        ],
      ),
    );
  }
}

class DashboardPageContent extends StatefulWidget {
  const DashboardPageContent({super.key});

  @override
  State<DashboardPageContent> createState() => _DashboardPageContentState();
}

class _DashboardPageContentState extends State<DashboardPageContent> {
  bool _isVisible = true;
  double _userBalance = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserBalance();
  }

  Future<void> _loadUserBalance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final DocumentSnapshot userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (mounted) {
          setState(() {
            _userBalance =
                (userDoc.data() as Map<String, dynamic>)['balance'] ?? 0.0;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user balance: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Value (USD)', style: TextStyle(color: Colors.grey)),
              IconButton(
                icon: Icon(
                  _isVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isVisible = !_isVisible;
                  });
                },
              ),
            ],
          ),
          _isLoading
              ? CircularProgressIndicator(color: Colors.blue[800])
              : Text(
                _isVisible ? '\$${_userBalance.toStringAsFixed(2)}' : '***',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _actionButton(
                Icons.add,
                'Deposit',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReceivePage()),
                  ).then(
                    (_) => _loadUserBalance(),
                  ); // Refresh balance when returning
                },
              ),
              _actionButton(
                Icons.send,
                'Send',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              SendPage(onTransactionComplete: _loadUserBalance),
                    ),
                  );
                },
              ),
              _actionButton(
                Icons.swap_horiz,
                'Convert',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ConvertPage()),
                  ).then(
                    (_) => _loadUserBalance(),
                  ); // Refresh balance when returning
                },
              ),
              _actionButton(Icons.more_horiz, 'More'),
            ],
          ),

          SizedBox(height: 20),
          _cashbackPromotion(),
          SizedBox(height: 20),
          Text(
            'Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          _transactionItem('Google One', '-225.00 DZD', '2025-03-27 15:38:59'),
          _transactionItem('Google One', '-225.00 DZD', '2025-02-28 15:39:29'),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(12),
            child: Icon(icon, color: Colors.black),
          ),
          SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _cashbackPromotion() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.wallet_giftcard, color: Colors.pink),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$10,000 Cashback via TON',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Deposit & Spend to Claim Your Cashback',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  Widget _transactionItem(String title, String amount, String date) {
    return ListTile(
      leading: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(8),
        child: Icon(Icons.account_balance_wallet, color: Colors.blue),
      ),
      title: Text(title),
      subtitle: Text(date),
      trailing: Text(
        amount,
        style: TextStyle(
          color: amount.contains('-') ? Colors.red : Colors.green,
        ),
      ),
    );
  }
}
