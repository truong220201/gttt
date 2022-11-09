// ignore_for_file: unused_local_variable, await_only_futures, non_constant_identifier_names, avoid_init_to_null
import 'dart:io' as Io;
import 'dart:convert';
import 'dart:developer';
// import 'dart:html';
import 'dart:io';
// import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:camera/camera.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_camera_demo/screens/newpage.dart';
import 'package:flutter_camera_demo/screens/preview_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

import '../main.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? controller;
  VideoPlayerController? videoController;

  File? _imageFile;
  File? _videoFile;

  // Initial values
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  bool _isRearCameraSelected = true;
  bool _isVideoCameraSelected = false;
  bool _isRecordingInProgress = false;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;

  // Current values
  double _currentZoomLevel = 1.0;
  double _currentExposureOffset = 0.0;
  FlashMode? _currentFlashMode;

  List<File> allFileList = [];

  final resolutionPresets = ResolutionPreset.values;

  ResolutionPreset currentResolutionPreset = ResolutionPreset.high;

  getPermissionStatus() async {
    await Permission.camera.request();
    var status = await Permission.camera.status;

    if (status.isGranted) {
      log('Camera Permission: GRANTED');
      setState(() {
        _isCameraPermissionGranted = true;
      });
      // Set and initialize the new camera
      onNewCameraSelected(cameras[0]);
      // refreshAlreadyCapturedImages();
    } else {
      log('Camera Permission: DENIED');
    }
  }

  refreshAlreadyCapturedImages() async {
    final directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> fileList = await directory.list().toList();
    allFileList.clear();
    List<Map<int, dynamic>> fileNames = [];

    fileList.forEach((file) {
      if (file.path.contains('.jpg') || file.path.contains('.mp4')) {
        allFileList.add(File(file.path));

        String name = file.path.split('/').last.split('.').first;
        fileNames.add({0: int.parse(name), 1: file.path.split('/').last});
      }
    });

    if (fileNames.isNotEmpty) {
      final recentFile =
          fileNames.reduce((curr, next) => curr[0] > next[0] ? curr : next);
      String recentFileName = recentFile[1];
      if (recentFileName.contains('.mp4')) {
        _videoFile = File('${directory.path}/$recentFileName');
        _imageFile = null;
        _startVideoPlayer();
      } else {
        _imageFile = File('${directory.path}/$recentFileName');
///////////////////// comand
        // List<int> imageBytes = await _imageFile!.readAsBytesSync();
        // String base64Image = base64Encode(imageBytes);

        // // await http.post(Uri.parse('http://192.168.0.21:5000/im_size'), body: {

        // //    'image': '$base64Image',
        // // },

        // // );
        // var dio = Dio();

        // var formData = FormData.fromMap({
        //   'image': '$base64Image',
        // });
        // var response =
        //     await dio.post('http://192.168.0.110:5000/im_size', data: formData);

        _videoFile = null;
      }

      setState(() {});
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;

    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      print('Error occured while taking picture: $e');
      return null;
    }
  }

  Future<void> _startVideoPlayer() async {
    if (_videoFile != null) {
      videoController = VideoPlayerController.file(_videoFile!);
      await videoController!.initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized,
        // even before the play button has been pressed.
        setState(() {});
      });
      await videoController!.setLooping(true);
      await videoController!.play();
    }
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (controller!.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }

    try {
      await cameraController!.startVideoRecording();
      setState(() {
        _isRecordingInProgress = true;
        print(_isRecordingInProgress);
      });
    } on CameraException catch (e) {
      print('Error starting to record video: $e');
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Recording is already is stopped state
      return null;
    }

    try {
      XFile file = await controller!.stopVideoRecording();
      setState(() {
        _isRecordingInProgress = false;
      });
      return file;
    } on CameraException catch (e) {
      print('Error stopping video recording: $e');
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Video recording is not in progress
      return;
    }

    try {
      await controller!.pauseVideoRecording();
    } on CameraException catch (e) {
      print('Error pausing video recording: $e');
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // No video recording was in progress
      return;
    }

    try {
      await controller!.resumeVideoRecording();
    } on CameraException catch (e) {
      print('Error resuming video recording: $e');
    }
  }

  void resetCameraValues() async {
    _currentZoomLevel = 1.0;
    _currentExposureOffset = 0.0;
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;

    final CameraController cameraController = CameraController(
      cameraDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();

    resetCameraValues();

    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value),
        cameraController
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);

      _currentFlashMode = controller!.value.flashMode;
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    controller!.setExposurePoint(offset);
    controller!.setFocusPoint(offset);
  }

  @override
  void initState() {
    // Hide the status bar in Android
    SystemChrome.setEnabledSystemUIOverlays([]);
    getPermissionStatus();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _isCameraPermissionGranted
            ? _isCameraInitialized
                ? Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1 / controller!.value.aspectRatio,
                        child: Stack(
                          children: [
                            CameraPreview(
                              controller!,
                              child: LayoutBuilder(builder:
                                  (BuildContext context,
                                      BoxConstraints constraints) {
                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTapDown: (details) =>
                                      onViewFinderTap(details, constraints),
                                );
                              }),
                            ),
                            // TODO: Uncomment to preview the overlay
                            // Center(
                            //   child: Image.asset(
                            //     'assets/camera_aim.png',
                            //     color: Colors.greenAccent,
                            //     width: 150,
                            //     height: 150,
                            //   ),
                            // ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16.0,
                                8.0,
                                16.0,
                                8.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                          right: 8.0,
                                        ),
                                        child: DropdownButton<ResolutionPreset>(
                                          dropdownColor: Colors.black87,
                                          underline: Container(),
                                          value: currentResolutionPreset,
                                          items: [
                                            for (ResolutionPreset preset
                                                in resolutionPresets)
                                              DropdownMenuItem(
                                                child: Text(
                                                  preset
                                                      .toString()
                                                      .split('.')[1]
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                value: preset,
                                              )
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              currentResolutionPreset = value!;
                                              _isCameraInitialized = false;
                                            });
                                            onNewCameraSelected(
                                                controller!.description);
                                          },
                                          hint: Text("Select item"),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 8.0, top: 16.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          _currentExposureOffset
                                                  .toStringAsFixed(1) +
                                              'x',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: RotatedBox(
                                      quarterTurns: 3,
                                      child: Container(
                                        height: 30,
                                        child: Slider(
                                          value: _currentExposureOffset,
                                          min: _minAvailableExposureOffset,
                                          max: _maxAvailableExposureOffset,
                                          activeColor: Colors.white,
                                          inactiveColor: Colors.white30,
                                          onChanged: (value) async {
                                            setState(() {
                                              _currentExposureOffset = value;
                                            });
                                            await controller!
                                                .setExposureOffset(value);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Slider(
                                          value: _currentZoomLevel,
                                          min: _minAvailableZoom,
                                          max: _maxAvailableZoom,
                                          activeColor: Colors.white,
                                          inactiveColor: Colors.white30,
                                          onChanged: (value) async {
                                            setState(() {
                                              _currentZoomLevel = value;
                                            });
                                            await controller!
                                                .setZoomLevel(value);
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black87,
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              _currentZoomLevel
                                                      .toStringAsFixed(1) +
                                                  'x',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: _isRecordingInProgress
                                            ? () async {
                                                if (controller!
                                                    .value.isRecordingPaused) {
                                                  await resumeVideoRecording();
                                                } else {
                                                  await pauseVideoRecording();
                                                }
                                              }
                                            : () {
                                                setState(() {
                                                  _isCameraInitialized = false;
                                                });
                                                onNewCameraSelected(cameras[
                                                    _isRearCameraSelected
                                                        ? 1
                                                        : 0]);
                                                setState(() {
                                                  _isRearCameraSelected =
                                                      !_isRearCameraSelected;
                                                });
                                              },
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(
                                              Icons.circle,
                                              color: Colors.black38,
                                              size: 60,
                                            ),
                                            _isRecordingInProgress
                                                ? controller!
                                                        .value.isRecordingPaused
                                                    ? Icon(
                                                        Icons.play_arrow,
                                                        color: Colors.white,
                                                        size: 30,
                                                      )
                                                    : Icon(
                                                        Icons.pause,
                                                        color: Colors.white,
                                                        size: 30,
                                                      )
                                                : Icon(
                                                    _isRearCameraSelected
                                                        ? Icons.camera_front
                                                        : Icons.camera_rear,
                                                    color: Colors.white,
                                                    size: 30,
                                                  ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: _isVideoCameraSelected
                                            ? () async {
                                                if (_isRecordingInProgress) {
                                                  XFile? rawVideo =
                                                      await stopVideoRecording();
                                                  File videoFile =
                                                      File(rawVideo!.path);

                                                  int currentUnix = DateTime
                                                          .now()
                                                      .millisecondsSinceEpoch;

                                                  final directory =
                                                      await getApplicationDocumentsDirectory();

                                                  String fileFormat = videoFile
                                                      .path
                                                      .split('.')
                                                      .last;

                                                  _videoFile =
                                                      await videoFile.copy(
                                                    '${directory.path}/$currentUnix.$fileFormat',
                                                  );

                                                  _startVideoPlayer();
                                                } else {
                                                  await startVideoRecording();
                                                }
                                              }
                                            : () async {
                                                XFile? rawImage =
                                                    await takePicture();
                                                File imageFile =
                                                    File(rawImage!.path);

                                                int currentUnix = DateTime.now()
                                                    .millisecondsSinceEpoch;

                                                final directory =
                                                    await getApplicationDocumentsDirectory();

                                                String fileFormat = imageFile
                                                    .path
                                                    .split('.')
                                                    .last;

                                                print(fileFormat);

                                                await imageFile.copy(
                                                  '${directory.path}/$currentUnix.$fileFormat',
                                                );

                                                refreshAlreadyCapturedImages();
                                              },
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(
                                              Icons.circle,
                                              color: _isVideoCameraSelected
                                                  ? Colors.white
                                                  : Colors.white38,
                                              size: 80,
                                            ),
                                            Icon(
                                              Icons.circle,
                                              color: _isVideoCameraSelected
                                                  ? Colors.red
                                                  : Colors.white,
                                              size: 65,
                                            ),
                                            _isVideoCameraSelected &&
                                                    _isRecordingInProgress
                                                ? Icon(
                                                    Icons.stop_rounded,
                                                    color: Colors.white,
                                                    size: 32,
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: _imageFile != null ||
                                                _videoFile != null
                                            ? () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PreviewScreen(
                                                      imageFile: _imageFile!,
                                                      fileList: allFileList,
                                                    ),
                                                  ),
                                                );
                                              }
                                            : null,
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                            image: _imageFile != null
                                                ? DecorationImage(
                                                    image:
                                                        FileImage(_imageFile!),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                          ),
                                          child: videoController != null &&
                                                  videoController!
                                                      .value.isInitialized
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: AspectRatio(
                                                    aspectRatio:
                                                        videoController!
                                                            .value.aspectRatio,
                                                    child: VideoPlayer(
                                                        videoController!),
                                                  ),
                                                )
                                              : Container(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                          right: 4.0,
                                        ),
                                        child: TextButton(
                                          onPressed: _isRecordingInProgress
                                              ? null
                                              : () {
                                                  if (_isVideoCameraSelected) {
                                                    setState(() {
                                                      _isVideoCameraSelected =
                                                          false;
                                                    });
                                                  }
                                                },
                                          style: TextButton.styleFrom(
                                            primary: _isVideoCameraSelected
                                                ? Colors.black54
                                                : Colors.black,
                                            backgroundColor:
                                                _isVideoCameraSelected
                                                    ? Colors.white30
                                                    : Colors.white,
                                          ),
                                          child: Text('IMAGE'),
                                        ),
                                      ),
                                    ),

                                    // test button
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                          right: 4.0,
                                        ),
                                        child: TextButton(
                                          // onPressed:
                                          style: TextButton.styleFrom(
                                            backgroundColor:
                                                _isVideoCameraSelected
                                                    ? Colors.white30
                                                    : Colors.white,
                                          ),
                                          onPressed: () async {
                                          
                                            String base64Image =
                                                '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';
                                           
 

                                            // List<int> imageBytes =
                                            //     await _imageFile!
                                            //         .readAsBytesSync();
                                            // String base64Image =
                                            //     base64Encode(imageBytes);

                                            var dio = Dio();

                                            var formData =
                                                await FormData.fromMap({
                                              'image': '$base64Image',
                                            });
                                            var response = await dio.post(
                                                'http://192.168.0.106:5000/im_size_test',
                                                data: formData);
                                            // var response = await dio.post(
                                            //   'http://192.168.0.114:5000/im_size',
                                            // );
                                            var jsontext = await json
                                                .decode(response.toString());
                                            var Information =
                                                await jsontext["Information"];
                                            var face_img =
                                                await jsontext["img_face"];
                                            var img_GTTT =
                                                await jsontext["img_GTTT"];
                                            //decode img 64
                                            final face_img1 =
                                                await base64Decode(face_img!);
                                            final img_GTTT1 =
                                                await base64Decode(img_GTTT!);

                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => newpage(
                                                  face: face_img1,
                                                  gtt: img_GTTT1,
                                                  infor: Information,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text('TEST BUTTON'),
                                        ),
                                      ),
                                    ),

                                    ///end test button
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 4.0, right: 8.0),
                                        child: TextButton(
                                          onPressed: () {
                                            if (!_isVideoCameraSelected) {
                                              setState(() {
                                                _isVideoCameraSelected = true;
                                              });
                                            }
                                          },
                                          style: TextButton.styleFrom(
                                            primary: _isVideoCameraSelected
                                                ? Colors.black
                                                : Colors.black54,
                                            backgroundColor:
                                                _isVideoCameraSelected
                                                    ? Colors.white
                                                    : Colors.white30,
                                          ),
                                          child: Text('VIDEO'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16.0, 8.0, 16.0, 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        setState(() {
                                          _currentFlashMode = FlashMode.off;
                                        });
                                        await controller!.setFlashMode(
                                          FlashMode.off,
                                        );
                                      },
                                      child: Icon(
                                        Icons.flash_off,
                                        color:
                                            _currentFlashMode == FlashMode.off
                                                ? Colors.amber
                                                : Colors.white,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        setState(() {
                                          _currentFlashMode = FlashMode.auto;
                                        });
                                        await controller!.setFlashMode(
                                          FlashMode.auto,
                                        );
                                      },
                                      child: Icon(
                                        Icons.flash_auto,
                                        color:
                                            _currentFlashMode == FlashMode.auto
                                                ? Colors.amber
                                                : Colors.white,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        setState(() {
                                          _currentFlashMode = FlashMode.always;
                                        });
                                        await controller!.setFlashMode(
                                          FlashMode.always,
                                        );
                                      },
                                      child: Icon(
                                        Icons.flash_on,
                                        color: _currentFlashMode ==
                                                FlashMode.always
                                            ? Colors.amber
                                            : Colors.white,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        setState(() {
                                          _currentFlashMode = FlashMode.torch;
                                        });
                                        await controller!.setFlashMode(
                                          FlashMode.torch,
                                        );
                                      },
                                      child: Icon(
                                        Icons.highlight,
                                        color:
                                            _currentFlashMode == FlashMode.torch
                                                ? Colors.amber
                                                : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      'LOADING',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(),
                  Text(
                    'Permission denied',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      getPermissionStatus();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Give permission',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
