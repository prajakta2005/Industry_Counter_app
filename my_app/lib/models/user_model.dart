

class UserModel {
  final String name;
  final String role;
  final String site;

  const UserModel({
    required this.name,
    required this.role,
    required this.site,
  });

  Map<String, String> toMap() {
    return {
      'name': name,
      'role': role,
      'site': site,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] as String,
      role: map['role'] as String,
      site: map['site'] as String,
    );
  }

  factory UserModel.empty() {
    return const UserModel(name: '', role: '', site: '');
  }

  bool get isEmpty => name.isEmpty;
  bool get isNotEmpty => name.isNotEmpty;


  UserModel copyWith({
    String? name,
    String? role,
    String? site,
  }) {
    return UserModel(
      name: name ?? this.name,
      role: role ?? this.role,
      site: site ?? this.site,
    );
  }

  @override
  String toString() => 'UserModel(name: $name, role: $role, site: $site)';
}