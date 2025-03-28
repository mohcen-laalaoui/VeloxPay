import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationsPage extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {
      "title": "Payment Received",
      "message": "You have received \$50 from Moncef Laalaoui.",
      "time": "2m ago",
    },
    {
      "title": "Transaction Successful",
      "message": "Your payment to Ali Baba was successful.",
      "time": "10m ago",
    },
    {
      "title": "Offer Alert",
      "message": "Get 10% cashback on your next transaction!",
      "time": "1h ago",
    },
    {
      "title": "Security Update",
      "message": "Your account password was changed.",
      "time": "3h ago",
    },
  ];

  NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        automaticallyImplyLeading: true,
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: Icon(Icons.notifications, color: Colors.blueAccent),
              title: Text(notifications[index]["title"]!),
              subtitle: Text(notifications[index]["message"]!),
              trailing: Text(notifications[index]["time"]!),
            ),
          );
        },
      ),
    );
  }
}
