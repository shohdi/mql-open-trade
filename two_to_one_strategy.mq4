//+------------------------------------------------------------------+

//|                                                  TradeByTick.mq5 |

//|                        Copyright 2017, MetaQuotes Software Corp. |

//|                                             https://www.mql5.com |

//+------------------------------------------------------------------+

#property copyright "Copyright 2018, shohdy elshemy"

#property link      ""

#property version   "1.00"













//+------------------------------------------------------------------+

//| My custom types                                   |

//+------------------------------------------------------------------+

enum TRADE_TYPE

{

   SELL = -1,

   BUY = 1

};





input float percentageMoney = 0.01;

double startBalance=0.0;



input double timeToTrade = 48.0;





input double lossTimesWin = 2.0;







input int EXPERT_MAGIC =188888 ;  // MagicNumber of the expert



enum SmaCalcType

{

   Close1 = 0

   ,High1 = 1

   ,Low1 = 2

   ,Mid = 3

};





struct MqlCandle

 {

   double Close1;

   double Open1;

    int Dir;

   double High1;

    double Low1;

    double Volume1;

    datetime Date;

 };

 

 

 



 

MqlTick currentTick;

MqlTick lastTick;

MqlCandle lastCandle;



int noOfSuccess = 0;

 int     noOfFail = 0;

 

 int lastTicket = 0;

int lastDir = 0;











//+------------------------------------------------------------------+

//| Expert initialization function                                   |

//+------------------------------------------------------------------+



int buyTicket = 0;

int sellTicket = 0;

int openTicket = 0;





int calcAndOpenTrade(TRADE_TYPE tradeDirection)

{

    

      

     

      

      

      double balance = AccountInfoDouble(ACCOUNT_BALANCE);

    

         

    

      

      

      //--- show all the information available from the function AccountInfoDouble()

   //printf("ACCOUNT_BALANCE =  %G",AccountInfoDouble(ACCOUNT_BALANCE));

   //printf("ACCOUNT_CREDIT =  %G",AccountInfoDouble(ACCOUNT_CREDIT));

  // printf("ACCOUNT_PROFIT =  %G",AccountInfoDouble(ACCOUNT_PROFIT));

  // printf("ACCOUNT_EQUITY =  %G",AccountInfoDouble(ACCOUNT_EQUITY));

  // printf("ACCOUNT_MARGIN =  %G",AccountInfoDouble(ACCOUNT_MARGIN));

   //printf("ACCOUNT_MARGIN_FREE =  %G",AccountInfoDouble(ACCOUNT_FREEMARGIN));

   //printf("ACCOUNT_MARGIN_LEVEL =  %G",AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));

   //printf("ACCOUNT_MARGIN_SO_CALL = %G",AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL));

   //printf("ACCOUNT_MARGIN_SO_SO = %G",AccountInfoDouble(ACCOUNT_MARGIN_SO_SO));

   //printf("ACCOUNT_LEVERAGE = %G",AccountInfoInteger(ACCOUNT_LEVERAGE));

   double lotSize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_CONTRACT_SIZE);

   //printf("lot size : %G" ,lotSize );

   double pointSize = MarketInfo(_Symbol,MODE_POINT);

   double spreadSize = MarketInfo(_Symbol,MODE_SPREAD);

   double bid = MarketInfo(_Symbol,MODE_BID);

   double ask = MarketInfo(_Symbol,MODE_ASK);

   //printf("point size : %G" , pointSize );

   //printf("spread : %G " , spreadSize);

   //printf("spread price : %G",spreadSize * pointSize);

   //printf("bid : %G",bid);

   //printf("ask : %G",ask);

   double close = getCurrentClose();

   double upPrice = getExitPrice(1);

   double downPrice = getExitPrice(-1);

   //Print("close ",close," up price " , upPrice," down price ",downPrice);

   

   

   //printf("month : %G",getMonth(TimeCurrent()));

   //printf("day of month : %G",getDayOfMonth(TimeCurrent()));

   //printf("day of week : %G",getDayOfWeek(TimeCurrent()));

   //printf("hour : %G",getHour(TimeCurrent()));

   //printf("minute : %G",getMinute(TimeCurrent()));

   double volume = calculateVolume(0);

    double historyMove = getMoveOnHistory(0); 

    

    double lossOrWinPrice = getValueInUSD(historyMove * volume * lotSize);

   

   //printf("volume to trade : %G , averageMove : %G , lossValue : %G",volume,historyMove,lossOrWinPrice);

                 //int orderNums = getOpenedOrderNo();

                  //Print("found signal : current order number " ,orderNums );

                  //if(orderNums == 0)

                  //{

                     //Print("0 orders open , starting new order in dir : ",tradeDirection);

                     int ret = openTrade((int)tradeDirection,historyMove,volume);

                     return ret;

                  //}

                  //else

                  //{

                  //   Print("no trades becase there is open orders :  ",orderNums);

                  //}

     

//---

}





int OnInit()

  {

//--- create timer

   EventSetTimer(1);



   lastTick.ask = -1 ;

      lastTick.bid = -1;

      currentTick.ask = -1;

      currentTick.bid = -1;

      lastCandle.Close1 = -1;

       buyTicket = 0;

 sellTicket = 0;

 openTicket = 0;

      

     

      

      

      double balance = AccountInfoDouble(ACCOUNT_BALANCE);

    

         startBalance = balance;

      

   return(INIT_SUCCEEDED);

  }

//+------------------------------------------------------------------+

//| Expert deinitialization function                                 |

//+------------------------------------------------------------------+

void OnDeinit(const int reason)

  {

  

      //Print("Min value to loss every trade : ",maxMinMoney);

      calcSuccessToFailOrders();

       Print("no of success : " + noOfSuccess + " , no of fail : " + noOfFail);

        double totalVal = noOfSuccess + noOfFail;

        if(totalVal > 0)

        {

            Print("Percentage : " + ((noOfSuccess/totalVal)* 100));

            

        }

   

//--- destroy timer

   EventKillTimer();

      

  }

  

  void calcSuccessToFailOrders()

  {

      noOfSuccess = 0;

      noOfFail = 0;

      int hstTotal = OrdersHistoryTotal();

      for(int i=0; i < hstTotal; i++)           

       {

            if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))

            {

               if(OrderMagicNumber() == EXPERT_MAGIC)

               {

                  if( OrderProfit() > 0)

                   {

                     noOfSuccess++;

                   }

                   else if (OrderProfit() < 0)

                   {

                     noOfFail++;

                   }

               }

                

             }

             

        }

                  

            

  }





  double getCurrentClose()

  {

      double closes[1];

      CopyClose(_Symbol,PERIOD_M1,0,1,closes);

      return closes[0];

  }

  

    double getExitPrice(int type)

  {

       double vbid    = MarketInfo(_Symbol,MODE_BID);

   double vask    = MarketInfo(_Symbol,MODE_ASK);

   double close = getCurrentClose();

   double slip = vask- vbid;

   if(slip < 0)

      slip = slip *-1;

   if(type == 1)

   {

      return close - slip;

   }

   else if (type == -1)

   {

      return close + slip;

   }

   

   return close;

  }

  

  

  double getMonth(datetime dateOne)

{

   MqlDateTime structTime ;

   TimeToStruct(dateOne,structTime);

   return (structTime.mon / 12.0) ;

   

   

}



double getDayOfMonth(datetime dateOne)

{

   MqlDateTime structTime ;

   TimeToStruct(dateOne,structTime);

   return (structTime.day / 31.0) ;

   

   

}



double getDayOfWeek(datetime dateOne)

{

   MqlDateTime structTime ;

   TimeToStruct(dateOne,structTime);

   return (structTime.day_of_week / 7.0) ;

   

   

}



double getHour(datetime dateOne)

{

   MqlDateTime structTime ;

   TimeToStruct(dateOne,structTime);

   return (structTime.hour / 24.0) ;

   

   

}



double getMinute (datetime dateOne)

{

   MqlDateTime structTime ;

   TimeToStruct(dateOne,structTime);

   return (structTime.min / 60.0) ;

   

   

}





double getMoveOnHistory(int pos)

{

   int count = (int)((timeToTrade * 10.0)/4.0);

   int highIndex = iHighest(_Symbol ,240,MODE_HIGH, count ,pos);

   int lowIndex = iLowest(_Symbol ,240,MODE_LOW, count ,pos);

   

   

   

   double high = iHigh(_Symbol,240,highIndex);

   double low  = iHigh(_Symbol,240,lowIndex);

   double diff = ((high - low)/10.0) * 0.75;

   return diff;

}





double getValueInUSD(double  symbolVal)

{

   double tickValue = MarketInfo(_Symbol,MODE_TICKVALUE);

   double tickSize = MarketInfo(_Symbol,MODE_TICKSIZE);

  

 

  double usdPrice = (symbolVal * tickValue);

  return usdPrice;



}







double calculateVolume(int pos)

{



   double balance = AccountInfoDouble(ACCOUNT_BALANCE);

   double lotSize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_CONTRACT_SIZE);

   double oneHundredth = MarketInfo(_Symbol, MODE_LOTSTEP);

   if(oneHundredth == 0)

   {

      oneHundredth = 0.01;

   }

   //double bidAbeea = MarketInfo(_Symbol,MODE_BID);

   //double askAshtry = MarketInfo(_Symbol,MODE_ASK);

    double askAshtry = getPriceAtPosition(pos);

 



   double minBuyMoney = askAshtry *oneHundredth  * lotSize ;

   

   //check history of price to get range to trade with

   double historyMove = getMoveOnHistory(pos); 

   double minHistoryPrice = getValueInUSD(historyMove *  oneHundredth * lotSize);

  

   double lossValue = percentageMoney * balance;

  

  if(lossValue < minHistoryPrice)

  {

      lossValue = minHistoryPrice;

  }

  



   double calcVol = 0;

   double volume = 0;





   while( getValueInUSD(historyMove *  volume  * lotSize) <= lossValue)

   {

      volume = volume +oneHundredth;

    

   } 

   

   

  



   if(volume > oneHundredth)

   {

      volume = volume - oneHundredth;

   }

  



   return volume;

   

}





double getPriceAtPosition(int pos)

{

   double closes1[];

   

   ArrayResize(closes1,1);

   CopyClose(_Symbol,_Period,pos,1,closes1);

   return closes1[0];

}



int openTrade (int type ,double tradeStop,double volume)

{

   Print("Start order ");

   double balance = AccountInfoDouble(ACCOUNT_BALANCE);

   Print("Account balance = ",balance);

   

      double vbid    = MarketInfo(_Symbol,MODE_BID);

   double vask    = MarketInfo(_Symbol,MODE_ASK);





 

 

 

   if(type == 1)

   {

      //buy

      vbid =  vbid - (tradeStop * lossTimesWin) ;

      vask = vask - (tradeStop * lossTimesWin) ;

     

      

   }

   else

   {

      //sell

      vbid = vbid + (tradeStop * lossTimesWin);

      vask = vask + (tradeStop * lossTimesWin) ;

   }





   double close = 0;

   string title = "";

   color arrowColor;

   

   int setType = 0;

   if (type == 1)

   {

      setType = OP_BUYLIMIT;

      close = vask;

      title = "Buy order";

      arrowColor = clrGreen;

   }

   else if(type == -1)

   {

      setType = OP_SELLLIMIT;

      close = vbid;

      title = "Sell order";

      arrowColor = clrRed;

   }

   else

   {

      return false;

   }

   



    double stopLoss = 0;

    double takeProfit = 0;

    if(type == 1)

    {

      stopLoss = close - tradeStop;

      takeProfit = close + tradeStop;

    }

    else if (type == -1)

    {

      stopLoss = close + tradeStop;

      takeProfit = close - tradeStop;

    }

    

   

   close = NormalizeDouble(close,Digits);

    stopLoss = NormalizeDouble(stopLoss,Digits);

    takeProfit = NormalizeDouble(takeProfit,Digits);

   

   //MqlTradeRequest request={0};

   //MqlTradeResult  result={0};

   //request.action   =TRADE_ACTION_DEAL;                     // type of trade operation

   //request.symbol   =Symbol();                              // symbol

   //request.volume   =volume;                                   // volume of 0.1 lot

   //request.type     =setType;                        // order type

   //request.price    =SymbolInfoDouble(Symbol(),SYMBOL_ASK); // price for opening

   //request.deviation=5;                                     // allowed deviation from the price

   //request.magic    =EXPERT_MAGIC;

   //request.sl = stopLoss;

   //request.tp = takeProfit;

  

                             // MagicNumber of the order

//--- send the request

   //return OrderSend(request,result);

   



   

   

   

      int ticket=OrderSend(Symbol(),setType,volume,close,5,stopLoss,takeProfit,title,EXPERT_MAGIC,0,arrowColor);

      int error = GetLastError();

      if(error != 0)

      {

         Print(error);

      }

         

      if(ticket>=0)

      {

            //order my be successed

            

            if(OrderSelect(ticket, SELECT_BY_TICKET)==true)

            {

               lastTicket = ticket;

               lastDir = type;

               

            //  lastAverageMove = averageMove;

            // lastOpenPrice = getCurrentClose();

               

               return ticket;

            }

      }

   

   

   

     

     

     return ticket;

   

}





int getOpenedOrderNo()

{

   int total1=0;//PositionsTotal();

   int total2=OrdersTotal();

   

   

    //Print("Pending orders number ",total2," opened orders number ",total1);

   return total1 + total2 ;

   

}



void OnTick()

{



   int orders = getOpenedOrderNo();

   if(orders == 0 && openTicket != 0)

   {

      openTicket = 0;

   }



   if(sellTicket == 0 && buyTicket == 0 && openTicket == 0)

   {

      //new

      buyTicket = calcAndOpenTrade(TRADE_TYPE::BUY);

      sellTicket = calcAndOpenTrade(TRADE_TYPE::SELL);

      openTicket = 0;

   }
   else
   {
      if(sellTicket !=0 )
      {
         if(OrderSelect(sellTicket, SELECT_BY_TICKET)==true)
         {
            if(OrderType() == OP_BUY || OrderType() == OP_SELL)
            {
               OrderDelete(buyTicket);
               openTicket = sellTicket;
               sellTicket = 0;
               buyTicket = 0;
               
            }
            
            
            
         }
      }
      
      if(buyTicket !=0 )
      {
         if(OrderSelect(buyTicket, SELECT_BY_TICKET)==true)
         {
            if(OrderType() == OP_BUY || OrderType() == OP_SELL)
            {
               OrderDelete(sellTicket);
               openTicket = buyTicket;
               sellTicket = 0;
               buyTicket = 0;
               
            }
            
            
            
         }
      }
      
   }


   

}





