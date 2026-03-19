

class LogEntry {
  final String id;
  final String lotNumber;
  final String materialType;
  final int quantity;
  final String issuedTo;
  final String countedBy;
  final DateTime issueDate;
  final String site;
  final bool isSynced;

  const LogEntry({
    required this.id,
    required this.lotNumber,
    required this.materialType,
    required this.quantity,
    required this.issuedTo,
    required this.countedBy,
    required this.issueDate,
    required this.site,
    this.isSynced = false, 
  });


  Map<String, dynamic> toMap() {
    return {
      'id':           id,
      'lotNumber':    lotNumber,
      'materialType': materialType,
      'quantity':     quantity,
      'issuedTo':     issuedTo,
      'countedBy':    countedBy,
      'issueDate':    issueDate.toIso8601String(),
      'site':         site,
      'isSynced':     isSynced ? 1 : 0,
    };
  }


  factory LogEntry.fromMap(Map<String, dynamic> map) {
    return LogEntry(
      id:           map['id'] as String,
      lotNumber:    map['lotNumber'] as String,
      materialType: map['materialType'] as String,
      quantity:     map['quantity'] as int,
      issuedTo:     map['issuedTo'] as String,
      countedBy:    map['countedBy'] as String,
      // WHY parse: we stored it as a String, now we convert it back to DateTime
      issueDate:    DateTime.parse(map['issueDate'] as String),
      site:         map['site'] as String,
      // WHY == 1: SQLite gives us int (1 or 0), we convert back to bool
      isSynced:     map['isSynced'] == 1,
    );
  }

  Map<String, dynamic> toFirebaseMap() {
    return {
      'id':           id,
      'lotNumber':    lotNumber,
      'materialType': materialType,
      'quantity':     quantity,
      'issuedTo':     issuedTo,
      'countedBy':    countedBy,
      'issueDate':    issueDate.toIso8601String(),
      'site':         site,
      'isSynced':     true, 
    };
  }


  LogEntry copyWith({
    String?   id,
    String?   lotNumber,
    String?   materialType,
    int?      quantity,
    String?   issuedTo,
    String?   countedBy,
    DateTime? issueDate,
    String?   site,
    bool?     isSynced,
  }) {
    return LogEntry(
      id:           id           ?? this.id,
      lotNumber:    lotNumber    ?? this.lotNumber,
      materialType: materialType ?? this.materialType,
      quantity:     quantity     ?? this.quantity,
      issuedTo:     issuedTo     ?? this.issuedTo,
      countedBy:    countedBy    ?? this.countedBy,
      issueDate:    issueDate    ?? this.issueDate,
      site:         site         ?? this.site,
      isSynced:     isSynced     ?? this.isSynced,
    );
  }

  @override
  String toString() {
    return 'LogEntry(id: $id, lot: $lotNumber, material: $materialType, '
        'qty: $quantity, by: $countedBy, date: $issueDate)';
  }
}