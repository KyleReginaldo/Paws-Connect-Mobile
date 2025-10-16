import 'package:flutter/material.dart';

import '../theme/paws_theme.dart';

/// Example of how to use the new PawsBottomSheet utility
class ExampleBottomSheetUsage {
  /// Method 1: Simple usage with PawsBottomSheet.show()
  static void showSimpleBottomSheet(BuildContext context) {
    PawsBottomSheet.show(
      context: context,
      title: 'Simple Bottom Sheet',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.pets),
            title: Text('Example Item 1'),
            subtitle: Text('This is a simple example'),
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text('Example Item 2'),
            subtitle: Text('With clean styling'),
          ),
          SizedBox(height: 16),
          Text('Your content goes here!'),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Method 2: Gradient style bottom sheet
  static void showGradientBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => PawsBottomSheet.gradientContainer(
        title: 'Premium Style Sheet',
        onClose: () => Navigator.of(context).pop(),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, size: 48, color: PawsColors.primary),
            SizedBox(height: 16),
            Text(
              'This has a beautiful gradient background!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(onPressed: null, child: Text('Example Button')),
          ],
        ),
      ),
    );
  }

  /// Method 3: Custom container with specific styling
  static void showCustomBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PawsBottomSheet.container(
        title: 'Custom Sheet',
        backgroundColor: Colors.white,
        showDragHandle: true,
        padding: const EdgeInsets.all(24),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PawsColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Custom styled content area',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PawsColors.primary,
                  ),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Method 4: Address selection bottom sheet (like in your home screen)
  static void showAddressBottomSheet(
    BuildContext context,
    List<String> addresses,
  ) {
    PawsBottomSheet.show(
      context: context,
      title: 'Select Address',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...addresses.map(
            (address) => ListTile(
              leading: const Icon(Icons.location_on, color: PawsColors.primary),
              title: Text(address),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).pop();
                // Handle address selection
              },
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle add new address
            },
            icon: const Icon(Icons.add),
            label: const Text('Add New Address'),
          ),
        ],
      ),
    );
  }
}
