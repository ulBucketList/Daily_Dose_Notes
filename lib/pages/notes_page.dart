import 'package:daily_dose_notes/models/note.dart';
import 'package:daily_dose_notes/models/note_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => NoteDatabase(),
      child: MaterialApp(debugShowCheckedModeBanner: false, home: NotesApp()),
    ),
  );
}

class NotesApp extends StatefulWidget {
  NotesApp({super.key});

  final textController = TextEditingController();
  // Function see and edit text

  void createNote(BuildContext context) {
    // Function to create a new note
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: TextField(
              controller: textController,
              decoration: const InputDecoration(hintText: 'Enter your note'),
            ),
            actions: [
              MaterialButton(
                onPressed: () {
                  context.read<NoteDatabase>().addNote(textController.text);
                  textController.clear(); // Clear the text field
                  context
                      .read<NoteDatabase>()
                      .fetchNotes(); // Refresh the notes
                  // Close the dialog
                  Navigator.pop(context);
                },
                child: const Text('Create'),
              ),
            ]
          ),
    );
  }

  //update note
  void updateNote(BuildContext context, Note note) {
    textController.text = note.text!;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Update Note'),
            content: TextField(
              controller: textController,
              autocorrect: true,
              textCapitalization: TextCapitalization.words,
            ),
            actions: [
              MaterialButton(
                onPressed: () {
                  context.read<NoteDatabase>().updateNote(
                    note.id,
                    textController.text,
                  );
                  textController.clear();
                  Navigator.pop(context);
                },
                child: const Text('Update'),
              ),
              IconButton(
                onPressed: () {
                  context.read<NoteDatabase>().deleteNote(note.id);
                  textController.clear();
                  Navigator.pop(context);
                },
                icon: Icon(Icons.delete_outline),
                tooltip: 'Delete Note',
              ),
            ],
          ),
    );
  }

  //delete note
  void deleteNote(BuildContext context, int id) {
    context.read<NoteDatabase>().deleteNote(id);
  }

  @override
  State<NotesApp> createState() => _NotesAppState();

// Floating action buttons initialization
//list of buttons
//Create note button
  //Home button
  //Delete note button
  //Update note button
  //List of buttons
  List<FloatingActionButton> getButtons(BuildContext context) {
    return [
      FloatingActionButton(
        onPressed: () => createNote(context),
        child: Icon(Icons.add),
      ),
      FloatingActionButton(
        onPressed: () => SystemNavigator.pop(),
        child: Icon(Icons.logout),
      ),
    ];
  }
}

class _NotesAppState extends State<NotesApp> {
  void readNotes() {
    context.watch<NoteDatabase>().fetchNotes();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    readNotes();
  }
  @override
  Widget build(BuildContext context) {
    final noteDatabase = context.watch<NoteDatabase>();
    List<Note> currentNotes = noteDatabase.currentNotes;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFFEAEAEA)),
        ),
        backgroundColor: Color(0xFF1A1A1A),
  
        body: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(
                top: 30,
                left: 19,
                right: 20,
                bottom: 40,
              ),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFB9AEE6).withOpacity(0.5),
                    blurRadius: 20,
                    blurStyle: BlurStyle.outer,
                    spreadRadius: 7,
                    offset: Offset(0,10),
                  ),
                ],
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 0,
                left: 19,
                right: 20,
                bottom: 40,
              ),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromRGBO(40, 40, 40, 0.8).withOpacity(0.3),
                    Color.fromRGBO(26, 26, 26, 0.6).withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    const SizedBox(height: 10),
                  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                    'Notes',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                      decorationColor:Color(0xFFEAEAEA),
                      fontSize: 48,
                      color: Color(0xFFEAEAEA),
                    ),
                  
                    ),
                  ],
                  ),
                    Expanded(child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 400),
                        child: GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 20,
                          childAspectRatio: 3/2,
                          ), itemCount: currentNotes.length,

                      itemBuilder: (context, index) {
                      final note = currentNotes[index];
                      return GestureDetector(
                        onTap: () => widget.updateNote(context, note),
                        child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB9AEE6)
                              .withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text(
                            note.text ?? 'No content',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFEAEAEA),
                            ),
                          ),
                          ],
                        ),
                        ),
                      );
                      },
                    ),
                    ),
                  ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Row(
          mainAxisSize: MainAxisSize.min,
          children: widget
              .getButtons(context)
              .map(
                (button) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: button,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
  // Removed duplicate build method
}
