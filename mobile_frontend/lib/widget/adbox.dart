import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:convert';

class AdBox extends StatefulWidget {
  final double height;
  final double width;

  const AdBox({Key? key, required this.height, required this.width})
      : super(key: key);

  @override
  _AdBoxState createState() => _AdBoxState();
}

class _AdBoxState extends State<AdBox> {
  List<String> _imageUrls = [
    "https://lh5.googleusercontent.com/p/AF1QipPce_WSG9TytYlhbbMlEfqYoF_axI4G0takCEMP=w426-h240-k-no",
    "https://lh5.googleusercontent.com/p/AF1QipN34nHWZxXm8X_a-LSiO3uknvsec-fyQ8H9R6iz=w426-h240-k-no",
    "https://lh5.googleusercontent.com/p/AF1QipNL_XRtBbowRV89w9KSADNxvqYPkBL41AnK0GkI=w426-h240-k-no"
  ];

  @override
  void dispose() {
    // Break any references to the State object here
    _imageUrls = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _imageUrls.isEmpty
        ? const SizedBox.shrink()
        : Transform.scale(
            scale: 1.1,
            child: SizedBox(
              height: widget.height,
              width: widget.width,
              child: CarouselSlider(
                options: CarouselOptions(
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  pauseAutoPlayOnTouch: true,
                  aspectRatio: widget.width / widget.height,
                  enlargeCenterPage: true,
                  enlargeStrategy: CenterPageEnlargeStrategy.scale,
                  enlargeFactor: 0.5,
                  viewportFraction: 0.9,
                ),
                items: _imageUrls
                    .map((imageUrl) => Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          // scale: 2,
                        ))
                    .toList(),
              ),
            ),
          );
  }
}
