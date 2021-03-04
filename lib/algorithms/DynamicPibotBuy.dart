import 'package:binance/binance.dart';
import 'package:binania/algorithms/BuyAlg.dart';
import 'package:binania/utils/enums/AlgEnums.dart';
import 'package:binania/utils/enums/BinanceEnums.dart';
import 'package:binania/utils/enums/PibotEnums.dart';

class DynamicPibotBuy extends BuyAlg{

  @override
  String symbol;
  @override
  double quoteBuyAmout;
  @override
  double selledPrice;
  @override
  double topRange;
  @override
  AlgBuyType algBuyType = AlgBuyType.dynamicPibotBuy;
  @override
  RangeType rangeType;
  @override
  Function(Map<String, dynamic>) onBuy;

  DynamicPibotBuy({
    this.symbol,
    this.rangeType,
    this.quoteBuyAmout,
    this.selledPrice,
    this.topRange,
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
    if(selledPrice != null) this.selledPrice = selledPrice;
    if(topRange != null) this.topRange = topRange;
    if(rangeType != null) this.rangeType = rangeType;
    midLine = this.selledPrice;
    calculateTopLine(this.topRange);
    printActualState();
    tradeStream = binanceService.getTradeStream(symbol);
    tradeSubscription = tradeStream.listen(handleTrades);
  }

  /// Handle each trade with the price change
  @override
  void handleTrades(WsAggregatedTrade trade){
    if(trade.price > topLine){
      tradeSubscription.cancel();
      binanceService.createMarketOrder(
        symbol,
        OrderSide.buy,
        quoteOrderQty: quoteBuyAmout,
      ).then((resMap){
        print('=========================================================');
        print('------------------------ BUYED --------------------------');
        print('Buyed at ' + DateTime.now().toString());
        print(resMap);
        if(onBuy != null) onBuy(resMap);
      });
      return;
    }
    if(trade.price < midLine){
      midLine = trade.price;
      calculateTopLine(topRange);
      printActualState();
      return;
    }
  }
  


}