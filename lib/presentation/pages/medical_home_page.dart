import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_constants.dart';
import '../widgets/medical_widgets.dart';

class MedicalHomePage extends StatefulWidget {
  const MedicalHomePage({super.key});

  @override
  State<MedicalHomePage> createState() => _MedicalHomePageState();
}

class _MedicalHomePageState extends State<MedicalHomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedLanguage = 'he';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Language Switcher
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (language) {
              setState(() {
                _selectedLanguage = language;
              });
              // TODO: Implement language switching
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'he',
                child: Text('עברית'),
              ),
              const PopupMenuItem(
                value: 'ar',
                child: Text('العربية'),
              ),
              const PopupMenuItem(
                value: 'en',
                child: Text('English'),
              ),
            ],
          ),
          // User Menu
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: AppTheme.primaryColor,
                size: 16,
              ),
            ),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Navigator.of(context).pushNamed('/profile');
                  break;
                case 'appointments':
                  Navigator.of(context).pushNamed('/appointments');
                  break;
                case 'login':
                  Navigator.of(context).pushNamed('/login');
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(width: 8),
                    Text(l10n.profile),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'appointments',
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    Text(l10n.appointments),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'login',
                child: Row(
                  children: [
                    const Icon(Icons.login),
                    const SizedBox(width: 8),
                    Text(l10n.login),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Welcome Section
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryLightColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ברוכים הבאים למערכת התורים הרפואיים',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'קבעו תור בקלות ובמהירות',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Search Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.search,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      _showFilterDialog(context);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  ),
                ),
                onSubmitted: (value) {
                  _performSearch(value);
                },
              ),
            ),
          ),
          
          // Quick Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.calendar_today,
                      title: l10n.appointments,
                      color: AppTheme.infoColor,
                      onTap: () {
                        Navigator.of(context).pushNamed('/appointments');
                      },
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.person,
                      title: l10n.profile,
                      color: AppTheme.successColor,
                      onTap: () {
                        Navigator.of(context).pushNamed('/profile');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SliverToBoxAdapter(
            child: SizedBox(height: AppTheme.spacingL),
          ),
          
          // Medical Specialties Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
              child: Text(
                'תחומי רפואה',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SliverToBoxAdapter(
            child: SizedBox(height: AppTheme.spacingM),
          ),
          
          // Medical Specialties Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: AppTheme.spacingM,
                mainAxisSpacing: AppTheme.spacingM,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final specialty = AppConstants.medicalSpecialties[index];
                  return MedicalSpecialtyCard(
                    specialty: specialty,
                    icon: _getSpecialtyIcon(specialty),
                    color: AppTheme.getSpecialtyColor(specialty),
                    onTap: () {
                      _navigateToSpecialty(specialty);
                    },
                  );
                },
                childCount: AppConstants.medicalSpecialties.length,
              ),
            ),
          ),
          
          const SliverToBoxAdapter(
            child: SizedBox(height: AppTheme.spacingL),
          ),
          
          // Featured Doctors Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'רופאים מומלצים',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/doctors');
                    },
                    child: const Text('הצג הכל'),
                  ),
                ],
              ),
            ),
          ),
          
          const SliverToBoxAdapter(
            child: SizedBox(height: AppTheme.spacingM),
          ),
          
          // Featured Doctors List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                    child: DoctorCard(
                      name: 'ד"ר ${_getSampleDoctorName(index)}',
                      specialty: AppConstants.medicalSpecialties[index % AppConstants.medicalSpecialties.length],
                      location: 'תל אביב',
                      rating: 4.5 + (index % 5) * 0.1,
                      reviewCount: 25 + index * 10,
                      onTap: () {
                        _navigateToDoctor(index);
                      },
                    ),
                  );
                },
                childCount: 3, // Show 3 featured doctors
              ),
            ),
          ),
          
          const SliverToBoxAdapter(
            child: SizedBox(height: AppTheme.spacingXL),
          ),
        ],
      ),
    );
  }

  IconData _getSpecialtyIcon(String specialty) {
    switch (specialty.toLowerCase()) {
      case 'osteopath':
        return Icons.healing;
      case 'physiotherapist':
        return Icons.fitness_center;
      case 'dentist':
        return Icons.medical_services;
      case 'dental_hygienist':
        return Icons.cleaning_services;
      case 'massage_therapist':
        return Icons.spa;
      case 'acupuncturist':
        return Icons.ac_unit;
      case 'psychologist':
        return Icons.psychology;
      case 'nutritionist':
        return Icons.restaurant;
      case 'general_practitioner':
        return Icons.local_hospital;
      case 'specialist':
        return Icons.medical_information;
      default:
        return Icons.medical_services;
    }
  }

  String _getSampleDoctorName(int index) {
    final names = [
      'אברהם כהן',
      'שרה לוי',
      'דוד ישראלי',
      'רחל גולדברג',
      'יוסף מזרחי',
    ];
    return names[index % names.length];
  }

  void _navigateToSpecialty(String specialty) {
    // TODO: Navigate to specialty page with filtered doctors
    Navigator.of(context).pushNamed('/doctors', arguments: {'specialty': specialty});
  }

  void _navigateToDoctor(int index) {
    // TODO: Navigate to doctor details page
    Navigator.of(context).pushNamed('/doctor-details', arguments: {'doctorId': index});
  }

  void _performSearch(String query) {
    // TODO: Implement search functionality
    Navigator.of(context).pushNamed('/search', arguments: {'query': query});
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).filter),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Filter options will be implemented here'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).confirm),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTheme.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}