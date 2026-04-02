import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class VehicleType {
  final String id;
  final String name;
  final String icon;
  final double price;

  VehicleType({
    required this.id,
    required this.name,
    required this.icon,
    required this.price,
  });
}

class VehicleSelectorWidget extends StatefulWidget {
  final Function(VehicleType) onSelected;
  const VehicleSelectorWidget({super.key, required this.onSelected});

  @override
  State<VehicleSelectorWidget> createState() => _VehicleSelectorWidgetState();
}

class _VehicleSelectorWidgetState extends State<VehicleSelectorWidget> {
  String _selectedId = 'bike';

  final List<VehicleType> _vehicles = [
    VehicleType(id: 'bike', name: 'Bike Loader', icon: '📦', price: 200),
    VehicleType(id: 'small', name: 'Small Loader', icon: '🛻', price: 350),
    VehicleType(id: 'mini', name: 'Mini Truck', icon: '🚚', price: 450),
    VehicleType(id: 'large', name: 'Large Truck', icon: '🚛', price: 900),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            "CHOOSE VEHICLE",
            style: TextStyle(
              color: AppConstants.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = _vehicles[index];
              final isSelected = _selectedId == vehicle.id;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedId = vehicle.id);
                  widget.onSelected(vehicle);
                },
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppConstants.primaryColor : AppConstants.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppConstants.primaryColor : Colors.white12,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(vehicle.icon, style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 4),
                      Text(
                        vehicle.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppConstants.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Rs. ${vehicle.price.toInt()}",
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : AppConstants.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
