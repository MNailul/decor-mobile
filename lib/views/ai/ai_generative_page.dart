import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/bounce_tap.dart';
import '../../widgets/animated_wishlist_button.dart';
import '../../services/api_service.dart';

class AiGenerativePage extends StatefulWidget {
  const AiGenerativePage({super.key});

  @override
  State<AiGenerativePage> createState() => _AiGenerativePageState();
}

class _AiGenerativePageState extends State<AiGenerativePage> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  String? _generatedImageUrl;
  bool _isGenerating = false;
  String _loadingMessage = 'Menganalisis struktur ruangan...';
  double _generationProgress = 0.0;
  double sliderValue = 0.5;

  Timer? _loadingTimer;
  Timer? _progressTimer;

  String selectedStyle = 'Scandinavian';
  String selectedRoom = 'living-room';

  final List<Map<String, String>> styles = [
    {
      'name': 'Scandinavian',
      'desc': 'LIGHT & ORGANIC',
      'image': 'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=400',
    },
    {
      'name': 'Industrial',
      'desc': 'RAW & STRUCTURAL',
      'image': 'https://images.unsplash.com/photo-1534349762230-e0cadf78f5da?w=400',
    },
    {
      'name': 'Minimalist',
      'desc': 'PURE & ESSENTIAL',
      'image': 'https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=400',
    },
    {
      'name': 'Modern',
      'desc': 'SLEEK & FLUID',
      'image': 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400',
    },
    {
      'name': 'Classic',
      'desc': 'TIMELESS & ORNATE',
      'image': 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=400',
    },
    {
      'name': 'Bohemian',
      'desc': 'FREE & ECLECTIC',
      'image': 'https://images.unsplash.com/photo-1583847268964-b28dc8f51f92?w=400',
    },
    {
      'name': 'Japanese',
      'desc': 'ZEN & NATURAL',
      'image': 'https://images.unsplash.com/photo-1507089947368-19c1da9775ae?w=400',
    },
    {
      'name': 'Mediterranean',
      'desc': 'WARM & VIBRANT',
      'image': 'https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=400',
    },
  ];

  final List<Map<String, dynamic>> rooms = [
    {'value': 'living-room', 'label': 'Ruang Tamu', 'icon': Icons.chair},
    {'value': 'bedroom', 'label': 'Kamar Tidur', 'icon': Icons.bed},
    {'value': 'kitchen', 'label': 'Dapur', 'icon': Icons.countertops},
    {'value': 'bathroom', 'label': 'Kamar Mandi', 'icon': Icons.shower},
    {'value': 'dining-room', 'label': 'Ruang Makan', 'icon': Icons.restaurant},
    {'value': 'home-office', 'label': 'Home Office', 'icon': Icons.computer},
    {'value': 'garden', 'label': 'Taman', 'icon': Icons.yard},
    {'value': 'kids-room', 'label': 'Kamar Anak', 'icon': Icons.child_care},
  ];

  final List<Map<String, String>> recommendedProducts = [
    {
      'name': 'Aurelius Lounge Chair',
      'desc': 'Brushed Walnut & Tan Leather',
      'price': 'Rp 36.750.000',
      'image': 'https://images.unsplash.com/photo-1581539250439-c96689b516dd?w=400&q=80',
    },
    {
      'name': 'Zenith Pendant Light',
      'desc': 'Matte Black Steel',
      'price': 'Rp 13.350.000',
      'image': 'https://images.unsplash.com/photo-1513506003901-1e6a229e2d15?w=400&q=80',
    },
    {
      'name': 'Nordic Floating Credenza',
      'desc': 'White Oak Finish',
      'price': 'Rp 25.800.000',
      'image': 'https://images.unsplash.com/photo-1595428774223-ef52624120d2?w=400&q=80',
    },
    {
      'name': 'Handwoven Wool Rug',
      'desc': 'Organic Ivory Fibers',
      'price': 'Rp 9.600.000',
      'image': 'https://images.unsplash.com/photo-1531835673320-96f30a6c6731?w=400&q=80',
    },
  ];

  final List<String> loadingMessages = [
    'Menganalisis struktur ruangan...',
    'Menerapkan gaya desain pilihan...',
    'AI sedang meredesain ruanganmu...',
    'Menambahkan detail interior...',
    'Hampir selesai...',
    'Memfinalisasi hasil akhir...',
  ];

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showToast('Gagal memuat gambar: $e', isError: true);
    }
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Cek apakah di web atau platform mobile untuk menampilkan opsi kamera
        bool isMobile = false;
        try {
          if (Platform.isAndroid || Platform.isIOS) {
            isMobile = true;
          }
        } catch (e) {
          // Jika berjalan di Web, Platform.isAndroid akan melempar error
          isMobile = false; 
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Sumber Foto',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF3EFEA),
                    child: Icon(Icons.photo_library_outlined, color: AppColors.primaryColor),
                  ),
                  title: const Text('Galeri Foto'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (isMobile)
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFF3EFEA),
                      child: Icon(Icons.camera_alt_outlined, color: AppColors.primaryColor),
                    ),
                    title: const Text('Kamera'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _generateDesign() async {
    if (_selectedImage == null) return;

    setState(() {
      _isGenerating = true;
      _generationProgress = 0.0;
      _loadingMessage = loadingMessages[0];
    });

    // Start cycling loading status messages
    int msgIdx = 0;
    _loadingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      msgIdx = (msgIdx + 1) % loadingMessages.length;
      setState(() {
        _loadingMessage = loadingMessages[msgIdx];
      });
    });

    // Start advancing progress up to 90%
    _progressTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      setState(() {
        if (_generationProgress < 0.90) {
          _generationProgress += 0.02;
        }
      });
    });

    final response = await _apiService.generateRoomDesign(
      imagePath: _selectedImage!.path,
      roomType: selectedRoom,
      style: selectedStyle,
    );

    _loadingTimer?.cancel();
    _progressTimer?.cancel();

    if (response['success'] == true) {
      setState(() {
        _generationProgress = 1.0;
        _isGenerating = false;
        _generatedImageUrl = response['output'];
      });
      _showToast('✨ Ruangan berhasil diredesain!');
    } else {
      setState(() {
        _isGenerating = false;
      });
      _showToast('❌ ${response['message'] ?? 'Gagal membuat desain'}', isError: true);
    }
  }

  Future<void> _openImageUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showToast('Tidak dapat membuka link gambar', isError: true);
    }
  }

  void _showToast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        backgroundColor: isError ? Colors.redAccent : AppColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI DESIGN LAB',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Reimagine\n',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                height: 1.1,
                              ),
                            ),
                            TextSpan(
                              text: 'Your Space',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryColor,
                                fontStyle: FontStyle.italic,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Upload foto ruanganmu, pilih jenis ruangan & gaya desain, lalu biarkan AI kami mentransformasinya secara ajaib.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                // Upload Zone & Before/After Comparison
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _generatedImageUrl != null
                      ? _buildComparisonSlider()
                      : _buildUploadPlaceholder(),
                ),

                const SizedBox(height: 24),

                // Step 1: Room Type
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primaryColor,
                        child: Text('1', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'PILIH JENIS RUANGAN',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      final isSelected = selectedRoom == room['value'];
                      return GestureDetector(
                        onTap: () {
                          if (!_isGenerating) {
                            setState(() => selectedRoom = room['value']);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 100,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFAF2EB) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryColor : Colors.grey.shade200,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                room['icon'],
                                color: isSelected ? AppColors.primaryColor : Colors.grey,
                                size: 24,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                room['label'],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppColors.primaryColor : Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 28),

                // Step 2: Architectural Style
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primaryColor,
                        child: Text('2', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'PILIH GAYA DESAIN',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 225,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: styles.length,
                    itemBuilder: (context, index) {
                      final style = styles[index];
                      final isSelected = selectedStyle == style['name'];
                      return GestureDetector(
                        onTap: () {
                          if (!_isGenerating) {
                            setState(() => selectedStyle = style['name']!);
                          }
                        },
                        child: Container(
                          width: 140,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                height: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: isSelected
                                      ? Border.all(color: AppColors.primaryColor, width: 3)
                                      : Border.all(color: Colors.transparent, width: 3),
                                  image: DecorationImage(
                                    image: NetworkImage(style['image']!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                style['name']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isSelected ? AppColors.primaryColor : Colors.black,
                                ),
                              ),
                              Text(
                                style['desc']!,
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 9, letterSpacing: 1),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Generate Button or Result Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      if (_generatedImageUrl == null)
                        IgnorePointer(
                          ignoring: (_selectedImage == null || _isGenerating),
                          child: BounceTap(
                            onTap: () => _generateDesign(),
                            child: Opacity(
                              opacity: (_selectedImage == null || _isGenerating) ? 0.5 : 1.0,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryColor.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: const Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                                      SizedBox(width: 12),
                                      Text(
                                        'GENERATE AI DESIGN',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      else ...[
                        Row(
                          children: [
                            Expanded(
                              child: BounceTap(
                                onTap: () => _openImageUrl(_generatedImageUrl!),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.primaryColor, width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.download_rounded, color: AppColors.primaryColor, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          'DOWNLOAD HASIL',
                                          style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: BounceTap(
                                onTap: () => _generateDesign(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.rotate_right_rounded, color: Colors.black87, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          'GENERATE ULANG',
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _generatedImageUrl = null;
                            });
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.grey),
                          label: const Text('Mulai Ulang / Ganti Gambar', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ),
                      ]
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Shop the Look
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Shop the Look', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(
                        'VIEW ALL 12 ITEMS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: recommendedProducts.length,
                  itemBuilder: (context, index) {
                    final product = recommendedProducts[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: NetworkImage(product['image']!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: AnimatedWishlistButton(
                                    size: 14,
                                    onChanged: (isLiked) {},
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          product['name']!,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          product['desc']!,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product['price']!,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 120),
              ],
            ),
          ),

          // Loading Overlay
          if (_isGenerating) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return GestureDetector(
      onTap: _showImageSourceOptions,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade200,
            style: BorderStyle.solid,
            width: 1,
          ),
        ),
        child: _selectedImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: const Icon(Icons.camera_alt_outlined, color: AppColors.primaryColor, size: 28),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Upload Foto Ruangan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPEG, PNG or HEIC up to 20MB',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_selectedImage!, fit: BoxFit.cover),
                    Container(color: Colors.black.withOpacity(0.2)),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, size: 14, color: AppColors.primaryColor),
                            SizedBox(width: 6),
                            Text(
                              'Ganti Foto',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildComparisonSlider() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Generated Image (After)
              Container(
                height: 350,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(_generatedImageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Original Image (Before, Clipped)
              ClipRect(
                clipper: _ImageClipper(sliderValue),
                child: Container(
                  height: 350,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(_selectedImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  foregroundDecoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),
              ),
              // Labels
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('FOTO ASLI', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('AI REIMAGINED', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ),
              // Slider Control overlay
              Positioned.fill(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 0,
                    thumbShape: _CustomThumbShape(),
                    overlayColor: Colors.transparent,
                  ),
                  child: Slider(
                    value: sliderValue,
                    onChanged: (val) => setState(() => sliderValue = val),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Geser slider untuk membandingkan sebelum dan sesudah',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
        )
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.75),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                strokeWidth: 5,
              ),
              const SizedBox(height: 24),
              const Text(
                'AI sedang meredesain ruanganmu...',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _loadingMessage,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                width: 200,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _generationProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageClipper extends CustomClipper<Rect> {
  final double value;
  _ImageClipper(this.value);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * value, size.height);
  }

  @override
  bool shouldReclip(_ImageClipper oldClipper) => oldClipper.value != value;
}

class _CustomThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(40, 40);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Draw vertical line
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5;
    canvas.drawLine(
      Offset(center.dx, center.dy - 175),
      Offset(center.dx, center.dy + 175),
      linePaint,
    );

    // Draw circle thumb
    final circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 20, circlePaint);

    final borderPaint = Paint()
      ..color = AppColors.primaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, 20, borderPaint);

    // Draw icons (unfold_more_rounded or chevron_left/right)
    const icon = Icons.unfold_more_rounded;
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 22,
          fontFamily: icon.fontFamily,
          color: AppColors.primaryColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }
}
