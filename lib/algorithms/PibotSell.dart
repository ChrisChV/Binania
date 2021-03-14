import 'package:binance/data/ws_classes.dart';
import 'package:binania/algorithms/SellAlg.dart';
import 'package:binania/services/BinanceService.dart';
import 'package:binania/utils/enums/AlgEnums.dart';
import 'package:binania/utils/enums/PibotEnums.dart';
import 'package:get_it/get_it.dart';

class PibotSell extends SellAlg{

  @override
  String symbol;
  @override
  double buyedPrice;
  @override
  double initialLose;
  @override
  double initialEarn;
  @override
  double loseRange;
  @override
  double earnRange;
  @override
  RangeType rangeType;
  @override
  AlgSellType algSellType = AlgSellType.pibotSell;
  @override
  Function(Map<String, dynamic>) onSell;

  bool _canceled;

  PibotSell({
    this.symbol,
    this.rangeType,
    this.buyedPrice,
    this.initialLose,
    this.initialEarn,
    this.loseRange,
    this.earnRange,
    this.onSell,
  });

  /// Init this algorithm
  @override
  void init({
    double buyedPrice,
    RangeType rangeType,
    double initialLose,
    double initialEarn,
    double loseRange,
    double earnRange,
  }){
    if(buyedPrice != null) this.buyedPrice = buyedPrice;
    if(rangeType != null) this.rangeType = rangeType;
    if(initialLose != null) this.initialLose = initialLose;
    if(initialEarn != null) this.initialEarn = initialEarn;
    if(loseRange != null) this.loseRange = loseRange;
    if(earnRange != null) this.earnRange = earnRange;
    midLine = this.buyedPrice;
    calculateTopLine(this.initialEarn);
    calculateBottomLine(this.initialLose);
    binanceService = GetIt.I<BinanceService>();
    printActualState();
    _canceled = false;
    tradeStream = binanceService.getTradeStream(symbol);
    tradeSubscription = tradeStream.listen(handleTrades);
  }

  /// Handle each trade with the price change
  @override
  void handleTrades(WsAggregatedTrade trade){
    if(_canceled) return;
    if(trade.price < bottomLine){
      _canceled = true;
      binanceService.sellAll(symbol).then((resMap){
        print('=========================================================');
        print('------------------------ SELLED -------------------------');
        print('Selled at ' + DateTime.now().toString());
        print(resMap);
        tradeSubscription.cancel();
        if(onSell != null) onSell(resMap);
      });
      return;
    }
    if(trade.price > topLine){
      midLine = topLine;
      calculateTopLine(earnRange);
      calculateBottomLine(loseRange);
      printActualState();
      return;
    }
  }




}