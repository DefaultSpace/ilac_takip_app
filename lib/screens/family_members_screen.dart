import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animations/animations.dart';
import '../providers/medicine_provider.dart';
import '../utils/app_theme.dart';
import '../models/medicine_model.dart';

class FamilyMembersScreen extends StatefulWidget {
  const FamilyMembersScreen({Key? key}) : super(key: key);

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Aile üyeleri listesi
  List<FamilyMember> _familyMembers = [
    FamilyMember(
      id: '1',
      name: 'Ahmet',
      relationship: 'Baba',
      color: Colors.blue,
    ),
    FamilyMember(
      id: '2',
      name: 'Ayşe',
      relationship: 'Anne',
      color: Colors.pink,
    ),
    FamilyMember(
      id: '3',
      name: 'Mehmet',
      relationship: 'Dede',
      color: Colors.green,
    ),
  ];

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

  // Aile üyesini sil
  void _removeFamilyMember(String id) {
    setState(() {
      _familyMembers.removeWhere((member) => member.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aile Üyeleri'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _familyMembers.isEmpty
            ? _buildEmptyState()
            : _buildFamilyMembersList(),
      ),
      floatingActionButton: OpenContainer(
        transitionDuration: const Duration(milliseconds: 500),
        openBuilder: (context, _) => const AddFamilyMemberScreen(),
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
            'Henüz aile üyesi eklenmemiş',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textSecondaryColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Aile üyelerinizin ilaçlarını takip etmek için\naile üyesi ekleyin',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const AddFamilyMemberScreen(),
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
            label: const Text('Aile Üyesi Ekle'),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyMembersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _familyMembers.length,
      itemBuilder: (context, index) {
        final member = _familyMembers[index];

        // Her kart için ayrı bir animasyon zamanlaması
        final itemAnimation = Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              index / _familyMembers.length * 0.6,
              (index + 1) / _familyMembers.length * 0.6 + 0.4,
              curve: Curves.easeOutQuart,
            ),
          ),
        );

        return SlideTransition(
          position: itemAnimation,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildFamilyMemberCard(member),
          ),
        );
      },
    );
  }

  Widget _buildFamilyMemberCard(FamilyMember member) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => FamilyMemberDetailScreen(member: member),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: member.color.withOpacity(0.2),
                child: Text(
                  member.name.substring(0, 1),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: member.color,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.relationship,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  '3 İlaç',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                onPressed: () => _removeFamilyMember(member.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddFamilyMemberScreen extends StatefulWidget {
  const AddFamilyMemberScreen({Key? key}) : super(key: key);

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _relationshipController = TextEditingController();
  Color _selectedColor = Colors.blue;
  bool _isLoading = false;
  
  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];
  
  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aile Üyesi Ekle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: _selectedColor.withOpacity(0.2),
                  child: Text(
                    _nameController.text.isNotEmpty
                        ? _nameController.text.substring(0, 1)
                        : 'A',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: _selectedColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  hintText: 'Örn: Ahmet Yılmaz',
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen ad soyad girin';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _relationshipController,
                decoration: const InputDecoration(
                  labelText: 'Yakınlık Derecesi',
                  hintText: 'Örn: Baba, Anne, Dede',
                  prefixIcon: Icon(Icons.family_restroom),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen yakınlık derecesi girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Renk Seçin',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colorOptions.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveFamilyMember,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _selectedColor,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.0,
                        ),
                      )
                    : const Text(
                        'KAYDET',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _saveFamilyMember() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      // Burada aile üyesi kaydetme işlemi yapılacak
      // Örnek olarak şimdilik sadece başarılı mesajı gösteriyoruz
      
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_nameController.text} başarıyla eklendi'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.successColor,
          ),
        );
        
        Navigator.pop(context);
      });
    }
  }
}

class FamilyMemberDetailScreen extends StatelessWidget {
  final FamilyMember member;
  
  const FamilyMemberDetailScreen({
    Key? key,
    required this.member,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Örnek ilaçlar
    final medicines = [
      Medicine(
        id: '1',
        name: 'Aspirin',
        quantity: 10,
        addedDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Medicine(
        id: '2',
        name: 'Parol',
        quantity: 5,
        addedDate: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Medicine(
        id: '3',
        name: 'Vitamin D',
        quantity: 30,
        addedDate: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${member.name} İlaçları'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          _buildProfileHeader(context),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final medicine = medicines[index];
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: member.color,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: member.color.withOpacity(0.1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: member.color.withOpacity(0.2),
            child: Text(
              member.name.substring(0, 1),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: member.color,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member.relationship,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '3 İlaç Takip Ediliyor',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FamilyMember {
  final String id;
  final String name;
  final String relationship;
  final Color color;
  
  FamilyMember({
    required this.id,
    required this.name,
    required this.relationship,
    required this.color,
  });
}
