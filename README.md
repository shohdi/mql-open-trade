# mql-open-trade

Simple expert advisors to open trade setting take profit and stop loss to a percent of capital

In these simple files , it will open the trade handling the account currency exchange and manage your risk to be an input percentage and a period of trade time


open_trade.mq4 will open a trade at current time with stop loss set to the input percent

open_delay_trade.mq4 will open a trade when it arrives an automatic price in the future with stop loss set to the input percent


all files will not open more than one trade

if your percent is too small it will reset to match the lowest lot size available to trade


experts became ready and used live on 08-04-2021 18:22 UTC

you can use inputs to set the capital percentage , average trade number of hours  (default 48 hour trade)  , direction as buy and sell and Expert random number to recognize trades
<br>
percentageMoney                  the capital percentage<br>
timeToTrade                      the average number of hours trade will be<br>
tradeDirection                   the direction of the trade (BUY 1 or SELL -1)<br>
EXPERT_MAGIC                     Trades magic number<br> 
<br>

if you like my work , your donate is appretiated to bitcoin wallet address :
bc1q6zrsxk6x6wjj3573s4fee46c8h3wagjskpc6p3





