import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../features/transfers/screens/transfer_list_screen.dart';
import '../../features/adjustments/screens/adjustment_list_screen.dart';
import '../../features/ledger/screens/stock_ledger_screen.dart';
import '../settings/settings_page.dart';
import '../profile/profile_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'More Operations',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('INVENTORY TOOLS'),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              title: 'Internal Transfers',
              subtitle: 'Move stock between locations',
              icon: Iconsax.arrow_swap_horizontal,
              color: const Color(0xFF8B5CF6),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TransferListScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              title: 'Stock Adjustments',
              subtitle: 'Correct physical stock counts',
              icon: Iconsax.edit_2,
              color: AppColors.error,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdjustmentListScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              title: 'Stock Ledger',
              subtitle: 'Detailed history of stock moves',
              icon: Iconsax.document_text,
              color: AppColors.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StockLedgerScreen()),
              ),
            ),
            const SizedBox(height: 32),
            _sectionLabel('ACCOUNT & APP'),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              title: 'Profile Settings',
              subtitle: 'Manage your account details',
              icon: Iconsax.user,
              color: AppColors.textSecondary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              ),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              title: 'App Settings',
              subtitle: 'Preferences & configurations',
              icon: Iconsax.setting_2,
              color: AppColors.textSecondary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.textLight,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
