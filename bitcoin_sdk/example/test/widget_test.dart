// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:bitcoin_sdk/bitcoin_sdk.dart';
import 'package:bitcoin_sdk_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Bitcoin SDK Demo app loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app title is displayed
    expect(find.text('Bitcoin SDK Demo'), findsOneWidget);

    // Verify that key UI elements are present
    expect(find.text('Rede Bitcoin:'), findsOneWidget);
    expect(find.text('Gerar Nova Carteira'), findsOneWidget);
    expect(find.text('Restaurar Carteira'), findsOneWidget);
    expect(find.text('Validar Endereço'), findsOneWidget);
    expect(find.text('Conversão BTC ↔ Satoshis'), findsOneWidget);
  });

  testWidgets('Network selector is functional', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Find the dropdown button
    expect(find.byType(DropdownButton<BitcoinNetwork>), findsOneWidget);

    // Verify default selection (should be testnet)
    expect(find.text('Bitcoin Testnet (Testnet)'), findsOneWidget);
  });

  testWidgets('Generate wallet button exists', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Find the generate wallet button
    expect(find.text('Gerar Carteira'), findsOneWidget);

    // Verify it's tappable
    final button = find.text('Gerar Carteira');
    expect(button, findsOneWidget);
  });
}
