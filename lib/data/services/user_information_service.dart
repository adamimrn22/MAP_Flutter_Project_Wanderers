import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mycrochetbag/domain/model/Address.dart';
import 'package:mycrochetbag/domain/model/User.dart';

class UserInformationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  Future<User?> fetchUserById(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();

      if (doc.exists && doc.data() != null) {
        print(doc.data());
        return User.fromMap(doc.data()!, id: doc.id);
      }

      return null;
    } catch (e) {
      print('Error fetching user by ID: $e');
      return null;
    }
  }

  Future<bool> updateUserAddress(String userId, Address address) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'address': address.toMap(),
      });

      return true;
    } catch (e) {
      print('Error updating user address: $e');
      return false;
    }
  }
}
