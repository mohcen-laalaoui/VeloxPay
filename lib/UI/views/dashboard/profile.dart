import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Profile'),
        actions: [IconButton(icon: Icon(Icons.more_vert), onPressed: () {})],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildUserHeader(),

              _buildReferralSection(),

              _buildSectionHeader('Security Settings'),
              _buildSettingsItem(
                icon: Icons.security,
                title: 'Security',
                trailing: Text(
                  'Medium',
                  style: TextStyle(color: Colors.orange),
                ),
              ),

              _buildSectionHeader('Payment Settings'),
              _buildSettingsItem(
                icon: Icons.payment,
                title: 'Payment Priority',
              ),
              _buildSettingsItem(
                icon: Icons.low_priority,
                title: 'Low Balance Alert',
              ),

              _buildSectionHeader('General'),
              _buildSettingsItem(icon: Icons.settings, title: 'Settings'),
              _buildSettingsItem(icon: Icons.support, title: 'Support Center'),
              _buildSettingsItem(icon: Icons.group, title: 'Community'),
              _buildSettingsItem(icon: Icons.share, title: 'Share'),
              _buildSettingsItem(
                icon: Icons.info_outline,
                title: 'About Us',
                bottomTrailing: Text(
                  'v 2.4.4',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              _buildSectionHeader('Account'),
              _buildLogoutItem(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    final User? user = FirebaseAuth.instance.currentUser;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            radius: 30,
            child: Icon(Icons.person, color: Colors.grey),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Full Name',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  'UID: ${user?.uid ?? 'N/A'}',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralSection() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Referral', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Refer & Earn Up to 40% Commission'),
              ],
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: Text('Go referral'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(Icons.logout, color: Colors.red),
      title: Text(
        'Logout',
        style: TextStyle(color: Colors.red),
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => _showLogoutConfirmationDialog(context),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => _performLogout(context),
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    Widget? bottomTrailing,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: Colors.grey),
      title: Text(title, overflow: TextOverflow.ellipsis),
      trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.grey),
      subtitle: bottomTrailing,
    );
  }
}

Widget _buildLogoutItem(BuildContext context) {
  return ListTile(
    contentPadding: EdgeInsets.symmetric(horizontal: 16),
    leading: Icon(Icons.logout, color: Colors.red),
    title: Text(
      'Logout',
      style: TextStyle(color: Colors.red),
      overflow: TextOverflow.ellipsis,
    ),
    onTap: () => _showLogoutConfirmationDialog(context),
  );
}

void _showLogoutConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => _performLogout(context),
            child: Text('Logout'),
          ),
        ],
      );
    },
  );
}

void _performLogout(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  } catch (e) {
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logout failed: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
