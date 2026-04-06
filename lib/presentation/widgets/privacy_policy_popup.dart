import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../services/language_service.dart';

/// Privacy Policy Popup Widget
class PrivacyPolicyPopup extends StatelessWidget {
  const PrivacyPolicyPopup({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PrivacyPolicyPopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    // Use MaterialApp's locale for real-time updates
    final language = Localizations.localeOf(context).languageCode;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.privacy_tip, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      localizations.privacy,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildPrivacyContent(language),
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      localizations.close,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyContent(String language) {
    if (language == 'he') {
      return _buildHebrewContent();
    } else if (language == 'ar') {
      return _buildArabicContent();
    } else {
      return _buildEnglishContent();
    }
  }

  Widget _buildHebrewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          'מדיניות הפרטיות',
          'אנו מחויבים להגן על הפרטיות שלך. מדיניות זו מסבירה כיצד אנו אוספים, משתמשים ומגנים על המידע האישי שלך.',
        ),
        const SizedBox(height: 20),
        _buildSection(
          'איסוף מידע',
          'אנו אוספים מידע שאתה מספק ישירות, כגון שם, כתובת אימייל, מספר טלפון ומידע רפואי רלוונטי.',
        ),
        const SizedBox(height: 20),
        _buildSection(
          'שימוש במידע',
          'אנו משתמשים במידע שלך כדי לספק שירותים רפואיים, לתאם תורים, לעבד תשלומים ולשפר את השירות שלנו.',
        ),
        const SizedBox(height: 20),
        _buildSection(
          'אבטחת מידע',
          'אנו משתמשים בהצפנה מתקדמת ומגבילים גישה למידע האישי שלך רק לאנשים מורשים.',
        ),
        const SizedBox(height: 20),
        _buildSection(
          'זכויותיך',
          'יש לך זכות לגשת, לעדכן או למחוק את המידע האישי שלך בכל עת. אנא צור קשר עם התמיכה לפרטים נוספים.',
        ),
        const SizedBox(height: 20),
        _buildSection(
          'תאימות',
          'אנו עומדים בתקנות GDPR, HIPAA וחוק הגנת הפרטיות הישראלי.',
        ),
      ],
    );
  }

  Widget _buildArabicContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          'سياسة الخصوصية',
          'نحن ملتزمون بحماية خصوصيتك. توضح هذه السياسة كيفية جمع واستخدام وحماية معلوماتك الشخصية.',
        ),
        const SizedBox(height: 20),
        _buildSection(
          'جمع المعلومات',
          'نجمع المعلومات التي تقدمها مباشرة، مثل الاسم وعنوان البريد الإلكتروني ورقم الهاتف والمعلومات الطبية ذات الصلة.',
        ),
        const SizedBox(height: 20),
        _buildSection(
          'استخدام المعلومات',
          'نستخدم معلوماتك لتقديم الخدمات الطبية وتنسيق المواعيد ومعالجة المدفوعات وتحسين خدمتنا.',
        ),
        const SizedBox(height: 20),
        _buildSection(
          'أمان المعلومات',
          'نستخدم التشفير المتقدم ونقيد الوصول إلى معلوماتك الشخصية للأشخاص المصرح لهم فقط.',
        ),
        const SizedBox(height: 20),
        _buildSection(
          'حقوقك',
          'لديك الحق في الوصول إلى معلوماتك الشخصية أو تحديثها أو حذفها في أي وقت. يرجى الاتصال بالدعم لمزيد من التفاصيل.',
        ),
        const SizedBox(height: 20),
        _buildSection(
          'الامتثال',
          'نحن نلتزم بلوائح GDPR وHIPAA وقانون حماية الخصوصية الإسرائيلي.',
        ),
      ],
    );
  }

  Widget _buildEnglishContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          'Privacy Policy',
          'We are committed to protecting your privacy. This policy explains how we collect, use, and protect your personal information.',
        ),
        const SizedBox(height: 20),
        _buildSection(
          'Information Collection',
          'We collect information you provide directly, such as name, email address, phone number, and relevant medical information.',
        ),
        const SizedBox(height: 20),
        _buildSection(
          'Use of Information',
          'We use your information to provide medical services, coordinate appointments, process payments, and improve our service.',
        ),
        const SizedBox(height: 20),
        _buildSection(
          'Information Security',
          'We use advanced encryption and restrict access to your personal information to authorized personnel only.',
        ),
        const SizedBox(height: 20),
        _buildSection(
          'Your Rights',
          'You have the right to access, update, or delete your personal information at any time. Please contact support for more details.',
        ),
        const SizedBox(height: 20),
        _buildSection(
          'Compliance',
          'We comply with GDPR, HIPAA, and Israeli Privacy Law regulations.',
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

