import 'package:app/FirebaseServices/repository.dart';
import 'package:app/View/Notes/notes_model.dart';
import 'package:flutter/material.dart';

class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  final TextEditingController title = TextEditingController();
  final TextEditingController content = TextEditingController();
  final repo = Repository();
  List<NotesModel> _notes = [];

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  Future<void> _refreshNotes() async {
    final notesData = await repo.getNotes();
    setState(() {
      _notes = notesData;
    });
  }

  @override
  void dispose() {
    title.dispose();
    content.dispose();
    super.dispose();
  }

  Future<void> _actionDialog({NotesModel? existingNote}) async {
    if (existingNote != null) {
      title.text = existingNote.title ?? '';
      content.text = existingNote.content ?? '';
    } else {
      title.clear();
      content.clear();
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existingNote == null ? "New Note" : "Update Note"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: InputDecoration(hintText: "Title"),
              ),
              TextField(
                controller: content,
                decoration: InputDecoration(labelText: "Content"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.blue),
                foregroundColor: WidgetStatePropertyAll(Colors.white),
              ),
              onPressed: () async {
                final enteredTitle = title.text.trim();
                final enteredContent = content.text.trim();
                if (enteredTitle.isEmpty || enteredContent.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill in all fields")),
                  );
                  return;
                }

                if (existingNote != null) {
                  final updated = await repo.updateNote(
                    existingNote.copyWith(
                      title: enteredTitle,
                      content: enteredContent,
                      createAt: DateTime.now().toIso8601String(),
                    ),
                  );

                  if (updated && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Note updated successfully!"),
                      ),
                    );
                  }
                } else {
                  final result = await repo.addNote(
                    NotesModel(
                      title: enteredTitle,
                      content: enteredContent,
                      createAt: DateTime.now().toIso8601String(),
                    ),
                  );
                  if (result.isNotEmpty && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Note created successfully!"),
                      ),
                    );
                  }
                }
                if (mounted) {
                  Navigator.of(context).pop();
                }
                await _refreshNotes();
              },
              child: Text(existingNote == null ? "CREATE" : "UPDATE"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _actionDialog(),
        child: Icon(Icons.add),
      ),
      appBar: AppBar(title: const Text("Notes")),
      body: _notes.isNotEmpty
          ? ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return ListTile(
                  title: Text(note.title ?? ''),
                  subtitle: Text(note.content ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _actionDialog(existingNote: note),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await repo.deleteNote(note.id!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Note deleted successfully!"),
                            ),
                          );
                          _refreshNotes();
                        },
                      ),
                    ],
                  ),
                );
              },
            )
          : const Center(child: Text("No notes available")),
    );
  }
}
