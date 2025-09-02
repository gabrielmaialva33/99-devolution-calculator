import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devolution_calculator/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const DevolutionCalculatorApp());
    
    expect(find.text('Sendo Devolvido'), findsOneWidget);
    expect(find.text('Aguardando primeiro código...'), findsOneWidget);
    expect(find.text('Escanear com Câmera'), findsOneWidget);
  });
}