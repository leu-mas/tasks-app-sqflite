import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tasks_app/helpers/database_helper.dart';
import 'package:tasks_app/models/task_model.dart';
import 'package:tasks_app/screens/add_task_screen.dart';

class TasksScreen extends StatefulWidget {
  final Function updateTaskList;
  final Task task;

  TasksScreen({this.updateTaskList, this.task});

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  Future<List<Task>> _taskList;
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    _updateTaskList();
  }

  _updateTaskList() {
    setState(() {
      _taskList = DatabaseHelper.instance.getTaskList();
    });
  }

  _delete(int taskId) {
    DatabaseHelper.instance.deleteTask(taskId);
    widget.updateTaskList();
  }

  Widget _buildTasks(Task task) {
    return Dismissible(
      onDismissed: (direction) {
        print(task.id);
        setState(() {
          _delete(task.id);
        });
      },
      key: Key(
        task.id.toString(),
      ),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        child: Padding(
          padding: EdgeInsets.only(
            right: 32.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Delete',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            ListTile(
              title: Text(
                task.title,
                style: TextStyle(
                  fontSize: 18.0,
                  decoration: task.status == 0
                      ? TextDecoration.none
                      : TextDecoration.lineThrough,
                ),
              ),
              subtitle: Row(
                children: [
                  Text(
                    '${_dateFormatter.format(task.date)}',
                    style: TextStyle(
                      fontSize: 14.0,
                      decoration: task.status == 0
                          ? TextDecoration.none
                          : TextDecoration.lineThrough,
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Text(
                    '${task.priority}',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: task.priority == 'High'
                          ? Colors.red
                          : task.priority == 'Medium'
                              ? Colors.orange
                              : Colors.black54,
                      decoration: task.status == 0
                          ? TextDecoration.none
                          : TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
              trailing: Checkbox(
                onChanged: (value) {
                  task.status = value ? 1 : 0;
                  DatabaseHelper.instance.updateTask(task);
                  _updateTaskList();
                },
                activeColor: Theme.of(context).primaryColor,
                value: task.status == 1 ? true : false,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddTasksScreen(
                    updateTaskList: _updateTaskList,
                    task: task,
                  ),
                ),
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTasksScreen(
                updateTaskList: _updateTaskList,
              ),
            ),
          );
        },
      ),
      body: FutureBuilder(
        future: _taskList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final int completedTaskCount = snapshot.data
              .where((Task task) => task.status == 1)
              .toList()
              .length;

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            itemCount: 1 + snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My tasks',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        '$completedTaskCount of ${snapshot.data.length}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return _buildTasks(snapshot.data[index - 1]);
            },
          );
        },
      ),
    );
  }
}
