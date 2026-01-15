import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:patho_logos/models/analysis_result.dart';
import 'package:patho_logos/services/gemini_service.dart';

class AppViewModel extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();

  // Inputs
  Uint8List? _imageBytes;
  String? _imageName;
  String? _textData;
  final TextEditingController textController = TextEditingController();

  // State
  bool _isLoading = false;
  String? _error;
  AnalysisResult? _result;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  AnalysisResult? get result => _result;
  Uint8List? get imageBytes => _imageBytes;
  String? get imageName => _imageName;
  bool get hasImage => _imageBytes != null;

  void updateText(String val) {
    _textData = val;
    notifyListeners();
  }

  Future<void> pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true, // Needed for web and some platforms to get bytes immediately
      );

      if (result != null) {
        _imageBytes = result.files.first.bytes;
        _imageName = result.files.first.name;
        // If bytes are null (can happen on IO if not handled), try to read from path (not implemented for Web here but handled by 'withData: true' usually)
        if (_imageBytes == null && result.files.first.path != null) {
          // In a real app we'd load from file, but for MVP assuming bytes are loaded or web.
          // Note: withData: true can be memory intensive for huge files.
        }
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = "Error picking image: $e";
      notifyListeners();
    }
  }

  void clearImage() {
    _imageBytes = null;
    _imageName = null;
    notifyListeners();
  }

  Future<void> analyze() async {
    if (_imageBytes == null && (_textData == null || _textData!.isEmpty)) {
      _error = "Please provide an image or text data.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _result = null;
    notifyListeners();

    try {
      _result = await _geminiService.analyzeParams(
        imageBytes: _imageBytes,
        textData: _textData,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
