//+------------------------------------------------------------------+
//|                                                        Input.mqh |
//|                                     Copyright 2020, Michael Wade |
//|                                             michaelwade@yeah.net |
//+------------------------------------------------------------------+
//| All FollowTrend input variables should be defined here.
//+------------------------------------------------------------------+
#property strict
#define SmallTimes  12

// Parameters for small period indicator
input int SmallFastEMA= 100*SmallTimes;
input int SmallSlowEMA= 216*SmallTimes;
input int SmallSignalSMA= 9*SmallTimes;
// Number of continuous bars of cross signal (at least 2 hours)
input int SmallCrossBars=2*SmallTimes;
// Parameters for big period indicator
input int BigFastEMA= 4*100*SmallTimes;
input int BigSlowEMA= 4*216*SmallTimes;
input int BigSignalSMA= 4*9*SmallTimes;
// Number of continuous bars of short time trend
input int ShortTimeBars=3*SmallTimes;
// Minimum profit for every closing position.
input double MinProfit = 1;

//+------------------------------------------------------------------+
