import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:binance/binance.dart';
import 'package:binania/utils/constants/BinanceConstants.dart';
import 'package:binania/utils/enums/BinanceEnums.dart';
import 'package:binania/utils/utils.dart';

class BinanceService{

  final Binance _binance = Binance();
  String _apiKey;
  String _secretKey;
  HashMap<String, BinanceSymbol> exchangeInfoMap;
  DateTime _exchangeInfoServerTime;

  /// Initialize this service
  Future<void> init(String apiKey, String secretKey){
    _apiKey = apiKey;
    _secretKey = secretKey;
    return _loadExchangeInfo();
  }


  /// Gets a trade stream of [symbol]
  Stream<WsAggregatedTrade> getTradeStream(String symbol){
    return _binance.aggTrade(symbol);
  }

  /// Gets the account info of the keys
  Future<Map<String, dynamic>> getAccountInfo() async{
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String params = 'timestamp=' + timestamp;
    String signature = await getSignature(params);
    String command = 'curl -H \"X-MBX-APIKEY: ' + _apiKey + '\" -X GET \"https://api.binance.com/api/v3/account?' + params + '&signature=' + signature + '\"';
    var res = await Utils.runCommand(command);
    return json.decode(res.first.stdout);
  }

  /// Creates a market order
  /// 
  /// It returns null if there is an error in the order creation
  /// 
  /// MARKET orders using the quantity field specifies the amount of the base asset the user wants to buy or sell at the market price.
  /// E.g. MARKET order on BTCUSDT will specify how much BTC the user is buying or selling. 
  /// 
  /// MARKET orders using quoteOrderQty specifies the amount the user wants to spend (when buying) or receive (when selling) the quote asset; the correct quantity will be determined based on the market liquidity and quoteOrderQty.
  /// E.g. Using the symbol BTCUSDT:
  /// BUY side, the order will buy as many BTC as quoteOrderQty USDT can.
  /// SELL side, the order will sell as much BTC needed to receive quoteOrderQty USDT.
  Future<Map<String, dynamic>> createMarketOrder(
    String symbol,
    OrderSide side, { 
    double quantity,
    double quoteOrderQty,
  }) async{
    if((quantity == null && quoteOrderQty == null) ||
        (quantity != null && quoteOrderQty != null)) return null;
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String params = 'symbol=' + symbol + '&side=' + _parseSideString(side)
                      + '&type=' + BinanceConstants.MARKET_ORDER_TYPE_STRING
                      + '&timestamp=' + timestamp;
    if(quantity != null){
      print('Quantity in command => ' + _buildQuantityString(symbol, quantity));
      params += '&quantity=' + _buildQuantityString(symbol, quantity);
    }   
    if(quoteOrderQty != null){
      params += '&quoteOrderQty=' + quoteOrderQty.toString();
    }
    String signature = await getSignature(params);
    String command = 'curl -H \"X-MBX-APIKEY: ' + _apiKey + '\" -X POST \"https://api.binance.com/api/v3/order?' + params + '&signature=' + signature + '\"';
    if(!(await testOrder(params, signature))) return null;
    var res = await Utils.runCommand(command);
    return json.decode(res.first.stdout);
  }

  /// Sells all [leftSymbol] in [symbol] that the account has
  /// 
  /// Example: In 'XRPUSDT', sells all 'XRP' that the account has
  Future<Map<String, dynamic>> sellAll(
    String symbol,
  ) async{
    double quantity = await getSymbolFreeBalance(
      exchangeInfoMap[symbol].baseAsset
    );
    print('Quantity from account => ' + quantity.toString());
    return createMarketOrder(
      symbol,
      OrderSide.sell,
      quantity: quantity,
    );
  }

  /// Gets the free balance of a single symbol (BTC, USDT, XRP)
  Future<double> getSymbolFreeBalance(String singleSymbol) async{
    Map<String, dynamic> account = await getAccountInfo();
    String res = (account[BinanceConstants.ACCOUNT_BALANCES] as List<dynamic>).firstWhere(
      (element) => element[BinanceConstants.ACCOUNT_BALANCES_ASSET] == singleSymbol
    )[BinanceConstants.ACCOUNT_BALANCES_FREE];
    return double.parse(res);
  }

  /// Test an order before send to binance
  Future<bool> testOrder(String params, String signature) async{
    String command = 'curl -H \"X-MBX-APIKEY: ' + _apiKey + '\" -X POST \"https://api.binance.com/api/v3/order/test?' + params + '&signature=' + signature + '\"';
    var res = await Utils.runCommand(command);
    Map<String, dynamic> resMap = json.decode(res.first.stdout);
    if(resMap.isNotEmpty) print(resMap);
    return resMap.isEmpty;
  }

  /// Returns the signature of a params
  Future<String> getSignature(String params) async{
    String commandToWrite = 'echo -n \"' + params + '\" \| openssl dgst -sha256 -hmac \"' + _secretKey + '\"';
    File file = File(BinanceConstants.SIGNATURE_FILE);
    file.writeAsStringSync(commandToWrite);
    String command = 'bash ' + BinanceConstants.SIGNATURE_FILE;
    var res = await Utils.runCommand(command);
    file.deleteSync();
    return res.first.stdout.toString().replaceFirst('(stdin)= ', '').trim();
  }

  /// Parse an order side to string
  String _parseSideString(OrderSide side){
    switch(side){
      case OrderSide.buy:
        return BinanceConstants.BUY_SIDE_STRING;
      case OrderSide.sell:
        return BinanceConstants.SELL_SIDE_STRING;  
    }
  }

  /// Loasd the exchange info
  /// 
  /// This function loads the exchange info if is null of 
  /// if has pass an expiration time
  Future<void> _loadExchangeInfo() async{
    if(exchangeInfoMap != null &&
      _exchangeInfoServerTime.difference(DateTime.now()).inHours 
                <= BinanceConstants.EXCHANGE_INFO_EXPIRATION_HOURS){
      return;
    }
    String command = 'curl https://www.binance.com/api/v3/exchangeInfo';
    var res = await Utils.runCommand(command);
    Map<String, dynamic> resMap = json.decode(res.first.stdout);
    _exchangeInfoServerTime = DateTime.fromMillisecondsSinceEpoch(
      resMap[BinanceConstants.EXCHANGE_INFO_SERVER_TIME]
    );
    exchangeInfoMap = HashMap();
    for(var _symbol in resMap[BinanceConstants.EXCHANGE_INFO_SYMBOLS] as List<dynamic>){
      BinanceSymbol symbol;
      HashMap<String, Map<String, dynamic>> filters = HashMap();
      for(var filter in (_symbol[BinanceConstants.EXCHANGE_INFO_FILTERS] as List<dynamic>)){
        filters[filter[BinanceConstants.EXCHANGE_INFO_FILTER_TYPE]] = filter;
      }
      symbol = BinanceSymbol(
        symbol: _symbol[BinanceConstants.EXCHANGE_INFO_SYMBOL],
        status: _symbol[BinanceConstants.EXCHANGE_INFO_STATUS],
        baseAsset: _symbol[BinanceConstants.EXCHANGE_INFO_BASE_ASSET],
        baseAssetPrecision: _symbol[BinanceConstants.EXCHANGE_INFO_BASE_ASSET_PRECISION],
        quoteAsset: _symbol[BinanceConstants.EXCHANGE_INFO_QUOTE_ASSET],
        quoteAssetPrecision: _symbol[BinanceConstants.EXCHANGE_INFO_QUOTE_ASSET_PRECISION],
        quotePresicion: _symbol[BinanceConstants.EXCHANGE_INFO_QUOTE_PRECISION],
        baseCommisionPresicion: _symbol[BinanceConstants.EXCHANGE_INFO_BASE_COMMISSION_PRECISION],
        quoteCommisionPresicion: _symbol[BinanceConstants.EXCHANGE_INFO_QUOTE_COMMISSION_PRECISION],
        filters: filters
      );
      exchangeInfoMap[symbol.symbol] = symbol;
    }
  }

  /// Builsd the quanity string
  String _buildQuantityString(String symbol, double quantity){
    String stepSize = exchangeInfoMap[symbol].filters[BinanceConstants.LOT_SIZE][BinanceConstants.LOT_SIZE_STEP_SIZE];
    var stepSizeItems = stepSize.split('.');
    if(stepSizeItems.first == '1') return quantity.toStringAsFixed(0);
    int index;
    for(index = 0; index < stepSizeItems[1].length; index++){
      if(stepSizeItems[1][index] == '1') break;
    }
    return quantity.toStringAsFixed(index + 1);
  }

}

class BinanceSymbol{
  String symbol;
  String status;
  String baseAsset;
  int baseAssetPrecision;
  String quoteAsset;
  int quoteAssetPrecision;
  int quotePresicion;
  int baseCommisionPresicion;
  int quoteCommisionPresicion;
  HashMap<String, Map<String, dynamic>> filters;

  BinanceSymbol({
    this.symbol,
    this.status,
    this.baseAsset,
    this.baseAssetPrecision,
    this.quoteAsset,
    this.quoteAssetPrecision,
    this.quotePresicion,
    this.baseCommisionPresicion,
    this.quoteCommisionPresicion,
    this.filters,
  });


}
