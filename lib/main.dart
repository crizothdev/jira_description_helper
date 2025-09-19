import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const JiraHelperApp());
}

class JiraHelperApp extends StatelessWidget {
  const JiraHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jira Text Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const JiraFormPage(),
    );
  }
}

class JiraFormPage extends StatefulWidget {
  const JiraFormPage({super.key});

  @override
  State<JiraFormPage> createState() => _JiraFormPageState();
}

enum Tipo { problema, solucao }

class _JiraFormPageState extends State<JiraFormPage> {
  final _contaUtilizada = TextEditingController();
  final _usuario = TextEditingController();
  final _senha = TextEditingController();
  final _ambienteTeste =
      TextEditingController(text: 'HMG - firebase (prod, loja, ios)');
  final _regrasTeste =
      TextEditingController(text: 'utilizar conta no plano full');
  final _descricao = TextEditingController(); // descrição do problema/solução
  Tipo _tipo = Tipo.solucao;

  String get _saida {
    final tipoStr = _tipo == Tipo.solucao ? 'solução' : 'problema';
    final bloco = _tipo == Tipo.solucao
        ? 'ex de solução: ${_descricao.text.trim()}'
        : 'ex de problema: ${_descricao.text.trim()}';
    final usuario = _usuario.text.trim();
    final senha = _senha.text.trim();
    final conta = _contaUtilizada.text.trim();
    final ambiente = _ambienteTeste.text.trim();
    final regras = _regrasTeste.text.trim();

    return '''
conta utilizada
usuário: ${usuario.isEmpty ? 'xxx.xxx.xxx-xx' : usuario}
senha: ${senha.isEmpty ? 'xxxxxxxx' : senha}

ambiente de teste:
${ambiente.isEmpty ? 'HMG - firebase (prod, loja, ios)' : ambiente}

regras para teste:
${regras.isEmpty ? 'utilizar conta no plano full' : regras}

$tipoStr:
$bloco
''';
  }

  Future<void> _copiar() async {
    await Clipboard.setData(ClipboardData(text: _saida));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Texto copiado!')),
    );
  }

  @override
  void dispose() {
    _contaUtilizada.dispose();
    _usuario.dispose();
    _senha.dispose();
    _ambienteTeste.dispose();
    _regrasTeste.dispose();
    _descricao.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final max = w > 900 ? 900.0 : w * 0.95;

    return Scaffold(
      appBar: AppBar(title: const Text('Gerador de descrição Jira')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: max),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _box(
                    child: DropdownButtonFormField<Tipo>(
                      value: _tipo,
                      decoration: const InputDecoration(labelText: 'Tipo'),
                      items: const [
                        DropdownMenuItem(
                            value: Tipo.problema, child: Text('Problema')),
                        DropdownMenuItem(
                            value: Tipo.solucao, child: Text('Solução')),
                      ],
                      onChanged: (v) =>
                          setState(() => _tipo = v ?? Tipo.solucao),
                    ),
                  ),
                  _box(
                    child: TextField(
                      controller: _contaUtilizada,
                      decoration: const InputDecoration(
                        labelText: 'Conta utilizada (opcional)',
                        hintText: 'Ex: plano full / conta XYZ',
                      ),
                    ),
                  ),
                  _box(
                    child: TextField(
                      controller: _usuario,
                      decoration: const InputDecoration(
                        labelText: 'Usuário (CPF/email)',
                        hintText: 'xxx.xxx.xxx-xx',
                      ),
                    ),
                  ),
                  _box(
                    child: TextField(
                      controller: _senha,
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        hintText: '********',
                      ),
                      obscureText: true,
                    ),
                  ),
                  _box(
                    child: TextField(
                      controller: _ambienteTeste,
                      decoration: const InputDecoration(
                        labelText: 'Ambiente de teste',
                        hintText: 'HMG - firebase (prod, loja, ios)',
                      ),
                    ),
                  ),
                  _box(
                    child: TextField(
                      controller: _regrasTeste,
                      decoration: const InputDecoration(
                        labelText: 'Regras para teste',
                        hintText: 'utilizar conta no plano full',
                      ),
                    ),
                  ),
                  _box(
                    child: TextField(
                      controller: _descricao,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: _tipo == Tipo.solucao
                            ? 'Descrição da solução'
                            : 'Descrição do problema',
                        hintText: _tipo == Tipo.solucao
                            ? 'Ex: corrigido problema no textfield'
                            : 'Ex: textfield não permite usar números',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: _copiar,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copiar'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Atualizar Prévia'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _previewBox(_saida),
            ],
          ),
        ),
      ),
    );
  }

  Widget _box({required Widget child}) => SizedBox(
        width: 420,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: child,
        ),
      );

  Widget _previewBox(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: SelectableText(
        text,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
      ),
    );
  }
}
