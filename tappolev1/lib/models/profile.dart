class UserProfile {
  final String id;
  final String role;
  final String firstName;
  final String lastName;
  final String phone;
  final DateTime dob;
  final String gender;

  UserProfile({
    required this.id,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.dob,
    required this.gender,
  });

  // A 'factory constructor' to easily create a Profile from Supabase's JSON
  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      id: data['id'],
      role: data['role'],
      firstName: data['first_name'],
      lastName: data['last_name'],
      phone: data['phone'],
      dob: DateTime.parse(data['dob']), // Parse string back to DateTime
      gender: data['gender'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'dob': dob.toIso8601String(), // Convert DateTime to string
      'gender': gender,
    };
  }
}
