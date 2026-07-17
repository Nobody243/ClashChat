import 'package:cloud_firestore/cloud_firestore.dart';

class UsageQuotaState {
  final int dailyLimit;
  final int usedToday;
  final String dayKey;

  const UsageQuotaState({
    required this.dailyLimit,
    required this.usedToday,
    required this.dayKey,
  });

  int get remainingToday => dailyLimit - usedToday < 0 ? 0 : dailyLimit - usedToday;

  double get progress => dailyLimit <= 0 ? 0 : (usedToday / dailyLimit).clamp(0.0, 1.0);

  bool get isLocked => remainingToday <= 0;
}

class UsageQuotaService {
  static const int defaultDailyLimit = 20;
  static const String _limitField = 'dailyUsageLimit';
  static const String _usedField = 'dailyUsageUsed';
  static const String _dayField = 'dailyUsageDayKey';
  static const String _updatedAtField = 'dailyUsageUpdatedAt';

  static DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  static String todayKey([DateTime? now]) {
    final utc = (now ?? DateTime.now()).toUtc();
    final year = utc.year.toString().padLeft(4, '0');
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static UsageQuotaState fromData(Map<String, dynamic>? data) {
    final dailyLimit = (data?[_limitField] as num?)?.toInt() ?? defaultDailyLimit;
    final usedToday = (data?[_usedField] as num?)?.toInt() ?? 0;
    final dayKey = data?[_dayField] as String? ?? todayKey();

    if (dayKey != todayKey()) {
      return UsageQuotaState(
        dailyLimit: dailyLimit,
        usedToday: 0,
        dayKey: todayKey(),
      );
    }

    return UsageQuotaState(
      dailyLimit: dailyLimit,
      usedToday: usedToday < 0 ? 0 : usedToday,
      dayKey: dayKey,
    );
  }

  static Future<void> ensureInitialized(String uid) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final docRef = _userDoc(uid);
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() ?? <String, dynamic>{};
      final currentLimit = (data[_limitField] as num?)?.toInt() ?? defaultDailyLimit;
      final currentDayKey = data[_dayField] as String?;
      final needsReset = currentDayKey != todayKey();

      final updateData = <String, dynamic>{
        _limitField: currentLimit <= 0 ? defaultDailyLimit : currentLimit,
        _dayField: todayKey(),
        _updatedAtField: FieldValue.serverTimestamp(),
      };

      if (needsReset) {
        updateData[_usedField] = 0;
      } else if (!(data.containsKey(_usedField))) {
        updateData[_usedField] = 0;
      }

      if (updateData.isNotEmpty) {
        transaction.set(docRef, updateData, SetOptions(merge: true));
      }
    });
  }

  static Future<bool> consume(String uid, {int amount = 1}) async {
    if (amount <= 0) return true;

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final docRef = _userDoc(uid);
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return false;

      final data = snapshot.data() ?? <String, dynamic>{};
      final currentLimit = (data[_limitField] as num?)?.toInt() ?? defaultDailyLimit;
      final currentUsed = (data[_usedField] as num?)?.toInt() ?? 0;
      final currentDayKey = data[_dayField] as String?;
      final isStale = currentDayKey != todayKey();
      final usedToday = isStale ? 0 : currentUsed;
      final nextUsed = usedToday + amount;

      if (nextUsed > currentLimit) {
        return false;
      }

      transaction.set(
        docRef,
        <String, dynamic>{
          _limitField: currentLimit <= 0 ? defaultDailyLimit : currentLimit,
          _usedField: nextUsed,
          _dayField: todayKey(),
          _updatedAtField: FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      return true;
    });
  }

  static Stream<UsageQuotaState> watch(String uid) {
    return _userDoc(uid).snapshots().map(
          (snapshot) => fromData(snapshot.data()),
        );
  }
}