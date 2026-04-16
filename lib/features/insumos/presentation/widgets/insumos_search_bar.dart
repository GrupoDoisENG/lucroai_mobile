import 'package:flutter/material.dart';

class InsumosSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onAdd;

  const InsumosSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF131313),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF1D1D1D),
              ),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: Color(0xFF6F6F6F),
                  size: 20,
                ),
                hintText: 'Buscar insumo...',
                hintStyle: TextStyle(
                  color: Color(0xFF6F6F6F),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 44,
          height: 44,
          child: ElevatedButton(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B3D),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Icon(Icons.add, size: 20),
          ),
        ),
      ],
    );
  }
}