import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(const MaterialApp(home: SlapGame()));
}

class SlapGame extends StatefulWidget {
  const SlapGame({super.key});

  @override
  State<SlapGame> createState() => _SlapGameState();
}

class _SlapGameState extends State<SlapGame> with SingleTickerProviderStateMixin {
  Uint8List? _imageBytes;
  Offset _handPosition = const Offset(100, 100);
  final AudioPlayer _audioPlayer = AudioPlayer();

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _imageBytes = result.files.single.bytes!;
      });
    }
  }

Future<void> _playSlapSound() async {
  if (kIsWeb) {
    // Web requires public URL (from /web/ folder)
    await _audioPlayer.play(UrlSource('sounds/hard-slap-46388.mp3'));
  } else {
    await _audioPlayer.play(AssetSource('assets/sounds/hard-slap-46388.mp3'));
  }
}

  void _onSlap() {
    if (_imageBytes == null) return;
    _playSlapSound();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Slap Your Ex!'),
      ),
      body: MouseRegion(
        onHover: (event) {
          setState(() {
            _handPosition = event.localPosition;
          });
        },
        child: Stack(
          children: [
            Center(
              child: _imageBytes == null
                  ? ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Upload Your Ex\'s Photo'),
                    )
                  : GestureDetector(
                      onTapDown: (details) => _onSlap(),
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Image.memory(
                          _imageBytes!,
                          width: 300,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
            ),
            Positioned(
              left: _handPosition.dx - 40,
              top: _handPosition.dy - 40,
              child: IgnorePointer(
                child: Image.asset(
                  'assets/images/punch.jpg',
                  width: 80,
                  height: 80,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
