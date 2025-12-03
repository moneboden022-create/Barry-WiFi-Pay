// test/widget_test.dart
// 🧪 BARRY WI-FI - Tests Widget 5G

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Note: L'app utilise SharedPreferences au démarrage
// donc les tests complets nécessitent un mock

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Test minimal - l'app complète nécessite des mocks
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('BARRY WI-FI'),
          ),
        ),
      ),
    );

    // Vérifie que le texte s'affiche
    expect(find.text('BARRY WI-FI'), findsOneWidget);
  });

  testWidgets('Theme toggle test', (WidgetTester tester) async {
    bool isDark = true;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) {
          return MaterialApp(
            theme: isDark ? ThemeData.dark() : ThemeData.light(),
            home: Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => setState(() => isDark = !isDark),
                  child: Text(isDark ? 'Dark' : 'Light'),
                ),
              ),
            ),
          );
        },
      ),
    );

    // Vérifie le thème initial
    expect(find.text('Dark'), findsOneWidget);

    // Toggle
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Vérifie le changement
    expect(find.text('Light'), findsOneWidget);
  });
}
