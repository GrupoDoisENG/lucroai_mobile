enum MetodoRateio {
  fixo('FIXO'),
  porUnidade('POR_UNIDADE'),
  proporcional('PROPORCIONAL');

  const MetodoRateio(this.value);
  final String value;

  String get label => switch (this) {
        MetodoRateio.fixo => 'Valor fixo por producao',
        MetodoRateio.porUnidade => 'Proporcional ao total de unidades',
        MetodoRateio.proporcional => 'Proporcional a qtd. de lotes',
      };

  static MetodoRateio fromValue(String value) => MetodoRateio.values.firstWhere(
        (m) => m.value == value,
        orElse: () => MetodoRateio.fixo,
      );
}

class GastoIndireto {
  final int id;
  final int empresaId;
  final String descricao;
  final double valor;
  final MetodoRateio metodoRateio;

  const GastoIndireto({
    required this.id,
    required this.empresaId,
    required this.descricao,
    required this.valor,
    required this.metodoRateio,
  });
}
