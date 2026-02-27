import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/customer.dart';
import '../viewmodels/customer_viewmodel.dart';

class CustomerAddEditScreen extends ConsumerStatefulWidget {
  /// null = Add mode, non-null = Edit mode
  final Customer? customer;

  const CustomerAddEditScreen({super.key, this.customer});

  @override
  ConsumerState<CustomerAddEditScreen> createState() =>
      _CustomerAddEditScreenState();
}

class _CustomerAddEditScreenState
    extends ConsumerState<CustomerAddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late bool _isActive;

  bool get _isEditMode => widget.customer != null;

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _nameCtrl    = TextEditingController(text: c?.name ?? '');
    _emailCtrl   = TextEditingController(text: c?.email ?? '');
    _phoneCtrl   = TextEditingController(text: c?.phone ?? '');
    _addressCtrl = TextEditingController(text: c?.address ?? '');
    _isActive    = c?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final customer = Customer(
      id: widget.customer?.id,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      isActive: _isActive,
    );

    final vm = ref.read(customerViewModelProvider.notifier);
    final success = _isEditMode
        ? await vm.updateCustomer(customer)
        : await vm.addCustomer(customer);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      final error = ref.read(customerViewModelProvider).error ??
          AppStrings.unknownError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(customerViewModelProvider).status == CustomerStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            _isEditMode ? AppStrings.editCustomer : AppStrings.addCustomer),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Full Name
              TextFormField(
                controller: _nameCtrl,
                validator: Validators.required,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: AppStrings.fullName,
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // Email
              TextFormField(
                controller: _emailCtrl,
                validator: Validators.email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: AppStrings.email,
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // Phone
              TextFormField(
                controller: _phoneCtrl,
                validator: Validators.phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: AppStrings.phone,
                  prefixIcon: Icon(Icons.phone_outlined),
                  counterText: '',
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // Address
              TextFormField(
                controller: _addressCtrl,
                validator: Validators.required,
                keyboardType: TextInputType.streetAddress,
                textInputAction: TextInputAction.done,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: AppStrings.address,
                  prefixIcon: Icon(Icons.location_on_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // Status toggle
              Card(
                child: SwitchListTile(
                  title: const Text(AppStrings.status),
                  subtitle: Text(
                    _isActive ? AppStrings.active : AppStrings.inactive,
                    style: TextStyle(
                      color: _isActive
                          ? AppColors.activeGreen
                          : AppColors.inactiveGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: _isActive,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _isActive = val),
                  secondary: Icon(
                    _isActive
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    color: _isActive
                        ? AppColors.activeGreen
                        : AppColors.inactiveGrey,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              // Save button
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _onSave,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textOnPrimary,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                      isLoading ? 'Saving...' : AppStrings.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
