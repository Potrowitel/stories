import 'dart:ui';
import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as rad;

import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:video_player/video_player.dart';
import 'package:story_view/story_view.dart';

import 'package:stories/models/storyCell.dart';
import 'package:stories/models/story.dart';

class Stories extends StatefulWidget {
  final List<StoryCell> cells;
  final List<Story> stories;
  final Color backgroundColor;
  final Color indicatorColor;
  Stories({
    required this.cells,
    required this.stories,
    required this.backgroundColor,
    required this.indicatorColor,
  });

  @override
  _StoriesState createState() => _StoriesState();
}

class _StoriesState extends State<Stories> {
  List<StoryPage> storyPages = [];
  late PageController pageController;

  void onPageComplete() {
    if (pageController.page == widget.cells.length - 1)
      Navigator.of(context).pop();

    pageController.nextPage(
        duration: Duration(milliseconds: 300), curve: Curves.linear);
  }

  @override
  void initState() {
    super.initState();
    widget.cells.forEach((elem) {
      storyPages.add(StoryPage(
        stories: _getStories(elem),
        onPageComplete: onPageComplete,
        backgroundColor: widget.backgroundColor,
        indicatorColor: widget.indicatorColor,
      ));
    });
  }

  List<Story> _getStories(dynamic elem) {
    return widget.stories.where((e) => e.cell == elem).toList();
  }

  @override
  Widget build(BuildContext context) {
    _onStorySwipeClicked(int initialPage) {
      pageController = PageController(initialPage: initialPage);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StorySwipe(
            children: storyPages,
            pageController: pageController,
          ),
        ),
      );
    }

    return Scaffold(
        body: Center(
      child: Container(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.cells.length,
          itemBuilder: (context, index) {
            return GestureDetector(
                onTap: () {
                  _onStorySwipeClicked(index);
                },
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: AdvancedAvatar(
                    image: AssetImage(widget.cells[index].imagePath),
                  ),
                ));
          },
        ),
      ),
    ));
  }
}

////////////////////////////////////
//          StoryPage
////////////////////////////////////

class StoryPage extends StatefulWidget {
  final List<Story> stories;
  final Color backgroundColor;
  final Color indicatorColor;
  final void Function() onPageComplete;

  StoryPage({
    required this.stories,
    required this.onPageComplete,
    required this.backgroundColor,
    required this.indicatorColor,
  });

  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  final storyController = StoryController();

  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StoryView(
        storyItems: toStoryItems(widget.stories),
        onComplete: () {
          widget.onPageComplete();
        },
        inline: false,
        progressPosition: ProgressPosition.top,
        repeat: false,
        controller: storyController,
      ),
    );
  }

  List<StoryItem> toStoryItems(List<Story> stories) {
    List<StoryItem> storyItems = [];
    for (int i = 0; i < stories.length; i++) {
      switch (stories[i].meadiaType) {
        case MediaType.image:
          {
            switch (stories[i].sourceType) {
              case SourceType.asset:
                {
                  storyItems.add(StoryItem(ImageWidget(stories[i].path),
                      duration: stories[i].duration));
                  break;
                }
              case SourceType.url:
                {
                  storyItems.add(StoryItem(
                      ImageWidget(stories[i].path, isNetworkImage: true),
                      duration: stories[i].duration));
                  break;
                }
              default:
                break;
            }

            break;
          }
        case MediaType.video:
          {
            switch (stories[i].sourceType) {
              case SourceType.asset:
                {
                  storyItems.add(StoryItem(
                      VideoWidget(stories[i].path, widget.backgroundColor,
                          widget.indicatorColor,
                          key: Key('video-$i')),
                      duration: stories[i].duration));
                  break;
                }
              case SourceType.url:
                {
                  storyItems.add(StoryItem(
                      VideoWidget(stories[i].path, widget.backgroundColor,
                          widget.indicatorColor,
                          key: Key('video-$i'), isNetworkVideo: true),
                      duration: stories[i].duration));
                  break;
                }
              default:
                break;
            }
            break;
          }
        default:
          break;
      }
    }
    return storyItems;
  }
}

////////////////////////////////////
//         ImageWidget
////////////////////////////////////

class ImageWidget extends StatelessWidget {
  final String path;
  final bool isNetworkImage;
  const ImageWidget(this.path, {Key? key, this.isNetworkImage = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.zero,
            child: Stack(
              children: [
                Positioned.fill(child: Image.asset(path, fit: BoxFit.cover)),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
          Image.asset(path),
        ],
      ),
    );
  }
}

////////////////////////////////////
//         VideoWidget
////////////////////////////////////

class VideoWidget extends StatefulWidget {
  final String path;
  final bool isNetworkVideo;
  final Color backgroundColor;
  final Color indicatorColor;
  VideoWidget(
    this.path,
    this.backgroundColor,
    this.indicatorColor, {
    Key? key,
    this.isNetworkVideo = false,
  }) : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    _controller = VideoPlayerController.asset(widget.path);

    _controller.addListener(() {
      setState(() {});
    });

    //_controller.setLooping(true);
    _controller.initialize().then((_) => setState(() {
          isLoading = false;
        }));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? Container(
            child: GestureDetector(
              onTapDown: (value) {
                _controller.pause();
              },
              onTapCancel: () {
                _controller.play();
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.zero,
                    child: Stack(
                      children: [
                        Positioned.fill(child: VideoPlayer(_controller)),
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                          child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            VideoPlayer(_controller),
                            //_ControlsOverlay(controller: _controller),
                            // VideoProgressIndicator(_controller, allowScrubbing: true),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container(
            color: widget.backgroundColor,
            child: Center(
                child: CircularProgressIndicator(
              color: widget.indicatorColor,
            )));
  }
}

////////////////////////////////////
//            Swipe
////////////////////////////////////

class StorySwipe extends StatefulWidget {
  final List<Widget> children;
  final PageController pageController;

  StorySwipe({
    required this.children,
    required this.pageController,
  }) {
    assert(children.length != 0);
  }

  @override
  _StorySwipeState createState() => _StorySwipeState();
}

class _StorySwipeState extends State<StorySwipe> {
//  late PageController _pageController;
  double currentPageValue = 0.0;

  @override
  void initState() {
    super.initState();

    //_pageController = PageController(initialPage: widget.initialPage);
    widget.pageController.addListener(() {
      setState(() {
        currentPageValue = widget.pageController.page!;
      });
    });
  }

  void next() {
    setState(() {
      currentPageValue = widget.pageController.page!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: widget.pageController,
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        double value;

        if (widget.pageController.position.haveDimensions == false) {
          value = index.toDouble();
        } else {
          value = widget.pageController.page!;
        }
        return _SwipeWidget(
          index: index,
          pageNotifier: value,
          child: widget.children[index],
        );
      },
    );
  }
}

num degToRad(num deg) => deg * (pi / 180.0);

class _SwipeWidget extends StatelessWidget {
  final int index;

  final double pageNotifier;

  final Widget child;

  const _SwipeWidget({
    Key? key,
    required this.index,
    required this.pageNotifier,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLeaving = (index - pageNotifier) <= 0;
    final t = (index - pageNotifier);
    final rotationY = lerpDouble(0, 90, t);
    final opacity = lerpDouble(0, 1, t.abs())!.clamp(0.0, 1.0);
    final transform = Matrix4.identity();
    transform.setEntry(3, 2, 0.001);
    transform.rotateY(-rad.radians(rotationY!));
    return Transform(
      alignment: isLeaving ? Alignment.centerRight : Alignment.centerLeft,
      transform: transform,
      child: Stack(
        children: [
          child,
          Positioned.fill(
            child: Opacity(
              opacity: opacity,
              child: SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
