String formatFcfa(int montant) {
  final negatif = montant < 0;
  final chiffres = montant.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < chiffres.length; i++) {
    final reste = chiffres.length - i;
    buffer.write(chiffres[i]);
    if (reste > 1 && reste % 3 == 1) buffer.write(' ');
  }
  return '${negatif ? '-' : ''}${buffer.toString()} FCFA';
}

String formatDate(DateTime date) {
  const mois = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];
  return '${date.day.toString().padLeft(2, '0')} ${mois[date.month - 1]} ${date.year}';
}

String formatDateTime(DateTime date) {
  return '${formatDate(date)} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
