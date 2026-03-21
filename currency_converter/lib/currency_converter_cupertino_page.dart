import 'package:flutter/cupertino.dart';

class CurrencyConverterCupertinoPage extends StatefulWidget {
  const CurrencyConverterCupertinoPage({super.key});

  @override
  State<CurrencyConverterCupertinoPage> createState() =>
      _CurrencyConverterCupertinoPageState();
}

class _CurrencyConverterCupertinoPageState
    extends State<CurrencyConverterCupertinoPage> {
  static const double _usdToInrRate = 81.0;
  double result = 0;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void _convertCurrency() {
    final double usd = double.tryParse(textEditingController.text) ?? 0;
    setState(() {
      result = usd * _usdToInrRate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Currency Converter'),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                result != 0 ? result.toStringAsFixed(2) : '0',
                style: const TextStyle(
                  fontSize: 30,
                  color: Color.fromARGB(255, 233, 13, 13),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                'INR',
                style: TextStyle(
                  fontSize: 30,
                  color: Color.fromARGB(255, 233, 13, 13),
                  fontWeight: FontWeight.w800,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CupertinoTextField(
                  controller: textEditingController,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 59, 120, 252),
                    fontWeight: FontWeight.w800,
                  ),
                  placeholder: 'Enter amount in USD',
                  placeholderStyle: const TextStyle(
                    color: Color.fromARGB(255, 233, 13, 13),
                    fontWeight: FontWeight.w700,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(
                      CupertinoIcons.money_dollar,
                      color: Color.fromARGB(255, 233, 13, 13),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 86, 194, 56),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color.fromARGB(255, 255, 244, 45),
                      width: 2,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    onPressed: _convertCurrency,
                    color: const Color.fromARGB(255, 90, 96, 112),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    child: const Text(
                      'CONVERT',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
