import 'package:flutter/material.dart';

import './widgets/new_transaction.dart';
import './widgets/transaction_list.dart';
import './models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static const String _correctPassword = 'YourPassword';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Your Personal Diary',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.deepPurple,
      ),
      home: PasswordScreen(),
    );
  }
}

class PasswordScreen extends StatefulWidget {
  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final _passwordController = TextEditingController();
  bool _passwordIsValid = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _checkPassword(String password) {
    setState(() {
      _passwordIsValid = password == MyApp._correctPassword;
    });
    if (_passwordIsValid) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              onSubmitted: _checkPassword,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _checkPassword(_passwordController.text),
              child: Text('Submit'),
            ),
            if (_passwordIsValid) SizedBox(height: 16),
            if (_passwordIsValid)
              Text(
                'Password is correct!',
                style: TextStyle(color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // String titleInput;
  // String amountInput;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Transaction> _userTransactions = [];

  void initState() {
    super.initState();
    loadCustomDataList().then((transactions) {
      setState(() {
        _userTransactions = transactions;
      });
    });
  }

  static const String _key = 'custom_data';

  // store a list of CustomData objects in SharedPreferences
  static Future<void> saveCustomDataList(List<Transaction> dataList) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> dataJsonList =
        dataList.map((data) => data.toJson()).toList();
    await prefs.setStringList(_key, dataJsonList);
  }

  // retrieve a list of CustomData objects from SharedPreferences
  static Future<List<Transaction>> loadCustomDataList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> dataJsonList = prefs.getStringList(_key);
    if (dataJsonList == null) {
      return [];
    }
    return dataJsonList
        .map((dataJson) => Transaction.fromJson(dataJson))
        .toList();
  }

  void _addNewTransaction(String txTitle, DateTime txAmount) {
    final newTx = Transaction(
      title: txTitle,
      date: DateTime.now(),
    );

    setState(() {
      _userTransactions.add(newTx);
      saveCustomDataList(_userTransactions);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewTransaction(_addNewTransaction),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  void _deleteTransaction(BuildContext ctx) {
    setState(() {
      _userTransactions = [];
      saveCustomDataList(_userTransactions);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Personal Diary'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _startAddNewTransaction(context),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 10,
          ),
          SingleChildScrollView(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TransactionList(_userTransactions),
              ],
            ),
          ),
          Align(
              alignment: Alignment.topRight,
              child: ElevatedButton(
                child: Text('Delete All Messages'),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.purple),
                ),
                onPressed: () => _deleteTransaction(context),
              )),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _startAddNewTransaction(context),
      ),
    );
  }
}
