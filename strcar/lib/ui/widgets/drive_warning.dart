import 'package:flutter/material.dart';

class DriveWarningBanner extends StatelessWidget {
  const DriveWarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber.shade100,
      padding: const EdgeInsets.all(8),
      child: const Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.amber),
          SizedBox(width: 8),
          Expanded(child: Text('Güvenlik: Aracı sürerken uygulamayı kullanmayın.')),
        ],
      ),
    );
  }
}

