import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FloatingAddRecordMenu extends StatefulWidget {
  final VoidCallback onAddGrowth;
  final VoidCallback onAddImmunization;

  const FloatingAddRecordMenu({
    super.key,
    required this.onAddGrowth,
    required this.onAddImmunization,
  });

  @override
  State<FloatingAddRecordMenu> createState() =>
      _FloatingAddRecordMenuState();
}

class _FloatingAddRecordMenuState extends State<FloatingAddRecordMenu>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      _isOpen ? _controller.forward() : _controller.reverse();
    });
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ScaleTransition(
      scale: _animation,
      child: FadeTransition(
        opacity: _animation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ElevatedButton.icon(
            onPressed: () {
              _toggle();
              onTap();
            },
            icon: Icon(icon, size: 20),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.faintWhite,
              foregroundColor: AppColors.brandPrimary,
              elevation: 6,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        /// OPTIONS
        if (_isOpen)
          Padding(
            padding: const EdgeInsets.only(bottom: 72),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildOption(
                  icon: Icons.show_chart_rounded,
                  label: 'Add Growth Record',
                  onTap: widget.onAddGrowth,
                ),
                _buildOption(
                  icon: Icons.vaccines_rounded,
                  label: 'Add Immunization',
                  onTap: widget.onAddImmunization,
                ),
              ],
            ),
          ),

        /// MAIN FAB
        FloatingActionButton(
          backgroundColor: AppColors.brandPrimary,
          onPressed: _toggle,
          child: AnimatedRotation(
            turns: _isOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 220),
            child: const Icon(Icons.add, size: 30),
          ),
        ),
      ],
    );
  }
}
