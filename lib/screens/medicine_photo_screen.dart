import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animations/animations.dart';
import 'dart:io';
import '../providers/medicine_provider.dart';
import '../utils/app_theme.dart';
import '../models/medicine_model.dart';

class MedicinePhotoScreen extends StatefulWidget {
  final String? medicineId;
  
  const MedicinePhotoScreen({
    Key? key,
    this.medicineId,
  }) : super(key: key);

  @override
  State<MedicinePhotoScreen> createState() => _MedicinePhotoScreenState();
}

class _MedicinePhotoScreenState extends State<MedicinePhotoScreen> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isLoading = false;
  Medicine? _medicine;
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
    
    _loadMedicine();
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadMedicine() async {
    if (widget.medicineId != null) {
      final provider = Provider.of<MedicineProvider>(context, listen: false);
      final medicine = await provider.getMedicineById(widget.medicineId!);
      
      setState(() {
        _medicine = medicine;
        // Burada ilaç fotoğrafı varsa yüklenecek
        // Örnek olarak şimdilik boş bırakıyoruz
      });
    }
  }
  
  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fotoğraf çekilemedi: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
  
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fotoğraf seçilemedi: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
  
  Future<void> _saveMedicinePhoto() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen önce bir fotoğraf seçin veya çekin'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Burada fotoğrafı kaydetme işlemi yapılacak
      // Örnek olarak şimdilik sadece başarılı mesajı gösteriyoruz
      
      await Future.delayed(const Duration(seconds: 1)); // Simüle edilmiş işlem
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fotoğraf başarıyla kaydedildi'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.successColor,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fotoğraf kaydedilemedi: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_medicine != null ? '${_medicine!.name} Fotoğrafı' : 'İlaç Fotoğrafı'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildImagePreview(),
              ),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildImagePreview() {
    if (_imageFile != null) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            _imageFile!,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
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
              'Henüz fotoğraf eklenmemiş',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'İlaç kutusunun veya ilacın fotoğrafını\nçekmek veya galeriden seçmek için\naşağıdaki butonları kullanın',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _takePicture,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Fotoğraf Çek'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Galeriden Seç'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: AppTheme.secondaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _isLoading || _imageFile == null ? null : _saveMedicinePhoto,
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.save),
          label: const Text('FOTOĞRAFI KAYDET'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: AppTheme.accentColor,
          ),
        ),
      ],
    );
  }
}
