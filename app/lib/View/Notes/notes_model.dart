// To parse this JSON data, do
//
//     final notesModel = notesModelFromJson(jsonString);

import 'dart:convert';

NotesModel notesModelFromJson(String str) =>
    NotesModel.fromJson(json.decode(str));

String notesModelToJson(NotesModel data) => json.encode(data.toMap());

class NotesModel {
  final String? id;
  final String? title;
  final String? content;
  final String? createAt;

  NotesModel({this.id, this.title, this.content, this.createAt});

  NotesModel copyWith({
    String? id,
    String? title,
    String? content,
    String? createAt,
  }) => NotesModel(
    id: id ?? this.id,
    title: title ?? this.title,
    content: content ?? this.content,
    createAt: createAt ?? this.createAt,
  );

  factory NotesModel.fromJson(Map<String, dynamic> json) => NotesModel(
    id: json["id"],
    title: json["title"],
    content: json["content"],
    createAt: json["createAt"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "title": title,
    "content": content,
    "createAt": createAt,
  };
}
