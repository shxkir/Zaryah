class MessageModel {
  final String id;
  final String text;
  final String senderId;
  final String receiverId;
  final bool read;
  final DateTime createdAt;
  final UserBasicInfo? sender;
  final UserBasicInfo? receiver;

  MessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.receiverId,
    required this.read,
    required this.createdAt,
    this.sender,
    this.receiver,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      text: json['text'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      read: json['read'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      sender: json['sender'] != null
          ? UserBasicInfo.fromJson(json['sender'])
          : null,
      receiver: json['receiver'] != null
          ? UserBasicInfo.fromJson(json['receiver'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'senderId': senderId,
      'receiverId': receiverId,
      'read': read,
      'createdAt': createdAt.toIso8601String(),
      'sender': sender?.toJson(),
      'receiver': receiver?.toJson(),
    };
  }
}

class UserBasicInfo {
  final String id;
  final String email;
  final String? name;

  UserBasicInfo({
    required this.id,
    required this.email,
    this.name,
  });

  factory UserBasicInfo.fromJson(Map<String, dynamic> json) {
    return UserBasicInfo(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['profile'] != null ? json['profile']['name'] as String? : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'profile': name != null ? {'name': name} : null,
    };
  }
}

class ConversationModel {
  final String partnerId;
  final String partnerName;
  final String partnerEmail;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ConversationModel({
    required this.partnerId,
    required this.partnerName,
    required this.partnerEmail,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      partnerId: json['partnerId'] as String,
      partnerName: json['partnerName'] as String,
      partnerEmail: json['partnerEmail'] as String,
      lastMessage: json['lastMessage'] as String,
      lastMessageTime: DateTime.parse(json['lastMessageTime'] as String),
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partnerId': partnerId,
      'partnerName': partnerName,
      'partnerEmail': partnerEmail,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }
}
