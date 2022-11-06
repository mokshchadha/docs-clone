import 'dart:async';

import 'package:docs/common/widgets/loader.dart';
import 'package:docs/models/error_model.dart';
import 'package:docs/repository/auth.dart';
import 'package:docs/repository/document_repository.dart';
import 'package:docs/repository/socket_repository.dart';
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

  quill.QuillController? _controller;

  SocketRepository socketRepository = SocketRepository();

  ErrorModel? errorModel;

  @override
  void initState() {
    super.initState();
    socketRepository.joinRoom(widget.id);
    fetchDocumentData();
    socketRepository.changeListener((data) {
      _controller?.compose(
          quill.Delta.fromJson(data['delta']),
          _controller?.selection ?? const TextSelection.collapsed(offset: 0),
          quill.ChangeSource.REMOTE);
    });
    Timer.periodic(const Duration(seconds: 2), (timer) {
      socketRepository.autoSave(<String, dynamic>{
        'delta': _controller!.document.toDelta(),
        'room': widget.id,
      });
    });
  }

  void fetchDocumentData() async {
    errorModel = await ref
        .read(documentRepositoryProvider)
        .getDocumentById(ref.read(userProvider)!.token, widget.id);

    if (errorModel!.data != null) {
      _titleController.text = errorModel!.data.title;
      _controller = quill.QuillController(
          selection: const TextSelection.collapsed(offset: 0),
          document: errorModel!.data.content.isEmpty
              ? quill.Document()
              : quill.Document.fromDelta(
                  quill.Delta.fromJson(errorModel!.data.content)));
      setState(() {});
    }
    _controller?.document.changes.listen((event) {
      if (event.item3 == quill.ChangeSource.LOCAL) {
        Map<String, dynamic> map = {
          'delta': event.item2,
          'room': widget.id,
        };
        socketRepository.typing(map);
      }
    });
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
    if (_controller == null) {
      return const Scaffold(
        body: Loader(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 9),
          child: Row(children: [
            const Icon(Icons.article, color: Colors.blue),
            const SizedBox(width: 5),
            SizedBox(
              width: deviceWidth * 0.4,
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 5),
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
            padding: const EdgeInsets.all(5),
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
                child: quill.QuillToolbar.basic(controller: _controller!),
              ),
              const SizedBox(height: 10),
              SizedBox(
                  width: deviceWidth * 0.7,
                  height: MediaQuery.of(context).viewInsets.bottom == 0
                      ? deviceHeight * 0.7
                      : deviceHeight * .4,
                  child: Card(
                      elevation: 5,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: quill.QuillEditor.basic(
                          controller: _controller!,
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
