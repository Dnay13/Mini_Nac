import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/empty_state.dart';

class QRHistoryScreen extends StatelessWidget {
  const QRHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de QR'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: EmptyStateVariants.noQRCodes(
            onGenerateQR: () {
              // TODO: Navigate to generate QR
            },
          ),
        ),
      ),
    );
  }
}