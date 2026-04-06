import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationService _notificationService = NotificationService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    try {
      final notifications = await NotificationService.getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בטעינת התראות: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _markAsRead(String notificationId) async {
    try {
      await NotificationService.markAsRead(notificationId);
      setState(() {
        final index = _notifications.indexWhere((n) => n['id'] == notificationId);
        if (index != -1) {
          _notifications[index]['isRead'] = true;
        }
      });
    } catch (e) {
      // Silently fail
    }
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'appointment_reminder':
        return Icons.calendar_today;
      case 'appointment_confirmation':
      case 'appointment_confirmed':
        return Icons.check_circle;
      case 'appointment_cancellation':
      case 'appointment_cancelled':
        return Icons.cancel;
      case 'payment':
      case 'payment_received':
        return Icons.payment;
      case 'payment_failed':
        return Icons.error;
      case 'system':
        return Icons.info;
      case 'doctor_message': // PD-10: Doctor/therapist messages
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String? type) {
    switch (type) {
      case 'appointment_reminder':
        return Colors.blue;
      case 'appointment_confirmation':
      case 'appointment_confirmed':
        return Colors.green;
      case 'appointment_cancellation':
      case 'appointment_cancelled':
        return Colors.red;
      case 'payment':
      case 'payment_received':
        return Colors.green;
      case 'payment_failed':
        return Colors.red;
      case 'system':
        return Colors.orange;
      case 'doctor_message': // PD-10: Doctor/therapist messages
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedNotifications = _showUnreadOnly
        ? _notifications.where((n) => !(n['isRead'] ?? false)).toList()
        : _notifications;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('התראות'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(_showUnreadOnly ? Icons.filter_list_off : Icons.filter_list),
              onPressed: () {
                setState(() => _showUnreadOnly = !_showUnreadOnly);
              },
              tooltip: _showUnreadOnly ? 'הצג הכל' : 'הצג רק לא נקרא',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadNotifications,
            ),
          ],
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : displayedNotifications.isEmpty
                  ? Center(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showUnreadOnly ? 'אין התראות חדשות' : 'אין התראות',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8),
                      itemCount: displayedNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = displayedNotifications[index];
                      final isRead = notification['isRead'] ?? false;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: isRead ? Colors.white : Colors.blue.shade50,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getColorForType(notification['type']).withOpacity(0.2),
                            child: Icon(
                              _getIconForType(notification['type']),
                              color: _getColorForType(notification['type']),
                            ),
                          ),
                          title: Text(
                            notification['title'] ?? '',
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(notification['message'] ?? ''),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(notification['createdAt']),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            if (!isRead) {
                              _markAsRead(notification['id']);
                            }
                          },
                          trailing: !isRead
                              ? Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                        ),
                      );
                      },
                    ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
          backgroundColor: Colors.orange,
          child: const Icon(Icons.settings),
        ),
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '';
    
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) {
        return 'לפני ${diff.inMinutes} דקות';
      } else if (diff.inHours < 24) {
        return 'לפני ${diff.inHours} שעות';
      } else if (diff.inDays < 7) {
        return 'לפני ${diff.inDays} ימים';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }
}
