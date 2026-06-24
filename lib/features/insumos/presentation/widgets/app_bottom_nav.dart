import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavItemData> _items = [
    _NavItemData(label: 'Home', icon: Icons.grid_view_rounded),
    _NavItemData(label: 'Insumos', icon: Icons.inventory_2_outlined),
    _NavItemData(label: 'Receitas', icon: Icons.restaurant_menu_outlined),
    _NavItemData(label: 'Custos', icon: Icons.calculate_outlined),
    _NavItemData(label: 'Vendas', icon: Icons.show_chart_rounded),
    _NavItemData(label: 'Estoque', icon: Icons.inventory_outlined),
    _NavItemData(label: 'Produções', icon: Icons.precision_manufacturing_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF050505),
        border: Border(top: BorderSide(color: Color(0xFF171717), width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 12),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final isSelected = index == currentIndex;

            return Expanded(
              child: InkWell(
                onTap: () => onTap(index),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 22,
                        color: isSelected
                            ? const Color(0xFFFF6B3D)
                            : const Color(0xFF8A8A8A),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFFFF6B3D)
                              : const Color(0xFF8A8A8A),
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final IconData icon;

  const _NavItemData({required this.label, required this.icon});
}
