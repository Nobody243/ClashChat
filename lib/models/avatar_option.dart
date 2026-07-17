class AvatarOption {
  final String name;
  final String seed;

  const AvatarOption({required this.name, required this.seed});

  String get url => 'https://api.dicebear.com/9.x/bottts/svg?seed=$seed';
}

const List<AvatarOption> kAvatars = [
  AvatarOption(name: 'Felix', seed: 'Felix'),
  AvatarOption(name: 'Aneka', seed: 'Aneka'),
  AvatarOption(name: 'Milo', seed: 'Milo'),
  AvatarOption(name: 'Luna', seed: 'Luna'),
  AvatarOption(name: 'Sophie', seed: 'Sophie'),
];
