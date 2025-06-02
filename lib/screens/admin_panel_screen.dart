import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/campus_background.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CampusBackgroundScaffold(
      showOverlay: true,
      overlayOpacity: 0.1,
      appBar: AppBar(
        title: const Text('Panel Admin'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Admin Panel Screen\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
