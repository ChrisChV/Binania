import 'package:binance/binance.dart';
import 'package:binania/algorithms/SellAlg.dart';
import 'package:binania/services/BinanceService.dart';
import 'package:binania/utils/enums/AlgEnums.dart';
import 'package:binania/utils/enums/PibotEnums.dart';
import 'package:get_it/get_it.dart';

class DynamicPibotSell extends SellAlg{

  @override
  String symbol;
  @override
  double buyedPrice;
  @override
  double loseRange;
  @override
  RangeType rangeType;
  @override
  AlgSellType algSellType = AlgSellType.dynamicPibotSell;
  @override
  Function(Map<String, dynamic>) onSell;

  DynamicPibotSell({
    this.symbol,
    this.buyedPrice,
    this.loseRange,
    this.rangeType,
    this.onSell
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
    if(loseRange != null) this.loseRange = loseRange;
    midLine = this.buyedPrice;
    calculateBottomLine(this.loseRange);
    binanceService = GetIt.I<BinanceService>();
    printActualState();
    tradeStream = binanceService.getTradeStream(symbol);
    tradeSubscription = tradeStream.listen(handleTrades);
  }

  /// Handle each trade with the price change
  @override
  void handleTrades(WsAggregatedTrade trade){
    if(trade.price < bottomLine){
      tradeSubscription.cancel();
      binanceService.sellAll(symbol).then((resMap){
        print('=========================================================');
        print('------------------------ SELLED -------------------------');
        print('Selled at ' + DateTime.now().toString());
        print(resMap);
        if(onSell != null) onSell(resMap);
      });
      return;
    }
    if(trade.price > midLine){
      midLine = trade.price;
      calculateBottomLine(loseRange);
      printActualState();
      return;
    }
  }


}