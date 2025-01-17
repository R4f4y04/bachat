import 'package:flutter/material.dart';
import 'package:giki_expense/screens/new_month_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Welcome to Bachat: Budget',
      description:
          'Your personal expense tracker designed for hassle-free budget management.',
      image: 'assets/welcome.png',
    ),
    OnboardingPage(
      title: 'Changing Theme',
      description:
          'Easily switch between light and dark themes to suit your preference.',
      image: 'assets/change_theme.png',
    ),
    OnboardingPage(
      title: 'Adding a New Day',
      description: 'Add a new day to start tracking your expenses.',
      image: 'assets/add_new_day.png',
    ),
    OnboardingPage(
      title: 'Editing a Day',
      description:
          'Edit the details of a day, including adding and removing expenses.',
      image: 'assets/edit_day.png',
    ),
    OnboardingPage(
      title: 'Adding Expenses',
      description:
          'Add detailed expenses for each day, including place, amount, and items.',
      image: 'assets/add_expense.png',
    ),
    OnboardingPage(
      title: 'Deleting a Day',
      description: 'Remove a day and its expenses from your records.',
      image: 'assets/delete_day.png',
    ),
    OnboardingPage(
      title: 'Saving a Month',
      description: 'Save your monthly expenses and start a new month.',
      image: 'assets/save_month.gif',
    ),
    OnboardingPage(
      title: 'Starting a New Month',
      description:
          'Set up a new month with a budget and selected places. Choose frequently visited points of expenditure from major institutes or create new templates for frequent expenditures to use throughout the month.',
      image: 'assets/new_month.gif',
    ),
    OnboardingPage(
      title: 'Viewing Charts',
      description: 'Analyze your spending patterns with detailed charts.',
      image: 'assets/view_charts.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == pages.length - 1;
              });
            },
            itemCount: pages.length,
            itemBuilder: (context, index) {
              return OnboardingPageTemplate(
                title: pages[index].title,
                description: pages[index].description,
                imagePath: pages[index].image,
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => _controller.jumpToPage(pages.length - 1),
                    child: Text(
                      'skip',
                      style:
                          TextStyle(color: theme.appBarTheme.foregroundColor),
                    ),
                  ),
                  Center(
                    child: SmoothPageIndicator(
                      controller: _controller,
                      count: pages.length,
                      effect: WormEffect(
                        spacing: 8,
                        dotColor: theme.cardColor,
                        activeDotColor: theme.appBarTheme.foregroundColor!,
                      ),
                      onDotClicked: (index) => _controller.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (isLastPage) {
                        _completeOnboarding();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      isLastPage ? 'start' : 'next',
                      style:
                          TextStyle(color: theme.appBarTheme.foregroundColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showHome', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const NewMonthScreen()),
      );
    }
  }
}

class OnboardingPageTemplate extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingPageTemplate({
    Key? key,
    required this.title,
    required this.description,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 500,
          width: 300,
          child: Image.asset(
            imagePath,
            fit: BoxFit.fitHeight,
          ),
        ),
        // SizedBox(height: 32),
        Text(
          title,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            description,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String image;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
  });
}
