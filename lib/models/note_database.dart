import 'package:daily_dose_notes/models/note.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class NoteDatabase extends ChangeNotifier {
 Isar? isar; // Make isar nullable to handle initialization properly

  // Initialize Isar for this instance
  NoteDatabase() {
    initialize();
  }
  Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [NoteSchema], 
      directory: dir.path,
      inspector: true, // Enable Isar inspector for debugging
    );
    await fetchNotes(); // Fetch notes after initializing Isar to display existing notes
  }

  // List of notes
  final List<Note> currentNotes = [];

  // Create a new note
  Future<void> addNote(String textFromUser) async {
    final newNote = Note()..text = textFromUser;
    
    if (isar != null) {
      await isar!.writeTxn(() => isar!.notes.put(newNote));
    }
    await fetchNotes();
  }

  // Fetch all notes
  Future<void> fetchNotes() async {
    if (isar != null) {
      List<Note> fetchedNotes = await isar!.notes.where().findAll();
      currentNotes.clear();
      currentNotes.addAll(fetchedNotes);
      notifyListeners();
    }
  }
  // Update an existing note
  Future<void> updateNote(int id, String newText) async {
    final existingNote = isar != null ? await isar!.notes.get(id) : null;
    if (existingNote != null) {
      existingNote.text = newText;
      await isar!.writeTxn(() => isar!.notes.put(existingNote));
      await fetchNotes();
    }
  }
  // Delete a note
  Future<void> deleteNote(int id) async {
    if (isar != null) {
      await isar!.writeTxn(() => isar!.notes.delete(id));
    }
    await fetchNotes();
  }


  
}
