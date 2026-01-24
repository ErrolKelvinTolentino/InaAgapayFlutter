import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ComparisonCard extends StatelessWidget {
  final int week;

  const ComparisonCard({
    super.key,
    required this.week,
  });

  // 🧠 CENTRALIZED DATA SOURCE (easy to edit later)
  static const Map<int, Map<String, String>> _comparisonData = {
    4:  {'label': 'Your baby is as small as', 'name': 'A Rice Grain', 'image': 'rice.png'},
    5:  {'label': 'Your baby is about the size of', 'name': 'A Green Pea', 'image': 'pea.png'},
    6:  {'label': 'Your baby is about the size of', 'name': 'A Coffee Bean', 'image': 'coffee.png'},
    7:  {'label': 'Your baby is now as big as', 'name': 'A Blueberry', 'image': 'blueberry.png'},
    8:  {'label': 'Your baby is now as big as', 'name': 'A Raspberry', 'image': 'raspberry.png'},
    9:  {'label': 'Your baby is now as big as', 'name': 'A Cherry', 'image': 'cherry.png'},
    10: {'label': 'Your baby is now as big as', 'name': 'A Strawberry', 'image': 'strawberry.png'},
    11: {'label': 'Your baby is about the size of', 'name': 'A Lime', 'image': 'lime.png'},
    12: {'label': 'Your baby is about the size of', 'name': 'A Plum', 'image': 'plum.png'},
    13: {'label': 'Your baby is about the size of', 'name': 'A Lemon', 'image': 'lemon.png'},
    14: {'label': 'Your baby is about the size of', 'name': 'A Peach', 'image': 'peach.png'},
    15: {'label': 'Your baby is about the size of', 'name': 'An Apple', 'image': 'apple.png'},
    16: {'label': 'Your baby is about the size of', 'name': 'An Avocado', 'image': 'avocado.png'},
    17: {'label': 'Your baby is about the size of', 'name': 'A Pear', 'image': 'pear.png'},
    18: {'label': 'Your baby is about the size of', 'name': 'A Bell Pepper', 'image': 'pepper.png'},
    19: {'label': 'Your baby is about the size of', 'name': 'A Mango', 'image': 'mango.png'},
    20: {'label': 'Your baby is about the size of', 'name': 'A Banana', 'image': 'banana.png'},
    21: {'label': 'Your baby is about the size of', 'name': 'A Carrot', 'image': 'carrot.png'},
    22: {'label': 'Your baby is about the size of', 'name': 'An Orange', 'image': 'orange.png'},
    23: {'label': 'Your baby is about the size of', 'name': 'A Pomelo', 'image': 'pomelo.png'},
    24: {'label': 'Your baby is about the size of', 'name': 'An Ear of Corn', 'image': 'corn.png'},
    25: {'label': 'Your baby is about the size of', 'name': 'A Cucumber', 'image': 'cucumber.png'},
    26: {'label': 'Your baby is about the size of', 'name': 'An Eggplant', 'image': 'eggplant.png'},
    27: {'label': 'Your baby is about the size of', 'name': 'A Cauliflower', 'image': 'cauliflower.png'},
    28: {'label': 'Your baby is about the size of', 'name': 'A Large Carrot', 'image': 'largecarrot.png'},
    29: {'label': 'Your baby is about the size of', 'name': 'A Sweet Potato', 'image': 'potato.png'},
    30: {'label': 'Your baby is about the size of', 'name': 'A Cabbage', 'image': 'cabbage.png'},
    31: {'label': 'Your baby is about the size of', 'name': 'A Coconut', 'image': 'coconut.png'},
    32: {'label': 'Your baby is about the size of', 'name': 'A Large White Onion', 'image': 'onion.png'},
    33: {'label': 'Your baby is about the size of', 'name': 'A Pineapple', 'image': 'pineapple.png'},
    34: {'label': 'Your baby is about the size of', 'name': 'A Melon', 'image': 'melon.png'},
    35: {'label': 'Your baby is about the size of', 'name': 'A Large Melon', 'image': 'melon.png'},
    36: {'label': 'Your baby is about the size of', 'name': 'A Lettuce Head', 'image': 'lettuce.png'},
    37: {'label': 'Your baby is about the size of', 'name': 'A Bunch of Spinach', 'image': 'spinach.png'},
    38: {'label': 'Your baby is about the size of', 'name': 'Green Onions', 'image': 'greenonions.png'},
    39: {'label': 'Your baby is about the size of', 'name': 'A Mini Watermelon', 'image': 'watermelon.png'},
    40: {'label': 'Your baby is about the size of', 'name': 'A Small Pumpkin', 'image': 'pumpkin.png'},
  };

  @override
  Widget build(BuildContext context) {
    final data = _comparisonData[week];

    if (data == null) {
      return const SizedBox.shrink(); // safety fallback
    }

    return Container(
      height: 96,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/images/pinkbg.png'),
          fit: BoxFit.cover,
          opacity: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        child: Row(
          children: [
            // 📝 Text
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${data['label']}\n',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                    TextSpan(
                      text: data['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandText,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 16),

            // 🫐 Image
            Image.asset(
              'assets/images/${data['image']}',
              height: 72,
              width: 72,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
