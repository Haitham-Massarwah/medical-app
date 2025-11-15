import 'package:flutter/material.dart';

/// Advanced H.M Logo with gradient letters and calendar/medical cross
class HMLogoAdvanced extends StatelessWidget {
  final double size;
  
  const HMLogoAdvanced({Key? key, this.size = 100}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Gradient H.M letters with calendar/medical cross
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
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
                color: const Color(0xFF00C6FB).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // H.M text
              Text(
                'H.M',
                style: TextStyle(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: size * 0.02,
                ),
              ),
              // Calendar icon overlay (top-right)
              Positioned(
                top: size * 0.15,
                right: size * 0.15,
                child: Container(
                  width: size * 0.25,
                  height: size * 0.25,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(size * 0.04),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    size: size * 0.15,
                    color: Colors.white,
                  ),
                ),
              ),
              // Medical cross overlay (center-right)
              Positioned(
                right: size * 0.18,
                child: Icon(
                  Icons.add,
                  size: size * 0.2,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: size * 0.15),
        // Text below
        Text(
          'H.M',
          style: TextStyle(
            fontSize: size * 0.18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        Text(
          'Appointments',
          style: TextStyle(
            fontSize: size * 0.14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}




