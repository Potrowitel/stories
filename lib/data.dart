import 'package:stories/models/story.dart';
import 'package:stories/models/storyCell.dart';

final cell = StoryCell(name: 'Octane', imagePath: 'assets/images/octane.jpg');
final cell1 = StoryCell(name: 'Cat', imagePath: 'assets/images/cat.jpg');
final cell2 = StoryCell(name: 'Cat1', imagePath: 'assets/images/cat.jpg');
final List<Story> stories = [
  Story('assets/images/image.jpg', cell),
  Story('assets/video/1.mp4', cell, meadiaType: MediaType.video),
  Story('assets/video/2.mp4', cell, meadiaType: MediaType.video),
  Story('assets/video/3.mp4', cell, meadiaType: MediaType.video),
  Story('assets/video/5.mp4', cell,
      meadiaType: MediaType.video, duration: Duration(seconds: 3)),
  Story('assets/gif/wow-cat.gif', cell),
  Story('assets/images/3.jpg', cell1),
  Story('assets/gif/wow-cat.gif', cell1),
  Story('assets/images/1.jpg', cell1),
  Story('assets/images/2.jpg', cell1),
  Story('assets/images/3.jpg', cell2),
];
//final List<StoryPage> stories1 = [];
