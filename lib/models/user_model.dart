class User {
  final int id;
  final String nim;
  final String nama;
  final String email;
  final String peran;
  final String? profilePicture;
  final DateTime dibuatPada;

  User({
    required this.id,
    required this.nim,
    required this.nama,
    required this.email,
    required this.peran,
    this.profilePicture,
    required this.dibuatPada,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      nim: json['nim'] ?? '',
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      peran: json['peran'] ?? 'pengguna',
      profilePicture: json['profile_picture'],
      dibuatPada: DateTime.tryParse(json['dibuat_pada'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nim': nim,
      'nama': nama,
      'email': email,
      'peran': peran,
      'profile_picture': profilePicture,
      'dibuat_pada': dibuatPada.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? nim,
    String? nama,
    String? email,
    String? peran,
    String? profilePicture,
    DateTime? dibuatPada,
  }) {
    return User(
      id: id ?? this.id,
      nim: nim ?? this.nim,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      peran: peran ?? this.peran,
      profilePicture: profilePicture ?? this.profilePicture,
      dibuatPada: dibuatPada ?? this.dibuatPada,
    );
  }

  bool get isReviewer => peran == 'peninjau';
  bool get isUser => peran == 'pengguna';

  @override
  String toString() {
    return 'User(id: $id, nama: $nama, email: $email, peran: $peran)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
