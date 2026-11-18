import 'package:flutter_test/flutter_test.dart';
import 'package:g2k_gestion_recouvrement_creances_mobile/models/current_user.dart';
import 'package:g2k_gestion_recouvrement_creances_mobile/models/transaction.dart';

void main() {
  test('CurrentUser lit le payload /auth/me', () {
    final user = CurrentUser.fromApi(<String, dynamic>{
      'id': 'u1',
      'username': 'agent1',
      'prenom': 'Fatima',
      'nom': 'Ba',
      'profil': 'RESPONSABLE',
      'roles': <dynamic>['SNR', 'VALIDATEUR'],
      'permissions': <dynamic>['dash.view', 'report.view'],
      'portefeuilles': <dynamic>['BAS'],
      'mandantId': 'm1',
    });

    expect(user.displayName, 'Fatima Ba');
    expect(user.hasPermission('report.view'), isTrue);
    expect(user.hasPermission('asset.manage'), isFalse);
    expect(user.mandantId, 'm1');
    expect(CurrentUser.fromApi(user.toJson()).roles, contains('VALIDATEUR'));
  });

  test('Reversement normalise statut, mandant et montant net', () {
    final reversement = Reversement.fromApi(<String, dynamic>{
      'key': 'm1|2026-10',
      'mandantId': 'm1',
      'mois': '2026-10',
      'rec': 1500000,
      'com': 150000,
      'net': 1350000,
      'statut': 'Payé',
    });

    expect(reversement.mandant, 'm1');
    expect(reversement.montant, 1350000);
    expect(Reversement.statutFromApi('À préparer').name, contains('aPreparer'));
  });

  test('Transaction retrouve la créance depuis les affectations', () {
    final transaction = Transaction.fromApi(<String, dynamic>{
      'id': 't1',
      'ref': 'TRX-1',
      'montant': 250000,
      'date': '2026-11-10T10:00:00Z',
      'affectations': <dynamic>[
        <String, dynamic>{'creanceId': 'c1', 'montant': 250000},
      ],
    });

    expect(transaction.creanceId, 'c1');
    expect(transaction.montant, 250000);
  });
}
