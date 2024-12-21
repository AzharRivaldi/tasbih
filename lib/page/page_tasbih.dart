import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vibration/vibration.dart';

import '../tools/animated_flip_counter.dart';

class PageTasbih extends StatefulWidget {
  const PageTasbih({super.key});

  @override
  State<PageTasbih> createState() => PageTasbihState();
}

class PageTasbihState extends State<PageTasbih> {
  CarouselSliderController buttonCarouselController = CarouselSliderController();
  final PageController controller = PageController(viewportFraction: 0.1, initialPage: 5);
  final int numberOfCountsToCompleteRound = 33;
  String kBeadsCount = 'beadsCount';
  String kRoundCount = 'roundCount';
  int imageIndex = 1;
  int beadCounter = 0;
  int roundCounter = 0;
  int accumulatedCounter = 0;
  bool canVibrate = true;
  bool isDisposed = false;
  List<String> listTasbih = [
    'سُبْحَانَ ٱللَّٰهِ',
    'اَلْحَمْدُ للَّهِ',
    'ٱللَّٰهُ أَكْبَرُ',
    'لا إِلَهَ إِلاَّ اللهُ'
  ];
  final List<Color> bgColour = [
    Colors.teal.shade50,
    Colors.lime.shade50,
    Colors.lightBlue.shade50,
    Colors.pink.shade50,
    Colors.black12
  ];

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Tasbih",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: _clicked,
        onVerticalDragStart: (_) => _clicked(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
                flex: 2,
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 45),
                          IconButton(
                              tooltip: 'Change color',
                              icon: const Icon(Icons.palette, color: Colors.black),
                              onPressed: () {
                                setState(() {
                                  imageIndex < 5
                                      ? imageIndex++
                                      : imageIndex = 1;
                                });
                              }
                          ),
                          IconButton(
                              tooltip: 'Reset counter',
                              icon: const Icon(Icons.refresh, color: Colors.black),
                              onPressed: () {
                                confirmReset(context, _resetEverything);
                              }
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        textDirection: TextDirection.ltr,
                        children: [
                          Counter(counter: roundCounter, counterName: 'Round'),
                          Counter(counter: beadCounter, counterName: 'Beads'),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Accumulated',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                )
                            ),
                            const SizedBox(width: 10),
                            AnimatedFlipCounter(
                                value: accumulatedCounter,
                                duration: const Duration(milliseconds: 730),
                                size: 14),
                          ],
                        ),
                      ),
                      CarouselSlider(
                        carouselController: buttonCarouselController,
                        options: CarouselOptions(
                          height: 100,
                          enlargeCenterPage: true,
                        ),
                        items: [0, 1, 2, 3].map((i) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  decoration: BoxDecoration(
                                      color: bgColour[imageIndex - 1],
                                      borderRadius: BorderRadius.circular(12)
                                  ),
                                  child: Center(
                                      child: Text(listTasbih[i],
                                          style: const TextStyle(
                                            fontSize: 34,
                                            color: Colors.black,
                                          )
                                      )
                                  )
                              );
                            },
                          );
                        }).toList(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                              onPressed: () {
                                buttonCarouselController.previousPage();
                              },
                              icon: const Icon(Icons.navigate_before, color: Colors.black)),
                          IconButton(
                              onPressed: () {
                                buttonCarouselController.nextPage();
                              },
                              icon: const Icon(Icons.navigate_next, color: Colors.black)),
                        ],
                      ),
                      const Spacer()
                    ],
                  ),
                )
            ),
            Expanded(
              flex: 1,
              child: PageView.builder(
                reverse: true,
                physics: const NeverScrollableScrollPhysics(),
                controller: controller,
                scrollDirection: Axis.vertical,
                itemBuilder: (_, __) {
                  return Image.asset(
                    'assets/beads/bead-$imageIndex.png',
                  );
                },
                itemCount: null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void loadSettings() async {
    bool? canVibrate = await Vibration.hasVibrator();
    if (!isDisposed) {
      setState(() {
        canVibrate = canVibrate!;
        loadData();
      });
    }
  }

  void loadData() {
    if (!isDisposed) {
      setState(() {
        beadCounter = GetStorage().read(kBeadsCount) ?? 0;
        roundCounter = GetStorage().read(kRoundCount) ?? 0;
        accumulatedCounter = roundCounter * numberOfCountsToCompleteRound + beadCounter;
      });
    }
  }

  void _resetEverything() {
    GetStorage().write(kBeadsCount, 0);
    GetStorage().write(kRoundCount, 0);
    loadData();
  }

  void _clicked() {
    if (!isDisposed) {
      setState(() {
        beadCounter++;
        accumulatedCounter++;
        if (beadCounter > numberOfCountsToCompleteRound) {
          beadCounter = 1;
          roundCounter++;
          if (canVibrate) Vibration.vibrate(duration: 500, amplitude: 128);
        }
      });
    }
    GetStorage().write(kBeadsCount, beadCounter);
    GetStorage().write(kRoundCount, roundCounter);
    int nextPage = controller.page!.round() + 1;
    controller.animateToPage(nextPage,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn,
    );
  }
}

class Counter extends StatelessWidget {
  const Counter({super.key, required this.counter, required this.counterName});

  final int counter;
  final String counterName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedFlipCounter(
          duration: const Duration(milliseconds: 300),
          value: counter,
        ),
        Text(counterName,
            style: const TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w300)
        )
      ],
    );
  }
}

void confirmReset(BuildContext context, VoidCallback callback) {
  const confirmText = Text('Reset', style: TextStyle(color: Colors.red,));
  const cancelText = Text('Batal', style: TextStyle(color: Colors.black));
  const dialogTitle = Text("Reset Counter?", style: TextStyle(color: Colors.black));
  const dialogContent = Text("Tindakan ini tidak bisa dibatalkan.", style: TextStyle(color: Colors.black));

  void confirmResetAction() {
    callback();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.white,
          ),
          SizedBox(width: 10),
          Text('Reset Counter berhasil.', style: TextStyle(
              color: Colors.white,
              fontFamily: 'Noto'))
        ],
      ),
      backgroundColor: Colors.amber,
      shape: StadiumBorder(),
      behavior: SnackBarBehavior.floating,
    ));
    Navigator.of(context).pop();
  }

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (_) {
      return AlertDialog(
        title: dialogTitle,
        content: dialogContent,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: cancelText,
          ),
          TextButton(
            onPressed: confirmResetAction,
            child: confirmText,
          ),
        ],
      );
    },
  );
}