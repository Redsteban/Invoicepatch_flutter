import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  final ImagePicker _picker = ImagePicker();
  List<CameraDescription>? _cameras;
  CameraController? _controller;

  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
    } catch (e) {
      print('Error initializing cameras: $e');
    }
  }

  Future<bool> requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final storageStatus = await Permission.storage.request();
    
    return cameraStatus.isGranted && storageStatus.isGranted;
  }

  Future<CameraController?> initializeCamera() async {
    if (_cameras == null || _cameras!.isEmpty) {
      await initialize();
    }

    if (_cameras == null || _cameras!.isEmpty) {
      return null;
    }

    _controller = CameraController(
      _cameras!.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      return _controller;
    } catch (e) {
      print('Error initializing camera controller: $e');
      return null;
    }
  }

  Future<String?> captureReceiptImage() async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        throw Exception('Camera permissions not granted');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image == null) return null;

      // Save to app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final receiptDir = Directory('${appDir.path}/receipts');
      
      if (!await receiptDir.exists()) {
        await receiptDir.create(recursive: true);
      }

      final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = path.join(receiptDir.path, fileName);
      
      await File(image.path).copy(savedPath);
      
      return savedPath;
    } catch (e) {
      print('Error capturing receipt image: $e');
      return null;
    }
  }

  Future<String?> pickReceiptFromGallery() async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        throw Exception('Storage permissions not granted');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image == null) return null;

      // Save to app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final receiptDir = Directory('${appDir.path}/receipts');
      
      if (!await receiptDir.exists()) {
        await receiptDir.create(recursive: true);
      }

      final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = path.join(receiptDir.path, fileName);
      
      await File(image.path).copy(savedPath);
      
      return savedPath;
    } catch (e) {
      print('Error picking receipt from gallery: $e');
      return null;
    }
  }

  Future<List<String>> getReceiptImages() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final receiptDir = Directory('${appDir.path}/receipts');
      
      if (!await receiptDir.exists()) {
        return [];
      }

      final files = await receiptDir.list().toList();
      return files
          .where((file) => file is File && file.path.endsWith('.jpg'))
          .map((file) => file.path)
          .toList();
    } catch (e) {
      print('Error getting receipt images: $e');
      return [];
    }
  }

  Future<bool> deleteReceiptImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting receipt image: $e');
      return false;
    }
  }

  void dispose() {
    _controller?.dispose();
  }
}