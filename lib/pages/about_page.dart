import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info, size: 64, color: Colors.green),
          SizedBox(height: 16),
          Text('About Us', style: TextStyle(fontSize: 24)),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'We are a team of passionate developers creating the amazing Smart Itinerary Planner. \n Presented by Chang Sum Wing & Chu Ka Hei',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
