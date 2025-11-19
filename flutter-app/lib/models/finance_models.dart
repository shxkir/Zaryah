class StockQuote {
  final String symbol;
  final double price;
  final double change;
  final String changePercent;
  final int? volume;
  final double? high;
  final double? low;
  final double? open;
  final double? previousClose;
  final String? exchange;

  StockQuote({
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePercent,
    this.volume,
    this.high,
    this.low,
    this.open,
    this.previousClose,
    this.exchange,
  });

  factory StockQuote.fromJson(Map<String, dynamic> json) {
    return StockQuote(
      symbol: json['symbol'] as String,
      price: (json['price'] as num).toDouble(),
      change: (json['change'] as num).toDouble(),
      changePercent: json['changePercent']?.toString() ?? '0%',
      volume: json['volume'] as int?,
      high: json['high'] != null ? (json['high'] as num).toDouble() : null,
      low: json['low'] != null ? (json['low'] as num).toDouble() : null,
      open: json['open'] != null ? (json['open'] as num).toDouble() : null,
      previousClose: json['previousClose'] != null
          ? (json['previousClose'] as num).toDouble()
          : null,
      exchange: json['exchange'] as String?,
    );
  }

  bool get isPositive => change >= 0;

  String get priceFormatted => '₹${price.toStringAsFixed(2)}';

  String get changeFormatted {
    final sign = change >= 0 ? '+' : '';
    return '$sign₹${change.toStringAsFixed(2)}';
  }

  String get changePercentFormatted {
    if (changePercent.contains('%')) return changePercent;
    final sign = change >= 0 ? '+' : '';
    return '$sign$changePercent%';
  }
}

class CurrencyRate {
  final String from;
  final String to;
  final double rate;
  final String? timestamp;

  CurrencyRate({
    required this.from,
    required this.to,
    required this.rate,
    this.timestamp,
  });

  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    return CurrencyRate(
      from: json['from'] as String,
      to: json['to'] as String,
      rate: (json['rate'] as num).toDouble(),
      timestamp: json['timestamp'] as String?,
    );
  }

  String get pairSymbol => '$from/$to';

  String get rateFormatted => rate.toStringAsFixed(2);

  String get displayText => '1 $from = $rateFormatted $to';
}

class CommodityPrice {
  final String commodity;
  final double price;
  final String currency;
  final String unit;
  final double? change;
  final String? changePercent;

  CommodityPrice({
    required this.commodity,
    required this.price,
    required this.currency,
    required this.unit,
    this.change,
    this.changePercent,
  });

  factory CommodityPrice.fromJson(Map<String, dynamic> json) {
    return CommodityPrice(
      commodity: json['commodity'] ?? 'Unknown',
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      unit: json['unit'] as String? ?? 'per unit',
      change: json['change'] != null ? (json['change'] as num).toDouble() : null,
      changePercent: json['changePercent'] as String?,
    );
  }

  bool get isPositive => (change ?? 0) >= 0;

  String get priceFormatted => '$currency ${price.toStringAsFixed(2)}';

  String get changeFormatted {
    if (change == null) return '';
    final sign = change! >= 0 ? '+' : '';
    return '$sign$currency ${change!.toStringAsFixed(2)}';
  }
}

class WatchlistItem {
  final String id;
  final String userId;
  final String symbol;
  final String assetType; // equity, currency, commodity
  final String? exchange;
  final DateTime createdAt;

  // Current data (populated from API)
  StockQuote? stockData;
  CurrencyRate? currencyData;
  CommodityPrice? commodityData;

  WatchlistItem({
    required this.id,
    required this.userId,
    required this.symbol,
    required this.assetType,
    this.exchange,
    required this.createdAt,
    this.stockData,
    this.currencyData,
    this.commodityData,
  });

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    StockQuote? stock;
    CurrencyRate? currency;
    CommodityPrice? commodity;

    // Parse current data based on asset type
    if (json['currentData'] != null) {
      final assetType = json['assetType'] as String;
      if (assetType == 'equity' && json['currentData']['symbol'] != null) {
        stock = StockQuote.fromJson(json['currentData']);
      } else if (assetType == 'currency' && json['currentData']['rate'] != null) {
        currency = CurrencyRate.fromJson(json['currentData']);
      } else if (assetType == 'commodity' && json['currentData']['price'] != null) {
        commodity = CommodityPrice.fromJson(json['currentData']);
      }
    }

    return WatchlistItem(
      id: json['id'] as String,
      userId: json['userId'] as String,
      symbol: json['symbol'] as String,
      assetType: json['assetType'] as String,
      exchange: json['exchange'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      stockData: stock,
      currencyData: currency,
      commodityData: commodity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'symbol': symbol,
      'assetType': assetType,
      'exchange': exchange,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get displayName => symbol;

  String? get currentPrice {
    if (stockData != null) return stockData!.priceFormatted;
    if (currencyData != null) return currencyData!.rateFormatted;
    if (commodityData != null) return commodityData!.priceFormatted;
    return null;
  }

  String? get currentChange {
    if (stockData != null) return stockData!.changePercentFormatted;
    if (commodityData != null) return commodityData!.changePercent;
    return null;
  }

  bool? get isPositive {
    if (stockData != null) return stockData!.isPositive;
    if (commodityData != null) return commodityData!.isPositive;
    return null;
  }
}

class SearchResult {
  final String symbol;
  final String name;
  final String type;
  final String region;
  final String? currency;

  SearchResult({
    required this.symbol,
    required this.name,
    required this.type,
    required this.region,
    this.currency,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      region: json['region'] as String,
      currency: json['currency'] as String?,
    );
  }
}

class MarketIndex {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final String changePercent;
  final String? exchange;

  MarketIndex({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    this.exchange,
  });

  factory MarketIndex.fromJson(Map<String, dynamic> json) {
    return MarketIndex(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      change: (json['change'] as num).toDouble(),
      changePercent: json['changePercent']?.toString() ?? '0%',
      exchange: json['exchange'] as String?,
    );
  }

  bool get isPositive => change >= 0;

  String get priceFormatted => price.toStringAsFixed(2);

  String get changeFormatted {
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(2)}';
  }

  String get changePercentFormatted {
    if (changePercent.contains('%')) return changePercent;
    final sign = change >= 0 ? '+' : '';
    return '$sign$changePercent%';
  }
}

class MarketOverview {
  final List<MarketIndex> indices;
  final List<CurrencyRate> currencies;
  final List<CommodityPrice> commodities;
  final List<StockQuote> topGainers;
  final List<StockQuote> topLosers;
  final String timestamp;

  MarketOverview({
    required this.indices,
    required this.currencies,
    required this.commodities,
    required this.topGainers,
    required this.topLosers,
    required this.timestamp,
  });

  factory MarketOverview.fromJson(Map<String, dynamic> json) {
    return MarketOverview(
      indices: (json['indices'] as List?)
          ?.map((e) => MarketIndex.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      currencies: (json['currencies'] as List?)
          ?.map((e) => CurrencyRate.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      commodities: (json['commodities'] as List?)
          ?.map((e) => CommodityPrice.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      topGainers: (json['topGainers'] as List?)
          ?.map((e) => StockQuote.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      topLosers: (json['topLosers'] as List?)
          ?.map((e) => StockQuote.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}
