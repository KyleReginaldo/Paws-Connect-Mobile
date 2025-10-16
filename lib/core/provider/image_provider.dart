import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageProvider extends ChangeNotifier {
  XFile? _imageFile;
  XFile? get imageFile => _imageFile;

  void pickImageFile(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image != null) {
      _imageFile = image;
      notifyListeners();
    } else {
      debugPrint("No image selected");
    }
  }

  void removeImageFile() async {
    _imageFile = null;
    notifyListeners();
  }
}
