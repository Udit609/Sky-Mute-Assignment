import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:path_provider/path_provider.dart';
import '../helpers/database_helper.dart';

class VideoMerger {
  static Future<String?> mergeVideos(List<Map> selectedVideos) async {
    if (selectedVideos.isEmpty || selectedVideos.length < 2) {
      return null;
    }
    try {
      final dir = await getApplicationDocumentsDirectory();
      final outputPath = '${dir.path}/merged_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final inputListPath = '${dir.path}/input_list.txt';
      final inputListFile = File(inputListPath);

      String fileContent = '';
      for (var video in selectedVideos) {
        fileContent += "file '${video['path']}'\n";
      }
      await inputListFile.writeAsString(fileContent);

      final session =
          await FFmpegKit.execute('-f concat -safe 0 -i $inputListPath -c copy $outputPath');
      final returnCode = await session.getReturnCode();

      if (await inputListFile.exists()) {
        await inputListFile.delete();
      }

      if (ReturnCode.isSuccess(returnCode)) {
        await DatabaseHelper().insertMergedVideo(outputPath);
        return outputPath;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
