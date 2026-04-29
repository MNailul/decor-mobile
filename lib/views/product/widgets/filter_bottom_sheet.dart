import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/bounce_tap.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  RangeValues _priceRange = const RangeValues(200, 3500);
  String _selectedMaterial = 'Oak';
  String _selectedStyle = 'Modern';

  final List<String> _materials = ['Oak', 'Walnut', 'Fabric', 'Metal'];
  final List<String> _styles = ['Minimalist', 'Modern', 'Classic'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120), // Space for bottom button
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BounceTap(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: AppColors.primaryColor),
                      ),
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      BounceTap(
                        onTap: () {
                          setState(() {
                            _priceRange = const RangeValues(200, 3500);
                            _selectedMaterial = 'Oak';
                            _selectedStyle = 'Modern';
                          });
                        },
                        child: const Text(
                          'RESET',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                // Price Range
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Price Range', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        '\$${_priceRange.start.toInt()} — \$${_priceRange.end.toInt()}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.primaryColor,
                    inactiveTrackColor: Colors.grey.shade200,
                    thumbColor: Colors.white,
                    overlayColor: AppColors.primaryColor.withOpacity(0.1),
                    trackHeight: 4,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 5000,
                      onChanged: (values) {
                        setState(() {
                          _priceRange = values;
                        });
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$0', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                      Text('\$5,000+', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Material
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text('Material', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _materials.map((m) => _buildChip(m, _selectedMaterial == m, (val) {
                      setState(() => _selectedMaterial = m);
                    })).toList(),
                  ),
                ),
                const SizedBox(height: 40),

                // Style
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text('Style', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _styles.map((s) => _buildChip(s, _selectedStyle == s, (val) {
                      setState(() => _selectedStyle = s);
                    })).toList(),
                  ),
                ),
                const SizedBox(height: 40),

                // Featured Collections
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text('Featured Collections', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _buildCollectionImage('https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=200&q=80'),
                      const SizedBox(width: 12),
                      _buildCollectionImage('https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=200&q=80'),
                      const SizedBox(width: 12),
                      _buildCollectionImage('https://images.unsplash.com/photo-1505693314120-0d443867891c?w=200&q=80'),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          
          // Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.9),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'priceRange': _priceRange,
                      'material': _selectedMaterial,
                      'style': _selectedStyle,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Apply Filter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, Function(bool) onSelected) {
    return BounceTap(
      onTap: () => onSelected(!isSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade200,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionImage(String url) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
