import 'package:cloud_firestore/cloud_firestore.dart';

class SellerProductViewModel {
  Stream<QuerySnapshot> getProductsStream() {
    return FirebaseFirestore.instance.collection('products').snapshots();
  }
}
