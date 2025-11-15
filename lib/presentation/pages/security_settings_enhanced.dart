import 'package:flutter/material.dart';

class SecuritySettingsEnhancedPage extends StatefulWidget {
  const SecuritySettingsEnhancedPage({super.key});

  @override
  State<SecuritySettingsEnhancedPage> createState() => _SecuritySettingsEnhancedPageState();
}

class _SecuritySettingsEnhancedPageState extends State<SecuritySettingsEnhancedPage> {
  // Security Settings
  bool _enableTwoFactorAuth = true;
  bool _enableBiometricAuth = true;
  bool _enableAutoLogout = true;
  bool _enableSessionTimeout = true;
  bool _enablePasswordExpiry = false;
  bool _enableLoginNotifications = true;
  bool _enableSecurityAlerts = true;
  bool _enableDataEncryption = true;
  bool _enableAuditLogging = true;
  bool _enableVulnerabilityScanning = true;
  bool _enableIntrusionDetection = true;
  bool _enableFirewall = true;
  bool _enableAntivirus = true;
  bool _enableBackupEncryption = true;
  bool _enableSecureCommunication = true;
  bool _enableAccessControl = true;
  bool _enableDataRetention = true;
  bool _enableComplianceMonitoring = true;
  bool _enableThreatIntelligence = true;

  // Timeout Settings
  int _sessionTimeoutMinutes = 30;
  int _passwordExpiryDays = 90;
  int _backupRetentionDays = 365;
  int _logRetentionDays = 180;

  // Security Levels
  String _securityLevel = 'high';
  String _encryptionLevel = 'aes256';
  String _authenticationMethod = 'multi_factor';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('הגדרות אבטחה'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'שמור הגדרות',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Overview
            _buildSecurityOverview(),
            const SizedBox(height: 24),

            // Authentication Settings
            _buildSectionCard(
              'הגדרות אימות',
              Icons.security,
              Colors.blue,
              [
                _buildSwitchTile('אימות דו-שלבי', _enableTwoFactorAuth, (value) {
                  setState(() => _enableTwoFactorAuth = value);
                }),
                _buildSwitchTile('אימות ביומטרי', _enableBiometricAuth, (value) {
                  setState(() => _enableBiometricAuth = value);
                }),
                _buildSwitchTile('התנתקות אוטומטית', _enableAutoLogout, (value) {
                  setState(() => _enableAutoLogout = value);
                }),
                _buildSwitchTile('פג תוקף סיסמה', _enablePasswordExpiry, (value) {
                  setState(() => _enablePasswordExpiry = value);
                }),
                _buildDropdownTile(
                  'שיטת אימות',
                  _authenticationMethod,
                  ['single_factor', 'multi_factor', 'biometric_only'],
                  ['אימות יחיד', 'אימות מרובה', 'ביומטרי בלבד'],
                  (value) => setState(() => _authenticationMethod = value!),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Session Management
            _buildSectionCard(
              'ניהול סשנים',
              Icons.timer,
              Colors.orange,
              [
                _buildSwitchTile('פג תוקף סשן', _enableSessionTimeout, (value) {
                  setState(() => _enableSessionTimeout = value);
                }),
                _buildSliderTile(
                  'זמן פג תוקף סשן (דקות)',
                  _sessionTimeoutMinutes.toDouble(),
                  5.0,
                  120.0,
                  (value) => setState(() => _sessionTimeoutMinutes = value.round()),
                ),
                _buildSliderTile(
                  'פג תוקף סיסמה (ימים)',
                  _passwordExpiryDays.toDouble(),
                  30.0,
                  365.0,
                  (value) => setState(() => _passwordExpiryDays = value.round()),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notifications & Alerts
            _buildSectionCard(
              'התראות ואזעקות',
              Icons.notifications,
              Colors.green,
              [
                _buildSwitchTile('התראות התחברות', _enableLoginNotifications, (value) {
                  setState(() => _enableLoginNotifications = value);
                }),
                _buildSwitchTile('אזעקות אבטחה', _enableSecurityAlerts, (value) {
                  setState(() => _enableSecurityAlerts = value);
                }),
                _buildSwitchTile('זיהוי חדירות', _enableIntrusionDetection, (value) {
                  setState(() => _enableIntrusionDetection = value);
                }),
                _buildSwitchTile('מודיעין איומים', _enableThreatIntelligence, (value) {
                  setState(() => _enableThreatIntelligence = value);
                }),
              ],
            ),
            const SizedBox(height: 16),

            // Data Protection
            _buildSectionCard(
              'הגנת נתונים',
              Icons.lock,
              Colors.purple,
              [
                _buildSwitchTile('הצפנת נתונים', _enableDataEncryption, (value) {
                  setState(() => _enableDataEncryption = value);
                }),
                _buildSwitchTile('הצפנת גיבויים', _enableBackupEncryption, (value) {
                  setState(() => _enableBackupEncryption = value);
                }),
                _buildSwitchTile('תקשורת מאובטחת', _enableSecureCommunication, (value) {
                  setState(() => _enableSecureCommunication = value);
                }),
                _buildDropdownTile(
                  'רמת הצפנה',
                  _encryptionLevel,
                  ['aes128', 'aes256', 'rsa2048', 'rsa4096'],
                  ['AES-128', 'AES-256', 'RSA-2048', 'RSA-4096'],
                  (value) => setState(() => _encryptionLevel = value!),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // System Security
            _buildSectionCard(
              'אבטחת מערכת',
              Icons.computer,
              Colors.indigo,
              [
                _buildSwitchTile('סריקת פגיעויות', _enableVulnerabilityScanning, (value) {
                  setState(() => _enableVulnerabilityScanning = value);
                }),
                _buildSwitchTile('חומת אש', _enableFirewall, (value) {
                  setState(() => _enableFirewall = value);
                }),
                _buildSwitchTile('אנטי-וירוס', _enableAntivirus, (value) {
                  setState(() => _enableAntivirus = value);
                }),
                _buildSwitchTile('בקרת גישה', _enableAccessControl, (value) {
                  setState(() => _enableAccessControl = value);
                }),
              ],
            ),
            const SizedBox(height: 16),

            // Monitoring & Logging
            _buildSectionCard(
              'ניטור ורישום',
              Icons.monitor,
              Colors.teal,
              [
                _buildSwitchTile('רישום ביקורת', _enableAuditLogging, (value) {
                  setState(() => _enableAuditLogging = value);
                }),
                _buildSwitchTile('שמירת נתונים', _enableDataRetention, (value) {
                  setState(() => _enableDataRetention = value);
                }),
                _buildSwitchTile('ניטור ציות', _enableComplianceMonitoring, (value) {
                  setState(() => _enableComplianceMonitoring = value);
                }),
                _buildSliderTile(
                  'שמירת יומנים (ימים)',
                  _logRetentionDays.toDouble(),
                  30.0,
                  730.0,
                  (value) => setState(() => _logRetentionDays = value.round()),
                ),
                _buildSliderTile(
                  'שמירת גיבויים (ימים)',
                  _backupRetentionDays.toDouble(),
                  30.0,
                  1095,
                  (value) => setState(() => _backupRetentionDays = value.round()),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Security Level
            _buildSectionCard(
              'רמת אבטחה כללית',
              Icons.shield,
              Colors.red,
              [
                _buildDropdownTile(
                  'רמת אבטחה',
                  _securityLevel,
                  ['low', 'medium', 'high', 'maximum'],
                  ['נמוכה', 'בינונית', 'גבוהה', 'מקסימלית'],
                  (value) => setState(() => _securityLevel = value!),
                ),
                _buildInfoTile('הגדרות מומלצות לפי רמת אבטחה', _getSecurityRecommendations()),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityOverview() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.red[600], size: 32),
                const SizedBox(width: 12),
                Text(
                  'סקירת הגדרות אבטחה',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('הגדרות פעילות', _getActiveSettingsCount(), Colors.green),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard('רמת אבטחה', _getSecurityLevelText(), Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('הצפנה', _getEncryptionText(), Colors.purple),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard('אימות', _getAuthText(), Colors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, Color color, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return ListTile(
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDropdownTile(String title, String value, List<String> options, List<String> labels, Function(String?) onChanged) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        items: options.asMap().entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.value,
            child: Text(labels[entry.key]),
          );
        }).toList(),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSliderTile(String title, double value, double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text('${value.round()}'),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).round(),
          onChanged: onChanged,
          activeColor: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildInfoTile(String title, String info) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(info, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
            label: const Text('שמור הגדרות'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _resetToDefaults,
            icon: const Icon(Icons.restore),
            label: const Text('איפוס לברירת מחדל'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  String _getActiveSettingsCount() {
    int count = 0;
    if (_enableTwoFactorAuth) count++;
    if (_enableBiometricAuth) count++;
    if (_enableAutoLogout) count++;
    if (_enableSessionTimeout) count++;
    if (_enableLoginNotifications) count++;
    if (_enableSecurityAlerts) count++;
    if (_enableDataEncryption) count++;
    if (_enableAuditLogging) count++;
    if (_enableVulnerabilityScanning) count++;
    if (_enableIntrusionDetection) count++;
    if (_enableFirewall) count++;
    if (_enableAntivirus) count++;
    if (_enableBackupEncryption) count++;
    if (_enableSecureCommunication) count++;
    if (_enableAccessControl) count++;
    if (_enableDataRetention) count++;
    if (_enableComplianceMonitoring) count++;
    if (_enableThreatIntelligence) count++;
    return '$count/18';
  }

  String _getSecurityLevelText() {
    switch (_securityLevel) {
      case 'low': return 'נמוכה';
      case 'medium': return 'בינונית';
      case 'high': return 'גבוהה';
      case 'maximum': return 'מקסימלית';
      default: return 'לא מוגדר';
    }
  }

  String _getEncryptionText() {
    switch (_encryptionLevel) {
      case 'aes128': return 'AES-128';
      case 'aes256': return 'AES-256';
      case 'rsa2048': return 'RSA-2048';
      case 'rsa4096': return 'RSA-4096';
      default: return 'לא מוגדר';
    }
  }

  String _getAuthText() {
    switch (_authenticationMethod) {
      case 'single_factor': return 'יחיד';
      case 'multi_factor': return 'מרובה';
      case 'biometric_only': return 'ביומטרי';
      default: return 'לא מוגדר';
    }
  }

  String _getSecurityRecommendations() {
    switch (_securityLevel) {
      case 'low':
        return '• הפעל אימות דו-שלבי\n• הפעל הצפנת נתונים\n• הגדר פג תוקף סיסמה';
      case 'medium':
        return '• הפעל אימות ביומטרי\n• הפעל סריקת פגיעויות\n• הגדר ניטור ציות';
      case 'high':
        return '• הפעל כל הגדרות האבטחה\n• השתמש בהצפנה חזקה\n• הגדר ניטור מתקדם';
      case 'maximum':
        return '• כל ההגדרות מופעלות\n• הצפנה מקסימלית\n• ניטור רציף 24/7';
      default:
        return 'בחר רמת אבטחה לקבלת המלצות';
    }
  }

  void _saveSettings() {
    // Show saving dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('שומר הגדרות אבטחה...'),
          ],
        ),
      ),
    );

    // Simulate save process
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('הגדרות האבטחה נשמרו בהצלחה!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('איפוס הגדרות'),
        content: const Text('האם אתה בטוח שברצונך לאפס את כל הגדרות האבטחה לברירת המחדל?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performReset();
            },
            child: const Text('איפוס'),
          ),
        ],
      ),
    );
  }

  void _performReset() {
    setState(() {
      // Reset to default values
      _enableTwoFactorAuth = true;
      _enableBiometricAuth = false;
      _enableAutoLogout = true;
      _enableSessionTimeout = true;
      _enablePasswordExpiry = false;
      _enableLoginNotifications = true;
      _enableSecurityAlerts = true;
      _enableDataEncryption = true;
      _enableAuditLogging = true;
      _enableVulnerabilityScanning = true;
      _enableIntrusionDetection = false;
      _enableFirewall = true;
      _enableAntivirus = false;
      _enableBackupEncryption = true;
      _enableSecureCommunication = true;
      _enableAccessControl = true;
      _enableDataRetention = true;
      _enableComplianceMonitoring = false;
      _enableThreatIntelligence = false;

      _sessionTimeoutMinutes = 30;
      _passwordExpiryDays = 90;
      _backupRetentionDays = 365;
      _logRetentionDays = 180;

      _securityLevel = 'high';
      _encryptionLevel = 'aes256';
      _authenticationMethod = 'multi_factor';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('הגדרות האבטחה אופסו לברירת המחדל'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
