import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Calculator',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.black,
    ),
    home: const CalculatorPage(),
  );
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  static const rows = [
    ['AC', '±', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '−'],
    ['1', '2', '3', '+'],
    ['0', '.', '='],
  ];

  String display = '0';
  String expression = '';
  double? stored;
  String? operation;
  bool replaceDisplay = false;
  String? lastOperation;
  double? lastOperand;

  void press(String key) {
    if ('0123456789'.contains(key)) {
      setState(() {
        if (display == 'Error') reset();
        if (replaceDisplay) {
          if (operation == null) expression = '';
          display = key;
          replaceDisplay = false;
        } else {
          final count = display.replaceAll(RegExp(r'\.$'), '');
  }

  void reset() {
    display = '0';
    expression = '';
    stored = null;
    operation = null;
    replaceDisplay = false;
    lastOperation = null;
    lastOperand = null;
  }

  void showError() {
    setState(() {
      display = 'Error';
      expression = 'Cannot divide by zero';
      stored = null;
      operation = null;
      replaceDisplay = true;
      lastOperation = null;
      lastOperand = null;
    });
  }

  String keyId(String label) => switch (label) {
        '±' => 'sign',
        '÷' => 'divide',
        '×' => 'multiply',
        '−' => 'subtract',
        _ => label,
      };

  Widget keyButton(String label) {
    final isOperator = const {'÷', '×', '−', '+', '='}.contains(label);
    return Expanded(
      flex: label == '0' ? 2 : 1,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Material(
          color: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: isOperator ? Colors.white54 : Colors.white24,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: ValueKey<String>('calculator-key-${keyId(label)}'),
            onTap: () => press(label),
            splashColor: Colors.white10,
            highlightColor: Colors.white12,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: label.length > 2 ? 20 : 29,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 4, 6, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CALCULATOR',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.2,
                      ),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        expression,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 21,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          display,
                          key: const ValueKey<String>('calculator-display'),
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 68,
                            fontWeight: FontWeight.w300,
                            height: 1.05,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  for (final row in rows)
                    Expanded(
                      child: Row(
                        children: [for (final label in row) keyButton(label)],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

