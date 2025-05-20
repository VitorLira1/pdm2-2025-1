import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

void main() {
  final db = sqlite3.open('alunos.db');

  // Create table TB_ALUNO
  db.execute('''
    CREATE TABLE IF NOT EXISTS TB_ALUNO (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL CHECK(length(nome) <= 50)
    );
  ''');

  print('Bem-vindo ao gerenciador de alunos!');
  while (true) {
    print('\nEscolha uma opção:');
    print('1 - Inserir novo aluno');
    print('2 - Listar alunos');
    print('0 - Sair');

    stdout.write('Opção: ');
    String? input = stdin.readLineSync();
    if (input == null) continue;

    switch (input) {
      case '1':
        inserirAluno(db);
        break;
      case '2':
        listarAlunos(db);
        break;
      case '0':
        print('Saindo...');
        db.dispose();
        exit(0);
      default:
        print('Opção inválida, tente novamente.');
    }
  }
}

void inserirAluno(Database db) {
  stdout.write('Digite o nome do aluno (max 50 caracteres): ');
  String? nome = stdin.readLineSync();

  if (nome == null || nome.trim().isEmpty) {
    print('Nome inválido.');
    return;
  }

  nome = nome.trim();
  if (nome.length > 50) {
    print('Nome muito longo. Deve ter no máximo 50 caracteres.');
    return;
  }

  try {
    final stmt = db.prepare('INSERT INTO TB_ALUNO (nome) VALUES (?)');
    stmt.execute([nome]);
    stmt.dispose();
    print('Aluno "$nome" inserido com sucesso.');
  } catch (e) {
    print('Erro ao inserir aluno: $e');
  }
}

void listarAlunos(Database db) {
  final ResultSet result = db.select('SELECT id, nome FROM TB_ALUNO ORDER BY id');
  if (result.isEmpty) {
    print('Nenhum aluno cadastrado.');
  } else {
    print('\nLista de alunos:');
    for (final row in result) {
      print('ID: ${row['id']} - Nome: ${row['nome']}');
    }
  }
}

