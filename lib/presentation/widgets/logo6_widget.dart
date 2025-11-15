import 'package:flutter/material.dart';

/// Logo6 - White HM letters with shield/plus in M (pure Flutter, no image)
class Logo6Widget extends StatelessWidget {
  final double size;
  
  const Logo6Widget({Key? key, this.size = 150}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.6,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // H Letter
          _buildHLetter(size * 0.45),
          SizedBox(width: size * 0.05),
          // M Letter with shield
          _buildMLetter(size * 0.45),
        ],
      ),
    );
  }

  Widget _buildHLetter(double height) {
    return Container(
      width: height * 0.6,
      height: height,
      child: Stack(
        children: [
          // Left vertical bar
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: height * 0.15,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(height * 0.05),
              ),
            ),
          ),
          // Right vertical bar
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: height * 0.15,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(height * 0.05),
              ),
            ),
          ),
          // Horizontal bar (middle)
          Positioned(
            left: 0,
            right: 0,
            top: height * 0.42,
            child: Container(
              height: height * 0.15,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(height * 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMLetter(double height) {
    return Container(
      width: height * 0.75,
      height: height,
      child: Stack(
        children: [
          // Left vertical bar
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: height * 0.15,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(height * 0.05),
              ),
            ),
          ),
          // Right vertical bar
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: height * 0.15,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(height * 0.05),
              ),
            ),
          ),
          // Left diagonal
          Positioned(
            left: height * 0.1,
            top: 0,
            child: Transform.rotate(
              angle: 0.4,
              child: Container(
                width: height * 0.12,
                height: height * 0.5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(height * 0.04),
                ),
              ),
            ),
          ),
          // Right diagonal
          Positioned(
            right: height * 0.1,
            top: 0,
            child: Transform.rotate(
              angle: -0.4,
              child: Container(
                width: height * 0.12,
                height: height * 0.5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(height * 0.04),
                ),
              ),
            ),
          ),
          // Shield with plus (center of M)
          Positioned(
            left: height * 0.22,
            top: height * 0.15,
            child: Container(
              width: height * 0.3,
              height: height * 0.35,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(height * 0.08),
                border: Border.all(color: Colors.white, width: height * 0.02),
              ),
              child: Center(
                child: Icon(
                  Icons.add,
                  color: Color(0xFF0E2C70),
                  size: height * 0.18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}




