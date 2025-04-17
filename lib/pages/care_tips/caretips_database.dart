import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kontak_application_2/pages/care_tips/caretips_model.dart';

class DatabaseMethodsCareTips {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addCareTip(CareTip careTip) async {
    await _firestore
        .collection('care_tips')
        .doc(careTip.id)
        .set(careTip.toMap());
  }

  Future<void> addDisasterCareTip(DisasterCareTip diastercareTip) async {
    await _firestore
        .collection('disaster_care_tips')
        .doc(diastercareTip.id)
        .set(diastercareTip.toMap());
  }

  Future<void> addEvacuationCareTip(EvacuationCareTip evacuationcareTip) async {
    await _firestore
        .collection('evacuation_care_tips')
        .doc(evacuationcareTip.id)
        .set(evacuationcareTip.toMap());
  }

  Future<void> updateCareTip(CareTip careTip) async {
    await _firestore
        .collection('care_tips')
        .doc(careTip.id)
        .update(careTip.toMap());
  }

  Future<void> updateDisasterCareTip(
      DisasterCareTip updatedDisasterCareTip) async {
    await _firestore
        .collection('disaster_care_tips')
        .doc(updatedDisasterCareTip.id)
        .update(updatedDisasterCareTip.toMap());
  }

  Future<void> updateEvacuationCareTip(
      EvacuationCareTip updatedEvacuationCareTip) async {
    await _firestore
        .collection('evacuation_care_tips')
        .doc(updatedEvacuationCareTip.id)
        .update(updatedEvacuationCareTip.toMap());
  }

  Future<void> deleteCareTip(String id) async {
    await _firestore.collection('care_tips').doc(id).delete();
  }

  Future<void> deleteDisasterCareTip(String id) async {
    await _firestore.collection('disaster_care_tips').doc(id).delete();
  }

  Future<void> deleteEvacuationCareTip(String id) async {
    await _firestore.collection('evacuation_care_tips').doc(id).delete();
  }

  Stream<List<CareTip>> getCareTips() {
    return _firestore.collection('care_tips').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CareTip.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Stream<List<DisasterCareTip>> getDisasterCareTips() {
    return _firestore
        .collection('disaster_care_tips')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              DisasterCareTip.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Stream<List<EvacuationCareTip>> getEvacuationCareTips() {
    return _firestore
        .collection('evacuation_care_tips')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              EvacuationCareTip.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
