import 'package:flutter/material.dart';

void main() {
  runApp(
    const MyApp(),
  ); // The runApp function takes the given Widget and makes it the root of the widget tree. In this case, we are passing an instance of MyApp, which is a StatelessWidget that we will define next. The const keyword is used to indicate that the MyApp widget is a compile-time constant, which can help with performance by allowing Flutter to optimize the widget tree.
}
// Widgets are the basic building blocks of a Flutter app's user interface. Each widget is an immutable declaration of part of the user interface. Unlike other frameworks that separate views, view controllers, layouts, and other properties, Flutter has a consistent, unified object model: the widget. A widget can define:
// 1. Stateless widgets: These are immutable and do not have any internal state. They are typically used for static content that does not change over time.
// 2. Stateful widgets: These can maintain internal state that may change during the lifetime of the widget.
// 3. Inherited widgets: These are used to propagate information down the widget tree and allow child widgets to access that information.
// 4. Layout widgets: These are used to arrange other widgets on the screen, such as Row, Column, Stack, etc.
// 5. Input widgets: These are used to receive user input, such as TextField, Checkbox, etc.

// Material design is a design system created by Google that provides a set of guidelines and components for building user interfaces. In Flutter, the MaterialApp widget is a convenience widget that wraps a number of widgets that are commonly required for material design applications. It provides features such as navigation, theming, and localization. By using MaterialApp, you can easily create a consistent look and feel for your app that follows the material design principles.
// Cupertino design is a design system created by Apple that provides a set of guidelines and components for building user interfaces. In Flutter, the CupertinoApp widget is a convenience widget that wraps a number of widgets that are commonly required for Cupertino design applications. It provides features such as navigation, theming, and localization. By using CupertinoApp, you can easily create a consistent look and feel for your app that follows the Cupertino design principles.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  }); // This widget is the root of your application.this constructor is used to create an instance of the MyApp class. The super.key is a named parameter that allows you to pass a key to the parent class (StatelessWidget) constructor. A key is an identifier for widgets, elements, and semantic nodes. It is used to preserve the state of widgets when they are moved in the widget tree or when the widget tree is rebuilt. By passing the key to the parent class, you can ensure that the widget's state is preserved correctly during these operations.

  @override
  Widget build(BuildContext context) {    // The build method describes how to display the widget in terms of other, lower-level widgets. The framework calls this method in a number of different situations. For example: a
    return MaterialApp(      // The MaterialApp widget is a convenience widget that wraps a number of widgets that are commonly required for material design applications. It provides features such as navigation, theming, and localization. By using MaterialApp, you can easily create a consistent look and feel for your app that follows the material design principles.
      home: Scaffold(
        body: Center(child: Text('Hello World')),
      ), // The home property of the MaterialApp widget is used to specify the default route of the app, which is displayed when the app is launched. In this case, we are setting it to a Text widget that displays "Hello World". This means that when the app is launched, it will show a screen with the text "Hello World" in the center.

      title: 'Flutter Demo',

      //  home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
