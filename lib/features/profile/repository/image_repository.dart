import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageRepository extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedImage;
  XFile? get selectedImage => _selectedImage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      _setLoading(true);
      _clearError();

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImage = image;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to pick image from gallery: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      _setLoading(true);
      _clearError();

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImage = image;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to take photo: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Show image source selection dialog
  Future<void> showImageSourceDialog(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Select Photo Source',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildSourceOption(
                        context: context,
                        icon: Icons.photo_library,
                        label: 'Gallery',
                        onTap: () {
                          Navigator.pop(context);
                          pickImageFromGallery();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSourceOption(
                        context: context,
                        icon: Icons.camera_alt,
                        label: 'Camera',
                        onTap: () {
                          Navigator.pop(context);
                          pickImageFromCamera();
                        },
                      ),
                    ),
                  ],
                ),
                if (_selectedImage != null) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        clearImage();
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text(
                        'Remove Current Photo',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  /// Clear selected image
  void clearImage() {
    _selectedImage = null;
    _clearError();
    notifyListeners();
  }

  /// Upload image to server (placeholder - implement based on your backend)
  Future<String?> uploadImage(String userId) async {
    if (_selectedImage == null) return null;

    try {
      _setLoading(true);
      _clearError();

      // TODO: Implement actual image upload to your server
      // Example using multipart request:
      /*
      final request = http.MultipartRequest(
        'POST', 
        Uri.parse('${dotenv.get('BASE_URL')}/users/$userId/profile-image')
      );
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _selectedImage!.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
      
      final response = await request.send();
      
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);
        return data['imageUrl']; // Return the uploaded image URL
      } else {
        throw Exception('Failed to upload image');
      }
      */

      // Simulate upload delay
      await Future.delayed(const Duration(seconds: 2));

      // Return a mock URL for now
      return 'https://example.com/uploaded-image.jpg';
    } catch (e) {
      _setError('Failed to upload image: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Check if image has been modified
  bool get hasImageChanged => _selectedImage != null;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}
