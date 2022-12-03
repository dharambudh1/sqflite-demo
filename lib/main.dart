import 'package:flutter/material.dart';
import 'package:sqflite_demo/db.dart';

import 'create.dart';
import 'model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sqflite Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Details>? details;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);
    details = await DetailsDatabase.instance.readAllDetails();
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    DetailsDatabase.instance.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateEntry(
                  editMode: false,
                  detailsValues: Details(
                    id: null,
                    firstName: '',
                    lastName: '',
                    gender: '',
                    age: 0,
                  ),
                ),
              ),
            ).whenComplete(() => refreshNotes());
          },
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerFloat,
        body: SafeArea(
          child: ListView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            reverse: true,
            itemCount: details?.length ?? 0,
            itemBuilder: (context, index) {
              Details? detailsValues = details?[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            commonRichTextWidget(
                                label: 'ID number',
                                value: detailsValues?.id.toString() ?? ''),
                            commonRichTextWidget(
                                label: 'First name',
                                value: detailsValues?.firstName ?? ''),
                            commonRichTextWidget(
                                label: 'Last name',
                                value: detailsValues?.lastName ?? ''),
                            commonRichTextWidget(
                                label: 'Age',
                                value: detailsValues?.age.toString() ?? ''),
                            commonRichTextWidget(
                                label: 'Gender',
                                value: detailsValues?.gender ?? ''),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateEntry(
                                  editMode: true,
                                  detailsValues: detailsValues!),
                            ),
                          ).whenComplete(() => refreshNotes());
                        },
                        child: const Icon(Icons.edit),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        onTap: () async {
                          await DetailsDatabase.instance
                              .delete(detailsValues?.id ?? 0);
                          refreshNotes();
                        },
                        child: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget commonRichTextWidget({
    required String label,
    required String value,
  }) {
    return RichText(
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      maxLines: 1,
      text: TextSpan(
        text: '$label: ',
        style: Theme.of(context).textTheme.bodyMedium,
        children: <TextSpan>[
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
