import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/secondary_header.dart';
import '../widgets/small_description.dart';

class MotherChildGrowthPage extends StatelessWidget {
  final VoidCallback onBack;

  const MotherChildGrowthPage({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SecondaryHeader(
          title: 'Growth Statistics',
          onBack: onBack,
        ),
      ),

      body: const Center(
        child: SmallDescription(
          text: 'Growth charts will be shown here',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
