// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:registro_ponto_agro_cana_forte/main.dart'; // Importa a classe main.dart

void main() {
  testWidgets('Testa se o botão de escanear aparece na tela inicial', (WidgetTester tester) async {
    // Constrói nosso app (Corrigido: usa AgroCanaForteApp)
    await tester.pumpWidget(const AgroCanaForteApp());

    // Verifica se a mensagem de boas-vindas aparece
    expect(find.text('REGISTRO DE PONTO'), findsOneWidget);
    
    // Verifica se o botão principal de escanear está presente
    expect(find.widgetWithText(ElevatedButton, 'ESCANEAR QR CODE'), findsOneWidget);
    
    // O teste de contador (0 e 1) foi removido, pois a tela inicial não possui um contador.
  });
}