import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';


class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 20),
            _buildTransactionList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Colors.blueAccent,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Balance',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '\$12,345.67',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton('Send', LucideIcons.send),
                _buildActionButton('Receive', LucideIcons.download),
                _buildActionButton('More', LucideIcons.moreVertical),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(icon, color: Colors.blueAccent),
        ),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  Widget _buildTransactionList() {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    _buildTransactionItem(
                      'Spotify Subscription',
                      '-\$9.99',
                      LucideIcons.music,
                    ),
                    _buildTransactionItem(
                      'Coffee Shop',
                      '-\$4.50',
                      LucideIcons.coffee,
                    ),
                    _buildTransactionItem(
                      'Freelance Payment',
                      '+\$450.00',
                      LucideIcons.briefcase,
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

  Widget _buildTransactionItem(String title, String amount, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: Icon(icon, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Today',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      items:  [
        BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.creditCard),
          label: 'Cards',
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.barChart2),
          label: 'Stats',
        ),
        BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: 'Profile'),
      ],
    );
  }
}
