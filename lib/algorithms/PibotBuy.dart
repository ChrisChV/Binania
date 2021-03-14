import 'package:binance/binance.dart';
import 'package:binania/algorithms/BuyAlg.dart';
import 'package:binania/services/BinanceService.dart';
import 'package:binania/utils/enums/AlgEnums.dart';
import 'package:binania/utils/enums/BinanceEnums.dart';
import 'package:binania/utils/enums/PibotEnums.dart';
import 'package:get_it/get_it.dart';

class PibotBuy extends BuyAlg{

  @override
  String symbol;
  @override
  double quoteBuyAmout;
  @override
  double selledPrice;
  @override
  double initialBottom;
  @override
  double initialTop;
  @override
  double bottomRange;
  @override
  double topRange;
  @override
  AlgBuyType algBuyType = AlgBuyType.pibotBuy;
  @override
  RangeType rangeType;
  
  @override
  Function(Map<String, dynamic>) onBuy;

  bool _canceled;

  PibotBuy({
    this.symbol,
    this.quoteBuyAmout,
    this.rangeType,
    this.initialBottom,
    this.initialTop,
    this.bottomRange,
    this.topRange,
    this.selledPrice, /// Can be empty
    this.onBuy,
  });

  /// Init this algorithm
  @override
  void init({
    double quoteBuyAmout,
    RangeType rangeType,
    double initialBottom,
    double initialTop,
    double bottomRange,
    double topRange,
    double selledPrice,
  }){
    if(quoteBuyAmout != null) this.quoteBuyAmout = quoteBuyAmout;
    if(rangeType != null) this.rangeType = rangeType;
    if(initialBottom != null) this.initialBottom = initialBottom;
    if(initialTop != null) this.initialTop = initialTop;
    if(bottomRange != null) this.bottomRange = bottomRange;
    if(topRange != null) this.topRange = topRange;
    if(selledPrice != null) this.selledPrice = selledPrice;
    midLine = this.selledPrice;
    calculateTopLine(this.initialTop);
    calculateBottomLine(this.initialBottom);
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
    if(trade.price > topLine){
      _canceled = true;
      binanceService.createMarketOrder(
        symbol,
        OrderSide.buy,
        quoteOrderQty: quoteBuyAmout,
      ).then((resMap){
        print('=========================================================');
        print('------------------------ BUYED --------------------------');
        print('Buyed at ' + DateTime.now().toString());
        print(resMap);
        tradeSubscription.cancel();
        if(onBuy != null) onBuy(resMap);
      });
      return;
    }
    if(trade.price < bottomLine){
      midLine = bottomLine;
      calculateTopLine(topRange);
      calculateBottomLine(bottomRange);
      printActualState();
      return;
    }
  }

}