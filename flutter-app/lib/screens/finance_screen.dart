import 'package:flutter/material.dart';
import '../models/finance_models.dart';
import '../services/finance_service.dart';
import '../theme/luxury_theme.dart';
import '../widgets/luxury_components.dart';
import '../widgets/animated_loading.dart';
import '../widgets/animated_card.dart';
import '../utils/smooth_page_route.dart';
import 'stock_detail_screen.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  MarketOverview? _marketOverview;
  List<WatchlistItem> _watchlist = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Get dashboard data and watchlist
      final dashboardData = await FinanceService.getFinanceDashboard();
      final watchlist = await FinanceService.getWatchlist();

      // Convert dashboard data to MarketOverview
      MarketOverview? overview;
      if (dashboardData != null) {
        print('📊 Dashboard data loaded: ${dashboardData.keys}');

        // Parse indices
        final indices = (dashboardData['indices'] as List?)
            ?.map((e) => MarketIndex.fromJson(e as Map<String, dynamic>))
            .toList() ?? [];

        // Parse currencies
        final currencies = (dashboardData['currencies'] as List?)
            ?.map((e) => CurrencyRate.fromJson(e as Map<String, dynamic>))
            .toList() ?? [];

        // Parse commodities
        final commodities = (dashboardData['commodities'] as List?)
            ?.map((e) => CommodityPrice.fromJson(e as Map<String, dynamic>))
            .toList() ?? [];

        // Parse popular stocks (use them as topGainers for now)
        final popularStocks = (dashboardData['popularStocks'] as List?)
            ?.map((e) => StockQuote.fromJson(e as Map<String, dynamic>))
            .toList() ?? [];

        overview = MarketOverview(
          indices: indices,
          currencies: currencies,
          commodities: commodities,
          topGainers: popularStocks, // Use popular stocks as gainers
          topLosers: [], // Empty for now
          timestamp: dashboardData['timestamp'] as String? ?? DateTime.now().toIso8601String(),
        );

        print('✅ Market overview created with ${indices.length} indices, ${popularStocks.length} stocks');
      }

      setState(() {
        _marketOverview = overview;
        _watchlist = watchlist;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Finance screen error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load market data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markets', style: TextStyle(color: LuxuryColors.bodyText)),
        backgroundColor: LuxuryColors.mainBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: LuxuryColors.primaryGold),
            onPressed: _isLoading ? null : _loadData,
            tooltip: 'Refresh market data',
          ),
        ],
      ),
      body: Column(
        children: [
          // Error message
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.red.withOpacity(0.2),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          // Market Indices Section
          if (_marketOverview != null && _marketOverview!.indices.isNotEmpty)
            _buildMarketIndicesSection(),

          // Watchlist Section
          if (_watchlist.isNotEmpty) _buildWatchlistSection(),

          // Tabs
          Container(
            color: LuxuryColors.cardBackground,
            child: TabBar(
              controller: _tabController,
              indicatorColor: LuxuryColors.primaryGold,
              labelColor: LuxuryColors.primaryGold,
              unselectedLabelColor: LuxuryColors.mutedText,
              tabs: const [
                Tab(text: 'Stocks'),
                Tab(text: 'Currency'),
                Tab(text: 'Commodities'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStocksTab(),
                _buildCurrencyTab(),
                _buildCommoditiesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketIndicesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LuxuryColors.secondaryBackground,
            LuxuryColors.mainBackground,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.show_chart, color: LuxuryColors.primaryGold, size: 20),
              SizedBox(width: 8),
              Text(
                'Market Indices',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: LuxuryColors.bodyText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: _marketOverview!.indices.take(3).toList().asMap().entries.map((entry) {
              return Expanded(
                child: AnimatedListItem(
                  index: entry.key,
                  delay: const Duration(milliseconds: 100),
                  child: _buildIndexCard(entry.value),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIndexCard(MarketIndex index) {
    final isPositive = index.isPositive;
    return GestureDetector(
      onTap: () => _showStockDetails(index.symbol, name: index.name),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LuxuryColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPositive
                ? Colors.green.withOpacity(0.3)
                : Colors.red.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            index.name,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: LuxuryColors.mutedText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            index.priceFormatted,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: LuxuryColors.primaryGold,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositive ? Colors.green : Colors.red,
                size: 12,
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  index.changePercentFormatted,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildWatchlistSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: LuxuryColors.secondaryBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star, color: LuxuryColors.primaryGold, size: 20),
              SizedBox(width: 8),
              Text(
                'Watchlist',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: LuxuryColors.bodyText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _watchlist.length,
              itemBuilder: (context, index) {
                final item = _watchlist[index];
                return _buildWatchlistCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistCard(WatchlistItem item) {
    final isPositive = item.isPositive ?? true;
    return GestureDetector(
      onTap: () => _showStockDetails(item.symbol),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LuxuryColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: LuxuryColors.primaryGold.withOpacity(0.3)),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.symbol,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: LuxuryColors.bodyText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (item.currentPrice != null)
            Text(
              item.currentPrice!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: LuxuryColors.primaryGold,
              ),
            ),
          if (item.currentChange != null)
            Text(
              item.currentChange!,
              style: TextStyle(
                color: isPositive ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
        ],
        ),
      ),
    );
  }

  Widget _buildStocksTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: LuxuryColors.primaryGold,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Top Gainers Section
          if (_marketOverview != null && _marketOverview!.topGainers.isNotEmpty) ...[
            const Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text(
                  'Top Gainers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: LuxuryColors.bodyText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._marketOverview!.topGainers.take(3).toList().asMap().entries.map((entry) =>
              AnimatedListItem(
                index: entry.key,
                child: _buildStockCard(entry.value),
              )
            ),
            const SizedBox(height: 24),
          ],

          // Top Losers Section
          if (_marketOverview != null && _marketOverview!.topLosers.isNotEmpty) ...[
            const Row(
              children: [
                Icon(Icons.trending_down, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text(
                  'Top Losers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: LuxuryColors.bodyText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._marketOverview!.topLosers.take(3).map((stock) => _buildStockCard(stock)),
            const SizedBox(height: 24),
          ],

          // Loading or Error State
          if (_isLoading) ...[
            const CardSkeleton(),
            const CardSkeleton(),
            const CardSkeleton(),
          ] else if (_marketOverview == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Unable to load market data. Pull to refresh.',
                  style: TextStyle(color: LuxuryColors.mutedText),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // Popular Stocks Section
          const Text(
            'Popular Stocks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: LuxuryColors.bodyText,
            ),
          ),
          const SizedBox(height: 12),
          ...FinanceService.getPopularStocks().asMap().entries.map((entry) {
            final stock = entry.value;
            final index = entry.key;
            return AnimatedListItem(
              index: index,
              child: AnimatedCard(
                margin: const EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.zero,
                onTap: () => _showStockDetails(stock['symbol']!, name: stock['name']),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: LuxuryColors.primaryGold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.trending_up, color: LuxuryColors.primaryGold, size: 20),
                  ),
                  title: Text(
                    stock['name']!,
                    style: const TextStyle(
                      color: LuxuryColors.bodyText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    stock['symbol']!,
                    style: const TextStyle(color: LuxuryColors.mutedText, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: LuxuryColors.mutedText),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStockCard(StockQuote stock) {
    return AnimatedCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _showStockDetails(stock.symbol),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stock.symbol,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: LuxuryColors.bodyText,
                  ),
                ),
                if (stock.exchange != null)
                  Text(
                    stock.exchange!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: LuxuryColors.mutedText,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                stock.priceFormatted,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: LuxuryColors.primaryGold,
                ),
              ),
              Text(
                stock.changePercentFormatted,
                style: TextStyle(
                  color: stock.isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: LuxuryColors.primaryGold,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Currency Exchange Rates',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: LuxuryColors.bodyText,
            ),
          ),
          const SizedBox(height: 16),

          // Show currencies from market overview if available
          if (_marketOverview != null && _marketOverview!.currencies.isNotEmpty) ...[
            ..._marketOverview!.currencies.map((currency) => _buildCurrencyCardFromData(currency)),
            const SizedBox(height: 16),
          ] else if (_isLoading)
            const Center(child: CircularProgressIndicator(color: LuxuryColors.primaryGold))
          else ...[
            // Fallback to loading individual currency pairs
            ...FinanceService.getPopularCurrencyPairs().map((pair) {
              return _buildCurrencyCard(pair['from']!, pair['to']!, pair['name']!);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrencyCardFromData(CurrencyRate currency) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LuxuryColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LuxuryColors.primaryGold.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: LuxuryColors.primaryGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.currency_exchange, color: LuxuryColors.primaryGold),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${currency.from} → ${currency.to}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: LuxuryColors.bodyText,
                  ),
                ),
                Text(
                  currency.displayText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: LuxuryColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            currency.rateFormatted,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: LuxuryColors.primaryGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyCard(String from, String to, String name) {
    return FutureBuilder<CurrencyRate>(
      future: FinanceService.getCurrencyRate(from, to),
      builder: (context, snapshot) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: LuxuryColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: LuxuryColors.primaryGold.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: LuxuryColors.primaryGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.currency_exchange, color: LuxuryColors.primaryGold),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$from → $to',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: LuxuryColors.bodyText,
                      ),
                    ),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 12,
                        color: LuxuryColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              if (snapshot.hasData)
                Text(
                  snapshot.data!.rateFormatted,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: LuxuryColors.primaryGold,
                  ),
                )
              else if (snapshot.hasError)
                const Icon(Icons.error, color: Colors.red)
              else
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: LuxuryColors.primaryGold),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommoditiesTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: LuxuryColors.primaryGold,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Commodity Prices',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: LuxuryColors.bodyText,
            ),
          ),
          const SizedBox(height: 16),

          // Show commodities from market overview if available
          if (_marketOverview != null && _marketOverview!.commodities.isNotEmpty) ...[
            ..._marketOverview!.commodities.map((commodity) => _buildCommodityCardFromData(commodity)),
          ] else if (_isLoading)
            const Center(child: CircularProgressIndicator(color: LuxuryColors.primaryGold))
          else ...[
            // Fallback to loading individual commodities
            ...FinanceService.getPopularCommodities().map((commodity) => _buildCommodityCard(commodity)),
          ],
        ],
      ),
    );
  }

  Widget _buildCommodityCardFromData(CommodityPrice commodity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LuxuryColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LuxuryColors.primaryGold.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: LuxuryColors.primaryGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              commodity.commodity == 'GOLD' ? Icons.diamond :
              commodity.commodity == 'SILVER' ? Icons.ac_unit :
              Icons.local_gas_station,
              color: LuxuryColors.primaryGold,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commodity.commodity.replaceAll('_', ' '),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: LuxuryColors.bodyText,
                  ),
                ),
                Text(
                  commodity.unit,
                  style: const TextStyle(
                    fontSize: 12,
                    color: LuxuryColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                commodity.priceFormatted,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: LuxuryColors.primaryGold,
                ),
              ),
              if (commodity.changeFormatted.isNotEmpty)
                Text(
                  commodity.changeFormatted,
                  style: TextStyle(
                    color: commodity.isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommodityCard(String commodity) {
    return FutureBuilder<CommodityPrice>(
      future: FinanceService.getCommodityPrice(commodity),
      builder: (context, snapshot) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: LuxuryColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: LuxuryColors.primaryGold.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: LuxuryColors.primaryGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  commodity == 'GOLD' ? Icons.diamond :
                  commodity == 'SILVER' ? Icons.ac_unit :
                  Icons.local_gas_station,
                  color: LuxuryColors.primaryGold,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      commodity.replaceAll('_', ' '),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: LuxuryColors.bodyText,
                      ),
                    ),
                    if (snapshot.hasData)
                      Text(
                        snapshot.data!.unit,
                        style: const TextStyle(
                          fontSize: 12,
                          color: LuxuryColors.mutedText,
                        ),
                      ),
                  ],
                ),
              ),
              if (snapshot.hasData)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      snapshot.data!.priceFormatted,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: LuxuryColors.primaryGold,
                      ),
                    ),
                    if (snapshot.data!.changeFormatted.isNotEmpty)
                      Text(
                        snapshot.data!.changeFormatted,
                        style: TextStyle(
                          color: snapshot.data!.isPositive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                )
              else if (snapshot.hasError)
                const Icon(Icons.error, color: Colors.red)
              else
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: LuxuryColors.primaryGold),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showStockDetails(String symbol, {String? name}) async {
    // Navigate to stock detail screen with smooth transition
    await context.smoothPush(
      StockDetailScreen(
        symbol: symbol,
        name: name,
      ),
    );
  }
}
