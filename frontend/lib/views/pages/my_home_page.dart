import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '/core/widgets/dialog_box.dart';
import '/models/security.dart';
import '/providers/security_provider.dart';
import '/providers/theme_mode_provider.dart';
import '/providers/my_aliments_provider.dart';


class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // securityProvider --> le when est déja géré dans login
    ref.watch(securityProvider);
    final securityNotifier = ref.read(securityProvider.notifier);

    final user = ref
        .read(securityProvider)
        .value;

    final themeNotifier = ref.read(themeModeProvider.notifier);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      /* ---------------------- APP BAR ---------------------- */
        appBar: AppBar(
          backgroundColor: Colors.blue,
          leading: Builder(
            builder: (ctx) =>
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
          ),
          title: const Text('Home',
              style: TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: null, // () => myTricountsNotifier.refresh(),
            ),

            const SizedBox(width: 4),
          ],
        ),

        /* ---------------------- DRAWER ----------------------- */
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.blue),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(user != null ? user.fullName : '',
                        // user peut passer à null lorsqu'on clique sur logout (permet d'éviter une page d'erreur)
                        style:
                        const TextStyle(color: Colors.white, fontSize: 16)),
                    Text(user != null ? user.email : '',
                        style:
                        const TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dataset),
                title: const Text('Ma base de données'),
                onTap: () {
                  Navigator.pushNamed(context, '/my_aliment_groups');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.dark_mode,
                  color: isDark ? Colors.grey : Colors.grey,
                ),
                title: Text(isDark ? 'Switch to Light Mode'
                    : 'Switch to Dark Mode'),
                onTap: () => themeNotifier.toggle(),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
                  securityNotifier.logout();
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_box_outlined),
                title: const Text('Création d''un nouveau régime'),
                onTap: () {
                  Navigator.pushNamed(context, '/add_diet');
                },
              ),
              ListTile(
                leading: const Icon(Icons.recycling),
                title: const Text('Reset Database'),
                onTap: () async {
                  final action = await DialogBox(
                    title: 'Confirmation',
                    message: 'Are you sure you want to reset the database?',
                    actions: const ['Yes', 'No'],
                  ).show(context);

                  if (action == 'Yes') {
                    try {
                      await Security.resetDatabase();
                      // Invalider le provider pour recharger les données
                      ref.invalidate(myAlimentsProvider);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Reset failed: $e')),
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ),
        )
    );
  }
}
