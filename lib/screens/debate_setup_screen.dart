import 'package:flutter/material.dart';
import 'chat_screen.dart';
import '../models/debate_mode.dart';

class DebateSetupScreen extends StatefulWidget {
  final String topic;
  final String stance;
  final DebateMode mode;

  const DebateSetupScreen({
    super.key,
    required this.topic,
    required this.stance,
    required this.mode,
  });

  @override
  State<DebateSetupScreen> createState() => _DebateSetupScreenState();
}

class _DebateSetupScreenState extends State<DebateSetupScreen> {
  String _difficulty = 'Medium';
  int? _timerMinutes; // null = no timer
  bool _timerEnabled = false;

  final List<Map<String, dynamic>> _difficulties = [
    {
      'name': 'Easy',
      'emoji': '🌱',
      'desc': 'AI is gentle and encouraging',
      'color': Colors.green,
    },
    {
      'name': 'Medium',
      'emoji': '⚔️',
      'desc': 'AI pushes back moderately',
      'color': Colors.orange,
    },
    {
      'name': 'Hard',
      'emoji': '🔥',
      'desc': 'AI is aggressive and sharp',
      'color': Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debate Setup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Topic recap
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.topic, color: Colors.blue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.topic,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Arguing: ${widget.stance}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Difficulty selector
            const Text(
              'Difficulty',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: _difficulties.map((d) {
                final isSelected = _difficulty == d['name'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _difficulty = d['name']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                                    ? (d['color'] as Color).withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? d['color'] as Color
                                      : Colors.grey.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            d['emoji'],
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            d['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? d['color'] as Color : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              d['desc'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            if (widget.mode != DebateMode.learning) ...[
              // Timer toggle
              const Text(
                'Timer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Enable Timer'),
                subtitle: Text(
                  _timerEnabled
                      ? 'Debate ends when time runs out'
                      : 'No time limit',
                ),
                value: _timerEnabled,
                onChanged: (val) => setState(() {
                  _timerEnabled = val;
                  if (val) _timerMinutes = 10; // default
                }),
              ),

              if (_timerEnabled) ...[
                const SizedBox(height: 12),
                Row(
                  children:
                      [5, 10, 15].map((mins) {
                        final isSelected = _timerMinutes == mins;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _timerMinutes = mins),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.timer, size: 20),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$mins min',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.blue : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList()..add(
                        Expanded(
                          child: GestureDetector(
                            onTap: _showCustomTimePicker,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: (_timerMinutes != null && ![5, 10, 15].contains(_timerMinutes))
                                  ? Colors.blue.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.edit, size: 20),
                                  const SizedBox(height: 4),
                                  Text(
                                    (_timerMinutes != null &&
                                            ![
                                              5,
                                              10,
                                              15,
                                            ].contains(_timerMinutes))
                                        ? '$_timerMinutes min'
                                        : 'Custom',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                ),
              ],
            ],

            const Spacer(),

            // Start button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _startDebate,
                child: const Text(
                  'Start Debate 🔥',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCustomTimePicker() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Custom Timer'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter minutes (1-60)',
            suffixText: 'minutes',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final mins = int.tryParse(ctrl.text);
              if (mins != null && mins >= 1 && mins <= 60) {
                setState(() => _timerMinutes = mins);
                Navigator.pop(context);
              }
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  void _startDebate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          topic: widget.topic,
          stance: widget.stance,
          difficulty: _difficulty,
          timerMinutes: _timerEnabled ? _timerMinutes : null,
          mode: widget.mode,
        ),
      ),
    );
  }
}
