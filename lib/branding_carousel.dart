import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BrandingCarousel extends StatelessWidget {
  BrandingCarousel({super.key});

  final List<String> brandingMessages = [
    "Welcome to News Africa TV Survey",
    "We also conduct Market Research & Polling",
    "Contact us: +233 542 608 681",
    "Share this survey with friends on WhatsApp, Facebook, TikTok",
  ];

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(autoPlay: true, height: 200),
      items: brandingMessages.map((msg) {
        return Builder(
          builder: (_) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage(
                    "assets/images/seth.jpg",
                  ), // 👈 studio photo
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black54,
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        msg,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black87,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Image.asset(
                      "assets/images/newsafrica.jpg", // 👈 your logo file
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
