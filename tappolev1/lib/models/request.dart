// ignore_for_file: non_constant_identifier_names

class Request {
  final String req_id;
  final String requested_by;
  final String? accepted_by;
  final String? req_title;
  final String req_content;
  final String req_status;
  final DateTime created_at;
  final DateTime? updated_at;
  final String? senior_name; // Optional field for senior's name

  Request({
    required this.req_id,
    required this.requested_by,
    this.accepted_by,
    this.req_title,
    required this.req_content,
    required this.req_status,
    required this.created_at,
    this.updated_at,
    this.senior_name,
  });

  factory Request.fromMap(Map<String, dynamic> data) {
    String? fetchedName;
    if (data['profiles'] != null) {
      final profileData = data['profiles'];
      // Handle case where it might be a list or a map depending on DB relationship
      // Usually for One-to-One it's a Map:
      if (profileData is Map) {
        fetchedName = profileData['first_name'];
      }
    }

    return Request(
      req_id: data['req_id'] as String,
      requested_by: data['requested_by'] as String,
      accepted_by: data['accepted_by'] as String?,
      req_title: data['req_title'] as String?,
      req_content: data['req_content'] as String,
      req_status: data['req_status'] as String,
      created_at: DateTime.parse(data['created_at'] as String),
      updated_at: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'] as String)
          : null,
      senior_name: fetchedName,
    );
  }
}
