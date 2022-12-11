import 'package:flutter/material.dart';
import 'package:practiceofsqlite/db_handler.dart';
import 'package:practiceofsqlite/notes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  DBHelper? dbHelper;
  late Future<List<NotesModel>> notesList;
  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    loadData();
  }

  loadData (){
    notesList = dbHelper!.getNotesList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes SQL"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: notesList,
                builder: (context, AsyncSnapshot<List<NotesModel>> snapshot) {

                if(snapshot.hasData){
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    reverse: false,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          dbHelper!.update(
                            NotesModel(
                                title: 'First flitter note',
                                age: 11,
                                description: 'let me talk to your tomorrow',
                                email: 'ahmed@gmail.com'
                            )
                          );
                          setState(() {
                            notesList = dbHelper!.getNotesList();
                          });
                        },
                        child: Dismissible(
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            child: Icon(Icons.delete_forever),
                          ),
                          onDismissed: (DismissDirection direction){
                            setState(() {
                              dbHelper!.delete(snapshot.data![index].id!);
                              notesList = dbHelper!.getNotesList();
                              snapshot.data!.remove(snapshot.data![index]);
                            });
                          },
                          key: ValueKey<int>(snapshot.data![index].id!),
                          child: Card(
                            child: ListTile(
                              contentPadding: EdgeInsets.all(8),
                              title: Text(snapshot.data![index].title.toString()),
                              subtitle: Text(snapshot.data![index].description.toString()),
                              trailing: Text(snapshot.data![index].age.toString()),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }else{
                  return CircularProgressIndicator();
                }


                },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          dbHelper!.insert(
            NotesModel(
                title: 'First',
                age: 27,
                description: 'This is my first sql app',
                email: 'ali@gmail.com'
            )
          ).then((value) {
            print('data added');
            setState(() {
              notesList = dbHelper!.getNotesList();
            });
          }).onError((error, stackTrace) {
            print(error.toString());
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
