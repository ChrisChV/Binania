import 'dart:async';

import 'package:binance/data/ws_classes.dart';
import 'package:binania/services/BinanceService.dart';
import 'package:binania/utils/enums/PibotEnums.dart';
import 'package:binania/utils/utils.dart';

class PibotSell {

  String symbol;
  double buyedPrice;
  double initialLose;
  double initialEarn;
  double loseRange;
  double earnRange;
  RangeType rangeType;
  

  double _midleLine;
  double _topLine;
  double _bottomLine;
  int _actualIteration;
  Function(Map<String, dynamic>) onSell;

  BinanceService _binanceService;
  Stream<WsAggregatedTrade> _tradeStream;
  StreamSubscription<WsAggregatedTrade> _tradeSubscription;


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
  Future<void> init(String apiKey, String secretKey) async{
    _midleLine = buyedPrice;
    _calculateTopLine(initialEarn);
    _calculateBottomLine(initialLose);
    _binanceService = BinanceService();
    await _binanceService.init(
      apiKey,
      secretKey,
    );
    printActualState();
    _tradeStream = _binanceService.getTradeStream(symbol);
    _tradeSubscription = _tradeStream.listen(_handleTrades);
  }

  /// Prints the actual state of this pibot sell
  void printActualState(){
    print('=========================================================');
    print('Pibot Sell state at [' + DateTime.now().toString() + ']');
    print('Symbol: ' + symbol);
    print('Buyed Price: ' + buyedPrice.toString());
    print('Top line: ' + _topLine.toString());
    print('Mid line: ' + _midleLine.toString());
    print('Bottom line: ' + _bottomLine.toString());
  }
  
  /// Calculates the top line from the middle line in [range]
  void _calculateTopLine(double range){
    switch(rangeType){
      case RangeType.target:
        _topLine = _midleLine + range;
        break;
      case RangeType.percentage:
        _topLine = _midleLine + Utils.getTargetFromPercentage(_midleLine, range);
        break;
    }
  }

  /// Calculates the bottom line from the middle line in [range]
  void _calculateBottomLine(double range){
    switch(rangeType){
      case RangeType.target:
        _bottomLine = _midleLine - range;
        break;
      case RangeType.percentage:
        _bottomLine = _midleLine - Utils.getTargetFromPercentage(_midleLine, range);
    }
  }

  /// Handle each trade with the price change
  void _handleTrades(WsAggregatedTrade trade){
    if(trade.price < _bottomLine){
      _tradeSubscription.cancel();
      _binanceService.sellAll(symbol).then((resMap){
        if(onSell != null) onSell(resMap);
        print('=========================================================');
        print("------------------------ SELLED -------------------------");
        print(resMap);
      });
      return;
    }
    if(trade.price > _topLine){
      _midleLine = _topLine;
      _calculateTopLine(earnRange);
      _calculateBottomLine(loseRange);
      printActualState();
      return;
    }
  }




}