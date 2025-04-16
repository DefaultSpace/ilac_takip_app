import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animations/animations.dart';
import '../providers/medicine_provider.dart';
import '../screens/settings_screen.dart';
import '../screens/logs_screen.dart';
import '../screens/add_medicine_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/family_members_screen.dart';
import '../utils/app_theme.dart';
import '../models/medicine_model.dart'; // Medicine model import eklendi

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    // Verileri yükle
    Future.microtask(() {
      Provider.of<MedicineProvider>(context, listen: false).loadData();
      _animationController.forward();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/images/medicine_logo.svg',
              height: 32,
              width: 32,
            ),
            const SizedBox(width: 12),
            const Text('İlaç Takip'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Ayarlar',
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const SettingsScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'İşlem Geçmişi',
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const LogsScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
        ],
        elevation: 0,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildMedicineList(),
          const CalendarScreen(),
          const StatisticsScreen(),
          const FamilyMembersScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication),
            label: 'İlaçlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Takvim',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'İstatistik',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Aile',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0 ? OpenContainer(
        transitionDuration: const Duration(milliseconds: 500),
        openBuilder: (context, _) => const AddMedicineScreen(),
        closedElevation: 6,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        closedColor: AppTheme.accentColor,
        closedBuilder: (context, openContainer) => Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ) : null,
    );
  }

  Widget _buildMedicineList() {
    final theme = Theme.of(context);
    
    return Consumer<MedicineProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.medicines.isEmpty) {
          return FadeTransition(
            opacity: _animationController,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/medicine_logo.svg',
                    height: 120,
                    width: 120,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Henüz ilaç eklenmemiş',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'İlaçlarınızı takip etmek için ekleyin',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const AddMedicineScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('İlaç Ekle'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.medicines.length,
              itemBuilder: (context, index) {
                final medicine = provider.medicines[index];
                final isLowStock = medicine.quantity <= 1;
                
                // Her kart için ayrı bir animasyon zamanlaması
                final itemAnimation = Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      index / provider.medicines.length * 0.7,
                      (index + 1) / provider.medicines.length * 0.7 + 0.3,
                      curve: Curves.easeOutQuart,
                    ),
                  ),
                );

                return SlideTransition(
                  position: itemAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildMedicineCard(context, medicine, isLowStock),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMedicineCard(BuildContext context, Medicine medicine, bool isLowStock) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
        border: isLowStock
            ? Border.all(color: AppTheme.errorColor, width: 2)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showMedicineDetails(context, medicine),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isLowStock
                              ? AppTheme.errorColor.withOpacity(0.1)
                              : AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.medication,
                          color: isLowStock
                              ? AppTheme.errorColor
                              : AppTheme.primaryColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medicine.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isLowStock
                                    ? AppTheme.errorColor
                                    : AppTheme.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 16,
                                  color: isLowStock
                                      ? AppTheme.errorColor
                                      : AppTheme.textSecondaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Kalan miktar: ${medicine.quantity}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isLowStock
                                        ? AppTheme.errorColor
                                        : AppTheme.textSecondaryColor,
                                    fontWeight: isLowStock
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                            tooltip: 'Düzenle',
                            onPressed: () {
                              _showEditDialog(context, medicine);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                            tooltip: 'Sil',
                            onPressed: () {
                              _showDeleteConfirmation(context, medicine);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (isLowStock) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: AppTheme.errorColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'İlacı yazdırmayı unutmayın!',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.errorColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMedicineDetails(BuildContext context, Medicine medicine) {
    final theme = Theme.of(context);
    final isLowStock = medicine.quantity <= 1;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isLowStock
                        ? AppTheme.errorColor.withOpacity(0.1)
                        : AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.medication,
                    color: isLowStock
                        ? AppTheme.errorColor
                        : AppTheme.primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine.name,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isLowStock
                              ? AppTheme.errorColor
                              : AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Eklenme tarihi: ${_formatDate(medicine.addedDate)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailItem(
              context,
              icon: Icons.inventory_2_outlined,
              title: 'Kalan miktar',
              value: medicine.quantity.toString(),
              isWarning: isLowStock,
            ),
            const SizedBox(height: 16),
            if (isLowStock) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.errorColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'İlacınız tükenmek üzere! Lütfen yeni reçete yazdırmayı unutmayın.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditDialog(context, medicine);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Düzenle'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(context, medicine);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Sil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    bool isWarning = false,
  }) {
    final theme = Theme.of(context);
    final color = isWarning ? AppTheme.errorColor : AppTheme.primaryColor;
    
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isWarning
                    ? AppTheme.errorColor
                    : AppTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day.$month.$year';
  }

  void _showEditDialog(BuildContext context, Medicine medicine) {
    final TextEditingController nameController = TextEditingController(text: medicine.name);
    final TextEditingController quantityController = TextEditingController(text: medicine.quantity.toString());
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlaç Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'İlaç Adı',
                prefixIcon: Icon(Icons.medication),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Miktar',
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'İptal',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final quantity = int.tryParse(quantityController.text.trim()) ?? 0;

              if (name.isNotEmpty && quantity > 0) {
                final updatedMedicine = medicine.copyWith(
                  name: name,
                  quantity: quantity,
                );

                Provider.of<MedicineProvider>(context, listen: false)
                    .updateMedicine(updatedMedicine);

                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$name güncellendi'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lütfen geçerli değerler girin'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Medicine medicine) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlacı Sil'),
        content: RichText(
          text: TextSpan(
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textPrimaryColor,
            ),
            children: [
              const TextSpan(text: 'Gerçekten '),
              TextSpan(
                text: medicine.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(text: ' ilacını silmek istediğinize emin misiniz?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'İptal',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<MedicineProvider>(context, listen: false)
                  .deleteMedicine(medicine.id);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${medicine.name} silindi'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
