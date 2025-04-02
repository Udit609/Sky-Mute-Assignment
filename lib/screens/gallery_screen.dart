import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sky_mute/screens/video_player_screen.dart';
import '../helpers/database_helper.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<Map> mergedVideos = [];

  @override
  void initState() {
    super.initState();
    loadMergedVideos();
  }

  Future<void> loadMergedVideos() async {
    mergedVideos = await DatabaseHelper().getMergedVideos();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: mergedVideos.isEmpty
            ? Center(
                child: Text(
                  "No merged videos yet",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisExtent: MediaQuery.of(context).size.width / 1.5,
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: mergedVideos.length,
                itemBuilder: (context, index) {
                  final video = mergedVideos[index];
                  final thumbnailPath = video['thumbnail_path'];
                  final videoPath = video['path'];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerScreen(videoPath: videoPath),
                        ),
                      );
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            image: DecorationImage(
                              image: FileImage(
                                File(thumbnailPath),
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: thumbnailPath != null
                              ? null
                              : Container(
                                  color: Colors.grey[800],
                                  child: Center(
                                    child: Text(
                                      "Merged Video ${index + 1}",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                        ),
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
