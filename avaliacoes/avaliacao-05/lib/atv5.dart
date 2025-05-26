import 'package:atv5/secrets.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

Future<void> run() async {
  final smtpServer = gmail('vitor.lira06@aluno.ifce.edu.br', senha);

  final message =
      Message()
        ..from = Address('vitor.lira06@aluno.ifce.edu.br', 'Vitor Adriano')
        ..recipients.add('vitorac.lira@gmail.com')
        ..subject = 'Atv5-PDM2'
        ..text = 'Hello, world!';

  try {
    final sendReport = await send(message, smtpServer);
    print('E-mail enviado: ${sendReport.toString()}');
  } on MailerException catch (e) {
    print('Erro ao enviar e-mail: ${e.toString()}');
  }
}
