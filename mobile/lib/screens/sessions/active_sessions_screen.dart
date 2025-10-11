import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/empty_state.dart';

class ActiveSessionsScreen extends StatelessWidget {
  const ActiveSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesiones activas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: EmptyStateVariants.noSessions(
            onRefresh: () {},
          ),
        ),
      ),
    );
  }
}