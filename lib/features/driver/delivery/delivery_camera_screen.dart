import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/booking_model.dart';
import '../../../widgets/custom_button.dart';

class DeliveryCameraScreen extends StatefulWidget {
  final String bookingId;
  const DeliveryCameraScreen({super.key, required this.bookingId});

  @override
  State<DeliveryCameraScreen> createState() => _DeliveryCameraScreenState();
}

class _DeliveryCameraScreenState extends State<DeliveryCameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePictureAndComplete() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      setState(() => _isUploading = true);

      await _initializeControllerFuture;
      final image = await _controller!.takePicture();

      // Upload to Firebase Storage
      final fileName =
          'delivery_${widget.bookingId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('delivery_proofs')
          .child(fileName);

      await storageRef.putFile(File(image.path));
      final downloadUrl = await storageRef.getDownloadURL();

      // Update Booking Status
      await FirebaseFirestore.instance
          .collection(AppConstants.bookingsCollection)
          .doc(widget.bookingId)
          .update({
            'status': BookingStatus.completed.name,
            'deliveryProofUrl': downloadUrl,
            'completedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Delivery Completed Successfully!")),
        );
        context.go('/driver-dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Capture Delivery Proof"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Center(child: CameraPreview(_controller!)),
                if (_isUploading)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: CustomButton(
                    label: _isUploading ? "Uploading..." : "CAPTURE & COMPLETE",
                    onPressed: _isUploading ? null : () { _takePictureAndComplete(); },
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
