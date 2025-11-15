import 'package:flutter/material.dart';

/// Logo1 - Gradient H.M letters with integrated calendar and medical cross
class Logo1Widget extends StatelessWidget {
  final double size;
  
  const Logo1Widget({Key? key, this.size = 100}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF00C6FB), // Bright cyan
                  Color(0xFF005BEA), // Deep blue  
                  Color(0xFF667EEA), // Purple
                ],
              ),
              borderRadius: BorderRadius.circular(size * 0.15),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF00C6FB).withOpacity(0.4),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
          ),
          
          // H.M Letters
          Center(
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Colors.white, Colors.white.withOpacity(0.95)],
              ).createShader(bounds),
              child: Text(
                'H.M',
                style: TextStyle(
                  fontSize: size * 0.38,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: size * 0.02,
                ),
              ),
            ),
          ),
          
          // Calendar icon overlay (top-right)
          Positioned(
            top: size * 0.12,
            right: size * 0.12,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(size * 0.05),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Calendar frame
                  Icon(Icons.calendar_today_outlined, color: Colors.white, size: size * 0.18),
                  // Medical cross inside
                  Icon(Icons.add, color: Colors.white, size: size * 0.14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}




