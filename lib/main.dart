import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[100],
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
  // What is currently shown on the main display.
  String _display = '0';

  // The expression shown above the main display, e.g. "12 +".
  String _expression = '';

  // The first operand of the pending calculation.
  double? _firstOperand;

  // The pending operator, one of + - x /.
  String? _operator;

  // True right after an operator/equals was pressed: the next digit
  // press should start a fresh number instead of appending.
  bool _shouldResetDisplay = false;

  // True after an error (e.g. divide by zero): any input clears it.
  bool _hasError = false;

  static const int _maxDigits = 12;

  void _onDigitPressed(String digit) {
    setState(() {
      if (_hasError || _shouldResetDisplay) {
        _display = digit;
        _shouldResetDisplay = false;
        _hasError = false;
      } else if (_display == '0') {
        _display = digit;
      } else {
        if (_digitCount(_display) < _maxDigits) {
          _display += digit;
        }
      }
    });
  }

  void _onDecimalPressed() {
    setState(() {
      if (_hasError || _shouldResetDisplay) {
        _display = '0.';
        _shouldResetDisplay = false;
        _hasError = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  

  void _onOperatorPressed(String op) {
    setState(() {
      if (_hasError) {
        _hasError = false;
      }

      if (_operator != null && !_shouldResetDisplay) {
        // Chain calculations: e.g. 2 + 3 + becomes 5, then continues with +.
        final result = _calculate(
          _firstOperand!,
          double.parse(_display),
          _operator!,
        );
        if (result == null) {
          _showError();
          return;
        }
        _firstOperand = result;
        _display = _formatNumber(result);
      } else {
        _firstOperand = double.parse(_display);
      }

      _operator = op;
      _expression = '${_formatNumber(_firstOperand!)} ${_operatorSymbol(op)}';
      _shouldResetDisplay = true;
    });
  }

  void _onEqualsPressed() {
    setState(() {
      if (_operator == null || _firstOperand == null || _hasError) {
        return;
      }

      final secondOperand = double.parse(_display);
      final result = _calculate(_firstOperand!, secondOperand, _operator!);

      if (result == null) {
        _showError();
        return;
      }

      _expression =
          '${_formatNumber(_firstOperand!)} ${_operatorSymbol(_operator!)} ${_formatNumber(secondOperand)} =';
      _display = _formatNumber(result);
      _firstOperand = null;
      _operator = null;
      _shouldResetDisplay = true;
    });
  }

  void _onClearPressed() {
    setState(() {
      _display = '0';
      _expression = '';
      _firstOperand = null;
      _operator = null;
      _shouldResetDisplay = false;
      _hasError = false;
    });
  }

  void _onBackspacePressed() {
    setState(() {
      if (_hasError || _shouldResetDisplay) {
        return;
      }
      if (_display.length <= 1 ||
          (_display.length == 2 && _display.startsWith('-'))) {
        _display = '0';
      } else {
        _display = _display.substring(0, _display.length - 1);
      }
    });
  }

  void _showError() {
    _display = 'Error';
    _expression = '';
    _firstOperand = null;
    _operator = null;
    _shouldResetDisplay = true;
    _hasError = true;
  }

  double? _calculate(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '−':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        if (b == 0) {
          return null;
        }
        return a / b;
      default:
        return b;
    }
  }

  String _operatorSymbol(String op) => op;

  int _digitCount(String s) => s.replaceAll('-', '').replaceAll('.', '').length;

  String _formatNumber(double value) {
    if (value.isInfinite || value.isNaN) {
      return 'Error';
    }
    if (value == value.roundToDouble() && value.abs() < 1e12) {
      return value.toStringAsFixed(0);
    }
    String result = value.toStringAsFixed(8);
    result = result.replaceFirst(RegExp(r'0+$'), '');
    result = result.replaceFirst(RegExp(r'\.$'), '');
    if (result.length > _maxDigits + 2) {
      return value.toStringAsPrecision(10);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _expression,
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.bottomRight,
                      child: Text(
                        _display,
                        key: const Key('calc_display'),
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w300,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildRow([
                      _ButtonSpec.function('C', _onClearPressed),
                      _ButtonSpec.function('⌫', _onBackspacePressed),
                      _ButtonSpec.operatorBtn('÷', () => _onOperatorPressed('÷')),
                    ]),
                    _buildRow([
                      _ButtonSpec.digit('7', () => _onDigitPressed('7')),
                      _ButtonSpec.digit('8', () => _onDigitPressed('8')),
                      _ButtonSpec.digit('9', () => _onDigitPressed('9')),
                      _ButtonSpec.operatorBtn('×', () => _onOperatorPressed('×')),
                    ]),
                    _buildRow([
                      _ButtonSpec.digit('4', () => _onDigitPressed('4')),
                      _ButtonSpec.digit('5', () => _onDigitPressed('5')),
                      _ButtonSpec.digit('6', () => _onDigitPressed('6')),
                      _ButtonSpec.operatorBtn('−', () => _onOperatorPressed('−')),
                    ]),
                    _buildRow([
                      _ButtonSpec.digit('1', () => _onDigitPressed('1')),
                      _ButtonSpec.digit('2', () => _onDigitPressed('2')),
                      _ButtonSpec.digit('3', () => _onDigitPressed('3')),
                      _ButtonSpec.operatorBtn('+', () => _onOperatorPressed('+')),
                    ]),
                    _buildRow([
                      _ButtonSpec.digit('0', () => _onDigitPressed('0'), wide: true),
                      _ButtonSpec.digit('.', _onDecimalPressed),
                      _ButtonSpec.equalsBtn('=', _onEqualsPressed),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<_ButtonSpec> specs) {
    return Expanded(
      child: Row(
        children: specs.map((spec) {
          return Expanded(
            flex: spec.wide ? 2 : 1,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: _CalcButton(key: Key('btn_${spec.label}'), spec: spec),
            ),
          );
        }).toList(),
      ),
    );
  }
}

enum _ButtonType { digit, function, operatorType, equals }

class _ButtonSpec {
  final String label;
  final VoidCallback onPressed;
  final _ButtonType type;
  final bool wide;

  _ButtonSpec._(this.label, this.onPressed, this.type, {this.wide = false});

  factory _ButtonSpec.digit(String label, VoidCallback onPressed, {bool wide = false}) =>
      _ButtonSpec._(label, onPressed, _ButtonType.digit, wide: wide);

  factory _ButtonSpec.function(String label, VoidCallback onPressed) =>
      _ButtonSpec._(label, onPressed, _ButtonType.function);

  factory _ButtonSpec.operatorBtn(String label, VoidCallback onPressed) =>
      _ButtonSpec._(label, onPressed, _ButtonType.operatorType);

  factory _ButtonSpec.equalsBtn(String label, VoidCallback onPressed) =>
      _ButtonSpec._(label, onPressed, _ButtonType.equals);
}

class _CalcButton extends StatelessWidget {
  final _ButtonSpec spec;

  const _CalcButton({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;

    switch (spec.type) {
      case _ButtonType.digit:
        background = Colors.white;
        foreground = Colors.black87;
        break;
      case _ButtonType.function:
        background = Colors.grey[300]!;
        foreground = Colors.black87;
        break;
      case _ButtonType.operatorType:
        background = Colors.blue[600]!;
        foreground = Colors.white;
        break;
      case _ButtonType.equals:
        background = Colors.orange[600]!;
        foreground = Colors.white;
        break;
    }

    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: spec.onPressed,
        child: Center(
          child: Text(
            spec.label,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w500,
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }
}
