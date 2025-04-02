import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreen({super.key, required this.videoPath});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  double _currentPosition = 0;
  double _totalDuration = 0;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {
          _totalDuration = _controller.value.duration.inMilliseconds.toDouble();
          _controller.play();
          _isPlaying = true;
        });
        _setupVideoPlayerListener();
      });
  }

  void _setupVideoPlayerListener() {
    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _currentPosition = _controller.value.position.inMilliseconds.toDouble();
          _isPlaying = _controller.value.isPlaying;
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _showVideoDetails,
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: _controller.value.isInitialized
          ? GestureDetector(
              onTap: _toggleControls,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 150.0),
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: _showControls ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: Stack(
                      children: [
                        if (!_isPlaying)
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black45,
                              ),
                              child: IconButton(
                                iconSize: 60,
                                icon: Icon(Icons.play_arrow, color: Colors.white),
                                onPressed: () {
                                  _controller.play();
                                },
                              ),
                            ),
                          ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.black87, Colors.transparent],
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SliderTheme(
                                  data: SliderThemeData(
                                    thumbColor: Colors.white,
                                    activeTrackColor: Colors.white,
                                    inactiveTrackColor: Colors.grey[700],
                                    trackHeight: 2.0,
                                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
                                  ),
                                  child: Slider(
                                    min: 0.0,
                                    max: _totalDuration,
                                    value: _currentPosition,
                                    onChanged: (value) {
                                      setState(() {
                                        _currentPosition = value;
                                      });
                                    },
                                    onChangeEnd: (value) {
                                      _controller.seekTo(Duration(milliseconds: value.toInt()));
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 40.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        _formatDuration(
                                            Duration(milliseconds: _currentPosition.toInt())),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Spacer(),
                                      IconButton(
                                        icon: Icon(
                                          Icons.replay_10,
                                          color: Colors.white,
                                          size: 32.0,
                                        ),
                                        onPressed: () {
                                          _controller.seekTo(Duration(
                                            milliseconds: (_currentPosition - 10000)
                                                .clamp(0, _totalDuration)
                                                .toInt(),
                                          ));
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _isPlaying ? Icons.pause : Icons.play_arrow,
                                          color: Colors.white,
                                          size: 42,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (_controller.value.isPlaying) {
                                              _controller.pause();
                                            } else {
                                              _controller.play();
                                            }
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.forward_10,
                                          color: Colors.white,
                                          size: 32.0,
                                        ),
                                        onPressed: () {
                                          _controller.seekTo(Duration(
                                            milliseconds: (_currentPosition + 10000)
                                                .clamp(0, _totalDuration)
                                                .toInt(),
                                          ));
                                        },
                                      ),
                                      Spacer(),
                                      Text(
                                        _formatDuration(
                                            Duration(milliseconds: _totalDuration.toInt())),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  Future<void> _showVideoDetails() async {
    try {
      final info = await VideoCompress.getMediaInfo(widget.videoPath);

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Video Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Title', widget.videoPath.split('/').last),
                _buildDetailRow('File Path', widget.videoPath),
                _buildDetailRow(
                  'Duration',
                  _formatDuration(Duration(milliseconds: _totalDuration.toInt())),
                ),
                _buildDetailRow(
                    'File Size', '${(info.filesize! / (1024 * 1024)).toStringAsFixed(2)} MB'),
                _buildDetailRow('Resolution', '${info.width} x ${info.height}'),
                _buildDetailRow('Orientation', info.orientation.toString()),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting video details: $e')),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
