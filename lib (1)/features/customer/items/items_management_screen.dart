import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';

class ItemsManagementScreen extends StatefulWidget {
  const ItemsManagementScreen({super.key});

  @override
  State<ItemsManagementScreen> createState() => _ItemsManagementScreenState();
}

class _ItemsManagementScreenState extends State<ItemsManagementScreen> {
  final List<Map<String, dynamic>> _items = [];

  void _addItem(String category, IconData icon) {
    setState(() {
      _items.add({
        'category': category,
        'icon': icon,
        'quantity': 1,
        'weight': 'Medium',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text("Manage Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Category Selection
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _CategoryChip(icon: Icons.chair_rounded, label: "Furniture", onTap: () => _addItem("Furniture", Icons.chair_rounded)),
                _CategoryChip(icon: Icons.inventory_2_rounded, label: "Boxes", onTap: () => _addItem("Box", Icons.inventory_2_rounded)),
                _CategoryChip(icon: Icons.tv_rounded, label: "Electronics", onTap: () => _addItem("Electronics", Icons.tv_rounded)),
                _CategoryChip(icon: Icons.kitchen_rounded, label: "Kitchen", onTap: () => _addItem("Kitchen", Icons.kitchen_rounded)),
                _CategoryChip(icon: Icons.more_horiz_rounded, label: "Other", onTap: () => _addItem("Other", Icons.more_horiz_rounded)),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "ADDED ITEMS",
                style: TextStyle(color: AppConstants.textSecondary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ),
          
          // Items List
          Expanded(
            child: _items.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return _ItemTile(
                        item: item,
                        onDelete: () => setState(() => _items.removeAt(index)),
                        onUpdateQty: (val) => setState(() => item['quantity'] = val),
                      );
                    },
                  ),
          ),
          
          // Bottom Summary and Button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppConstants.secondaryColor.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Items", style: TextStyle(color: AppConstants.textSecondary, fontSize: 14)),
                      Text("${_items.fold<int>(0, (sum, item) => sum + (item['quantity'] as int))} Items", 
                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _items.isEmpty ? null : () {
                       context.pop();
                    },
                    child: const Text("Save and Return"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, color: Colors.white.withValues(alpha: 0.1), size: 100),
          const SizedBox(height: 20),
          Text(
            "No items added yet",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            "Select a category above to start",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CategoryChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppConstants.primaryColor, size: 24),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDelete;
  final Function(int) onUpdateQty;

  const _ItemTile({required this.item, required this.onDelete, required this.onUpdateQty});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item['icon'] as IconData, color: AppConstants.primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['category'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(item['weight'] as String, style: const TextStyle(color: AppConstants.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Row(
            children: [
              _QtyBtn(icon: Icons.remove, onTap: () {
                if (item['quantity'] > 1) onUpdateQty(item['quantity'] - 1);
              }),
              SizedBox(
                width: 40,
                child: Center(
                  child: Text("${item['quantity']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              _QtyBtn(icon: Icons.add, onTap: () => onUpdateQty(item['quantity'] + 1)),
              const SizedBox(width: 12),
              IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20)),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}
