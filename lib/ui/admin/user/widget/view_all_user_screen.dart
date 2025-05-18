import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:mycrochetbag/routing/routes.dart';
import 'package:mycrochetbag/ui/admin/user/view_model/user_viewmodel.dart';
import 'package:provider/provider.dart';

class ViewAllUserScreen extends StatelessWidget {
  const ViewAllUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UserViewModel>();

    if (viewModel.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (viewModel.hasError) {
      return Scaffold(
        body: Center(child: Text('Error: ${viewModel.errorMessage}')),
      );
    }

    final users = viewModel.users;

    return Scaffold(
      appBar: AppBar(
        title: Text("List of all users"),
        actions: [
          IconButton(
            icon: Icon(TablerIcons.circle_plus),
            onPressed: () {
              print('Add button pressed');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white, // White background
                      border: Border.all(color: Colors.grey), // Grey border
                      borderRadius: BorderRadius.circular(
                        5.0,
                      ), // 5-pixel radius
                    ),
                    child: ListTile(
                      title: Text('${user.firstName} ${user.lastName}'),
                      subtitle: Text(user.email),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        context.push('${Routes.viewAllUser}/${user.id}');
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
