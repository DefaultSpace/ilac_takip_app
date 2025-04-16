import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../providers/medicine_provider.dart';
import '../utils/app_theme.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({Key? key}) : super(key: key);

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> with SingleTickerProviderStateMixin {
  List<String> _logs = [];
  bool _isLoading = true;
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
    
    _loadLogs();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final logs = await Provider.of<MedicineProvider>(context, listen: false).getLogs();
      setState(() {
        _logs = logs.reversed.toList(); // En son log en üstte görünsün
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loglar yüklenirken hata: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İşlem Geçmişi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: _loadLogs,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? _buildEmptyState()
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildLogsList(),
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
              'Henüz işlem geçmişi bulunmuyor',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'İlaç eklediğinizde, düzenlediğinizde veya sildiğinizde\nburada görüntülenecektir',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _logs.length,
      itemBuilder: (context, index) {
        final log = _logs[index];
        
        // Log formatı: "2023-04-16T10:30:00.000Z: Parasetamol eklendi: 10 adet"
        final parts = log.split(': ');
        if (parts.length < 2) {
          return const Card(
            margin: EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text('Geçersiz log formatı'),
            ),
          );
        }
        
        final dateTimeString = parts[0];
        final message = parts.sublist(1).join(': ');
        
        DateTime? dateTime;
        try {
          dateTime = DateTime.parse(dateTimeString);
        } catch (e) {
          // Tarih ayrıştırılamadı
        }
        
        final formattedDate = dateTime != null
            ? DateFormat('dd.MM.yyyy HH:mm').format(dateTime)
            : 'Bilinmeyen tarih';
        
        // Log türünü belirle
        IconData icon = Icons.history;
        Color iconColor = AppTheme.textSecondaryColor;
        
        if (message.contains('eklendi')) {
          icon = Icons.add_circle_outline;
          iconColor = AppTheme.successColor;
        } else if (message.contains('silindi')) {
          icon = Icons.delete_outline;
          iconColor = AppTheme.errorColor;
        } else if (message.contains('güncellendi') || message.contains('->')) {
          icon = Icons.edit_outlined;
          iconColor = AppTheme.primaryColor;
        } else if (message.contains('azaltıldı')) {
          icon = Icons.remove_circle_outline;
          iconColor = AppTheme.accentColor;
        }
        
        // Her kart için ayrı bir animasyon zamanlaması
        final itemAnimation = Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              index / _logs.length * 0.6,
              (index + 1) / _logs.length * 0.6 + 0.4,
              curve: Curves.easeOutQuart,
            ),
          ),
        );
        
        return SlideTransition(
          position: itemAnimation,
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 40,
                height: 40,
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
              title: Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.textLightColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLightColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
