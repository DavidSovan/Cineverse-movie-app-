import 'package:cineverse/core/theme/colors.dart';
import 'package:cineverse/core/theme/demensions.dart';
import 'package:cineverse/core/theme/text_styles.dart';
import 'package:cineverse/features/donation/donation_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bakong_payway/flutter_bakong_payway.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DonationViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
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
                  onSelectionChanged: (v) => vm.setCurrency(v.first),
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.xl),

            /// Generate QR Button
            SizedBox(
              height: AppDimensions.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: vm.loading ? null : vm.generateQR,
                icon: const Icon(Icons.qr_code),
                label: const Text('Generate QR Code'),
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
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
                ),
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Text(
                        vm.error!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

            /// QR Code Display
            if (vm.qrData != null) ...[
              const SizedBox(height: AppDimensions.xl),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
                ),
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  children: [
                    Text(
                      'Scan to Pay',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                      ),
                      padding: const EdgeInsets.all(AppDimensions.md),
                      child: QrImageView(
                        data: vm.qrData!,
                        size: 280,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    if (vm.md5 != null)
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.md,
                          vertical: AppDimensions.sm,
                        ),
                        child: Text(
                          'MD5: ${vm.md5}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
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
