
import 'package:flutter/material.dart';

class InfoTileWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color bg;
  const InfoTileWidget({
    required this.icon,
    required this.label,
    required this.value,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 18),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.white),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 13, color: Colors.white70)),
              Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
            ],
          )
        ],
      ),
    );
  }
}
