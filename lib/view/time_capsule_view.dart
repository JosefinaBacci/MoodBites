import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/time_capsule_model.dart';
import '../presenter/time_capsule_presenter.dart';
import 'add_time_capsule_screen.dart';

class TimeCapsuleScreen extends StatefulWidget {
  const TimeCapsuleScreen({super.key});

  @override
  State<TimeCapsuleScreen> createState() => _TimeCapsuleScreenState();
}

class _TimeCapsuleScreenState extends State<TimeCapsuleScreen> {
  final TimeCapsuleModel _model = TimeCapsuleModel();
  late final TimeCapsulePresenter _presenter;

  List<Map<String, dynamic>> _capsules = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _presenter = TimeCapsulePresenter(
      model: _model,
      showLoading: () => setState(() => _isLoading = true),
      hideLoading: () => setState(() => _isLoading = false),
      showCapsules: (capsules) => setState(() {
        _capsules = capsules;
        _error = null;
      }),
      showError: (message) => setState(() => _error = message),
    );
    _presenter.loadCapsules();
  }

  void _showCapsuleDialog(String capsuleId, String message, DateTime unlockAt) {
    final now = DateTime.now().toUtc();
    if (now.isBefore(unlockAt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This capsule is still locked.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFF5F1E9), // beige suave
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
              maxWidth: 350,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Your message from the past ✉️",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3B4D65),
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.4,
                        color: Color(0xFF333333),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B4D65),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _presenter.openCapsule(capsuleId);
                  },
                  child: const Text(
                    "Close",
                    style: TextStyle(fontSize: 16, color: Color(0xFFD3DADC)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inDays > 0) return '${d.inDays} days';
    if (d.inHours > 0) return '${d.inHours} hours';
    if (d.inMinutes > 0) return '${d.inMinutes} minutes';
    return 'less than a minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E2DA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B4D65),
        title: const Text(
          'Upcoming Capsules',
          style: TextStyle(
            color: Color(0xFFD3DADC),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFD3DADC)),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTimeCapsuleScreen()),
              );
              if (result == true) {
                _presenter.loadCapsules();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _capsules.isEmpty
          ? const Center(
              child: Text(
                "There is no time capsule to open yet",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _capsules.length,
              itemBuilder: (context, index) {
                final capsule = _capsules[index];
                final unlockAt = (capsule['unlockAt'] as Timestamp)
                    .toDate()
                    .toUtc();
                final now = DateTime.now().toUtc();
                final isUnlocked =
                    now.isAfter(unlockAt) || now.isAtSameMomentAs(unlockAt);
                final timeRemaining = unlockAt.isBefore(now)
                    ? Duration.zero
                    : unlockAt.difference(now);
                final message = capsule['message'] ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 238, 236, 232),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      isUnlocked ? message : "🔒 Capsule locked",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: const Color(0xFF3B4D65),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Unlocks at: ${unlockAt.toLocal()}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isUnlocked
                              ? '¡You can open it!'
                              : 'It unlocks in ${_formatDuration(timeRemaining)}',
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      isUnlocked ? Icons.lock_open : Icons.lock_clock,
                      color: const Color(0xFF455763),
                    ),
                    onTap: isUnlocked
                        ? () => _showCapsuleDialog(
                            capsule['id'],
                            message,
                            unlockAt,
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
