import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:giki_expense/screens/new_month_screen.dart';

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
      title: 'Welcome to bachat : budget',
      description:
          'Your personal expense tracker designed for hassle-free budget management',
      image: Icons.account_balance_wallet,
    ),
    OnboardingPage(
      title: 'Track Daily Expenses',
      description:
          'Add your daily expenses with detailed information about places and items',
      image: Icons.add_chart,
    ),
    OnboardingPage(
      title: 'Smart Analytics',
      description:
          'View your spending patterns with beautiful charts and insights',
      image: Icons.analytics,
    ),
    OnboardingPage(
      title: 'Monthly Overview',
      description:
          'Keep track of your monthly budget and expenses in one place',
      image: Icons.calendar_month,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(bottom: 80),
        child: PageView.builder(
          controller: _controller,
          onPageChanged: (index) {
            setState(() {
              isLastPage = index == pages.length - 1;
            });
          },
          itemCount: pages.length,
          itemBuilder: (context, index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  pages[index].image,
                  size: 150,
                  color: theme.appBarTheme.foregroundColor,
                ),
                const SizedBox(height: 64),
                Text(
                  pages[index].title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: theme.appBarTheme.foregroundColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    pages[index].description,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomSheet: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => _controller.jumpToPage(pages.length - 1),
              child: Text(
                'skip',
                style: TextStyle(
                  color: theme.appBarTheme.foregroundColor,
                ),
              ),
            ),
            Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: pages.length,
                effect: WormEffect(
                  spacing: 16,
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
                isLastPage ? 'START' : 'NEXT',
                style: TextStyle(color: theme.appBarTheme.foregroundColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData image;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
  });
}
