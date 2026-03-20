import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../models/log_entry.dart';
import 'database_service.dart';


class FirebaseService {
  // ── Singleton ────────────────────────────
  FirebaseService._internal();
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  static const String _collection = 'logs';

  Future<bool> isConnected() async {
    final result = await Connectivity().checkConnectivity();

    return result != ConnectivityResult.none;
  }

  Future<int> syncPendingLogs() async {

    final connected = await isConnected();
    if (!connected) return 0;

    final unsyncedLogs = await DatabaseService().getUnsyncedLogs();
    if (unsyncedLogs.isEmpty) return 0;

    int syncedCount = 0;
    for (final log in unsyncedLogs) {
      try {
        await _db
            .collection(_collection)
            .doc(log.id) 
            .set(_toFirestoreMap(log));

        await DatabaseService().markAsSynced(log.id);
        syncedCount++;

      } catch (e) {
        debugPrint('FirebaseService: failed to sync log ${log.id} — $e');
       
      }
    }

    return syncedCount;
  }
  Future<List<LogEntry>> fetchAllFromCloud() async {
    final connected = await isConnected();
    if (!connected) return [];

    try {
      final snapshot = await _db
          .collection(_collection)
          .orderBy('issue_date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => _fromFirestoreMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      debugPrint('FirebaseService: failed to fetch from cloud — $e');
      return [];
    }
  }
  Map<String, dynamic> _toFirestoreMap(LogEntry e) {
    return {
      'lot_number':    e.lotNumber,
      'material_type': e.materialType,
      'quantity':      e.quantity,
      'issued_to':     e.issuedTo,
      'counted_by':    e.countedBy,
      'issue_date':    Timestamp.fromDate(e.issueDate),
      'site':          e.site,
      'is_synced':     true, // always true when in Firestore
    };
  }
  LogEntry _fromFirestoreMap(String id, Map<String, dynamic> data) {
    return LogEntry(
      id:           id,
      lotNumber:    data['lot_number']    as String,
      materialType: data['material_type'] as String,
      quantity:     data['quantity']      as int,
      issuedTo:     data['issued_to']     as String,
      countedBy:    data['counted_by']    as String,
      issueDate:    (data['issue_date']   as Timestamp).toDate(),
      site:         data['site']          as String,
      isSynced:     true,
    );
  }
}
