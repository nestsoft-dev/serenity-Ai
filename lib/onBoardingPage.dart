import 'package:ai_therapy/NavPage.dart';
import 'package:ai_therapy/constants/appconstant.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  int _currentPage = 0;
  final _pageContoller = PageController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                height: size.height * 0.55,
                width: size.width,

                child: PageView.builder(
                  controller: _pageContoller,
                  onPageChanged: (value) {
                    print('ScreenValue $value');
                    setState(() {
                      _currentPage = value;
                    });
                  },
                  itemCount: onboardingPages.length,
                  itemBuilder: (_, index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Lottie.asset(
                        onboardingPages[_currentPage]['image']!,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: size.height * .01),
              Expanded(
                child: Container(
                  width: size.width,
                  padding: EdgeInsets.all(10),

                  child: Column(
                    children: [
                      SizedBox(height: size.height * .03),
                      Text(
                        onboardingPages[_currentPage]['title']!,
                        style: TextStyle(
                          fontSize: size.height * .03,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: size.height * .02),
                      Text(
                        onboardingPages[_currentPage]['description']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.height * .015,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          if (_currentPage == 3) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => MainScreen()),
                            );
                          } else {
                            _pageContoller.nextPage(
                              duration: Duration(microseconds: 300),
                              curve: Curves.linear,
                            );
                          }
                        },
                        child: Container(
                          height: size.height * .06,
                          width: size.width * .8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.teal[200],
                          ),
                          child: Center(
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: size.height * .02,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * .03),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height * .01),
            ],
          ),
        ),
      ),
    );
  }
}
