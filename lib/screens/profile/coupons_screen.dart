import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/coupon_provider.dart';
import '../../data/models.dart';
class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});
  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}
class _CouponsScreenState extends State<CouponsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CouponProvider>().fetchCoupons();
    });
  }
  Future<void> _refreshCoupons() async {
    await context.read<CouponProvider>().fetchCoupons();
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Coupons & Offers',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textTertiary,
            indicatorColor: AppColors.primary,
            labelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 15),
            unselectedLabelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 15),
            tabs: const [
              Tab(text: 'Public Offers'),
              Tab(text: 'My Coupons'),
            ],
          ),
        ),
        body: Consumer<CouponProvider>(
          builder: (context, provider, _) {
            if (provider.loading && provider.publicCoupons.isEmpty && provider.privateCoupons.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return TabBarView(
              children: [
                _buildCouponList(provider.publicCoupons, 'No public offers available right now.'),
                _buildCouponList(provider.privateCoupons, 'No private coupons assigned to you.'),
              ],
            );
          },
        ),
      ),
    );
  }
  Widget _buildCouponList(List<AppCoupon> coupons, String emptyMessage) {
    if (coupons.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshCoupons,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: EmptyState(
              icon: Icons.local_offer_outlined,
              title: 'No Coupons Found',
              subtitle: emptyMessage,
            ),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _refreshCoupons,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: coupons.length,
        itemBuilder: (context, idx) {
          final coupon = coupons[idx];
          return StaggerAnimation(
            index: idx,
            child: _CouponCard(
              coupon: coupon,
              onApply: coupon.usable && !coupon.isUsed
                  ? () => Navigator.pushNamed(
                        context,
                        '/checkout',
                        arguments: {'couponCode': coupon.code},
                      )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
class _CouponCard extends StatelessWidget {
  final AppCoupon coupon;
  final VoidCallback? onApply;
  const _CouponCard({required this.coupon, this.onApply});
  @override
  Widget build(BuildContext context) {
    final bool isPercentage = coupon.discountType == 'percentage';
    final String discountStr = isPercentage
        ? '${coupon.discountValue.toStringAsFixed(0)}%'
        : 'Rs ${coupon.discountValue.toStringAsFixed(0)}';
    // Determine badge and color theme based on status/usable
    Color primaryColor = AppColors.primary;
    Color secondaryColor = AppColors.primaryBg;
    if (coupon.status == 'expired' || coupon.status == 'exhausted' || coupon.isUsed) {
      primaryColor = AppColors.textTertiary;
      secondaryColor = AppColors.borderLight;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Left Discount Strip
            Container(
              width: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    discountStr,
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'OFF',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            // Dotted Separator
            CustomPaint(
              size: const Size(1, double.infinity),
              painter: _DottedLinePainter(color: AppColors.border),
            ),
            // Right Coupon Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Coupon Code
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: secondaryColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.3),
                              style: BorderStyle.solid,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            coupon.code,
                            style: GoogleFonts.spaceGrotesk(
                              color: primaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        // Action Button
                        if (coupon.usable && !coupon.isUsed)
                          FilledButton(
                            onPressed: onApply ?? () {
                              Clipboard.setData(ClipboardData(text: coupon.code));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Coupon code "${coupon.code}" copied!'),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(70, 34),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                            ),
                            child: Text(onApply != null ? 'Use' : 'Copy'),
                          )
                        else
                          // Expiry / Used status badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.dangerLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              coupon.isUsed ? 'USED' : coupon.status.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.danger,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Title & Description
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coupon.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          coupon.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    // Min Spend & Expiry
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Min Spend: Rs ${coupon.minOrderAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (coupon.endDate != null)
                          Text(
                            'Expiry: ${_formatDate(coupon.endDate!)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                      ],
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
  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return isoString.split('T').first;
    }
  }
}
class _DottedLinePainter extends CustomPainter {
  final Color color;
  _DottedLinePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const double dashHeight = 5;
    const double dashSpace = 4;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
