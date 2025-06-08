import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

class CategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        if (categoryProvider.isLoading) {
          return const SizedBox(
            height: 40,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final categories = ['semua', ...categoryProvider.categories.map((c) => c.id.toString())];
        
        return SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final categoryId = categories[index];
              final isSelected = selectedCategory == categoryId;
              
              String displayName;
              String emoji;
              
              if (categoryId == 'semua') {
                displayName = 'Semua';
                emoji = '📋';
              } else {
                final id = int.parse(categoryId);
                final category = categoryProvider.getCategoryById(id);
                displayName = category?.nama ?? AppConstants.getCategoryName(id);
                emoji = category?.emoji ?? AppConstants.getCategoryEmoji(id);
              }

              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : 8,
                  right: index == categories.length - 1 ? 0 : 0,
                ),
                child: FilterChip(
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      onCategoryChanged(categoryId);
                    }
                  },
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        emoji,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.white,
                  selectedColor: categoryId == 'semua' 
                      ? AppColors.primary 
                      : AppColors.getCategoryColor(
                          categoryId == 'semua' ? 1 : int.parse(categoryId)
                        ),
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: isSelected 
                        ? (categoryId == 'semua' 
                            ? AppColors.primary 
                            : AppColors.getCategoryColor(
                                categoryId == 'semua' ? 1 : int.parse(categoryId)
                              ))
                        : AppColors.border,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class CategoryDropdown extends StatelessWidget {
  final String? selectedCategory;
  final Function(String?) onCategoryChanged;
  final String hint;
  final bool showAllOption;

  const CategoryDropdown({
    super.key,
    this.selectedCategory,
    required this.onCategoryChanged,
    this.hint = 'Pilih Kategori',
    this.showAllOption = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        if (categoryProvider.isLoading) {
          return Container(
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final categories = categoryProvider.categories;
        
        return DropdownButtonFormField<String>(
          value: selectedCategory,
          onChanged: onCategoryChanged,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          items: [
            if (showAllOption)
              const DropdownMenuItem<String>(
                value: 'semua',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('📋', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 8),
                    Text('Semua Kategori'),
                  ],
                ),
              ),
            ...categories.map((category) {
              return DropdownMenuItem<String>(
                value: category.id.toString(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.emoji ?? AppConstants.getCategoryEmoji(category.id),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        category.nama,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class CategoryFilterDropdown extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const CategoryFilterDropdown({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        if (categoryProvider.isLoading) {
          return Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final categories = ['semua', ...categoryProvider.categories.map((c) => c.id.toString())];

        return Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
            value: selectedCategory,
            onChanged: (value) {
              if (value != null) {
                onCategoryChanged(value);
              }
            },
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            elevation: 8,
            padding: const EdgeInsets.symmetric(horizontal: 16),
              selectedItemBuilder: (context) {
                return categories.map((categoryId) {
                  String itemDisplayName;
                  String itemEmoji;

                  if (categoryId == 'semua') {
                    itemDisplayName = 'Semua Kategori';
                    itemEmoji = '📋';
                  } else {
                    final id = int.parse(categoryId);
                    final category = categoryProvider.getCategoryById(id);
                    itemDisplayName = category?.nama ?? AppConstants.getCategoryName(id);
                    itemEmoji = category?.emoji ?? AppConstants.getCategoryEmoji(id);
                  }

                  return Row(
                    children: [
                      Text(
                        itemEmoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          itemDisplayName,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Aktif',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
              items: categories.map((categoryId) {
                String itemDisplayName;
                String itemEmoji;

                if (categoryId == 'semua') {
                  itemDisplayName = 'Semua Kategori';
                  itemEmoji = '📋';
                } else {
                  final id = int.parse(categoryId);
                  final category = categoryProvider.getCategoryById(id);
                  itemDisplayName = category?.nama ?? AppConstants.getCategoryName(id);
                  itemEmoji = category?.emoji ?? AppConstants.getCategoryEmoji(id);
                }

                final isSelected = selectedCategory == categoryId;

                return DropdownMenuItem<String>(
                  value: categoryId,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          itemEmoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            itemDisplayName,
                            style: TextStyle(
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
