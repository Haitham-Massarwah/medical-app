import 'package:flutter/material.dart';

class SystemLogsLitePage extends StatelessWidget {
  const SystemLogsLitePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('יומני מערכת'),
      ),
      body: const Center(
        child: Text('תצוגת יומנים זמנית. הגרסה המלאה תופעל לאחר שהאפליקציה תעלה.'),
      ),
    );
  }
}






