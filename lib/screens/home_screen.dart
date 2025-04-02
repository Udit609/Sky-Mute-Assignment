import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sky_mute/screens/video_player_screen.dart';
import '../helpers/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map> allVideos = [];
  bool isSelectionMode = false;
  List<Map> selectedVideos = [];

  @override
  void initState() {
    super.initState();
    loadAllVideos();
  }

  Future<void> loadAllVideos() async {
    allVideos = await DatabaseHelper().getAllVideos();
    setState(() {});
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
        if (video['type'] == 'recorded') {
          await dbHelper.deleteRecordedVideo(video['id']);
        } else {
          await dbHelper.deleteMergedVideo(video['id']);
        }
        await File(video['path']).delete();
        await File(video['thumbnail_path']).delete();
      }

      await loadAllVideos();

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
        title: const Text(
          'All Videos',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          isSelectionMode
              ? IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: deleteSelectedVideos,
                )
              : SizedBox.shrink(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: allVideos.isEmpty
            ? const Center(
                child: Text(
                  "No videos yet!",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisExtent: MediaQuery.of(context).size.width / 2,
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: allVideos.length,
                itemBuilder: (context, index) {
                  final video = allVideos[index];
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
                          padding: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.transparent,
                              width: isSelected ? 3.0 : 0.0,
                            ),
                            image: (thumbnailPath != null)
                                ? DecorationImage(
                                    image: FileImage(File(thumbnailPath)),
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
              ),
      ),
    );
  }
}
