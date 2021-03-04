import 'package:binania/algorithms/BuyAlg.dart';
import 'package:binania/algorithms/DynamicPibotBuy.dart';
import 'package:binania/algorithms/DynamicPibotSell.dart';
import 'package:binania/algorithms/PibotBuy.dart';
import 'package:binania/algorithms/PibotSell.dart';
import 'package:binania/algorithms/SellAlg.dart';
import 'package:binania/utils/constants/BinanceConstants.dart';
import 'package:binania/utils/enums/AlgEnums.dart';
import 'package:binania/utils/enums/PibotEnums.dart';

class MultipleAlg{

  String symbol;

  AlgSellType algSellType;
  AlgBuyType algBuyType;

  SellAlg _sellAlg;
  BuyAlg _buyAlg;

  double _initialBottom;
  double _initialTop;
  double _bottomRange;
  double _topRange;
  double _initialLose;
  double _initialEarn;
  double _loseRange;
  double _earnRange;

  Function(Map<String, dynamic>) _onBuy;
  Function(Map<String, dynamic>) _onSell;

  MultipleAlg(
    this.symbol,
    this.algBuyType,
    this.algSellType
  );

  /// Runs the buy algorithm first
  void runBuyFirst(
    RangeType rangeType,
    double quoteBuyAmount, 
    double firstInitialBottom,
    double firstInitialTop,
    double firstBottomRange,
    double firstTopRange, 
    double initialBottom,
    double initialTop,
    double bottomRange,
    double topRange,
    double initialLose,
    double initialEarn,
    double loseRange,
    double earnRange, {
    double selledPrice,
    Function(Map<String, dynamic>) onBuy,
    Function(Map<String, dynamic>) onSell,
  }){
    _initialBottom = initialBottom;
    _initialTop = initialTop;
    _bottomRange = bottomRange;
    _topRange = topRange;
    _initialLose = initialLose;
    _initialEarn = initialEarn;
    _loseRange = loseRange;
    _earnRange = earnRange;
    _onBuy = onBuy;
    _onSell = _onSell;
    switch(algSellType){
      case AlgSellType.pibotSell:
        _sellAlg = PibotSell(
          symbol: symbol,
          rangeType: rangeType,
          initialLose: _initialLose,
          initialEarn: _initialEarn,
          loseRange: _loseRange,
          earnRange: _earnRange,
          onSell: _onSellAlg,
        );
        break;
      case AlgSellType.dynamicPibotSell:
        _sellAlg = DynamicPibotSell(
          symbol: symbol,
          rangeType: rangeType,
          loseRange: loseRange,
          onSell: _onSell,
        );
        break;
    }
    switch(algBuyType){
      case AlgBuyType.pibotBuy:
        _buyAlg = PibotBuy(
          symbol: symbol,
          quoteBuyAmout: quoteBuyAmount,
          rangeType: rangeType,
          initialBottom: firstInitialBottom,
          initialTop: firstInitialTop,
          bottomRange: firstBottomRange,
          topRange: firstTopRange,
          selledPrice: selledPrice,
          onBuy: _onBuyAlg,
        );
        break;
      case AlgBuyType.dynamicPibotBuy:
        _buyAlg = DynamicPibotBuy(
          symbol: symbol,
          quoteBuyAmout: quoteBuyAmount,
          rangeType: rangeType,
          topRange: topRange,
          selledPrice: selledPrice,
          onBuy: _onBuyAlg,
        );
        break;
    }
    _buyAlg.init();
  }

  /// Runs the sell algorithm first
  void runSellFirst(
    RangeType rangeType,
    double quoteBuyAmount,
    double buyedPrice,
    double firstInitialLose,
    double firstInitialEarn,
    double firstLoseRange,
    double firstEarnRange,
    double initialLose,
    double initialEarn,
    double loseRange,
    double earnRange, 
    double initialBottom,
    double initialTop,
    double bottomRange,
    double topRange, {
    Function(Map<String, dynamic>) onBuy,
    Function(Map<String, dynamic>) onSell,
  }){
    _initialBottom = initialBottom;
    _initialTop = initialTop;
    _bottomRange = bottomRange;
    _topRange = topRange;
    _initialLose = initialLose;
    _initialEarn = initialEarn;
    _loseRange = loseRange;
    _earnRange = earnRange;
    _onBuy = onBuy;
    _onSell = _onSell;
    switch(algSellType){
      case AlgSellType.pibotSell:
        _sellAlg = PibotSell(
          symbol: symbol,
          rangeType: rangeType,
          buyedPrice: buyedPrice,
          initialLose: firstInitialLose,
          initialEarn: firstInitialEarn,
          loseRange: firstLoseRange,
          earnRange: firstEarnRange,
          onSell: _onSellAlg,
        );
        break;
      case AlgSellType.dynamicPibotSell:
        _sellAlg = DynamicPibotSell(
          symbol: symbol,
          rangeType: rangeType,
          buyedPrice: buyedPrice,
          loseRange: loseRange,
          onSell: _onSellAlg,
        );
        break;
    }
    switch(algBuyType){
      case AlgBuyType.pibotBuy:
        _buyAlg = PibotBuy(
          symbol: symbol,
          quoteBuyAmout: quoteBuyAmount,
          rangeType: rangeType,
          initialBottom: _initialBottom,
          initialTop: _initialTop,
          bottomRange: _bottomRange,
          topRange: _topRange,
          onBuy: _onBuyAlg,
        );
        break;
      case AlgBuyType.dynamicPibotBuy:
        _buyAlg = DynamicPibotBuy(
          symbol: symbol,
          rangeType: rangeType,
          quoteBuyAmout: quoteBuyAmount,
          topRange: topRange,
          onBuy: _onBuyAlg,
        );
        break;
    }
  
    _sellAlg.init();
  }

  /// On Buy function
  void _onBuyAlg(Map<String, dynamic> resMap){
    if(_onBuy != null) _onBuy(resMap);
    List<dynamic> fills = resMap[BinanceConstants.ORDER_FILLS];
    double total = 0;
    for(var fill in fills){
      total +=  double.parse(fill[BinanceConstants.ORDER_FILLS_PRICE]);
    }
    double averagePrice = total / fills.length;
    _sellAlg.init(
      buyedPrice: averagePrice,
      initialLose: _initialLose,
      initialEarn: _initialEarn,
      loseRange: _loseRange,
      earnRange: _earnRange,
    );
  }

  /// On Sell function
  void _onSellAlg(Map<String, dynamic> resMap){
    if(_onSell != null) _onSell(resMap);
    List<dynamic> fills = resMap[BinanceConstants.ORDER_FILLS];
    double total = 0;
    for(var fill in fills){
      total +=  double.parse(fill[BinanceConstants.ORDER_FILLS_PRICE]);
    }
    double averagePrice = total / fills.length;
    _buyAlg.init(
      selledPrice: averagePrice,
      initialBottom: _initialBottom,
      initialTop: _initialTop,
      topRange: _topRange,
      bottomRange: _bottomRange,
    );
  }


  

}