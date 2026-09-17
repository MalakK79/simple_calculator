// Widget tests for the simple calculator app.
//
// Each test drives the calculator the way a user would: tapping the on
// screen buttons (found by the keys assigned in lib/main.dart) and checking
// what ends up on the display (found by the 'calc_display' key).

// Widget tests for the simple calculator app.
//
// Each test drives the calculator the way a user would: tapping the on
// screen buttons (found by the keys assigned in lib/main.dart) and checking
// what ends up on the display (found by the 'calc_display' key).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:simple_calculator/main.dart';

/// Taps the button with the given key and lets the widget tree settle.
Future<void> tapButton(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pump();
}

/// Reads the current text shown on the calculator's main display.
String displayText(WidgetTester tester) {
  return tester.widget<Text>(find.byKey(const Key('calc_display'))).data ?? '';
}

void main() {
  testWidgets('Calculator starts with 0 on the display', (
      WidgetTester tester,
      ) async {
    await tester.pumpWidget(const CalculatorApp());

    expect(displayText(tester), '0');
  });

  testWidgets('Tapping digits builds a multi-digit number on the display', (
      WidgetTester tester,
      ) async {
    await tester.pumpWidget(const CalculatorApp());

    await tapButton(tester, 'btn_1');
    await tapButton(tester, 'btn_2');
    await tapButton(tester, 'btn_3');

    expect(displayText(tester), '123');
  });

  testWidgets('Addition: 2 + 3 = 5', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tapButton(tester, 'btn_2');
    await tapButton(tester, 'btn_+');
    await tapButton(tester, 'btn_3');
    await tapButton(tester, 'btn_=');

    expect(displayText(tester), '5');
  });

  testWidgets('Division by zero shows an Error instead of crashing', (
      WidgetTester tester,
      ) async {
    await tester.pumpWidget(const CalculatorApp());

    await tapButton(tester, 'btn_8');
    await tapButton(tester, 'btn_÷');
    await tapButton(tester, 'btn_0');
    await tapButton(tester, 'btn_=');

    expect(displayText(tester), 'Error');
  });

  testWidgets('Clear (C) resets the display back to 0', (
      WidgetTester tester,
      ) async {
    await tester.pumpWidget(const CalculatorApp());

    await tapButton(tester, 'btn_9');
    await tapButton(tester, 'btn_9');
    expect(displayText(tester), '99');

    await tapButton(tester, 'btn_C');

    expect(displayText(tester), '0');
  });
}