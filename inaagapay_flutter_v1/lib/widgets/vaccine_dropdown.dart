import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/vaccine_schedule.dart';

class VaccineDropdown extends StatefulWidget {
  final VaccineDefinition? value;
  final ValueChanged<VaccineDefinition> onChanged;

  const VaccineDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<VaccineDropdown> createState() => _VaccineDropdownState();
}

class _VaccineDropdownState extends State<VaccineDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _openDropdown();
    } else {
      _closeDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlay();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlay() {
    final RenderBox renderBox =
        context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;

    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closeDropdown,
        child: Stack(
          children: [
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height + 8),
                child: _VaccineDropdownList(
                  selected: widget.value,
                  onSelect: (vaccine) {
                    widget.onChanged(vaccine);
                    _closeDropdown();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.vaccines_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  widget.value?.name ?? 'Select Vaccine',
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.value == null
                        ? AppColors.textSecondary
                        : AppColors.brandPrimary,
                    fontWeight: widget.value == null
                        ? FontWeight.w400
                        : FontWeight.w600,
                  ),
                ),
              ),

              const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// DROPDOWN LIST (GROUPED BY AGE)
/// ------------------------------------------------------------
class _VaccineDropdownList extends StatelessWidget {
  final VaccineDefinition? selected;
  final ValueChanged<VaccineDefinition> onSelect;

  const _VaccineDropdownList({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: vaccineSchedule.map((group) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🧷 AGE GROUP LABEL
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: Text(
                    group.label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                ...group.vaccines.map((vaccine) {
                  final bool isSelected =
                      selected?.key == vaccine.key;

                  return InkWell(
                    onTap: () => onSelect(vaccine),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.brandPrimary.withOpacity(0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: isSelected
                                ? AppColors.brandPrimary
                                : AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              vaccine.name,
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected
                                    ? AppColors.brandPrimary
                                    : AppColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),

                          if (isSelected)
                            const Icon(
                              Icons.check,
                              size: 18,
                              color: AppColors.brandPrimary,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
