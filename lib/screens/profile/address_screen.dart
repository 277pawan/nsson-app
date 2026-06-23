import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/custom_snack_bars.dart';
import '../../core/widgets/animations.dart';
import '../../providers/address_provider.dart';

class AddressScreen extends StatefulWidget {
  /// If true, tapping an address returns it (for checkout selection).
  final bool selectionMode;

  const AddressScreen({super.key, this.selectionMode = false});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().loadAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddressProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.selectionMode ? 'Select Address' : 'My Addresses',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddressForm(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.addresses.isEmpty
              ? _buildEmpty()
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.addresses.length,
                  itemBuilder: (context, index) {
                    final addr = provider.addresses[index];
                    return StaggerAnimation(
                      index: index,
                      child: _buildAddressCard(context, addr, provider),
                    );
                  },
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.location_off_outlined,
                  color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'No saved addresses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Add an address for faster checkout',
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(
      BuildContext context, Address addr, AddressProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: addr.isDefault
            ? Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: widget.selectionMode ? () => Navigator.pop(context, addr) : null,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: addr.addressType == 'office'
                          ? AppColors.infoLight
                          : AppColors.primaryBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      addr.addressType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: addr.addressType == 'office'
                            ? AppColors.info
                            : AppColors.primary,
                      ),
                    ),
                  ),
                  if (addr.isDefault) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'DEFAULT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  PopupMenuButton<String>(
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      if (!addr.isDefault)
                        const PopupMenuItem(
                            value: 'default', child: Text('Set as Default')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete',
                            style: TextStyle(color: AppColors.danger)),
                      ),
                    ],
                    onSelected: (action) =>
                        _handleAction(action, addr, provider),
                    icon: const Icon(Icons.more_vert,
                        color: AppColors.textMuted, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                addr.fullName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                addr.displayShort,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                addr.phone,
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAction(
      String action, Address addr, AddressProvider provider) async {
    switch (action) {
      case 'edit':
        _showAddressForm(context, existing: addr);
        break;
      case 'default':
        await provider.setDefault(addr.id);
        break;
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Address'),
            content:
                const Text('Are you sure you want to delete this address?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete',
                    style: TextStyle(color: AppColors.danger)),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await provider.deleteAddress(addr.id);
        }
        break;
    }
  }

  void _showAddressForm(BuildContext context, {Address? existing}) {
    final nameCtrl = TextEditingController(text: existing?.fullName ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final streetCtrl = TextEditingController(text: existing?.street ?? '');
    final cityCtrl = TextEditingController(text: existing?.city ?? '');
    final stateCtrl = TextEditingController(text: existing?.state ?? '');
    final zipCtrl = TextEditingController(text: existing?.zipCode ?? '');
    String addressType = existing?.addressType ?? 'home';
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Form(
            key: formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  existing != null ? 'Edit Address' : 'Add New Address',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),

                // Address type toggle
                Row(
                  children: ['home', 'office', 'other'].map((type) {
                    final selected = addressType == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(type[0].toUpperCase() + type.substring(1)),
                        selected: selected,
                        selectedColor: AppColors.primaryBg,
                        onSelected: (_) =>
                            setSheetState(() => addressType = type),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined, size: 20),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: streetCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Street Address',
                    prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: cityCtrl,
                        decoration: const InputDecoration(labelText: 'City'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: stateCtrl,
                        decoration: const InputDecoration(labelText: 'State'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: zipCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'PIN Code'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final provider = context.read<AddressProvider>();
                      final addr = Address(
                        fullName: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        street: streetCtrl.text.trim(),
                        city: cityCtrl.text.trim(),
                        state: stateCtrl.text.trim(),
                        zipCode: zipCtrl.text.trim(),
                        addressType: addressType,
                      );

                      bool success;
                      if (existing != null) {
                        success =
                            await provider.updateAddress(existing.id, addr);
                      } else {
                        success = await provider.addAddress(addr);
                      }

                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);

                      if (success) {
                        CustomSnackBars.showGlassSnackBar(
                          context: context,
                          message: existing != null
                              ? 'Address updated'
                              : 'Address added',
                          duration: const Duration(seconds: 2),
                        );
                      } else {
                        CustomSnackBars.showGlassSnackBar(
                          context: context,
                          message: provider.error ?? 'Failed to save address',
                          duration: const Duration(seconds: 3),
                        );
                      }
                    },
                    child: Text(
                        existing != null ? 'Update Address' : 'Save Address'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
