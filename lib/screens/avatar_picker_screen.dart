import 'package:flutter/material.dart';
import '../models/avatar_option.dart';
import '../widgets/avatar_card.dart';

class AvatarPickerScreen extends StatefulWidget {
  final String? initialSeed;

  const AvatarPickerScreen({super.key, this.initialSeed});

  @override
  State<AvatarPickerScreen> createState() => _AvatarPickerScreenState();
}

class _AvatarPickerScreenState extends State<AvatarPickerScreen> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSeed;
  }

  @override
  Widget build(BuildContext context) {
    final allAvatarSeeds = kAvatars.map((a) => a.seed).toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Choose your avatar')),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: allAvatarSeeds.length,
              itemBuilder: (_, i) {
                final avatar = kAvatars[i];
                return AvatarCard(
                  avatar: avatar,
                  isSelected: _selected == avatar.seed,
                  onTap: () => setState(() => _selected = avatar.seed),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: FilledButton(
              onPressed: _selected == null
                  ? null
                  : () => Navigator.pop(context, _selected),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: const Text('Confirm'),
            ),
          ),
        ],
      ),
    );
  }
}
