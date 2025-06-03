import 'dart:convert';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class Curso {
  int id;
  String descricao;
  List<Professor> professores = [];
  List<Disciplina> disciplinas = [];
  List<Aluno> alunos = [];

  Curso({required this.id, required this.descricao});

  void adicionarProfessor(Professor prof) {
    professores.add(prof);
  }

  void adicionarDisciplina(Disciplina disc) {
    disciplinas.add(disc);
  }

  void adicionarAluno(Aluno al) {
    alunos.add(al);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'curso': descricao,
        'disciplinas': disciplinas.map((disc) => disc.toJson()).toList(),
        'alunos': alunos.map((al) => al.toJson()).toList(),
        'professores': professores.map((prof) => prof.toJson()).toList(),
      };
}

class Professor {
  int id;
  String codigo;
  String nome;
  List<Disciplina> disciplinas = [];

  Professor({required this.id, required this.codigo, required this.nome});

  void adicionarDisciplina(Disciplina disc) {
    disciplinas.add(disc);
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'nome': nome,
      'disciplinasLecionadas':
          disciplinas.map((disc) => disc.descricao).toList(),
    };
  }
}

class Disciplina {
  int id;
  String descricao;
  int qtdAulas;
  Disciplina(
      {required this.id, required this.descricao, required this.qtdAulas});

  Map<String, dynamic> toJson() {
    return {'descrição': descricao};
  }
}

class Aluno {
  int id;
  String nome;
  String matricula;
  Aluno({required this.id, required this.nome, required this.matricula});

  Map<String, dynamic> toJson() {
    return {
      'matricula': matricula,
      'nome': nome,
    };
  }
}

Future<void> run() async {
  final curso = Curso(id: 1, descricao: 'Curso de Informática');
  //
  final disc1 = Disciplina(
      id: 1, descricao: 'Programação de Dispositivos Móveis 2', qtdAulas: 4);
  final disc2 = Disciplina(id: 2, descricao: 'Programação Web 1', qtdAulas: 4);
  final disc3 =
      Disciplina(id: 3, descricao: 'Geometria Analítica', qtdAulas: 2);
  //
  final prof1 = Professor(id: 1, codigo: '9091', nome: 'Ricardo Taveira');
  final prof2 = Professor(id: 2, codigo: '9092', nome: 'José Roberto');
  final prof3 = Professor(id: 3, codigo: '9093', nome: 'Francisco Gêvane');
  //
  final al1 = Aluno(id: 1, nome: 'Vitor Adriano', matricula: '9001');
  final al2 = Aluno(id: 2, nome: 'Rayla Moriati', matricula: '9002');
  final al3 = Aluno(id: 3, nome: 'Elijah Defran', matricula: '9003');
  final al4 = Aluno(id: 4, nome: 'Kahlil Lima', matricula: '9004');
  final al5 = Aluno(id: 5, nome: 'Josiah Arwim', matricula: '9005');
  //
  prof1.adicionarDisciplina(disc1);
  prof2.adicionarDisciplina(disc2);
  prof3.adicionarDisciplina(disc3);
  //
  curso.adicionarDisciplina(disc1);
  curso.adicionarDisciplina(disc2);
  curso.adicionarDisciplina(disc3);
  curso.adicionarProfessor(prof1);
  curso.adicionarProfessor(prof2);
  curso.adicionarProfessor(prof3);
  curso.adicionarAluno(al1);
  curso.adicionarAluno(al2);
  curso.adicionarAluno(al3);
  curso.adicionarAluno(al4);
  curso.adicionarAluno(al5);
  final json = JsonEncoder.withIndent('  ').convert(curso);
  print(json);
  //
  final smtpServer = gmail('vitor.lira06@aluno.ifce.edu.br', '');
  final message = Message()
    ..from = Address('vitor.lira06@aluno.ifce.edu.br', 'Vitor Adriano')
    ..recipients.add('taveira@ifce.edu.br')
    ..subject = 'Prova_Prática_02'
    ..text = curso.toJson().toString();
  try {
    final sendReport = await send(message, smtpServer);
    print('E-mail enviado: ${sendReport.toString()}');
  } on MailerException catch (e) {
    print('Erro ao enviar e-mail: ${e.toString()}');
  }
}
