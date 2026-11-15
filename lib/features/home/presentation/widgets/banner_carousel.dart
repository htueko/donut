import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/motion/app_motion.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../catalog/domain/banner.dart' as catalog;

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({required this.banners, this.height = 140, super.key});

  final List<catalog.Banner> banners;
  final double height;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final _controller = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(BannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length) {
      _restartAutoPlay();
    }
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (MediaQuery.disableAnimationsOf(context) || widget.banners.length < 2) {
      return;
    }
    _timer = Timer.periodic(AppMotion.ambient + AppMotion.base, (_) {
      if (!mounted || !_controller.hasClients) {
        return;
      }
      final next = (_page + 1) % widget.banners.length;
      _controller.animateToPage(
        next,
        duration: motionScale(context, AppMotion.base),
        curve: AppMotion.standard,
      );
    });
  }

  void _restartAutoPlay() {
    _timer?.cancel();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _BannerImage(banner: banner),
              );
            },
          ),
          Positioned(
            bottom: AppSpacing.sm,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.banners.length; i++)
                  AnimatedContainer(
                    duration: motionScale(context, AppMotion.fast),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? AppColors.paper
                          : AppColors.paper.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerImage extends StatelessWidget {
  const _BannerImage({required this.banner});

  final catalog.Banner banner;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: banner.imageUrl.startsWith('assets/')
          ? Image.asset(
              banner.imageUrl,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
            )
          : ColoredBox(
              color: AppColors.hairline,
              child: banner.title.isEmpty
                  ? null
                  : Center(
                      child: Text(
                        banner.title,
                        style: const TextStyle(
                          color: AppColors.chocolate,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
            ),
    );
  }
}
