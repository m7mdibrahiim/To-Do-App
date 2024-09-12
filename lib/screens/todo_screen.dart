import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_app/helper/appbar_title.dart';
import 'package:todo_app/models/todo__item_model.dart';
import '../providers/todo_provider.dart';

class TodoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitle(size: 20),
        actions: [
          PopupMenuButton<String>(
            onSelected: todoProvider.setFilter,
            itemBuilder: (BuildContext context) {
              return ['All', 'Completed', 'Incomplete'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: todoProvider.filteredItems.isEmpty
          ? const Center(
              child: Text(
                'No tasks available.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : AnimatedList(
              key: todoProvider.animatedListKey,
              initialItemCount: todoProvider.filteredItems.length,
              itemBuilder: (context, index, animation) {
                if (index < todoProvider.filteredItems.length) {
                  final item = todoProvider.filteredItems[index];
                  return _buildAnimatedItem(item, animation, context);
                } else {
                  return Container();
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 175, 219, 255),
        onPressed: () => _showAddTodoDialog(context),
        child: const Icon(
          Icons.add,
          color: Color.fromARGB(255, 242, 112, 5),
          size: 25,
        ),
      ),
    );
  }

  Widget _buildAnimatedItem(
      TodoItem item, Animation<double> animation, BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);

    return SizeTransition(
      sizeFactor: animation,
      child: ListTile(
        title: GestureDetector(
          onTap: () => _showEditTodoDialog(context, item),
          child: Text(
            item.task,
            style: TextStyle(
              decoration: item.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        subtitle: Text(
          item.category,
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.clear,
            color: Colors.red,
            size: 20,
          ),
          onPressed: () => todoProvider.deleteTodoItem(item),
        ),
        leading: Checkbox(
          activeColor: Colors.blue,
          value: item.isCompleted,
          onChanged: (bool? value) {
            todoProvider.toggleTodoItem(item);
          },
        ),
      ),
    );
  }

  ///
  void _showEditTodoDialog(BuildContext context, TodoItem item) {
    TextEditingController taskController =
        TextEditingController(text: item.task);
    String updatedCategory = item.category;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Edit Task',
              style:
                  GoogleFonts.arvo(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: taskController,
                    decoration: const InputDecoration(labelText: 'Task'),
                  ),
                  DropdownButton<String>(
                    value: updatedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        updatedCategory = newValue!;
                      });
                    },
                    items: <String>['Personal', 'Work']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<TodoProvider>(context, listen: false)
                    .updateTodoItem(item, taskController.text, updatedCategory);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    String task = '';
    String category = 'Personal';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Add New Task',
              style:
                  GoogleFonts.arvo(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      task = value;
                    },
                    decoration: const InputDecoration(labelText: 'Task'),
                  ),
                  DropdownButton<String>(
                    value: category,
                    onChanged: (String? newValue) {
                      setState(() {
                        category = newValue!;
                      });
                    },
                    items: <String>['Personal', 'Work']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<TodoProvider>(context, listen: false)
                    .addTodoItem(task, category);
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
