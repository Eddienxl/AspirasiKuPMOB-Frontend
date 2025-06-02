import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

class SortDropdown extends StatelessWidget {
  final String selectedSort;
  final Function(String) onSortChanged;

  const SortDropdown({
    super.key,
    required this.selectedSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedSort,
          onChanged: (value) {
            if (value != null) {
              onSortChanged(value);
            }
          },
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textSecondary,
            size: 20,
          ),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          items: AppConstants.sortOptions.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getSortIcon(entry.key),
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(entry.value),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getSortIcon(String sortType) {
    switch (sortType) {
      case 'terbaru':
        return Icons.schedule;
      case 'populer':
        return Icons.trending_up;
      case 'terlama':
        return Icons.history;
      default:
        return Icons.sort;
    }
  }
}

class SortBottomSheet extends StatelessWidget {
  final String selectedSort;
  final Function(String) onSortChanged;

  const SortBottomSheet({
    super.key,
    required this.selectedSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Title
          Text(
            'Urutkan Berdasarkan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Sort options
          ...AppConstants.sortOptions.entries.map((entry) {
            final isSelected = selectedSort == entry.key;
            
            return ListTile(
              leading: Icon(
                _getSortIcon(entry.key),
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              title: Text(
                entry.value,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? const Icon(
                      Icons.check,
                      color: AppColors.primary,
                    )
                  : null,
              onTap: () {
                onSortChanged(entry.key);
                Navigator.pop(context);
              },
            );
          }),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  IconData _getSortIcon(String sortType) {
    switch (sortType) {
      case 'terbaru':
        return Icons.schedule;
      case 'populer':
        return Icons.trending_up;
      case 'terlama':
        return Icons.history;
      default:
        return Icons.sort;
    }
  }
}

class SortButton extends StatelessWidget {
  final String selectedSort;
  final Function(String) onSortChanged;

  const SortButton({
    super.key,
    required this.selectedSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => SortBottomSheet(
            selectedSort: selectedSort,
            onSortChanged: onSortChanged,
          ),
        );
      },
      icon: const Icon(Icons.sort),
      color: AppColors.textSecondary,
      tooltip: 'Urutkan',
    );
  }
}
