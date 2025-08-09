class Currency {
  final String code;
  final String name;

  const Currency({required this.code, required this.name});
}

const List<Currency> supportedCurrencies = [
  Currency(code: 'USD', name: 'US Dollar'),
  Currency(code: 'INR', name: 'Indian Rupee'),
  Currency(code: 'EUR', name: 'Euro'),
  Currency(code: 'AED', name: 'UAE Dirham'),
];


