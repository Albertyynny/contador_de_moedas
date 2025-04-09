import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ContadorMoedasApp());
}

class ContadorMoedasApp extends StatefulWidget {
  const ContadorMoedasApp({super.key});

  @override
  State<ContadorMoedasApp> createState() => _ContadorMoedasAppState();
}

class _ContadorMoedasAppState extends State<ContadorMoedasApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _carregarTema();
  }

  Future<void> _carregarTema() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode =
          ThemeMode.values[prefs.getInt('themeMode') ?? ThemeMode.system.index];
    });
  }

  Future<void> _salvarTema() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', _themeMode.index);
  }

  void alterarTema(ThemeMode modo) {
    setState(() {
      _themeMode = modo;
      _salvarTema();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contador simples de Moedas',
      theme: ThemeData.light().copyWith(
        primaryColor: const Color.fromARGB(255, 0, 0, 139),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
          bodyMedium: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
          titleLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.green,
            fontFamily: 'Roboto',
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey[900],
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
          bodyMedium: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
          titleLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.green,
            fontFamily: 'Roboto',
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.blueGrey[800],
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      themeMode: _themeMode,
      home: ContadorMoedas(alterarTema: alterarTema, temaAtual: _themeMode),
    );
  }
}

class ContadorMoedas extends StatefulWidget {
  final Function(ThemeMode) alterarTema;
  final ThemeMode temaAtual;

  const ContadorMoedas(
      {super.key, required this.alterarTema, required this.temaAtual});

  @override
  ContadorMoedasState createState() => ContadorMoedasState();
}

class ContadorMoedasState extends State<ContadorMoedas> {
  double total = 0.0;
  Map<String, int> quantidades = {
    '0,05': 0,
    '0,10': 0,
    '0,25': 0,
    '0,50': 0,
    '1,00': 0,
    '2,00': 0,
    '5,00': 0,
    '10,00': 0,
    '20,00': 0,
    '50,00': 0,
    '100,00': 0,
    '200,00': 0,
  };

  final Map<String, TextEditingController> _controllers = {};

  final Map<String, double> valoresMoedas = {
    '0,05': 0.05,
    '0,10': 0.10,
    '0,25': 0.25,
    '0,50': 0.50,
    '1,00': 1.00,
    '2,00': 2.00,
    '5,00': 5.00,
    '10,00': 10.00,
    '20,00': 20.00,
    '50,00': 50.00,
    '100,00': 100.00,
    '200,00': 200.00,
  };

  final Map<String, String> imagensMoedas = {
    '0,05': 'assets/images/05centavos.png',
    '0,10': 'assets/images/10centavos.png',
    '0,25': 'assets/images/25centavos.png',
    '0,50': 'assets/images/50centavos.png',
    '1,00': 'assets/images/1real.png',
    '2,00': 'assets/images/2reais.png',
    '5,00': 'assets/images/5reais.png',
    '10,00': 'assets/images/10reais.png',
    '20,00': 'assets/images/20reais.png',
    '50,00': 'assets/images/50reais.png',
    '100,00': 'assets/images/100reais.png',
    '200,00': 'assets/images/200reais.png',
  };

  @override
  void initState() {
    super.initState();
    for (var moeda in quantidades.keys) {
      _controllers[moeda] = TextEditingController(text: '0');
    }
    _carregarDados();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      total = prefs.getDouble('total') ?? 0.0;
      for (var moeda in quantidades.keys) {
        quantidades[moeda] = prefs.getInt(moeda) ?? 0;
        _controllers[moeda]!.text = quantidades[moeda].toString();
      }
    });
  }

  Future<void> _salvarDados() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('total', total);
    for (var moeda in quantidades.keys) {
      await prefs.setInt(moeda, quantidades[moeda]!);
    }
  }

  void _atualizarTotal() {
    setState(() {
      total = quantidades.entries.fold(0.0, (sum, entry) {
        return sum + (valoresMoedas[entry.key]! * entry.value);
      });
      _salvarDados();
    });
  }

  void _incrementarQuantidade(String moeda) {
    setState(() {
      quantidades[moeda] = quantidades[moeda]! + 1;
      _controllers[moeda]!.text = quantidades[moeda].toString();
      _atualizarTotal();
    });
  }

  void _decrementarQuantidade(String moeda) {
    setState(() {
      if (quantidades[moeda]! > 0) {
        quantidades[moeda] = quantidades[moeda]! - 1;
        _controllers[moeda]!.text = quantidades[moeda].toString();
        _atualizarTotal();
      }
    });
  }

  void _editarQuantidade(String moeda, String novoValor) {
    int valor = int.tryParse(novoValor) ?? 0;
    if (valor >= 0) {
      setState(() {
        quantidades[moeda] = valor;
        _atualizarTotal();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Albertiny Technology',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 10,
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              if (Theme.of(context).brightness == Brightness.dark) {
                widget.alterarTema(ThemeMode.light);
              } else {
                widget.alterarTema(ThemeMode.dark);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(
              'Total: R\$ ${total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      'Moedas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildCategoria(
                      valoresMoedas.keys.where(
                        (moeda) => valoresMoedas[moeda]! <= 1.00,
                      ),
                      imageSize: 40, 
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Notas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildCategoria(
                      valoresMoedas.keys.where(
                        (moeda) => valoresMoedas[moeda]! > 1.00,
                      ),
                      imageSize: 100,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoria(Iterable<String> moedas, {double imageSize = 50}) {
    return Column(
      children: moedas.map((moeda) {
        return Card(
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  imagensMoedas[moeda]!,
                  height: imageSize,
                  width: imageSize,
                ),
                Text(
                  moeda,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontFamily: 'Roboto',
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.red),
                      onPressed: () => _decrementarQuantidade(moeda),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withAlpha(25),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _controllers[moeda],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontFamily: 'Roboto',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _editarQuantidade(moeda, value),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.green),
                      onPressed: () => _incrementarQuantidade(moeda),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green.withAlpha(25),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}