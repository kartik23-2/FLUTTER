import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


//now this is all for UI and it just left the variables to work to store the values and the logic to convert the currencies. We will work on that in the next step. For now, we have created a basic UI for our currency converter app using Flutter's Material design components. The UI consists of a Scaffold with an AppBar, a Text widget to display the converted amount, a TextField for user input, and a TextButton to trigger the conversion. We have also added some styling to make the UI visually appealing.

class CurrencyConverterMaterialPage extends StatefulWidget {
  const CurrencyConverterMaterialPage({super.key});
  @override
  State<CurrencyConverterMaterialPage> createState() => _CurrencyConverterMaterialPageState();
}
class _CurrencyConverterMaterialPageState extends State<CurrencyConverterMaterialPage> {
  double result = 0;
  TextEditingController textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(title: Text('Currency Converter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              result != 0 ? result.toStringAsFixed(2) : '0',
              style: TextStyle(
                fontSize: 30,
                color: Color.fromARGB(255, 233, 13, 13),
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'INR',
              style: TextStyle(
                fontSize: 30,
                color: Color.fromARGB(255, 233, 13, 13),
                fontWeight: FontWeight.w800,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: textEditingController,
                style: TextStyle(
                  color: Color.fromARGB(255, 59, 120, 252),
                  fontWeight: FontWeight.w800,
                ),

                decoration: InputDecoration(
                  hintText: 'Enter amount in USD',

                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 233, 13, 13),
                    fontWeight: FontWeight.w800,
                  ),
                  iconColor: Color.fromARGB(255, 233, 13, 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 255, 244, 45),
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  label: Text(
                    'converterrrrrr....',
                    style: TextStyle(
                      color: Color.fromARGB(255, 233, 13, 13),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  floatingLabelStyle: TextStyle(color: Colors.blue),
                  hoverColor: Colors.yellow,
                  prefixIcon: Icon(
                    Icons.attach_money,
                    color: Color.fromARGB(255, 233, 13, 13),
                  ),
                  filled: true,
                  fillColor: Color.fromARGB(255, 86, 194, 56),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextButton(
                onPressed: () {
                  if (kDebugMode) {
                    print("KARTIK clicked the button");
                  }
                  String input = (double.parse(textEditingController.text) * 81.0).toString();
                  setState(() {
                    result = double.tryParse(input) ?? 0;
                  });
                  // Get the input value from the text field
                  
                  print ("Input value: $input");
                  
                  print ("Parsed result: $result INR");
                },
                onHover: (isHovering){
                  if (kDebugMode) {
                    print(isHovering ? "Hovering over the button" : "Not hovering over the button");
              
                  }
                },
                style: TextButton.styleFrom( 
                  backgroundColor: Color.fromARGB(255, 90, 96, 112),
                  foregroundColor:Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: 
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Color.fromARGB(255, 255, 244, 45), width: 2.0),
                    ),
                  
                  minimumSize: Size(double.infinity , 50),
                ),
                child: const Text("CONVERT",
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.w800,
                  ),
                  
                ),
                
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  
}
