import 'package:docs/common/widgets/loader.dart';
import 'package:docs/models/document_model.dart';
import 'package:docs/models/error_model.dart';
import 'package:docs/repository/auth.dart';
import 'package:docs/repository/document_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void signOut(WidgetRef ref) {
    ref.read(authRepositoryProvider).signOut();
    ref.read(userProvider.notifier).update((state) => null);
  }

  void createDocument(WidgetRef ref, BuildContext context) async {
    final token = ref.read(userProvider)!.token;
    final navigator = Routemaster.of(context);
    final snackbar = ScaffoldMessenger.of(context);
    final errorModel =
        await ref.read(documentRepositoryProvider).createDocument(token);

    if (errorModel.data != null) {
      navigator.push('/document/${errorModel.data.id}');
    } else {
      snackbar.showSnackBar(SnackBar(content: Text(errorModel.error ?? '')));
    }
  }

  void navigateToDocument(BuildContext context, String documentId) {
    Routemaster.of(context).push('document/$documentId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.read(userProvider)!.token;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () => createDocument(ref, context),
              icon: const Icon(Icons.add),
              color: Colors.blue),
          IconButton(
              onPressed: () => signOut(ref),
              icon: const Icon(Icons.logout, color: Colors.red))
        ],
      ),
      body: FutureBuilder<ErrorModel>(
        future: ref.watch(documentRepositoryProvider).getDocuments(token),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }
          return Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 600,
              child: ListView.builder(
                itemCount: snapshot.data?.data.length,
                itemBuilder: (context, index) {
                  final DocumentModel document = snapshot.data?.data[index];
                  return SizedBox(
                    height: 50,
                    child: InkWell(
                      onTap: () {
                        navigateToDocument(context, document.id);
                      },
                      child: Card(
                        child: Text(document.title,
                            style: const TextStyle(fontSize: 17)),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}
