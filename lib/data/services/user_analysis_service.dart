import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mycrochetbag/domain/model/User.dart';
import 'package:mycrochetbag/utils/result.dart';

class UserAnalysisService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Result<Map<String, dynamic>>> getUserAnalytics() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('users').get();

      if (snapshot.docs.isEmpty) {
        return Result.ok({
          'totalUsers': 0,
          'roleDistribution': <String, int>{},
          'recentUsers': <User>[],
        });
      }

      Map<String, int> roleDistribution = {};
      List<User> allUsers = [];
      List<User> recentUsers = [];

      // Process all users
      for (var doc in snapshot.docs) {
        try {
          final userData = doc.data() as Map<String, dynamic>;
          final user = User.fromMap(userData, id: doc.id);
          allUsers.add(user);

          // Count roles
          final role = userData['role'] as String? ?? 'user';
          roleDistribution[role] = (roleDistribution[role] ?? 0) + 1;

          // Check if user was created in the last 30 days
          if (userData['createdAt'] != null) {
            final createdAt = (userData['createdAt'] as Timestamp).toDate();
            final thirtyDaysAgo = DateTime.now().subtract(
              const Duration(days: 30),
            );
            if (createdAt.isAfter(thirtyDaysAgo)) {
              recentUsers.add(user);
            }
          }
        } catch (e) {
          print('Error processing user doc ${doc.id}: $e');
          continue;
        }
      }

      return Result.ok({
        'totalUsers': allUsers.length,
        'roleDistribution': roleDistribution,
        'recentUsers': recentUsers.take(10).toList(), // Last 10 recent users
      });
    } catch (e) {
      return Result.error('Failed to fetch user analytics: $e' as Exception);
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Future<Result<List<User>>> getTopUsers({int limit = 10}) async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection('users')
              .orderBy('createdAt', descending: true)
              .limit(limit)
              .get();

      final List<User> users =
          snapshot.docs.map((doc) {
            final userData = doc.data() as Map<String, dynamic>;
            return User.fromMap(userData, id: doc.id);
          }).toList();

      return Result.ok(users);
    } catch (e) {
      return Result.error('Failed to fetch top users: $e' as Exception);
    }
  }

  Future<Result<int>> getUserCountByRole(String role) async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: role)
              .get();

      return Result.ok(snapshot.docs.length);
    } catch (e) {
      return Result.error('Failed to count users by role: $e' as Exception);
    }
  }
}
