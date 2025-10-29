class Request {
  final String req_id;
  final String requested_by;
  final String accepted_by;
  final String req_title;
  final String req_content;
  final String req_status;
  final DateTime created_at;
  final DateTime updated_at;

  Request({
    required this.req_id,
    required this.requested_by,
    required this.accepted_by,
    required this.req_title,
    required this.req_content,
    required this.req_status,
    required this.created_at,
    required this.updated_at,
  });

  // A 'factory constructor' to easily create a Request from Supabase's JSON
  factory Request.fromMap(Map<String, dynamic> data) {
    return Request(
      req_id: data['req_id'],
      requested_by: data['requested_by'],
      accepted_by: data['accepted_by'],
      req_title: data['req_title'],
      req_content: data['req_content'],
      req_status: data['req_status'],
      created_at: DateTime.parse(data['created_at']),
      updated_at: DateTime.parse(data['updated_at']),
    );
  }
}
