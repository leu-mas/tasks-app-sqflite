import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tasks_app/helpers/database_helper.dart';
import 'package:tasks_app/models/task_model.dart';

class AddTasksScreen extends StatefulWidget {
  final Function updateTaskList;
  final Task task;

  AddTasksScreen({this.updateTaskList, this.task});

  @override
  _AddTasksScreenState createState() => _AddTasksScreenState();
}

class _AddTasksScreenState extends State<AddTasksScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _priority;
  DateTime _date = DateTime.now();
  TextEditingController _dateController = TextEditingController();

  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  // ignore: must_call_super
  void initState() {
    if (widget.task != null) {
      _title = widget.task.title;
      _date = widget.task.date;
      _priority = widget.task.priority;
    }

    _dateController.text = _dateFormatter.format(_date);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  _handlerDatePicker() async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      _dateController.text = _dateFormatter.format(date);
    }
  }

  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print('$_title, $_date, $_priority');

      Task task = Task(title: _title, date: _date, priority: _priority);
      if (widget.task == null) {
        task.status = 0;
        DatabaseHelper.instance.insertTask(task);
      } else {
        task.id = widget.task.id;
        task.status = widget.task.status;
        DatabaseHelper.instance.updateTask(task);
      }

      widget.updateTaskList();
      Navigator.pop(context);
    }
  }

  _delete() {
    DatabaseHelper.instance.deleteTask(widget.task.id);
    widget.updateTaskList();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 60.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back,
                    size: 24.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 20.0),
                Text(
                  widget.task == null ? 'Add Task' : 'Update Task',
                  style: TextStyle(
                    fontSize: 28.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.0),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: TextFormField(
                          style: TextStyle(fontSize: 16.0),
                          decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: TextStyle(fontSize: 16.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (input) => input.trim().isEmpty
                              ? 'Please, enter a task title'
                              : null,
                          onSaved: (input) => _title =
                              input[0].toUpperCase() + input.substring(1),
                          initialValue: _title,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: TextFormField(
                          readOnly: true,
                          controller: _dateController,
                          style: TextStyle(fontSize: 16.0),
                          onTap: _handlerDatePicker,
                          decoration: InputDecoration(
                            labelText: 'Date',
                            labelStyle: TextStyle(fontSize: 16.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: DropdownButtonFormField(
                          isDense: true,
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 22.0,
                          iconEnabledColor: Theme.of(context).primaryColor,
                          style: TextStyle(fontSize: 16.0),
                          items: _priorities.map((String priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Text(
                                priority,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                ),
                              ),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            labelText: 'Priority',
                            labelStyle: TextStyle(fontSize: 16.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (input) => _priority == null
                              ? 'Please, select a priority level'
                              : null,
                          onChanged: (value) {
                            setState(() {
                              _priority = value;
                            });
                            value = _priority;
                          },
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20.0),
                        height: 45.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: FlatButton(
                          child: Text(
                            widget.task == null ? 'Add' : 'Update',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                            ),
                          ),
                          onPressed: _submit,
                        ),
                      ),
                      widget.task != null
                          ? Container(
                              margin: EdgeInsets.symmetric(vertical: 10.0),
                              height: 45.0,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: FlatButton(
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                  ),
                                ),
                                onPressed: _delete,
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
