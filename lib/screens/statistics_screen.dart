import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animations/animations.dart';
import '../providers/medicine_provider.dart';
import '../utils/app_theme.dart';
import '../models/medicine_model.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İlaç İstatistikleri'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<MedicineProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.medicines.isEmpty) {
            return _buildEmptyState();
          }
          
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(provider),
                  const SizedBox(height: 24),
                  _buildMedicineQuantityChart(provider),
                  const SizedBox(height: 24),
                  _buildMedicineStatusDistribution(provider),
                  const SizedBox(height: 24),
                  _buildMedicineList(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/medicine_logo.svg',
              height: 100,
              width: 100,
              colorFilter: ColorFilter.mode(
                Colors.grey.shade300,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Henüz ilaç eklenmemiş',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'İstatistikleri görüntülemek için\nilaç eklemelisiniz',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.add),
              label: const Text('İlaç Ekle'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryCard(MedicineProvider provider) {
    final totalMedicines = provider.medicines.length;
    final lowStockMedicines = provider.medicines.where((m) => m.quantity <= 1).length;
    final totalQuantity = provider.medicines.fold(0, (sum, medicine) => sum + medicine.quantity);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'İlaç Özeti',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  title: 'Toplam İlaç',
                  value: totalMedicines.toString(),
                  icon: Icons.medication,
                  color: AppTheme.primaryColor,
                ),
                _buildSummaryItem(
                  title: 'Düşük Stok',
                  value: lowStockMedicines.toString(),
                  icon: Icons.warning_amber_rounded,
                  color: AppTheme.errorColor,
                ),
                _buildSummaryItem(
                  title: 'Toplam Adet',
                  value: totalQuantity.toString(),
                  icon: Icons.inventory_2_outlined,
                  color: AppTheme.secondaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }
  
  Widget _buildMedicineQuantityChart(MedicineProvider provider) {
    // En çok 5 ilacı göster
    final medicines = provider.medicines.length > 5
        ? provider.medicines.sublist(0, 5)
        : provider.medicines;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'İlaç Miktarları',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'İlaçlarınızın mevcut miktarları',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: medicines.isEmpty ? 10 : medicines.map((m) => m.quantity.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      // tooltipBgColor parametresi kaldırıldı - fl_chart 0.71.0 ile uyumlu hale getirildi
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${medicines[groupIndex].name}\n',
                          const TextStyle(
                            color: AppTheme.textPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: '${rod.toY.round()} adet',
                              style: TextStyle(
                                color: rod.toY <= 1 ? AppTheme.errorColor : AppTheme.primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value >= medicines.length || value < 0) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              medicines[value.toInt()].name.length > 8
                                  ? '${medicines[value.toInt()].name.substring(0, 8)}...'
                                  : medicines[value.toInt()].name,
                              style: const TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: medicines.asMap().entries.map((entry) {
                    final index = entry.key;
                    final medicine = entry.value;
                    final isLowStock = medicine.quantity <= 1;
                    
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: medicine.quantity.toDouble(),
                          color: isLowStock ? AppTheme.errorColor : AppTheme.primaryColor,
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMedicineStatusDistribution(MedicineProvider provider) {
    final totalMedicines = provider.medicines.length;
    if (totalMedicines == 0) return const SizedBox.shrink();
    
    final lowStockCount = provider.medicines.where((m) => m.quantity <= 1).length;
    final normalStockCount = totalMedicines - lowStockCount;
    
    final lowStockPercentage = (lowStockCount / totalMedicines) * 100;
    final normalStockPercentage = (normalStockCount / totalMedicines) * 100;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'İlaç Durumu Dağılımı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'İlaçlarınızın stok durumu dağılımı',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                SizedBox(
                  height: 180,
                  width: 180,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: AppTheme.primaryColor,
                          value: normalStockPercentage,
                          title: '${normalStockPercentage.toStringAsFixed(0)}%',
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: AppTheme.errorColor,
                          value: lowStockPercentage,
                          title: '${lowStockPercentage.toStringAsFixed(0)}%',
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(
                        color: AppTheme.primaryColor,
                        title: 'Normal Stok',
                        value: '$normalStockCount ilaç',
                      ),
                      const SizedBox(height: 16),
                      _buildLegendItem(
                        color: AppTheme.errorColor,
                        title: 'Düşük Stok',
                        value: '$lowStockCount ilaç',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLegendItem({
    required Color color,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildMedicineList(MedicineProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'İlaç Listesi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...provider.medicines.map((medicine) {
          final isLowStock = medicine.quantity <= 1;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isLowStock ? AppTheme.errorColor : Colors.grey.shade200,
                width: isLowStock ? 1.5 : 1,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isLowStock
                      ? AppTheme.errorColor.withOpacity(0.1)
                      : AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.medication,
                  color: isLowStock
                      ? AppTheme.errorColor
                      : AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              title: Text(
                medicine.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isLowStock
                      ? AppTheme.errorColor
                      : AppTheme.textPrimaryColor,
                ),
              ),
              subtitle: Text(
                'Kalan miktar: ${medicine.quantity}',
                style: TextStyle(
                  fontSize: 14,
                  color: isLowStock
                      ? AppTheme.errorColor
                      : AppTheme.textSecondaryColor,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isLowStock
                      ? AppTheme.errorColor.withOpacity(0.1)
                      : AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isLowStock ? 'Düşük' : 'Normal',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isLowStock
                        ? AppTheme.errorColor
                        : AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
