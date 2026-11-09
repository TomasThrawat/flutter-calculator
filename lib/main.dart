import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
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
          final count = display.replaceAll(RegExp(r'[^0-9]'), '').length;
          if (count < 15) display = display == '0' ? key : display + key;
        }
      });
      return;
    }

    switch (key) {
      case 'AC':
        setState(reset);
        break;
      case '±':
        final value = double.tryParse(display);
        if (value != null && value != 0) {
          setState(() => display = format(-value));
        }
        break;
      case '%':
        final value = double.tryParse(display);
        if (value != null) {
          setState(() {
            expression = format(value) + ' %';
            display = format(value / 100);
            replaceDisplay = false;
          });
        }
        break;
      case '.':
        setState(() {
          if (display == 'Error') reset();
          if (replaceDisplay) {
            if (operation == null) expression = '';
            display = '0.';
            replaceDisplay = false;
          } else if (!display.contains('.')) {
            display += '.';
          }
        });
        break;
      case '÷':
      case '×':
      case '−':
      case '+':
        chooseOperation(key);
        break;
      case '=':
        equals();
        break;
    }
  }

  void chooseOperation(String symbol) {
    final current = double.tryParse(display);
    if (current == null) return;
    var next = current;
    if (stored != null && operation != null && !replaceDisplay) {
      final result = calculate(stored!, current, operation!);
      if (result == null) {
        showError();
        return;
      }
      next = result;
    } else if (stored != null && operation != null) {
      next = stored!;
    }
    setState(() {
      stored = next;
      display = format(next);
      operation = symbol;
      expression = format(next) + ' ' + symbol;
      replaceDisplay = true;
      lastOperation = null;
      lastOperand = null;
    });
  }

  void equals() {
    if (operation == null || stored == null) {
      final op = lastOperation;
      final operand = lastOperand;
      final current = double.tryParse(display);
      if (op == null || operand == null || current == null) return;
      final repeated = calculate(current, operand, op);
      if (repeated == null) {
        showError();
        return;
      }
      setState(() {
        expression = format(current) + ' ' + op + ' ' + format(operand) + ' =';
        display = format(repeated);
        replaceDisplay = true;
      });
      return;
    }

    final left = stored!;
    final right = replaceDisplay ? left : double.tryParse(display);
    if (right == null) return;
    final op = operation!;
    final result = calculate(left, right, op);
    if (result == null) {
      showError();
      return;
    }
    setState(() {
      expression = format(left) + ' ' + op + ' ' + format(right) + ' =';
      display = format(result);
      lastOperation = op;
      lastOperand = right;
      stored = null;
      operation = null;
      replaceDisplay = true;
    });
  }

  double? calculate(double a, double b, String op) {
    final result = switch (op) {
      '+' => a + b,
      '−' => a - b,
      '×' => a * b,
      '÷' => b == 0 ? null : a / b,
      _ => null,
    };
    return result == null || !result.isFinite ? null : result;
  }

  String format(double value) {
    final normalized = value.abs() < 0.0000000001 ? 0.0 : value;
    if (normalized.abs() >= 1000000000000000 ||
        (normalized != 0 && normalized.abs() < 0.000000001)) {
      return normalized.toStringAsPrecision(10);
    }
    return normalized
        .toStringAsFixed(10)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
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
            key: ValueKey<String>('calculator-key-$label'),
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
                            children: [
                              for (final label in row) keyButton(label),
                            ],
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
