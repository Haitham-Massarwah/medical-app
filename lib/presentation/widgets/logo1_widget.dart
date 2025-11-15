import 'package:flutter/material.dart';

/// Logo1 - Exact replica: Gradient H.M letters with M as calendar + medical cross
class Logo1Widget extends StatelessWidget {
  final double size;
  
  const Logo1Widget({Key? key, this.size = 100}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background for gradient effect
          Positioned(
            top: 0,
            child: Container(
              width: size,
              height: size * 0.7,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.0, 0.5, 1.0],
                  colors: [
                    Color(0xFF00C6FB), // Cyan (H)
                    Color(0xFF005BEA), // Blue (middle)
                    Color(0xFF667EEA), // Purple (M)
                  ],
                ),
                borderRadius: BorderRadius.circular(size * 0.08),
              ),
              child: Stack(
                children: [
                  // H.M Text
                  Center(
                    child: Text(
                      'H.M',
                      style: TextStyle(
                        fontSize: size * 0.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: size * 0.05,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Calendar frame (top-right of M)
                  Positioned(
                    top: size * 0.08,
                    right: size * 0.12,
                    child: Container(
                      width: size * 0.28,
                      height: size * 0.32,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withOpacity(0.8), width: 2.5),
                        borderRadius: BorderRadius.circular(size * 0.04),
                      ),
                      child: Column(
                        children: [
                          // Calendar rings
                          SizedBox(height: size * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: size * 0.04,
                                height: size * 0.04,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: size * 0.04,
                                height: size * 0.04,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          // Medical cross inside calendar
                          Icon(
                            Icons.add,
                            color: Color(0xFF64B5F6),
                            size: size * 0.15,
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Text below
          Positioned(
            bottom: 0,
            child: Column(
              children: [
                Text(
                  'H.M',
                  style: TextStyle(
                    fontSize: size * 0.16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
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
            ),
          ),
        ],
      ),
    );
  }
}
