import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/page_title.dart';

class MidwifeChildrenPage extends StatefulWidget {
  const MidwifeChildrenPage({super.key});

  @override
  State<MidwifeChildrenPage> createState() => _MidwifeChildrenPageState();
}

class _MidwifeChildrenPageState extends State<MidwifeChildrenPage> {
  late Future<List<ChildRecord>> _childrenFuture;

  @override
  void initState() {
    super.initState();
    _childrenFuture = fetchChildren();
  }

  // 🟢 MOCK DATA
  Future<List<ChildRecord>> fetchChildren() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      ChildRecord(
        fullName: 'Juan Santos',
        motherName: 'Maria Santos',
      ),
      ChildRecord(
        fullName: 'Anna Cruz',
        motherName: 'Ana Cruz',
      ),
      ChildRecord(
        fullName: 'Leo Reyes',
        motherName: 'Liza Reyes',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ChildRecord>>(
      future: _childrenFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
              style: const TextStyle(color: AppColors.error),
            ),
          );
        }

        final children = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const PageTitle(
              title: 'Children',
              leadingIcon: Icons.child_care,
              trailingIcon: Icons.favorite,
            ),
            const SizedBox(height: 12),

            ...children.map(
              (c) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.faintWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderPrimary),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.child_friendly,
                        color: AppColors.brandPrimary),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Mother: ${c.motherName}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/* ================= MODEL ================= */

class ChildRecord {
  final String fullName;
  final String motherName;

  ChildRecord({
    required this.fullName,
    required this.motherName,
  });
}
