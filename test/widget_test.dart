import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Importa o arquivo principal usando um alias (como 'app')
// Isso resolve conflitos de nomes e garante que o test runner encontre o widget.
import 'package:registro_ponto_agro_cana_forte/main.dart' as app; 

void main() {
  testWidgets('Testa se o botão de escanear aparece na tela inicial', (WidgetTester tester) async {
    
    // 1. Constrói nosso app, referenciando a classe com o alias 'app.'
    await tester.pumpWidget(const app.AgroCanaForteApp());

    // O pump() garante que o widget é construído e o primeiro frame é desenhado.

    // 2. Verifica se a mensagem de boas-vindas aparece
    expect(find.text('REGISTRO DE PONTO'), findsOneWidget);
    
    // 3. Verifica se o botão principal de escanear está presente
    expect(find.widgetWithText(ElevatedButton, 'ESCANEAR QR CODE'), findsOneWidget);
  });
}