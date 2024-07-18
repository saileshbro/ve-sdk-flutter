import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ve_sdk_flutter/export_result.dart';
import 'package:ve_sdk_flutter/ve_sdk_flutter.dart';

const _licenseToken =
    "Qk5CIP6fsXtrMt5pKJA6SYUDrDT8Vz2veeFwo0HL5OwtQHoC4MBR/5IfWCTUMk1GHDg7D/L7djN9250EJZ91YSostVgWeIE2q2rqSKBdFEIvhkYqQDDvvaQMtnDI3fQ2fpD36la/teghglWevLPWdbjYW2yjjI8w3z1vCxTAkP3FnjqVtW67G6yF/K+IRQenVYWWL4amaa1Mixdkrj+K4nx7Vvll9hGrDKuMg0a25GIT/1qZkXIBvdq6H/j9WU3RMm7I/uTHexVGwgjcgs9jnxou+3CnFHbVdfEpRJlwWQ7JReYdTB0S1a4yhi6sr2orweaheApeV94wL+ZaP2IGmdeuzmXs29MHApzg7cu/QTzyOt7y/4nToFNcUxb4oHmn0OI0E1AtItgXB+SiFYbawL1F3UnbT5Ig1vIB1EOyEFklLwnr0TvvxZiOd1jTSfyGi/qh2K1lHPRmOdLWNuUXmRVYlRqcx3U12EqUNb0cZlAlorCRqRawoi5USVB7EkpP0qrPpCY5eUvGea15jCVut33YlJCUPTpjaerfXKs9P2yVpMb0vOwtBo5UXwQDzQI8TwxdNyXNtiM9uMuo6ZUq8fWlbfv9iOdb2gGQ8UNVbJlUFHUD6C5Ulhb4ejYoV5oeXmF8+zl21C0TJ1CoY8lHmUs=";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _veSdkFlutterPlugin = VeSdkFlutter();
  String _errorMessage = '';

  Future<void> _startVideoEditorInCameraMode() async {
    try {
      dynamic exportResult =
          await _veSdkFlutterPlugin.openCameraScreen(_licenseToken);
      _handleExportResult(exportResult);
    } on PlatformException catch (e) {
      _handlePlatformException(e);
    }
  }

  Future<void> _startVideoEditorInPipMode() async {
    final ImagePicker picker = ImagePicker();
    final videoFile = await picker.pickVideo(source: ImageSource.gallery);

    final sourceVideoFile = videoFile?.path;
    if (sourceVideoFile == null) {
      debugPrint(
          'Error: Cannot start video editor in pip mode: please pick video file');
      return;
    }

    try {
      dynamic exportResult = await _veSdkFlutterPlugin.openPipScreen(
          _licenseToken, sourceVideoFile);
      _handleExportResult(exportResult);
    } on PlatformException catch (e) {
      _handlePlatformException(e);
    }
  }

  Future<void> _startVideoEditorInTrimmerMode() async {
    final ImagePicker picker = ImagePicker();
    final videoFiles = await picker.pickMultipleMedia(imageQuality: 3);

    if (videoFiles.isEmpty) {
      debugPrint(
          'Error: Cannot start video editor in trimmer mode: please pick video files');
      return;
    }

    final sources = videoFiles.map((f) => f.path).toList();

    try {
      dynamic exportResult =
          await _veSdkFlutterPlugin.openTrimmerScreen(_licenseToken, sources);
      _handleExportResult(exportResult);
    } on PlatformException catch (e) {
      _handlePlatformException(e);
    }
  }

  void _handleExportResult(ExportResult? result) {
    if (result == null) {
      debugPrint(
          'No export result! The user has closed video editor before export');
      return;
    }

    // The list of exported video file paths
    debugPrint('Exported video files = ${result.videoSources}');

    // Preview as a image file taken by the user. Null - when preview screen is disabled.
    debugPrint('Exported preview file = ${result.previewFilePath}');

    // Meta file where you can find short data used in exported video
    debugPrint('Exported meta file = ${result.metaFilePath}');
  }

  void _handlePlatformException(PlatformException exception) {
    _errorMessage = exception.message ?? 'unknown error';
    // You can find error codes 'package:ve_sdk_flutter/errors.dart';
    debugPrint("Error: code = ${exception.code}, message = $_errorMessage");

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Banuba Video Editor Flutter plugin"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                'The plugin demonstrates how to use Banuba Video Editor',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17.0,
                ),
              ),
            ),
            Visibility(
              visible: _errorMessage.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17.0, color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 24),
            MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              disabledColor: Colors.grey,
              disabledTextColor: Colors.black,
              padding: const EdgeInsets.all(12.0),
              splashColor: Colors.blueAccent,
              minWidth: 240,
              onPressed: () => _startVideoEditorInCameraMode(),
              child: const Text(
                'Open Video Editor - Camera screen',
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
            ),
            const SizedBox(height: 24),
            MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              disabledColor: Colors.grey,
              disabledTextColor: Colors.black,
              padding: const EdgeInsets.all(12.0),
              splashColor: Colors.blueAccent,
              minWidth: 240,
              onPressed: () => _startVideoEditorInPipMode(),
              child: const Text(
                'Open Video Editor - PIP screen ',
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
            ),
            const SizedBox(height: 24),
            MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              disabledColor: Colors.grey,
              disabledTextColor: Colors.black,
              padding: const EdgeInsets.all(12.0),
              splashColor: Colors.blueAccent,
              minWidth: 240,
              onPressed: () => _startVideoEditorInTrimmerMode(),
              child: const Text(
                'Open Video Editor - Trimmer screen',
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
