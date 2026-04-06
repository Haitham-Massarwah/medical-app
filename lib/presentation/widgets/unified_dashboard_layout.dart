import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'dashboard_sidebar.dart';
import 'metric_card.dart';

/// PD-12: Unified Dashboard Layout
/// Ensures identical structure across all account types (Patient/Doctor/Admin)
/// Only colors differ per role
class UnifiedDashboardLayout extends StatelessWidget {
  final String currentRoute;
  final String role;
  final String pageTitle;
  final List<Widget> metricCards;
  final List<Widget> contentSections;
  final Color? primaryColor; // Role-specific color theme
  final List<Widget> headerActions;

  const UnifiedDashboardLayout({
    super.key,
    required this.currentRoute,
    required this.role,
    required this.pageTitle,
    required this.metricCards,
    required this.contentSections,
    this.primaryColor,
    this.headerActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    // PD-12: Unified structure - same layout for all roles
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar - Same structure for all roles
            DashboardSidebar(
              currentRoute: currentRoute,
              role: role,
            ),
            
            // Main Content - Same structure for all roles
            Expanded(
              child: Container(
                color: AppColors.backgroundLight,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Page Title - Same style for all roles
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              pageTitle,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (headerActions.isNotEmpty)
                            Row(children: headerActions),
                        ],
                      ),
                      const SizedBox(height: 30),
                      
                      // Metrics Row - Same structure for all roles
                      Row(
                        children: [
                          ...metricCards.map((card) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: card,
                            ),
                          )),
                        ],
                      ),
                      const SizedBox(height: 30),
                      
                      // Content Sections - Same structure for all roles
                      ...contentSections.map((section) => Padding(
                        padding: const EdgeInsets.only(bottom: 25),
                        child: section,
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// PD-12: Standardized content section container
class DashboardContentSection extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Color? backgroundColor;

  const DashboardContentSection({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header - Same structure for all roles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}




