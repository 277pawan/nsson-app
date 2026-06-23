import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/custom_snack_bars.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/mc_badge.dart';
import '../../providers/auth_provider.dart';
import 'address_screen.dart';
import 'settings_screen.dart';
import 'policy_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _shopCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _firstNameCtrl = TextEditingController(text: user?.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: user?.lastName ?? '');
    _shopCtrl = TextEditingController(text: user?.shopName ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _addressCtrl = TextEditingController(text: user?.address ?? '');
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _shopCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final success = await context.read<AuthProvider>().updateProfile(
    firstName: _firstNameCtrl .text,
    lastName: _lastNameCtrl.text,
          shopName: _shopCtrl.text,
          email: _emailCtrl.text,
          phone: _phoneCtrl.text,
          address: _addressCtrl.text,
        );
    if (!mounted) return;
    if (!success) {
      CustomSnackBars.showGlassSnackBar(
        context: context,
        message:
            context.read<AuthProvider>().error ?? 'Unable to update profile',
        duration: const Duration(seconds: 5),
      );
      return;
    }
    setState(() => _editing = false);
    CustomSnackBars.showGlassSnackBar(
      context: context,
      message: 'Profile updated successfully',
      duration: const Duration(seconds: 5),
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Profile header card
        FadeIn(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.15),
                        AppColors.primaryLight,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (user.shopName.isNotEmpty)
                        Text(
                          user.shopName,
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 14,
                          ),
                        ),
                      const SizedBox(height: 6),
                      McBadge(
                        label: user.isApproved
                            ? AppStrings.approvedRetailer
                            : AppStrings.pendingApproval,
                        variant: user.isApproved
                            ? McBadgeVariant.success
                            : McBadgeVariant.warning,
                        fontSize: 10,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _editing = !_editing),
                  icon: Icon(
                    _editing ? Icons.close : Icons.edit_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Edit form (expandable)
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _buildEditForm(),
          crossFadeState:
              _editing ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),

        // User info card
        if (!_editing)
          FadeIn(
            durationMs: 400,
            child: _buildUserInfoCard(user),
          ),
        const SizedBox(height: 12),

        // Menu sections
        FadeIn(
          durationMs: 500,
          child: _buildMenuSection(
            title: 'My Account',
            items: [
              _MenuItem(
                icon: Icons.location_on_outlined,
                title: 'My Addresses',
                subtitle: 'Manage delivery addresses',
                onTap: () => _navigateTo(const AddressScreen()),
              ),
              _MenuItem(
                icon: Icons.local_offer_outlined,
                title: 'My Coupons',
                subtitle: 'View available offers and discounts',
                onTap: () => Navigator.pushNamed(context, '/coupons'),
              ),
              _MenuItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                subtitle: 'Password, notifications',
                onTap: () => _navigateTo(const SettingsScreen()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        FadeIn(
          durationMs: 600,
          child: _buildMenuSection(
            title: 'Information',
            items: [
              _MenuItem(
                icon: Icons.policy_outlined,
                title: 'Privacy Policy & Terms',
                subtitle: 'Read our policies',
                onTap: () => _navigateTo(const PolicyScreen()),
              ),
              _MenuItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'FAQs, contact us',
                onTap: () => _navigateTo(const HelpSupportScreen()),
              ),
              _MenuItem(
                icon: Icons.info_outline,
                title: 'About Us',
                subtitle: 'Learn about NSSON Moto Crafter',
                onTap: () => _navigateTo(const AboutScreen()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Logout
        FadeIn(
          durationMs: 700,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              onTap: () => _showLogoutConfirmation(auth),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.logout, color: AppColors.danger, size: 20),
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.danger,
                ),
              ),
              trailing:
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildUserInfoCard(dynamic user) {
    final items = [
      {'i': Icons.email_outlined, 'v': user.email as String},
      {'i': Icons.phone_outlined, 'v': user.phone as String},
      if ((user.address as String).isNotEmpty)
        {'i': Icons.location_on_outlined, 'v': user.address as String},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(item['i'] as IconData,
                          color: AppColors.textTertiary, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item['v'] as String,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textTertiary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...items.asMap().entries.map((entry) {
            final item = entry.value;
            final isLast = entry.key == items.length - 1;
            return Column(
              children: [
                ListTile(
                  onTap: item.onTap,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, color: AppColors.primary, size: 20),
                  ),
                  title: Text(item.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  subtitle: Text(item.subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textTertiary)),
                  trailing: const Icon(Icons.chevron_right,
                      color: AppColors.textMuted),
                ),
                if (!isLast)
                  const Divider(height: 1, indent: 70, endIndent: 16),
              ],
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return FadeIn(
      key: const ValueKey('edit'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Profile',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _firstNameCtrl,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),

            const SizedBox(height: 16),
            TextFormField(
              controller: _lastNameCtrl,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _shopCtrl,
              decoration: const InputDecoration(labelText: 'Shop Name'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _addressCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _save,
                child: const Text(AppStrings.saveChanges),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              auth.logout();
            },
            child:
                const Text('Logout', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
