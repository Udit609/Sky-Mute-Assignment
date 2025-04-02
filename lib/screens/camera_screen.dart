import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sky_mute/screens/video_player_screen.dart';
import 'dart:io';
import '../helpers/database_helper.dart';
import '../helpers/video_merger.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  String? videoPath;
  List<Map> recordedVideos = [];

  bool isSelectionMode = false;
  List<Map> selectedVideos = [];
  bool isMerging = false;

  @override
  void initState() {
    super.initState();
    loadRecordedVideos();
  }

  Future<void> loadRecordedVideos() async {
    recordedVideos = await DatabaseHelper().getRecordedVideos();
    setState(() {});
  }

  Future<bool> requestPermissions() async {
    debugPrint("Requesting permissions...");

    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.manageExternalStorage,
      Permission.videos,
    ].request();

    debugPrint("Camera Permission: ${statuses[Permission.camera]}");
    debugPrint("Storage Permission: ${statuses[Permission.manageExternalStorage]}");
    debugPrint("Videos Permission: ${statuses[Permission.videos]}");

    if (statuses[Permission.camera]!.isGranted &&
        (statuses[Permission.manageExternalStorage]!.isGranted ||
            statuses[Permission.videos]!.isGranted)) {
      debugPrint("All required permissions granted.");
      return true;
    } else {
      debugPrint("Missing permissions.");
      return false;
    }
  }

  Future<void> recordVideo() async {
    bool hasPermissions = await requestPermissions();
    if (!hasPermissions) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Camera and storage permissions are required")),
      );
      return;
    }

    debugPrint("Permissions granted. Opening camera...");

    final XFile? video = await _picker.pickVideo(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (video != null) {
      debugPrint("Video recorded: ${video.path}");

      final dir = await getApplicationDocumentsDirectory();
      final savedPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';

      await File(video.path).copy(savedPath);
      debugPrint("Video saved to: $savedPath");

      await DatabaseHelper().insertRecordedVideo(savedPath);
      videoPath = savedPath;
      loadRecordedVideos();
    } else {
      debugPrint("No video recorded.");
    }
  }

  void toggleSelectionMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;
      if (!isSelectionMode) {
        selectedVideos.clear();
      }
    });
  }

  void toggleVideoSelection(Map video) {
    setState(() {
      final index = selectedVideos.indexWhere((v) => v['path'] == video['path']);
      if (index != -1) {
        selectedVideos.removeAt(index);
      } else {
        selectedVideos.add(video);
      }
    });
  }

  Future<void> mergeSelectedVideos() async {
    if (selectedVideos.isEmpty || selectedVideos.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least 2 videos to merge")),
      );
      return;
    }

    setState(() => isMerging = true);

    try {
      final mergedVideoPath = await VideoMerger.mergeVideos(selectedVideos);

      if (!mounted) return;

      if (mergedVideoPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Videos merged successfully")),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(videoPath: mergedVideoPath),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to merge videos")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error merging videos: $e")),
      );
    } finally {
      setState(() {
        isMerging = false;
        isSelectionMode = false;
        selectedVideos.clear();
      });
      loadRecordedVideos();
    }
  }

  Future<void> deleteSelectedVideos() async {
    if (selectedVideos.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Videos'),
        content: Text('Are you sure you want to delete ${selectedVideos.length} video(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final dbHelper = DatabaseHelper();
    try {
      for (var video in selectedVideos) {
        await dbHelper.deleteRecordedVideo(video['id']);
        await File(video['path']).delete();
        await File(video['thumbnail_path']).delete();
      }

      await loadRecordedVideos();

      setState(() {
        isSelectionMode = false;
        selectedVideos.clear();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Videos deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting videos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: toggleSelectionMode,
              )
            : null,
        centerTitle: true,
        title: Text(
          "Video Recorder",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          isSelectionMode ? popupMenu() : SizedBox.shrink(),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: isMerging
            ? Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  color: Colors.black,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text("Merging videos...", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  recordedVideos.isEmpty
                      ? Expanded(
                          child: Center(
                            child: Text(
                              "No videos yet!",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        )
                      : Expanded(child: recordedVideoGridView()),
                ],
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: FloatingActionButton(
          onPressed: recordVideo,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.videocam,
            color: Colors.black,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget recordedVideoGridView() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisExtent: MediaQuery.of(context).size.width / 2,
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: recordedVideos.length,
      itemBuilder: (context, index) {
        final video = recordedVideos[index];
        final thumbnailPath = video['thumbnail_path'];
        final videoPath = video['path'];
        final isSelected = selectedVideos.any((v) => v['path'] == video['path']);

        return GestureDetector(
          onTap: () {
            if (isSelectionMode) {
              toggleVideoSelection(video);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(videoPath: videoPath),
                ),
              );
            }
          },
          onLongPress: () {
            if (!isSelectionMode) {
              toggleSelectionMode();
              toggleVideoSelection(video);
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                padding: EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.transparent,
                    width: isSelected ? 3.0 : 0.0,
                  ),
                  image: (thumbnailPath != null)
                      ? DecorationImage(
                          image: FileImage(
                            File(thumbnailPath),
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (thumbnailPath != null)
                    ? null
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Center(
                          child: Text(
                            "No Preview",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
              ),
              if (isSelectionMode)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      isSelected ? Icons.check : Icons.circle_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              if (!isSelectionMode && (thumbnailPath != null))
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget popupMenu() {
    return PopupMenuButton<String>(
      color: Colors.black,
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (value) {
        switch (value) {
          case 'merge':
            mergeSelectedVideos();
            break;
          case 'delete':
            deleteSelectedVideos();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'merge',
          enabled: isSelectionMode && selectedVideos.length >= 2,
          child: Row(
            children: [
              Icon(Icons.merge, color: Colors.white),
              SizedBox(width: 10.0),
              Text(
                'Merge',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          enabled: isSelectionMode && selectedVideos.isNotEmpty,
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.white),
              SizedBox(width: 10.0),
              Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
