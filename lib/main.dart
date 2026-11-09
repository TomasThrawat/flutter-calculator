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
  Widget build(BuildContext context) {
    return MaterialApp(
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
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  static const List<List<String>> _rows = [
    ['AC', '±', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '−'],
    ['1', '2', '3', '+'],
    ['0', '.', '='],
  ];

  String _display = '0';
  String _expression = '';
  double? _storedValue;
  String? _pendingOperator;
  bool _replaceDisplay = false;
  String? _lastOperator;
  double? _lastOperand;

  void _press(String key) {
    if ('0123456789'.contains(key)) {
      _inputDigit(key);
      return;
    }

    switch (key) {
      case 'AC':
        _clear();
        break;
      case '±':
        _toggleSign();
        break;
      case '%':
        _percent();
        break;
      case '.':
        _inputDecimal();
        break;
      case '÷':
      case '×':
      case '−':
      case '+':
        _selectOperator(key);
        break;
      case '=':
        _equals();
        break;
    }
  }

  void _inputDigit(String digit) {
    setState(() {
      if (_display == 'Error') {
        _resetCalculation();
        _display = digit;
        return;
      }

      if (_replaceDisplay) {
        if (_pendingOperator == null) {
          _expression = '';
          _lastOperator = null;
          _lastOperand = null;
        }
        _display = digit;
        _replaceDisplay = false;
        return;
      }

      final digitCount = _display.replaceAll(RegExp(r'[^0-9]'), '').length;
      if (digitCount >= 15) {
        return;
      }

      if (_display == '0') {
        _display = digit;
      } else {
        _display += digit;
      }
    });
  }

  void _inputDecimal() {
    setState(() {
      if (_display == 'Error') {
        _resetCalculation();
        _display = '0.';
        return;
      }

      if (_replaceDisplay) {
        if (_pendingOperator == null) {
          _expression = '';
          _lastOperator = null;
          _lastOperand = null;
        }
        _display = '0.';
        _replaceDisplay = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _toggleSign() {
    final value = double.tryParse(_display);
    if (value == null || value == 0) {
      return;
    }
    setState(() {
      _display = _format(-value);
    });
  }

  void _percent() {
    final value = double.tryParse(_display);
    if (value == null) {
      return;
    }

    setState(() {
      _expression = '${_format(value)} %';
      _display = _format(value / 100);
      _replaceDisplay = false;
    });
  }

  void _selectOperator(String symbol) {
    final current = double.tryParse(_display);
    if (current == null) {
      return;
    }

    var nextValue = current;
    if (_storedValue != null && _pendingOperator != null) {
      if (_replaceDisplay) {
        nextValue = _storedValue!;
      } else {
        final result = _calculate(
          _storedValue!,
          current,
          _pendingOperator!,
        );
        if (result == null) {
          _showError();
          return;
        }
        nextValue = result;
      }
    }

    setState(() {
      _storedValue = nextValue;
      _display = _format(nextValue);
      _pendingOperator = symbol;
      _expression = '${_format(nextValue)} $symbol';
      _replaceDisplay = true;
      _lastOperator = null;
      _lastOperand = null;
    });
  }

  void _equals() {
    if (_pendingOperator == null || _storedValue == null) {
      _repeatLastOperation();
      return;
    }

    final left = _storedValue!;
    final right = _replaceDisplay ? left : double.tryParse(_display);
    if (right == null) {
      return;
    }

    final operator = _pendingOperator!;
    final result = _calculate(left, right, operator);
    if (result == null) {
      _showError();
      return;
    }

    setState(() {
      _expression =
          '${_format(left)} $operator ${_format(right)} =';
      _display = _format(result);
      _lastOperator = operator;
      _lastOperand = right;
      _storedValue = null;
      _pendingOperator = null;
      _replaceDisplay = true;
    });
  }

  void _repeatLastOperation() {
    final operator = _lastOperator;
    final operand = _lastOperand;
    final current = double.tryParse(_display);
    if (operator == null || operand == null || current == null) {
      return;
    }

    final result = _calculate(current, operand, operator);
    if (result == null) {
      _showError();
      return;
    }

    setState(() {
      _expression =
          '${_format(current)} $operator ${_format(operand)} =';
      _display = _format(result);
      _replaceDisplay = true;
    });
  }

  double? _calculate(double left, double right, String operator) {
    final result = switch (operator) {
      '+' => left + right,
      '−' => left - right,
      '×' => left * right,
      '÷' => right == 0 ? null : left / right,
      _ => null,
    };

    if (result == null || !result.isFinite) {
      return null;
    }
    return result;
  }

  String _format(double value) {
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

  void _clear() {
    setState(_resetCalculation);
  }

  void _resetCalculation() {
    _display = '0';
    _expression = '';
    _storedValue = null;
    _pendingOperator = null;
    _replaceDisplay = false;
    _lastOperator = null;
    _lastOperand = null;
  }

  void _showError() {
    setState(() {
      _display = 'Error';
      _expression = 'Cannot divide by zero';
      _storedValue = null;
      _pendingOperator = null;
      _replaceDisplay = true;
      _lastOperator = null;
      _lastOperand = null;
    });
  }

  String _keyId(String label) {
    return switch (label) {
      '±' => 'sign',
      '÷' => 'divide',
      '×' => 'multiply',
      '−' => 'subtract',
      _ => label,
    };
  }

  Widget _buildKey(String label) {
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
            key: ValueKey<String>('calculator-key-${_keyId(label)}'),
            onTap: () => _press(label),
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
  Widget build(BuildContext context) {
    return Scaffold(
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
                          _expression,
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
                            _display,
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
                    for (final row in _rows)
                      Expanded(
                        child: Row(
                          children: [
                            for (final label in row) _buildKey(label),
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
}
