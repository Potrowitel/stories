import 'storyCell.dart';

enum MediaType {
  image,
  video,
}

enum SourceType {
  asset,
  url,
}

class Story {
  final String path;
  final StoryCell cell;
  SourceType sourceType;
  MediaType meadiaType;
  Duration duration;

  Story(
    this.path,
    this.cell, {
    this.meadiaType = MediaType.image,
    this.sourceType = SourceType.asset,
    this.duration = const Duration(seconds: 5),
  });
}
