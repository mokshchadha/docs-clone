import 'package:docs/models/error_model.dart';
import 'package:docs/repository/auth.dart';
import 'package:docs/repository/document_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen(this.id, {Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  final TextEditingController _titleController =
      TextEditingController(text: 'Untitled Document');

  final quill.QuillController _controller = quill.QuillController.basic();

  ErrorModel? errorModel;

  @override
  void initState() {
    super.initState();
    fetchDocumentData();
  }

  void fetchDocumentData() async {
    errorModel = await ref
        .read(documentRepositoryProvider)
        .getDocumentById(ref.read(userProvider)!.token, widget.id);

    if (errorModel!.data != null) {
      _titleController.text = errorModel!.data.title;
      setState(() {});
    }
  }

  void updateTitle(WidgetRef ref, String value) {
    final token = ref.read(userProvider)!.token;
    ref
        .read(documentRepositoryProvider)
        .updateTitle(token: token, id: widget.id, title: value);
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 9),
          child: Row(children: [
            const Icon(Icons.article, color: Colors.blue),
            const SizedBox(width: 10),
            SizedBox(
              width: 300,
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 10),
                ),
                onSubmitted: (value) => updateTitle(ref, value),
              ),
            )
          ]),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade800, width: 0.1),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton.icon(
                onPressed: () {},
                label: const Text('Share'),
                icon: const Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 16,
                )),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade800, width: 0.1),
        ),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                child: quill.QuillToolbar.basic(controller: _controller),
              ),
              const SizedBox(height: 10),
              SizedBox(
                  width: deviceWidth * 0.7,
                  height: deviceHeight * 0.7,
                  child: Card(
                      elevation: 5,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: quill.QuillEditor.basic(
                          controller: _controller,
                          readOnly: false,
                        ),
                      )))
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
