import 'package:first_class/provider/NotesProvider.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:provider/provider.dart';

class NotesScreen extends StatefulWidget {
  NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  Widget build(BuildContext context) {
    NotesProvider watcher = context.watch<NotesProvider>();
    NotesProvider provider = context.read<NotesProvider>();
    final delet = Container(
      color: Colors.red,
      // margin: const EdgeInsets.symmetric(horizontal: 15),
      alignment: Alignment.centerRight,
      child: const Icon(
        Icons.delete,
        size: 40,
        color: Colors.white,
      ),
    );
    final edit = Container(
      color: Colors.green,
      // margin: const EdgeInsets.symmetric(horizontal: 15),
      alignment: Alignment.centerRight,
      child: const Icon(
        Icons.edit,
        size: 40,
        color: Colors.white,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        actions: [
          IconButton(
              onPressed: () {
                provider.getNotes();
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNoteScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: provider.notes == null
          ? const Center(
              child: Text(
              "No Notes",
              style: TextStyle(fontSize: 32),
            ))
          : ListView.separated(
              itemBuilder: (context, index) => Dismissible(
                    background: delet,
                    secondaryBackground: edit,
                    onDismissed: (DismissDirection direction) {

                      print("swipe direction: $direction");
                      if (direction == DismissDirection.startToEnd) {
                        delet;
                        int id = provider.notes?[index]['id'];
                        print("swiped id: $id");
                        provider.deleteNote(id);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                '${provider.notes![index]['content']} deleted')));
                      } else if (direction == DismissDirection.endToStart) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditNotesScreen(provider.notes![index]['id'],provider.notes![index]['content']),
                          ),
                        );
                      }

                    },
                    key: Key(provider.notes![index]['id'].toString()),
                    child: Container(
                      width: double.infinity,
                      height: 70,
                      child: GestureDetector(
                        onTap: () {
                          print("ontab");
                        },
                        child: ListTile(
                          visualDensity: VisualDensity(vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: Colors.green,
                            child:
                                Text(provider.notes![index]['id'].toString(),style: TextStyle(color: Colors.white),),
                          ),
                          title: Text(
                            provider.notes?[index]['content'],
                            style: const TextStyle(fontSize: 32),
                          ),
                          subtitle: Text('Item description'),

                          trailing: IconButton( onPressed: () {  Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditNotesScreen(provider.notes![index]['id'],provider.notes![index]['content']),
                            ),
                          );  }, icon:Icon(Icons.more_vert) ,),
                        ),
                      ),
                    ),
                  ),
              separatorBuilder: (context, index) => const SizedBox(
                    height: 16,
                  ),
              itemCount: watcher.notes!.length),
    );
  }
}

class AddNoteScreen extends StatefulWidget {
  AddNoteScreen({Key? key}) : super(key: key);

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  var noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    NotesProvider provider = context.read<NotesProvider>();
    NotesProvider watcher = context.watch<NotesProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a note"),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  label: Text("Note"),
                  icon: Icon(Icons.note),
                  border: UnderlineInputBorder(),
                ),
                keyboardType: TextInputType.multiline,
                controller: noteController,
                style: const TextStyle(fontSize: 24),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          provider.insertToDatabase(noteController.text);
          Navigator.pop(context);
        },
        child: const Icon(Icons.note_add),
      ),
    );
  }
}
 class EditNotesScreen extends StatefulWidget {
   int  n =0;
   String con ="";
  EditNotesScreen(int id ,String content){
      n =id;
     con =content;
  }


   @override
   State<EditNotesScreen> createState() => _EditNotesScreenState(n,con);
 }


 class _EditNotesScreenState extends State<EditNotesScreen> {
   var noteEditController = TextEditingController();
   int  n =-1;
   _EditNotesScreenState(int id ,String content){
     n =id;
     noteEditController.text=content;
   }

   @override
   Widget build(BuildContext context) {

     NotesProvider provider = context.read<NotesProvider>();
     NotesProvider watcher = context.watch<NotesProvider>();
     return Scaffold(
       appBar: AppBar(
         title: const Text("Enter your changes "),
       ),
       body: SizedBox(
         width: double.infinity,
         child: Padding(
           padding: const EdgeInsets.symmetric(horizontal: 16.0),
           child: Column(
             mainAxisSize: MainAxisSize.max,
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               TextFormField(
                 decoration: const InputDecoration(
                   label: Text("Add new changes"),
                   icon: Icon(Icons.note),
                   border: UnderlineInputBorder(),
                 ),
                 keyboardType: TextInputType.multiline,
                 controller: noteEditController,
                 style: const TextStyle(fontSize: 24),
               )
             ],
           ),
         ),
       ),
       floatingActionButton: FloatingActionButton(
         onPressed: () {
           // provider.insertToDatabase(noteEditController.text);
           provider.editNote(n, noteEditController.text);
           Navigator.pop(context);
         },
         child: const Icon(Icons.edit_note),
       ),
     );
   }
 }
