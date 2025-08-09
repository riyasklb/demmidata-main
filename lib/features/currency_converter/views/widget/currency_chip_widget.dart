
import 'package:flutter/material.dart';

class CurrencyChip extends StatelessWidget {
  final String currencyCode;
  final String label;

  const CurrencyChip({required this.currencyCode, required this.label});

  @override
  Widget build(BuildContext context) {
    IconData iconData = Icons.monetization_on;
    if (currencyCode == 'INR') iconData = Icons.currency_rupee;
    if (currencyCode == 'USD') iconData = Icons.attach_money;
    if (currencyCode == 'EUR') iconData = Icons.euro;
    if (currencyCode == 'AED') iconData = Icons.money;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade500.withOpacity(0.30),
            Colors.deepPurple.shade400.withOpacity(0.26),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.indigo.shade400.withOpacity(0.13), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: Colors.white.withOpacity(0.93),
            child: Icon(iconData, color: Colors.deepPurple, size: 24),
          ),
          SizedBox(width: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currencyCode,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17),
              ),
              Text(
                label,
                style: TextStyle(color: Colors.purpleAccent.shade100, fontSize: 11, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
