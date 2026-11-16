/// Single source of spacing, radii and recurring component dimensions. Widgets
/// must not contain raw size literals; add a named constant here instead.
abstract final class AppSpacing {
  // Base scale
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const huge = 48.0;

  // Radii
  static const radiusSm = 8.0;
  static const radiusMd = 12.0;
  static const radiusLg = 20.0;
  static const radiusXl = 28.0;
  static const radiusPill = 999.0;

  // Lines and strokes
  static const dividerThickness = 1.0;
  static const hairlineWidth = 1.0;
  static const focusWidth = 2.0;
  static const strokeWidthSm = 2.0;
  static const spinnerSize = 20.0;
  static const strokeWidthMd = 2.4;
  static const ringStroke = 12.0;

  // Structure
  static const headerHeight = 56.0;
  static const bottomNavHeight = 72.0;

  // Product tile
  static const tileWidth = 148.0;
  static const tileImage = 104.0;

  // Shop card
  static const shopCardWidth = 200.0;
  static const shopCardImage = 110.0;
  static const shopCardButtonFontSize = 11.0;

  // Banner carousel
  static const bannerHeight = 140.0;
  static const bannerDotActive = 16.0;
  static const bannerDotInactive = 6.0;
  static const bannerDotMargin = 3.0;
  static const bannerDotRadius = 3.0;

  // OTP entry
  static const otpBoxHeight = 52.0;
  static const otpFontSize = 20.0;

  // Avatars
  static const avatarSize = 44.0;
  static const avatarSmall = 36.0;

  // Icons
  static const iconSm = 18.0;
  static const iconMd = 40.0;
  static const errorIconSize = 40.0;
  static const emptyIconSize = 40.0;

  // Skeleton lines
  static const skeletonLine = 14.0;
  static const skeletonLineWidth = 110.0;
  static const skeletonLineSmall = 12.0;
  static const skeletonLineSmallWidth = 70.0;

  // Badges
  static const badgeFontSize = 11.0;
  static const badgeHorizontalPadding = 4.0;
  static const badgeVerticalPadding = 1.0;

  // Quantity stepper
  static const stepperWidth = 44.0;
  static const stepButtonSize = 40.0;
  static const stepperFontSize = 18.0;

  // Product detail
  static const detailImageSize = 320.0;

  // Tier ladder
  static const tierNodeSize = 18.0;
  static const tierTrackHeight = 4.0;
  static const tierLabelMaxWidth = 96.0;
  static const tierLabelFontSize = 10.0;
  static const tierCheckSize = 11.0;

  // Reward tabs
  static const tabBarHeight = 44.0;
  static const tabShadowBlur = 6.0;

  // Points ring
  static const pointsRingSize = 148.0;
  static const pointsRingFontSize = 28.0;
  static const pointsRingLabelFontSize = 11.0;

  // Challenge card
  static const challengeIconSize = 60.0;
  static const progressBarHeight = 6.0;
  static const glowBlurBase = 8.0;
  static const glowBlurRange = 8.0;
  static const glowSpread = 1.0;
}
