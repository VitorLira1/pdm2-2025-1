import 'dart:convert';

class Dependente {
  late String _nome;

  Dependente(String nome) {
    this._nome = nome;
  }

  String get nome => _nome;
}

class Funcionario {
  late String _nome;
  late List<Dependente> _dependentes;

  Funcionario(String nome, List<Dependente> dependentes) {
    this._nome = nome;
    this._dependentes = dependentes;
  }

  String get nome => _nome;

  Map<String,dynamic> toJson() =>
  {
    'nome': _nome,
    'dependentes': _dependentes.map((dep) => dep.nome).toList(),
  };
}

class EquipeProjeto{
  late String _nomeProjeto;
  late List<Funcionario> _funcionarios;

  EquipeProjeto(String nomeprojeto, List<Funcionario> funcionarios) {
    _nomeProjeto = nomeprojeto;
    _funcionarios = funcionarios;
  }

  Map<String, dynamic> toJson() =>
    {
      'nomeProjeto' : _nomeProjeto,
      'funcionarios': Map.fromIterable(
  _funcionarios,
  key: (func) => (func as Funcionario).nome,
  value: (func) => (func as Funcionario).toJson(),
)
    };
  

}

void main() {
  final depNames = ['Vitor', 'Paulo', 'Maria', 'Julia', 'Carla', 'Elijah', 'Kahlil', 'Rayla', 'Ambessa', 'Pedro'];
  final dependentesList = List.generate(10, (index) => Dependente(depNames[index]));
  final funcNames = ['Reynolds', 'Jeff', 'Maia', 'Dumb', 'Kairo'];
  final funcionariosList = List.generate(5, (index) => Funcionario(funcNames[index], dependentesList.sublist(index + index, index + index + 2)));
  final equipe = EquipeProjeto('NaMassa', funcionariosList);
  final encoder = JsonEncoder.withIndent(' ');
  final json = encoder.convert(equipe);
  print(json);
}