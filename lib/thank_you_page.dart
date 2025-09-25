import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ThankYouPage extends StatefulWidget {
  const ThankYouPage({super.key});

  @override
  State<ThankYouPage> createState() => _ThankYouPageState();
}

class _ThankYouPageState extends State<ThankYouPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<BrandingSlide> brandingSlides = [
    BrandingSlide(
      message: "Welcome to News Africa TV Survey",
      imagePath: "assets/images/seth.jpg",
    ),
    BrandingSlide(
      message: "We also conduct Market Research & Polling",
      imagePath: "assets/images/seth.jpg",
    ),
    BrandingSlide(
      message: "Contact us: +233 542 608 681",
      imagePath: "assets/images/seth.jpg",
      isContact: true,
    ),
    BrandingSlide(
      message: "Share this survey with friends on WhatsApp, Facebook, TikTok",
      imagePath: "assets/images/seth.jpg",
    ),
  ];

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        final nextPage = _currentPage + 1;
        if (nextPage < brandingSlides.length) {
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _share(String platform) {
    const surveyUrl = "https://survey.newsafricatv.com";
    final message = Uri.encodeComponent(
      "I just took the News Africa TV survey! Join here: $surveyUrl",
    );

    final url = switch (platform) {
      "whatsapp" => "https://wa.me/?text=$message",
      "facebook" =>
        "https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(surveyUrl)}",
      "tiktok" =>
        "https://www.tiktok.com/share?url=${Uri.encodeComponent(surveyUrl)}",
      _ => "",
    };

    if (url.isNotEmpty) {
      _launchUrl(url);
    }
  }

  void _makePhoneCall() async {
    final phoneUrl = 'tel:+233542608681';
    _launchUrl(phoneUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thank You"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Branding Carousel
            _buildBrandingCarousel(),
            const SizedBox(height: 24),

            // Thank You Message
            _buildThankYouMessage(),
            const SizedBox(height: 32),

            // Share Section
            _buildShareSection(),
            const SizedBox(height: 20),

            // Support Section
            _buildSupportSection(),
            const SizedBox(height: 20),

            // Follow Section
            _buildFollowSection(),
            const SizedBox(height: 30),

            // Back Button
            _buildBackButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandingCarousel() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: 220,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: brandingSlides.length,
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemBuilder: (context, index) {
                final slide = brandingSlides[index];
                return _buildSlide(slide, index);
              },
            ),

            // Page Indicators
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(brandingSlides.length, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(BrandingSlide slide, int index) {
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage("assets/images/seth.jpg"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    slide.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 6,
                          color: Colors.black87,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  if (slide.isContact) ...[
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _makePhoneCall,
                      icon: const Icon(Icons.phone, size: 16),
                      label: const Text("Call Now"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Image.asset(
              "assets/images/newsafrica.jpg",
              height: 35,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThankYouMessage() {
    return const Column(
      children: [
        Icon(Icons.check_circle, size: 64, color: Colors.green),
        SizedBox(height: 16),
        Text(
          "🎉 Thank you for your submission!",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          "Your feedback is valuable to us. Consider sharing the survey with others!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildShareSection() {
    return _buildSectionCard(
      title: "📢 Share this survey",
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          _buildPlatformButton(
            onPressed: () => _share("whatsapp"),
            icon: FontAwesomeIcons.whatsapp,
            label: "WhatsApp",
            color: Colors.green,
          ),
          _buildPlatformButton(
            onPressed: () => _share("facebook"),
            icon: FontAwesomeIcons.facebook,
            label: "Facebook",
            color: Colors.blue[700]!,
          ),
          _buildPlatformButton(
            onPressed: () => _share("tiktok"),
            icon: FontAwesomeIcons.tiktok,
            label: "TikTok",
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return _buildSectionCard(
      title: "☕ Support Us",
      subtitle: "Buy us a tea/coffee to help maintain our services",
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          _buildPlatformButton(
            onPressed: () => _launchUrl("0542608681"),
            icon: Icons.phone_android,
            label: "MoMo",
            color: Colors.purple,
          ),
          _buildPlatformButton(
            onPressed: () => _launchUrl("sethabbeya2@gmail.com"),
            icon: FontAwesomeIcons.paypal,
            label: "PayPal",
            color: Colors.blue[800]!,
          ),
          _buildPlatformButton(
            onPressed: () => _launchUrl("0542608681"),
            icon: Icons.account_balance,
            label: "Bank Transfer",
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildFollowSection() {
    return _buildSectionCard(
      title: "📲 Follow Us",
      subtitle: "Stay updated with our latest content",
      child: Wrap(
        spacing: 16,
        alignment: WrapAlignment.center,
        children: [
          _buildSocialIconButton(
            onPressed: () => _launchUrl("https://facebook.com/newsafricatv"),
            icon: FontAwesomeIcons.facebook,
            color: Colors.blue[700]!,
          ),
          _buildSocialIconButton(
            onPressed: () => _launchUrl("https://x.com/newsafricatv"),
            icon: FontAwesomeIcons.xTwitter,
            color: Colors.black,
          ),
          _buildSocialIconButton(
            onPressed: () => _launchUrl("https://tiktok.com/@newsafricatv"),
            icon: FontAwesomeIcons.tiktok,
            color: Colors.black,
          ),
          _buildSocialIconButton(
            onPressed: () => _launchUrl("https://instagram.com/newsafricatv"),
            icon: FontAwesomeIcons.instagram,
            color: Colors.pink,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformButton({
    required VoidCallback onPressed,
    required dynamic icon,
    required String label,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon is IconData ? Icon(icon, size: 18) : FaIcon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildSocialIconButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
  }) {
    return IconButton(
      icon: FaIcon(icon),
      color: color,
      iconSize: 28,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildBackButton() {
    return ElevatedButton.icon(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back),
      label: const Text("Back to Survey"),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class BrandingSlide {
  final String message;
  final String imagePath;
  final bool isContact;

  BrandingSlide({
    required this.message,
    required this.imagePath,
    this.isContact = false,
  });
}
