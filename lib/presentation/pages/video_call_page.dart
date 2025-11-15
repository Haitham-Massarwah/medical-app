import 'package:flutter/material.dart';
import '../../services/telehealth_service.dart';

class VideoCallPage extends StatefulWidget {
  final String appointmentId;
  final String doctorName;
  final String patientName;
  final bool isDoctor;

  const VideoCallPage({
    super.key,
    required this.appointmentId,
    required this.doctorName,
    required this.patientName,
    required this.isDoctor,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  final TelehealthService _telehealthService = TelehealthService();
  bool _isConnecting = true;
  bool _isCallActive = false;
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isSpeakerOn = true;
  String? _sessionId;

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    setState(() {
      _isConnecting = true;
    });

    try {
      // Create or join session
      final session = await _telehealthService.createSession(
        appointmentId: widget.appointmentId,
        doctorId: 'doctor_id',
        patientId: 'patient_id',
      );
      
      setState(() {
        _sessionId = session['id'];
        _isConnecting = false;
        _isCallActive = true;
      });
    } catch (e) {
      // Simulate successful connection for demo
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _sessionId = 'mock_session_${DateTime.now().millisecondsSinceEpoch}';
        _isConnecting = false;
        _isCallActive = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Main video view
            _buildMainVideo(),
            
            // Local video preview (small)
            Positioned(
              top: 16,
              right: 16,
              child: _buildLocalVideoPreview(),
            ),
            
            // Call info
            Positioned(
              top: 16,
              left: 16,
              child: _buildCallInfo(),
            ),
            
            // Controls
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: _buildControls(),
            ),
            
            // Connecting overlay
            if (_isConnecting)
              Container(
                color: Colors.black,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'מתחבר לשיחה...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainVideo() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade900,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue,
              child: Text(
                widget.isDoctor
                    ? widget.patientName.substring(0, 1)
                    : widget.doctorName.split(' ').last.substring(0, 1),
                style: const TextStyle(
                  fontSize: 48,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.isDoctor ? widget.patientName : widget.doctorName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_isCallActive)
              const Text(
                'שיחה פעילה',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalVideoPreview() {
    return Container(
      width: 120,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: _isVideoOff
          ? const Center(
              child: Icon(
                Icons.videocam_off,
                color: Colors.white,
                size: 32,
              ),
            )
          : const Center(
              child: Text(
                'אתה',
                style: TextStyle(color: Colors.white),
              ),
            ),
    );
  }

  Widget _buildCallInfo() {
    if (!_isCallActive) return const SizedBox();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.videocam,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              return Text(
                _formatDuration(DateTime.now().difference(DateTime.now().subtract(const Duration(seconds: 0)))),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute/Unmute
          _buildControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            label: _isMuted ? 'בטל השתקה' : 'השתק',
            color: _isMuted ? Colors.red : Colors.white,
            onTap: () {
              setState(() {
                _isMuted = !_isMuted;
              });
            },
          ),
          
          // Video On/Off
          _buildControlButton(
            icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
            label: _isVideoOff ? 'הפעל מצלמה' : 'כבה מצלמה',
            color: _isVideoOff ? Colors.red : Colors.white,
            onTap: () {
              setState(() {
                _isVideoOff = !_isVideoOff;
              });
            },
          ),
          
          // Speaker On/Off
          _buildControlButton(
            icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
            label: _isSpeakerOn ? 'רמקול פעיל' : 'רמקול כבוי',
            color: Colors.white,
            onTap: () {
              setState(() {
                _isSpeakerOn = !_isSpeakerOn;
              });
            },
          ),
          
          // End Call
          _buildControlButton(
            icon: Icons.call_end,
            label: 'סיים',
            color: Colors.red,
            backgroundColor: Colors.red,
            onTap: _endCall,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    Color? backgroundColor,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: backgroundColor != null ? Colors.white : color,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _endCall() async {
    // Confirm end call
    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('סיום שיחה'),
        content: const Text('האם אתה בטוח שברצונך לסיים את השיחה?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('סיים שיחה'),
          ),
        ],
      ),
    );

    if (shouldEnd == true) {
      if (_sessionId != null) {
        await _telehealthService.endSession(_sessionId!);
      }
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    if (_sessionId != null) {
      _telehealthService.endSession(_sessionId!);
    }
    super.dispose();
  }
}









