class StockQuote {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double changePercent;
  final double? open;
  final double? high;
  final double? low;
  final double? previousClose;
  final int? volume;
  final double? marketCap;
  final double? week52High;
  final double? week52Low;
  final String exchange;

  StockQuote({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    this.open,
    this.high,
    this.low,
    this.previousClose,
    this.volume,
    this.marketCap,
    this.week52High,
    this.week52Low,
    required this.exchange,
  });

  factory StockQuote.fromJson(Map<String, dynamic> json) {
    return StockQuote(
      symbol: json['symbol'] as String,
      name: json['name'] as String? ?? json['symbol'] as String,
      price: (json['price'] as num).toDouble(),
      change: (json['change'] as num).toDouble(),
      changePercent: (json['changePercent'] as num).toDouble(),
      open: json['open'] != null ? (json['open'] as num).toDouble() : null,
      high: json['high'] != null ? (json['high'] as num).toDouble() : null,
      low: json['low'] != null ? (json['low'] as num).toDouble() : null,
      previousClose: json['previousClose'] != null
          ? (json['previousClose'] as num).toDouble()
          : null,
      volume: json['volume'] as int?,
      marketCap: json['marketCap'] != null
          ? (json['marketCap'] as num).toDouble()
          : null,
      week52High: json['week52High'] != null
          ? (json['week52High'] as num).toDouble()
          : null,
      week52Low: json['week52Low'] != null
          ? (json['week52Low'] as num).toDouble()
          : null,
      exchange: json['exchange'] as String? ?? 'NSE',
    );
  }

  bool get isPositive => change >= 0;

  String get priceFormatted => '₹${price.toStringAsFixed(2)}';

  String get changeFormatted {
    final sign = change >= 0 ? '+' : '';
    return '$sign₹${change.toStringAsFixed(2)}';
  }

  String get changePercentFormatted {
    final sign = changePercent >= 0 ? '+' : '';
    return '$sign${changePercent.toStringAsFixed(2)}%';
  }

  String get volumeFormatted {
    if (volume == null) return 'N/A';
    if (volume! >= 10000000) {
      return '${(volume! / 10000000).toStringAsFixed(2)}Cr';
    } else if (volume! >= 100000) {
      return '${(volume! / 100000).toStringAsFixed(2)}L';
    } else if (volume! >= 1000) {
      return '${(volume! / 1000).toStringAsFixed(2)}K';
    }
    return volume.toString();
  }

  String get marketCapFormatted {
    if (marketCap == null) return 'N/A';
    if (marketCap! >= 10000000000000) {
      return '₹${(marketCap! / 10000000000000).toStringAsFixed(2)}T';
    } else if (marketCap! >= 10000000000) {
      return '₹${(marketCap! / 10000000000).toStringAsFixed(2)}B';
    } else if (marketCap! >= 10000000) {
      return '₹${(marketCap! / 10000000).toStringAsFixed(2)}Cr';
    }
    return '₹${marketCap!.toStringAsFixed(0)}';
  }
}

class CurrencyRate {
  final String from;
  final String to;
  final double rate;
  final DateTime timestamp;

  CurrencyRate({
    required this.from,
    required this.to,
    required this.rate,
    required this.timestamp,
  });

  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    return CurrencyRate(
      from: json['from'] as String,
      to: json['to'] as String,
      rate: (json['rate'] as num).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  String get rateFormatted => '₹${rate.toStringAsFixed(2)}';

  String get pair => '$from/$to';
}

class CommodityPrice {
  final String name;
  final double price;
  final String currency;
  final String unit;
  final double? change;
  final double? changePercent;

  CommodityPrice({
    required this.name,
    required this.price,
    required this.currency,
    required this.unit,
    this.change,
    this.changePercent,
  });

  factory CommodityPrice.fromJson(Map<String, dynamic> json) {
    return CommodityPrice(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      unit: json['unit'] as String? ?? 'per unit',
      change: json['change'] != null ? (json['change'] as num).toDouble() : null,
      changePercent: json['changePercent'] != null
          ? (json['changePercent'] as num).toDouble()
          : null,
    );
  }

  String get priceFormatted => '₹${price.toStringAsFixed(2)} $unit';

  bool get isPositive => (change ?? 0) >= 0;

  String get changeFormatted {
    if (change == null) return 'N/A';
    final sign = change! >= 0 ? '+' : '';
    return '$sign₹${change!.toStringAsFixed(2)}';
  }

  String get changePercentFormatted {
    if (changePercent == null) return '';
    final sign = changePercent! >= 0 ? '+' : '';
    return '$sign${changePercent!.toStringAsFixed(2)}%';
  }
}
