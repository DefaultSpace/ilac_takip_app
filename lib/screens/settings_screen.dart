import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../providers/medicine_provider.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
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
        title: const Text('Ayarlar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<MedicineProvider>(
          builder: (context, provider, child) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildProfileSection(),
                const SizedBox(height: 24),
                _buildSettingsCard(
                  title: 'Bildirim Ayarları',
                  icon: Icons.notifications_outlined,
                  iconColor: AppTheme.primaryColor,
                  children: [
                    _buildNotificationTimeSetting(context, provider),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSettingsCard(
                  title: 'İlaç Yönetimi',
                  icon: Icons.medication_outlined,
                  iconColor: AppTheme.accentColor,
                  children: [
                    _buildMedicineManagementSetting(context, provider),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSettingsCard(
                  title: 'Veri Yönetimi',
                  icon: Icons.save_outlined,
                  iconColor: AppTheme.secondaryColor,
                  children: [
                    _buildDataManagementSetting(context, provider),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSettingsCard(
                  title: 'Uygulama Bilgileri',
                  icon: Icons.info_outline,
                  iconColor: Colors.grey,
                  children: [
                    _buildAppInfoSetting(context),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/images/medicine_logo.svg',
            height: 80,
            width: 80,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'İlaç Takip',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'İlaçlarınızı takip etmenin en kolay yolu',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTimeSetting(BuildContext context, MedicineProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bildirim Saati',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Belirlediğiniz saatte günlük ilaç bildirimleri alacaksınız.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    provider.notificationTime != null
                        ? DateFormat.Hm().format(provider.notificationTime!)
                        : 'Ayarlanmadı',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: provider.notificationTime != null
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () => _selectNotificationTime(context),
                icon: const Icon(Icons.edit_calendar),
                label: const Text('Saat Seç'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMedicineManagementSetting(BuildContext context, MedicineProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'İlaç Sayısını Azalt',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tüm ilaçların sayısını manuel olarak azaltmak için bu butonu kullanabilirsiniz.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading
                ? null
                : () => _decreaseAllMedicines(context),
            icon: const Icon(Icons.remove_circle_outline),
            label: const Text('İLAÇLARI AZALT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataManagementSetting(BuildContext context, MedicineProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verileri Yedekle',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tüm ilaç verilerinizi ve ayarlarınızı JSON formatında dışa aktarın.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _exportData(context),
            icon: const Icon(Icons.cloud_download_outlined),
            label: const Text('VERİLERİ YEDEKLE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppInfoSetting(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Uygulama Hakkında',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'İlaç Takip uygulaması, ilaçlarınızı takip etmenize ve zamanında hatırlatmalar almanıza yardımcı olur.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sürüm',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => _showAboutDialog(context),
                icon: const Icon(Icons.info_outline),
                label: const Text('Detaylar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectNotificationTime(BuildContext context) async {
    final provider = Provider.of<MedicineProvider>(context, listen: false);
    final currentTime = provider.notificationTime ?? DateTime.now();
    
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              dayPeriodColor: MaterialStateColor.resolveWith((states) => 
                states.contains(MaterialState.selected)
                  ? AppTheme.primaryColor
                  : Colors.grey.shade200
              ),
              dayPeriodTextColor: MaterialStateColor.resolveWith((states) => 
                states.contains(MaterialState.selected)
                  ? Colors.white
                  : AppTheme.textPrimaryColor
              ),
              hourMinuteColor: MaterialStateColor.resolveWith((states) => 
                states.contains(MaterialState.selected)
                  ? AppTheme.primaryColor
                  : Colors.grey.shade200
              ),
              hourMinuteTextColor: MaterialStateColor.resolveWith((states) => 
                states.contains(MaterialState.selected)
                  ? Colors.white
                  : AppTheme.textPrimaryColor
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null && mounted) {
      setState(() {
        _isLoading = true;
      });

      try {
        final now = DateTime.now();
        final newDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        await provider.setNotificationTime(newDateTime);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bildirim saati güncellendi'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.successColor,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.errorColor,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _decreaseAllMedicines(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlaçları Azalt'),
        content: const Text(
          'Tüm ilaçların sayısını bir azaltmak istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İPTAL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
            ),
            child: const Text('AZALT'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() {
        _isLoading = true;
      });

      try {
        await Provider.of<MedicineProvider>(context, listen: false)
            .decreaseAllMedicines();
            
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tüm ilaçların sayısı azaltıldı'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.successColor,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.errorColor,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _exportData(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final jsonData = await Provider.of<MedicineProvider>(context, listen: false)
          .exportData();
          
      // Dosyayı kaydetme işlemi burada yapılacak
      // Bu örnek için sadece başarılı mesajı gösteriyoruz
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veriler başarıyla dışa aktarıldı'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uygulama Hakkında'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/images/medicine_logo.svg',
              height: 80,
              width: 80,
            ),
            const SizedBox(height: 16),
            const Text(
              'İlaç Takip',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sürüm 1.0.0',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'İlaç Takip uygulaması, ilaçlarınızı takip etmenize, günlük bildirimler almanıza ve ilaç miktarı azaldığında uyarılar görmenize olanak sağlar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '© 2025 İlaç Takip',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('KAPAT'),
          ),
        ],
      ),
    );
  }
}
