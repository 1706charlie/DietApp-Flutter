import 'package:flutter/material.dart';


class DebugPanel extends StatelessWidget {
  final Function loginAction;
  final List<String> users;

  DebugPanel({
    required this.loginAction,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    return Container(                                                           // boite qui entoure et stylise le contenu
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          for (var user in users)
            TextButton(
              onPressed: () => loginAction(context, user),
              child: Text(
                'Login as $user',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }



  // Future<void> _resetDb(BuildContext context) async {
  //   final action = await DialogBox(
  //     title: 'Confirmation',
  //     message: 'Are you sure you want to reset the database?',
  //     actions: const ['Yes', 'No'],
  //   ).show(context);
  //
  //   if (action == 'Yes') {
  //     try {
  //       await Security.resetDatabase();
  //     } catch (e) {
  //       if (context.mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Reset failed: $e')),
  //         );
  //       }
  //     }
  //   }
  // }


}

