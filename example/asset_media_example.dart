import 'package:flutter/material.dart';
import 'package:media_source/media_source.dart';

/// Example demonstrating AssetMediaSource usage.
///
/// This example shows how to:
/// - Load media assets from the Flutter asset bundle
/// - Work with different asset media types (video, audio, image, document)
/// - Convert assets to file or memory representations
/// - Use custom asset bundles
/// - Preserve metadata during conversions
void main() {
  runApp(const AssetMediaExampleApp());
}

class AssetMediaExampleApp extends StatelessWidget {
  const AssetMediaExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asset Media Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AssetMediaExampleScreen(),
    );
  }
}

class AssetMediaExampleScreen extends StatefulWidget {
  const AssetMediaExampleScreen({super.key});

  @override
  State<AssetMediaExampleScreen> createState() => _AssetMediaExampleScreenState();
}

class _AssetMediaExampleScreenState extends State<AssetMediaExampleScreen> {
  String _output = 'Tap a button to run an example';

  void _runExample(String title, Future<String> Function() example) async {
    setState(() => _output = 'Running...');
    try {
      final result = await example();
      setState(() => _output = '$title\n\n$result');
    } catch (e) {
      setState(() => _output = '$title\n\nError: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asset Media Examples')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () => _runExample('Video Asset', videoAssetExample),
                    child: const Text('Video Asset Example'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _runExample('Audio Asset', audioAssetExample),
                    child: const Text('Audio Asset Example'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _runExample('Image Asset', imageAssetExample),
                    child: const Text('Image Asset Example'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _runExample('Document Asset', documentAssetExample),
                    child: const Text('Document Asset Example'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _runExample('Asset Conversions', assetConversionExample),
                    child: const Text('Asset Conversion Example'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _runExample('Metadata Preservation', metadataPreservationExample),
                    child: const Text('Metadata Preservation Example'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _runExample('Pattern Matching', patternMatchingExample),
                    child: const Text('Pattern Matching Example'),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _output,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 1: Loading and working with video assets
Future<String> videoAssetExample() async {
  final output = StringBuffer();

  // Load a video asset from the bundle
  final video = await VideoAssetMedia.load(
    'assets/videos/intro.mp4',
    name: 'Intro Video',
    duration: const Duration(seconds: 30),
  );

  output.writeln('Video loaded from asset bundle:');
  output.writeln('  Asset path: ${video.assetPath}');
  output.writeln('  Name: ${video.name}');
  output.writeln('  Size: ${video.size}');
  output.writeln('  Duration: ${video.metadata.duration}');
  output.writeln('  MIME type: ${video.mimeType}');
  output.writeln();

  // Save asset to file system (if needed)
  // final savedVideo = await video.saveTo('/path/to/save/intro.mp4');
  // output.writeln('Saved to: ${savedVideo.file.path}');

  output.writeln('You can save it to file system:');
  output.writeln('  await video.saveTo(\'/path/to/save/intro.mp4\');');
  output.writeln();

  output.writeln('Or to a folder (keeps original name):');
  output.writeln('  await video.saveToFolder(\'/downloads\');');

  return output.toString();
}

/// Example 2: Loading and working with audio assets
Future<String> audioAssetExample() async {
  final output = StringBuffer();

  // Load an audio asset
  final audio = await AudioAssetMedia.load(
    'assets/audio/background_music.mp3',
    duration: const Duration(minutes: 3, seconds: 45),
  );

  output.writeln('Audio loaded from asset bundle:');
  output.writeln('  Asset path: ${audio.assetPath}');
  output.writeln('  Name: ${audio.name}');
  output.writeln('  Size: ${audio.size}');
  output.writeln('  Duration: ${audio.metadata.duration}');
  output.writeln('  MIME type: ${audio.mimeType}');
  output.writeln();

  // Load with custom name and MIME type
  final customAudio = await AudioAssetMedia.load(
    'assets/audio/sound_effect.wav',
    name: 'Button Click Sound',
    duration: const Duration(milliseconds: 500),
    mimeType: 'audio/wav',
  );

  output.writeln('Audio with custom properties:');
  output.writeln('  Name: ${customAudio.name}');
  output.writeln('  MIME type: ${customAudio.mimeType}');

  return output.toString();
}

/// Example 3: Loading and working with image assets
Future<String> imageAssetExample() async {
  final output = StringBuffer();

  // Load an image asset
  final image = await ImageAssetMedia.load('assets/images/logo.png');

  output.writeln('Image loaded from asset bundle:');
  output.writeln('  Asset path: ${image.assetPath}');
  output.writeln('  Name: ${image.name}');
  output.writeln('  Size: ${image.size}');
  output.writeln('  MIME type: ${image.mimeType}');
  output.writeln();

  // Load with custom properties
  final customImage = await ImageAssetMedia.load(
    'assets/images/background.jpg',
    name: 'Hero Background',
    mimeType: 'image/jpeg',
  );

  output.writeln('Image with custom name:');
  output.writeln('  Name: ${customImage.name}');
  output.writeln();

  // Optimize by providing size if known
  final optimizedImage = await ImageAssetMedia.load(
    'assets/images/icon.png',
    size: 50.kb, // Avoid loading asset just to get size
  );

  output.writeln('Optimized loading (size provided):');
  output.writeln('  Size: ${optimizedImage.size}');
  output.writeln('  (Asset not loaded until actually needed)');

  return output.toString();
}

/// Example 4: Loading and working with document assets
Future<String> documentAssetExample() async {
  final output = StringBuffer();

  // Load a PDF document asset
  final doc = await DocumentAssetMedia.load('assets/docs/terms.pdf');

  output.writeln('Document loaded from asset bundle:');
  output.writeln('  Asset path: ${doc.assetPath}');
  output.writeln('  Name: ${doc.name}');
  output.writeln('  Size: ${doc.size}');
  output.writeln('  MIME type: ${doc.mimeType}');
  output.writeln();

  // Load other document types
  final markdown = await OtherTypeAssetMedia.load(
    'assets/docs/readme.md',
    name: 'README',
    mimeType: 'text/markdown',
  );

  output.writeln('Markdown document:');
  output.writeln('  Name: ${markdown.name}');
  output.writeln('  MIME type: ${markdown.mimeType}');

  return output.toString();
}

/// Example 5: Converting assets to different representations
Future<String> assetConversionExample() async {
  final output = StringBuffer();

  // Load a video asset
  final assetVideo = await VideoAssetMedia.load(
    'assets/videos/clip.mp4',
    duration: const Duration(seconds: 15),
  );

  output.writeln('Original: Asset media');
  output.writeln('  Path: ${assetVideo.assetPath}');
  output.writeln('  Size: ${assetVideo.size}');
  output.writeln();

  // Convert to memory representation
  final memoryVideo = await assetVideo.convertToMemory();

  output.writeln('Converted to memory:');
  output.writeln('  Type: VideoMemoryMedia');
  output.writeln('  Bytes loaded: ${memoryVideo.bytes.length}');
  output.writeln('  Size: ${memoryVideo.size}');
  output.writeln('  Duration preserved: ${memoryVideo.metadata.duration}');
  output.writeln();

  // Save to file system (example, commented to avoid actual I/O)
  // final fileVideo = await assetVideo.saveTo('/temp/video.mp4');
  // output.writeln('Saved to file:');
  // output.writeln('  Type: VideoFileMedia');
  // output.writeln('  Path: ${fileVideo.file.path}');
  // output.writeln('  Duration preserved: ${fileVideo.metadata.duration}');

  output.writeln('Can also save to file:');
  output.writeln('  final fileVideo = await assetVideo.saveTo(\'/temp/video.mp4\');');
  output.writeln('  // Returns VideoFileMedia instance');

  return output.toString();
}

/// Example 6: Metadata preservation across conversions
Future<String> metadataPreservationExample() async {
  final output = StringBuffer();

  // Load audio with metadata
  final assetAudio = await AudioAssetMedia.load(
    'assets/audio/song.mp3',
    name: 'My Favorite Song',
    duration: const Duration(minutes: 4, seconds: 32),
    mimeType: 'audio/mpeg',
  );

  output.writeln('Original asset audio:');
  output.writeln('  Name: ${assetAudio.name}');
  output.writeln('  Duration: ${assetAudio.metadata.duration}');
  output.writeln('  MIME type: ${assetAudio.mimeType}');
  output.writeln();

  // Convert to memory - metadata is preserved
  final memoryAudio = await assetAudio.convertToMemory();

  output.writeln('After conversion to memory:');
  output.writeln('  Name: ${memoryAudio.name} ✓');
  output.writeln('  Duration: ${memoryAudio.metadata.duration} ✓');
  output.writeln('  MIME type: ${memoryAudio.mimeType} ✓');
  output.writeln();

  // Further conversion to file - metadata still preserved
  // final fileAudio = await memoryAudio.saveTo('/music/song.mp3');
  // output.writeln('After saving to file:');
  // output.writeln('  Name: ${fileAudio.name} ✓');
  // output.writeln('  Duration: ${fileAudio.metadata.duration} ✓');
  // output.writeln('  MIME type: ${fileAudio.mimeType} ✓');

  output.writeln('All metadata is preserved throughout');
  output.writeln('the entire conversion chain:');
  output.writeln('  Asset → Memory → File');

  return output.toString();
}

/// Example 7: Pattern matching with fold
Future<String> patternMatchingExample() async {
  final output = StringBuffer();

  // Load different media sources
  final assetVideo = await VideoAssetMedia.load(
    'assets/videos/intro.mp4',
    duration: const Duration(seconds: 30),
  );

  output.writeln('Pattern matching with fold:');
  output.writeln();

  // Pattern match on the media source
  final description = assetVideo.fold<String>(
    file: (f) => 'File source: ${f.file.path}',
    memory: (m) => 'Memory source: ${m.size}',
    network: (n) => 'Network source: ${n.uri}',
    asset: (a) => 'Asset source: ${a.assetPath}',
    orElse: () => 'Unknown source',
  );

  output.writeln('Source type: $description');
  output.writeln();

  // After conversion, the fold pattern works with new type
  final memoryVideo = await assetVideo.convertToMemory();

  final memoryDescription = memoryVideo.fold<String>(
    file: (f) => 'File source: ${f.file.path}',
    memory: (m) => 'Memory source: ${m.size} bytes',
    network: (n) => 'Network source: ${n.uri}',
    asset: (a) => 'Asset source: ${a.assetPath}',
    orElse: () => 'Unknown source',
  );

  output.writeln('After conversion:');
  output.writeln('Source type: $memoryDescription');
  output.writeln();

  output.writeln('Pattern matching allows type-safe handling');
  output.writeln('of different media source types with a unified API.');

  return output.toString();
}

/// Note: Before using these examples, make sure to:
/// 1. Add assets to your pubspec.yaml:
///    ```yaml
///    flutter:
///      assets:
///        - assets/videos/
///        - assets/audio/
///        - assets/images/
///        - assets/docs/
///    ```
///
/// 2. Place your media files in the corresponding directories
///
/// 3. Run the app to see the examples in action
