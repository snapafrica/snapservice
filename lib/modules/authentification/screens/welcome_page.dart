import 'package:snapservice/common.dart';

class PasswordPAge extends ConsumerWidget {
  const PasswordPAge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = LocalStorage.nosql.user;
    print(user?.pin);
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        title: Text(
          'WELCOME\n${user?.name ?? user?.email}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authenticationServiceProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SecureScreen(
        onConfirm: (value) {
          if (value == user?.pin) {
            context.go('/');
          } else {
            Fluttertoast.showToast(
              msg: "Invalid pin",
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          }
        },
        placeholder: 'Enter pin',
      ),
    );
  }
}
