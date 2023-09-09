import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:todoapp/intro%20screens/intro_screen_1.dart';
import 'package:todoapp/intro%20screens/intro_screen_2.dart';
import 'package:todoapp/intro%20screens/intro_screen_3.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  int numberOfPages = 3;
  bool lastPage = false;
  PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            onPageChanged: (index) {
              setState(() {
                lastPage = (index == (numberOfPages - 1));
              });
            },
            controller: _controller,
            children: const [
              IntroScreen1(),
              IntroScreen2(),
              IntroScreen3(),
            ],
          ),
          Container(
              alignment: const Alignment(0, 0.75),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    child: const SizedBox(
                      child: Text("Skip"),
                    ),
                    onTap: () {
                      _controller.jumpToPage(numberOfPages - 1);
                    },
                  ),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: numberOfPages,
                    effect: const ExpandingDotsEffect(),
                  ),

                  // On Last Page or Not?

                  lastPage
                      ? GestureDetector(
                          child: const SizedBox(
                            child: Text("Done"),
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                '/HomePage', (route) => false);
                          },
                        )
                      : GestureDetector(
                          child: const SizedBox(
                            child: Text("Next"),
                          ),
                          onTap: () {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 100),
                              curve: Curves.easeIn,
                            );
                          },
                        ),
                ],
              ))
        ],
      ),
    );
  }
}
