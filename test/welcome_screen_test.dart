import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pruebas/welcome_screen.dart';

void main() {
  group('WelcomeScreen Tests', () {
    setUp(() async {
      // Configuración inicial antes de cada prueba
    });

    testWidgets('Verifica el diseño completo en modo vertical', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      // Verifica que el logo esté presente y tenga las dimensiones correctas
      final logoFinder = find.byType(Image);
      expect(logoFinder, findsOneWidget);

      final logoWidget = tester.widget<Image>(logoFinder);
      expect(logoWidget.height, equals(300));
      expect(logoWidget.width, equals(300));

      // Verifica que los botones estén presentes con los textos correctos
      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(find.text('Registrarse'), findsOneWidget);

      // Verifica la estructura de la columna
      final columnFinder = find.byType(Column);
      expect(columnFinder, findsOneWidget);

      final columnWidget = tester.widget<Column>(columnFinder);
      expect(columnWidget.mainAxisAlignment, equals(MainAxisAlignment.start));
      expect(columnWidget.crossAxisAlignment, equals(CrossAxisAlignment.center));
    });

    testWidgets('Verifica los márgenes del logo en modo vertical', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      // Verifica el padding del logo
      final paddingFinder = find.ancestor(
        of: find.byType(Image),
        matching: find.byType(Padding),
      );
      expect(paddingFinder, findsOneWidget);

      final paddingWidget = tester.widget<Padding>(paddingFinder);
      expect((paddingWidget.padding as EdgeInsets).top, equals(0));
    });

    testWidgets('Verifica el diseño y separación de los botones en modo vertical', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      // Verifica la separación entre los botones
      final buttonFinder = find.text('Iniciar sesión');
      final buttonFinder2 = find.text('Registrarse');
      expect(buttonFinder, findsOneWidget);
      expect(buttonFinder2, findsOneWidget);

      final buttonTopPosition = tester.getTopLeft(buttonFinder).dy;
      final button2TopPosition = tester.getTopLeft(buttonFinder2).dy;

      // Verifica que la separación sea de 30 entre los botones
      expect((button2TopPosition - buttonTopPosition).toInt(), equals(120));
    });

    testWidgets('Navegación desde el botón de "Iniciar sesión" en modo vertical', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/',
          routes: {
            '/': (context) => WelcomeScreen(),
            '/login': (context) => Scaffold(body: Text('Login Screen')),
          },
        ),
      );

      final loginButton = find.text('Iniciar sesión');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verifica que la navegación funcione
      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('Navegación desde el botón de "Registrarse" en modo vertical', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/',
          routes: {
            '/': (context) => WelcomeScreen(),
            '/register': (context) => Scaffold(body: Text('Register Screen')),
          },
        ),
      );

      final registerButton = find.text('Registrarse');
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // Verifica que la navegación funcione
      expect(find.text('Register Screen'), findsOneWidget);
    });
  });
}
