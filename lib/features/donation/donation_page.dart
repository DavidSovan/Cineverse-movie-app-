import 'package:cineverse/core/theme/demensions.dart';
import 'package:cineverse/features/donation/donation_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bakong_payway/flutter_bakong_payway.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DonationViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Us'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPadding,
          vertical: AppDimensions.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// Header Section
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    BorderRadius.circular(AppDimensions.cardBorderRadius),
              ),
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                children: [
                  Icon(
                    Icons.favorite,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    'Help us grow',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    'Your support helps us bring you the best movie and TV content',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.xl),

            /// Currency Selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Currency',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimensions.md),
                SegmentedButton<KHQRCurrency>(
                  segments: const [
                    ButtonSegment(
                      value: KHQRCurrency.usd,
                      label: Text('USD'),
                      icon: Icon(Icons.attach_money),
                    ),
                    ButtonSegment(
                      value: KHQRCurrency.khr,
                      label: Text('KHR'),
                      icon: Icon(Icons.money),
                    ),
                  ],
                  selected: {vm.currency},
                  onSelectionChanged: (v) {
                    HapticFeedback.selectionClick();
                    vm.setCurrency(v.first);
                  },
                  style: SegmentedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.lg,
                      vertical: AppDimensions.md,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.xl),

            /// Quick Amount Selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Select',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimensions.md),
                Wrap(
                  spacing: AppDimensions.sm,
                  runSpacing: AppDimensions.sm,
                  children: [
                    _QuickAmountChip(
                      amount: vm.currency == KHQRCurrency.usd ? 1 : 4000,
                      currency: vm.currency,
                      onTap: (amount) {
                        vm.amountController.text = amount.toString();
                        vm.generateQR();
                      },
                      isSelected: vm.amountController.text ==
                          (vm.currency == KHQRCurrency.usd ? 1 : 4000)
                              .toString(),
                    ),
                    _QuickAmountChip(
                      amount: vm.currency == KHQRCurrency.usd ? 5 : 20000,
                      currency: vm.currency,
                      onTap: (amount) {
                        vm.amountController.text = amount.toString();
                        vm.generateQR();
                      },
                      isSelected: vm.amountController.text ==
                          (vm.currency == KHQRCurrency.usd ? 5 : 20000)
                              .toString(),
                    ),
                    _QuickAmountChip(
                      amount: vm.currency == KHQRCurrency.usd ? 10 : 40000,
                      currency: vm.currency,
                      onTap: (amount) {
                        vm.amountController.text = amount.toString();
                        vm.generateQR();
                      },
                      isSelected: vm.amountController.text ==
                          (vm.currency == KHQRCurrency.usd ? 10 : 40000)
                              .toString(),
                    ),
                    _QuickAmountChip(
                      amount: vm.currency == KHQRCurrency.usd ? 20 : 80000,
                      currency: vm.currency,
                      onTap: (amount) {
                        vm.amountController.text = amount.toString();
                        vm.generateQR();
                      },
                      isSelected: vm.amountController.text ==
                          (vm.currency == KHQRCurrency.usd ? 20 : 80000)
                              .toString(),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.xl),

            /// Amount Input
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter Amount',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimensions.md),
                TextField(
                  controller: vm.amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    hintText: vm.currency == KHQRCurrency.usd
                        ? 'e.g. 5.50 USD'
                        : 'e.g. 2000 KHR',
                    prefixIcon: Icon(
                      vm.currency == KHQRCurrency.usd
                          ? Icons.attach_money
                          : Icons.money,
                    ),
                    helperText: vm.currency == KHQRCurrency.usd
                        ? 'Minimum: \$1.00'
                        : 'Minimum: 4000៛',
                    helperStyle: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.xl),

            /// Generate QR Button
            SizedBox(
              height: AppDimensions.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: vm.loading
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        vm.generateQR();
                      },
                icon: vm.loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.qr_code),
                label: Text(vm.loading ? 'Generating...' : 'Generate QR Code'),
              ),
            ),

            const SizedBox(height: AppDimensions.xl),

            /// Loading State
            if (vm.loading)
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: AppDimensions.md),
                    Text(
                      'Generating QR Code...',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

            /// Error State
            if (vm.error != null)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.cardBorderRadius),
                ),
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Text(
                        vm.error!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: vm.clearError,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Dismiss',
                    ),
                  ],
                ),
              ),

            /// QR Code Display
            if (vm.qrData != null) ...[
              const SizedBox(height: AppDimensions.xl),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.surface,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.cardBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: AppDimensions.sm),
                        Text(
                          'Scan to Pay',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.borderRadius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(AppDimensions.md),
                      child: QrImageView(
                        data: vm.qrData!,
                        size: 280,
                        backgroundColor: Colors.white,
                      ),
                    ),

                    /// Circular Timer for QR Expiration
                    if (vm.qrRemainingSeconds != null)
                      Column(
                        children: [
                          const SizedBox(height: AppDimensions.lg),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: CircularProgressIndicator(
                                  value: vm.qrRemainingSeconds! / 120,
                                  strokeWidth: 4,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    vm.qrRemainingSeconds! <= 10
                                        ? Theme.of(context).colorScheme.error
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              Text(
                                '${vm.qrRemainingSeconds}s',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: vm.qrRemainingSeconds! <= 10
                                          ? Theme.of(context).colorScheme.error
                                          : null,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.sm),
                          Text(
                            vm.qrRemainingSeconds! <= 10
                                ? 'Expiring soon!'
                                : 'Time remaining',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ),

                    const SizedBox(height: AppDimensions.lg),

                    /// MD5 Display
                    if (vm.md5 != null)
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.borderRadius),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.md,
                          vertical: AppDimensions.sm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fingerprint,
                              size: 16,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            const SizedBox(width: AppDimensions.xs),
                            Text(
                              'MD5: ${vm.md5}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppDimensions.xl),
          ],
        ),
      ),
    );
  }
}

/// Quick Amount Chip Widget
class _QuickAmountChip extends StatelessWidget {
  final double amount;
  final KHQRCurrency currency;
  final Function(double) onTap;
  final bool isSelected;

  const _QuickAmountChip({
    required this.amount,
    required this.currency,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        currency == KHQRCurrency.usd
            ? '\$${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2)}'
            : '${amount.toStringAsFixed(0)}៛',
      ),
      selected: isSelected,
      onSelected: (_) {
        HapticFeedback.selectionClick();
        onTap(amount);
      },
      avatar: Icon(
        currency == KHQRCurrency.usd ? Icons.attach_money : Icons.money,
        size: 18,
      ),
      showCheckmark: false,
    );
  }
}
