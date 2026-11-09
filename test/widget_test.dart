import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_calculator/main.dart';

void main() {
  Future<void> press(WidgetTester tester, List<String> keys) async {
    for (final key in keys) {
      final keyId = switch (key) {
        '±' => 'sign',
        '÷' => 'divide',
        '×' => 'multiply',
        '−' => 'subtract',
        _ => key,
      };
      await tester.tap(
        find.byKey(ValueKey<String>('calculator-key-$keyId')),
      );
      await tester.pump();
    }
  }

  String display(WidgetTester tester) {
    return tester
            .widget<Text>(
              find.byKey(const ValueKey<String>('calculator-display')),
            )
            .data ??
        '';
  }

  testWidgets('adds two numbers', (tester) async {
    await tester.pumpWidget(const CalculatorApp());
    await press(tester, ['2', '+', '3', '=']);
    expect(display(tester), '5');
  });

  testWidgets('supports decimal calculations', (tester) async {
    await tester.pumpWidget(const CalculatorApp());
    await press(tester, ['1', '.', '5', '×', '2', '=']);
    expect(display(tester), '3');
  });

  testWidgets('handles divide by zero and recovers', (tester) async {
    await tester.pumpWidget(const CalculatorApp());
    await press(tester, ['8', '÷', '0', '=']);
    expect(display(tester), 'Error');
    await press(tester, ['7']);
    expect(display(tester), '7');
  });

  testWidgets('supports percent and clear', (tester) async {
    await tester.pumpWidget(const CalculatorApp());
    await press(tester, ['5', '0', '%']);
    expect(display(tester), '0.5');
    await press(tester, ['AC']);
    expect(display(tester), '0');
  });

  testWidgets('supports subtraction and repeated equals', (tester) async {
    await tester.pumpWidget(const CalculatorApp());
    await press(tester, ['9', '−', '3', '=', '=']);
    expect(display(tester), '3');
  });
}
