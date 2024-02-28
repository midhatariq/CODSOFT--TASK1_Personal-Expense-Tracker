import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Persnal Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        hintColor: Colors.purple,
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ExpenseTrackerHomePage(),
    );
  }
}

class ExpenseTrackerHomePage extends StatefulWidget {
  @override
  _ExpenseTrackerHomePageState createState() => _ExpenseTrackerHomePageState();
}

class _ExpenseTrackerHomePageState extends State<ExpenseTrackerHomePage> {
  List<Expense> expenses = [];
  double totalIncome = 0;
  Map<String, double> expenseCategories = {
    'Food and Grocery': 0,
    'Makeup and Dresses': 0,
    'Transport': 0,
    'Utility Bills': 0,
    'Entertainment': 0,
    'Loan': 0,
  };

  String _selectedCategory = 'Food and Grocery';

  final TextEditingController _expenseNameController = TextEditingController();
  final TextEditingController _expenseAmountController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      totalIncome = prefs.getDouble('totalIncome') ?? 0;
      String expenseData = prefs.getString('expenses') ?? '';
      if (expenseData.isNotEmpty) {
        List<dynamic> parsedList = expenseData.split('|');
        expenses = parsedList.map((item) {
          List<dynamic> data = item.split(',');
          return Expense(name: data[0], amount: double.parse(data[1]), category: data[2], timestamp: DateTime.parse(data[3]));
        }).toList();
      }
      expenses.forEach((expense) {
        expenseCategories[expense.category] = expenseCategories[expense.category]! + expense.amount;
      });
    });
  }

  void _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('totalIncome', totalIncome);
    String expenseData = expenses.map((expense) => '${expense.name},${expense.amount},${expense.category},${expense.timestamp}').join('|');
    prefs.setString('expenses', expenseData);
  }

  void _addExpense() {
    String name = _expenseNameController.text;
    double amount = double.parse(_expenseAmountController.text);

    setState(() {
      expenses.add(Expense(name: name, amount: amount, category: _selectedCategory, timestamp: DateTime.now()));
      expenseCategories[_selectedCategory] = expenseCategories[_selectedCategory]! + amount;
      _saveData();
    });

    _expenseNameController.clear();
    _expenseAmountController.clear();
  }

  void _addIncome() {
    double amount = double.parse(_incomeController.text);

    setState(() {
      totalIncome += amount;
      _saveData();
    });

    _incomeController.clear();
  }

  void _deleteExpense(int index) {
    String category = expenses[index].category;
    double amount = expenses[index].amount;
    setState(() {
      expenses.removeAt(index);
      expenseCategories[category] = expenseCategories[category]! - amount;
      _saveData();
    });
  }

  double getTotalExpenses() {
    double total = 0;
    expenses.forEach((expense) {
      total += expense.amount;
    });
    return total;
  }

  double getRemainingAmount() {
    double totalExpenses = getTotalExpenses();
    return totalIncome - totalExpenses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Persnal Expense Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAddExpenseForm(),
              SizedBox(height: 20),
              _buildAddIncomeForm(),
              SizedBox(height: 20),
              _buildExpenseSummary(),
              SizedBox(height: 20),
              _buildExpenseList(),
              SizedBox(height: 20),
              Text(
                'Remaining Income: \Rs ${getRemainingAmount().toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildAddExpenseForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Expense',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _expenseNameController,
              decoration: InputDecoration(
                labelText: 'Expense Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _expenseAmountController,
              decoration: InputDecoration(
                labelText: 'Expense Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
              items: <String>[
                'Food and Grocery',
                'Makeup and Dresses',
                'Transport',
                'Utility Bills',
                'Entertainment',
                'Loan'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addExpense,
              child: Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddIncomeForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Income',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _incomeController,
              decoration: InputDecoration(
                labelText: 'Income Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed:

              _addIncome,
              child: Text('Add Income'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseSummary() {
    List<charts.Series<ExpenseChartData, String>> _createChartData() {
      List<ExpenseChartData> data = [];
      expenseCategories.forEach((category, amount) {
        data.add(ExpenseChartData(category, amount));
      });

      return [
        charts.Series<ExpenseChartData, String>(
          id: 'Expenses',
          domainFn: (ExpenseChartData expense, _) => expense.type,
          measureFn: (ExpenseChartData expense, _) => expense.amount,
          data: data,
          colorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault,
          labelAccessorFn: (ExpenseChartData row, _) => '\Rs ${row.amount.toStringAsFixed(2)}',
        ),
      ];
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildExpenseChart(_createChartData()),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseChart(List<charts.Series<ExpenseChartData, String>> seriesList) {
    return Container(
      height: 200,
      child: charts.BarChart(
        seriesList,
        animate: true,
        barGroupingType: charts.BarGroupingType.grouped,
        vertical: false,
        behaviors: [charts.SeriesLegend()],
        domainAxis: charts.OrdinalAxisSpec(renderSpec: charts.NoneRenderSpec()),
      ),
    );
  }

  Widget _buildExpenseList() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(expenses[index].name),
                  subtitle: Text(expenses[index].timestamp.toString()),
                  trailing: Text(
                    '\Rs ${expenses[index].amount.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () => _deleteExpense(index),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Expense {
  final String name;
  final double amount;
  final String category;
  final DateTime timestamp;

  Expense({required this.name, required this.amount, required this.category, required this.timestamp});
}
class ExpenseChartData {
  final String type;
  final double amount;

  ExpenseChartData(this.type, this.amount);
}