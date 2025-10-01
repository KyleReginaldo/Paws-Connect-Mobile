import 'package:auto_route/auto_route.dart';
import 'package:cnic_scanner/cnic_scanner.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paws_connect/core/widgets/text.dart';

/// Minimal screen: scan ID and show raw extracted fields. Nothing more.
@RoutePage()
class SetUpVerificationScreen extends StatefulWidget {
  const SetUpVerificationScreen({super.key});

  @override
  State<SetUpVerificationScreen> createState() =>
      _SetUpVerificationScreenState();
}

class _SetUpVerificationScreenState extends State<SetUpVerificationScreen> {
  dynamic _result; // Raw object from cnic_scanner (CnicModel)
  bool _scanning = false;
  String? _error;
  DateTime? _lastScanStarted;

  static const _minScanInterval = Duration(
    seconds: 2,
  ); // simple debounce window

  Future<void> _scan() async {
    // Debounce: prevent starting a new scan if one is in progress or recently completed
    if (_scanning) return; // already in progress
    if (_result != null) return; // force user to Clear before rescanning
    final now = DateTime.now();
    if (_lastScanStarted != null &&
        now.difference(_lastScanStarted!) < _minScanInterval) {
      debugPrint('Scan blocked by debounce');
      return;
    }
    _lastScanStarted = now;
    setState(() {
      _scanning = true;
      _error = null;
    });
    try {
      final r = await CnicScanner().scanImage(imageSource: ImageSource.camera);
      setState(() => _result = r);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Widget _buildContent() {
    if (_error != null) {
      return _MessageBox(
        color: Colors.red.withOpacity(.08),
        border: Colors.redAccent.withOpacity(.4),
        child: PawsText('Error: $_error', color: Colors.red, fontSize: 13),
      );
    }
    if (_result == null) {
      return _MessageBox(
        child: const PawsText(
          'No scan yet. Tap the Scan ID button to start.',
          fontSize: 13,
        ),
      );
    }
    final r = _result!; // treat as CnicModel
    String? safe(String label, String? value) {
      if (value == null) return null;
      final v = value.trim();
      if (v.isEmpty) return null;
      return v;
    }

    // Access only documented getters from cnic_scanner:
    // cnicHolderName, cnicNumber, cnicIssueDate, cnicExpiryDate, cnicHolderDateOfBirth
    String? holderName;
    String? number;
    String? issueDate;
    String? expiryDate;
    String? dob;
    try {
      holderName = r.cnicHolderName;
    } catch (_) {}
    try {
      number = r.cnicNumber;
    } catch (_) {}
    try {
      issueDate = r.cnicIssueDate;
    } catch (_) {}
    try {
      expiryDate = r.cnicExpiryDate;
    } catch (_) {}
    try {
      dob = r.cnicHolderDateOfBirth;
    } catch (_) {}

    final rows = <MapEntry<String, String>>[];
    void add(String key, String? val) {
      final v = safe(key, val);
      if (v != null) rows.add(MapEntry(key.toUpperCase(), v));
    }

    add('Holder Name', holderName);
    add('Number', number);
    add('Issue Date', issueDate);
    add('Expiry Date', expiryDate);
    add('Date Of Birth', dob);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PawsText(
                'Scanned Data',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 10),
              ...rows.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 110,
                        child: PawsText(
                          e.key.replaceAll('_', ' ').toUpperCase(),
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Expanded(
                        child: PawsText(
                          e.value.isEmpty ? '-' : e.value,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.router.maybePop(_result),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Use This CnicModel'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const PawsText('Scan ID'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.maybePop(),
        ),
        actions: [
          if (_result != null)
            IconButton(
              tooltip: 'Clear',
              onPressed: () => setState(() => _result = null),
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PawsText(
              'Scan your government-issued ID. Extracted fields will appear below.',
              fontSize: 13,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _scanning ? null : _scan,
                icon: Icon(
                  _scanning
                      ? Icons.hourglass_top
                      : Icons.document_scanner_outlined,
                ),
                label: Text(
                  _result != null
                      ? 'Scan Complete (Clear to Rescan)'
                      : _scanning
                      ? 'Scanning...'
                      : 'Scan ID',
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildContent(),
          ],
        ),
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Color? border;
  const _MessageBox({required this.child, this.color, this.border});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade100,
        border: Border.all(color: border ?? Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
