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

enum EntryType { bug, solution }

class JiraFormPage extends StatefulWidget {
  const JiraFormPage({super.key});

  @override
  State<JiraFormPage> createState() => _JiraFormPageState();
}

class _JiraFormPageState extends State<JiraFormPage> {
  // Estado do dropdown Tipo e Ambiente
  EntryType _tipo = EntryType.bug;
  String _ambiente = 'TST'; // dropdown: TST, HMG, PROD, DEV

  // Demais campos
  final _cnpj = TextEditingController();
  final _cpf = TextEditingController();
  final _descricao =
      TextEditingController(); // (bug: problema) (solution: alterações)
  final _passos = TextEditingController(); // lista 1 por linha
  final _resultadoAtual = TextEditingController(); // só bug
  final _resultadoEsperado = TextEditingController(); // só bug

  @override
  void dispose() {
    _cnpj.dispose();
    _cpf.dispose();
    _descricao.dispose();
    _passos.dispose();
    _resultadoAtual.dispose();
    _resultadoEsperado.dispose();
    super.dispose();
  }

  // --- Utils ---
  String _t(String s) => s.trim();
  List<String> _lines(String raw) => raw
      .split('\n')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList(growable: false);

  // Campos obrigatórios por tipo
  bool get _isAmbienteRequired => true;
  bool get _isDescricaoRequired => true;
  bool get _isPassosRequired => true;
  bool get _isResultadoAtualRequired => false;
  bool get _isResultadoEsperadoRequired => _tipo == EntryType.bug;

  // Títulos dinâmicos
  String get _tituloDescricao => _tipo == EntryType.bug
      ? 'Descrição do problema'
      : 'Descrição das alterações';
  String get _tituloPassos => 'Passos para reprodução';
  String get _tituloResultadoAtual => 'Resultado atual';
  String get _tituloResultadoEsperado => 'Resultado esperado';

  // Placeholders para prévia/esqueleto
  String _placeholderCampo(String label) => '_(preencher $label)_';

  // Quais obrigatórios faltam?
  List<String> _missingRequired() {
    final missing = <String>[];
    if (_isAmbienteRequired && _ambiente.isEmpty) missing.add('Ambiente');
    if (_isDescricaoRequired && _t(_descricao.text).isEmpty) {
      missing.add(_tipo == EntryType.bug
          ? 'Descrição do problema'
          : 'Descrição das alterações');
    }
    if (_isPassosRequired && _lines(_passos.text).isEmpty) {
      missing.add('Passos para reprodução');
    }
    if (_isResultadoAtualRequired && _t(_resultadoAtual.text).isEmpty) {
      missing.add('Resultado atual');
    }
    if (_isResultadoEsperadoRequired && _t(_resultadoEsperado.text).isEmpty) {
      missing.add('Resultado esperado');
    }
    return missing;
  }

  // Render de Markdown com placeholders para obrigatórios vazios (prévia/esqueleto)
  String _renderMarkdown() {
    final b = StringBuffer();

    // Ambiente (sempre aparece; se vazio, mostra placeholder)
    b.writeln(
        '**Ambiente:** ${_ambiente.isNotEmpty ? _ambiente : _placeholderCampo('Ambiente')}');
    b.writeln();

    // Conta de teste (só aparece se tiver pelo menos um valor)
    final cnpj = _t(_cnpj.text);
    final cpf = _t(_cpf.text);
    if (cnpj.isNotEmpty || cpf.isNotEmpty) {
      b.writeln('**Conta de teste:**\n');
      if (cnpj.isNotEmpty) b.writeln('- **CNPJ:** $cnpj');
      if (cpf.isNotEmpty) b.writeln('- **CPF:** $cpf');
      b.writeln();
    }

    // Descrição (sempre obrigatória para ambos os tipos)
    final desc = _t(_descricao.text);
    b.writeln('**${_tituloDescricao}:**');
    b.writeln(desc.isNotEmpty ? desc : _placeholderCampo(_tituloDescricao));
    b.writeln();

    // Passos (sempre obrigatório para ambos os tipos)
    final passos = _lines(_passos.text);
    b.writeln('**$_tituloPassos:**');
    if (passos.isEmpty) {
      b.writeln('1. ${_placeholderCampo('Passo 1')}');
    } else {
      for (var i = 0; i < passos.length; i++) {
        b.writeln('${i + 1}. ${passos[i]}');
      }
    }
    b.writeln();

    if (_tipo == EntryType.bug) {
      // Resultado atual
      final atual = _t(_resultadoAtual.text);
      b.writeln('**$_tituloResultadoAtual:**');
      b.writeln(atual.isNotEmpty ? atual : '');
      b.writeln();

      // Resultado esperado
      final esperado = _t(_resultadoEsperado.text);
      b.writeln('**$_tituloResultadoEsperado:**');
      b.writeln(esperado.isNotEmpty
          ? esperado
          : _placeholderCampo(_tituloResultadoEsperado));
      b.writeln();
    }

    return b.toString();
  }

  Future<void> _copiar() async {
    final missing = _missingRequired();
    if (missing.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Preencha os obrigatórios: ${missing.join(', ')}')),
        );
      }
      return;
    }
    final text = _renderMarkdown().trimRight();
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Texto copiado (Markdown).')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final max = w > 900 ? 900.0 : w * 0.95;
    final missing = _missingRequired();

    return Scaffold(
      appBar: AppBar(title: const Text('Gerador de descrição Jira')),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: max,
            // constraints: BoxConstraints(maxWidth:max ),
            child: Column(
              // padding: const EdgeInsets.all(16),
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.start,
                  crossAxisAlignment:
                      WrapCrossAlignment.start, // mantém tudo alinhado no topo
                  children: [
                    // Tipo
                    _box(
                      child: DropdownButtonFormField<EntryType>(
                        value: _tipo,
                        decoration: const InputDecoration(labelText: 'Tipo *'),
                        items: const [
                          DropdownMenuItem(
                              value: EntryType.bug, child: Text('Bug')),
                          DropdownMenuItem(
                              value: EntryType.solution,
                              child: Text('Solução')),
                        ],
                        onChanged: (v) =>
                            setState(() => _tipo = v ?? EntryType.bug),
                      ),
                    ),
                    // Ambiente
                    _box(
                      child: DropdownButtonFormField<String>(
                        value: _ambiente,
                        decoration:
                            const InputDecoration(labelText: 'Ambiente *'),
                        items: const [
                          DropdownMenuItem(value: 'TST', child: Text('TST')),
                          DropdownMenuItem(value: 'HMG', child: Text('HMG')),
                          DropdownMenuItem(value: 'PROD', child: Text('PROD')),
                          DropdownMenuItem(value: 'DEV', child: Text('DEV')),
                        ],
                        onChanged: (v) =>
                            setState(() => _ambiente = v ?? 'TST'),
                      ),
                    ),
                    // CNPJ (opcional)
                    _box(
                      child: TextField(
                        controller: _cnpj,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'CNPJ',
                          hintText: 'Ex.: 91.821.122/0001-02',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    // CPF (opcional)
                    _box(
                      child: TextField(
                        controller: _cpf,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'CPF',
                          hintText: 'Ex.: 003.436.790-00',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    // Descrição (obrigatório)
                    _box(
                      child: TextField(
                        controller: _descricao,
                        maxLines: 4,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: '${_tituloDescricao} *',
                          hintText: _tipo == EntryType.bug
                              ? 'Explique o problema observado de forma objetiva.'
                              : 'Descreva as alterações implementadas.',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    // Passos (obrigatório)
                    _box(
                      child: TextField(
                        controller: _passos,
                        maxLines: 6,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Passos para reprodução *',
                          hintText:
                              'Um passo por linha.\nEx.: Criar cobrança recorrente via boleto...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    // Resultado atual e esperado (apenas para Bug)
                    if (_tipo == EntryType.bug)
                      _box(
                        child: TextField(
                          controller: _resultadoAtual,
                          maxLines: 3,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Resultado atual',
                            hintText:
                                'Ex.: Status exibido: “Desabilitado por cartão expirado”.',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    if (_tipo == EntryType.bug)
                      _box(
                        child: TextField(
                          controller: _resultadoEsperado,
                          maxLines: 3,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Resultado esperado *',
                            hintText:
                                'Ex.: Status exibido: “Cancelado” (ou equivalente).',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        FilledButton.icon(
                          onPressed: missing.isEmpty ? _copiar : null,
                          icon: const Icon(Icons.copy),
                          label: const Text('Copiar (Markdown)'),
                        ),
                        const SizedBox(width: 12),
                        if (missing.isNotEmpty)
                          Flexible(
                            child: Text(
                              'Preencha: ${missing.join(', ')}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 840,
                      child: _previewBox(_renderMarkdown()),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
              ],
            ),
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
