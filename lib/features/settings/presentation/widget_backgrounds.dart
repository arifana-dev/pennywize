class WidgetBackground {
  const WidgetBackground({
    required this.id,
    required this.label,
    required this.assetPath,
  });

  final String id;
  final String label;
  final String assetPath;
}

const builtInBackgrounds = <WidgetBackground>[
  WidgetBackground(
    id: 'penny',
    label: 'Penny',
    assetPath: 'assets/svg/backgrounds/bg_penny.svg',
  ),
  WidgetBackground(
    id: 'shiba',
    label: 'Shiba Inu',
    assetPath: 'assets/svg/backgrounds/bg_shiba.svg',
  ),
  WidgetBackground(
    id: 'frog',
    label: 'Kawaii Frog',
    assetPath: 'assets/svg/backgrounds/bg_frog.svg',
  ),
  WidgetBackground(
    id: 'piggy',
    label: 'Piggy Bank',
    assetPath: 'assets/svg/backgrounds/bg_piggy.svg',
  ),
  WidgetBackground(
    id: 'boba',
    label: 'Boba',
    assetPath: 'assets/svg/backgrounds/bg_boba.svg',
  ),
  WidgetBackground(
    id: 'capybara',
    label: 'Capybara',
    assetPath: 'assets/svg/backgrounds/bg_capybara.svg',
  ),
  WidgetBackground(
    id: 'duck',
    label: 'Duck',
    assetPath: 'assets/svg/backgrounds/bg_duck.svg',
  ),
  WidgetBackground(
    id: 'night',
    label: 'Starry Night',
    assetPath: 'assets/svg/backgrounds/bg_night.svg',
  ),
];
