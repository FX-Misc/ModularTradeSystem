//+------------------------------------------------------------------+
//|                                            SignalEngineTrend.mqh |
//|                                     Copyright 2020, Michael Wade |
//|                                             michaelwade@yeah.net |
//+------------------------------------------------------------------+
#property strict
#include "..\Common\ISignalEngine.mqh"
#include "..\Common\Const.mqh"
#include "..\Common\Input.mqh"
#include "..\Common\Log.mqh"
#include "..\Common\ShowUtil.mqh"
#include "InputTrend.mqh"

//+------------------------------------------------------------------+
//| The specific implementation class of the signal engine interface:
//| It implements the unified interface in ISignalEngine.mqh and 
//| independently encapsulate the signal calculation logic. 
//| You can customize your signal calculation logic here.                                                           |
//+------------------------------------------------------------------+
class CSignalEngineTrend : public ISignalEngine
  {
private:
   static const string TAG;
   int               m_big_cross;
   int               m_small_cross;
   int               m_big_trend;
   int               m_small_trend;
   int               m_short_trend;
   int               GetBigTrend();
   int               GetSmallTrend();
   int               GetSmallCross();
   int               GetShortTrend();
   int               GetOrientation();
   int               GetOpenSignal();
   int               GetCloseSignal();
   CSignalData       CreateSignalData();
   void              ShowOriginalSignalInfo();
public:
                     CSignalEngineTrend():m_big_cross(CROSS_NO),m_small_cross(CROSS_NO),m_big_trend(TREND_NO),m_small_trend(TREND_NO) { Print("CSignalEngineTrend was born"); }
                    ~CSignalEngineTrend() { Print("CSignalEngineTrend is dead");  }
   //--- Implementing the virtual methods of the ISignalEngine interface
   CSignalData       GetSignalData();
  };

const string CSignalEngineTrend::TAG = "CSignalEngineTrend";

//+------------------------------------------------------------------+
//| For the outside world to obtain original signal data                                                                 |
//+------------------------------------------------------------------+
CSignalData CSignalEngineTrend::GetSignalData()
  {
   m_big_trend = GetBigTrend();
   m_small_trend = GetSmallTrend();
   m_short_trend = GetShortTrend();
//Log(TAG,"GetSignalData..."+StringConcatenate("m_big_trend=",m_big_trend,",m_small_trend=",m_small_trend));
   ShowOriginalSignalInfo();
   return CreateSignalData();
  }

//+------------------------------------------------------------------+
//| Create a CSignalData instance                                                                 |
//+------------------------------------------------------------------+
CSignalData CSignalEngineTrend::CreateSignalData()
  {
   CSignalData data;
   data.orientation = GetOrientation();
   data.open_signal = GetOpenSignal();
   data.close_signal = GetCloseSignal();
   return data;
  }

//+------------------------------------------------------------------+
//| Get trading orientation                                                                 |
//+------------------------------------------------------------------+
int CSignalEngineTrend::GetOrientation()
  {
   switch(m_big_trend)
     {
      case TREND_UP:
         return ORIENTATION_UP;
      case TREND_DW:
         return ORIENTATION_DW;
     }
   return ORIENTATION_NO;
  }

//+------------------------------------------------------------------+
//| Get signal to open a position                                                                  |
//+------------------------------------------------------------------+
int CSignalEngineTrend::GetOpenSignal()
  {
   if(m_small_cross == CROSS_GLOD)
      return SIGNAL_OPEN_BUY;
   if(m_small_cross == CROSS_DEAD)
      return SIGNAL_OPEN_SELL;
   return SIGNAL_NO;
  }

//+------------------------------------------------------------------+
//| Get signal to close a position                                                                      |
//+------------------------------------------------------------------+
int CSignalEngineTrend::GetCloseSignal()
  {
   if(m_small_trend == TREND_DW && m_short_trend == TREND_DW)
      return SIGNAL_CLOSE_BUY;
   if(m_small_trend == TREND_UP && m_short_trend == TREND_UP)
      return SIGNAL_CLOSE_SELL;
   return SIGNAL_NO;
  }

//+------------------------------------------------------------------+
//| Get the big timeframe trend
//+------------------------------------------------------------------+
int CSignalEngineTrend::GetBigTrend()
  {
   double macdCurrent=iMACD(NULL,0,BigFastEMA,BigSlowEMA,BigSignalSMA,PRICE_CLOSE,MODE_MAIN,1);
   double signalCurrent=iMACD(NULL,0,BigFastEMA,BigSlowEMA,BigSignalSMA,PRICE_CLOSE,MODE_SIGNAL,1);
   if(macdCurrent == signalCurrent)
      return TREND_NO;
   return macdCurrent > signalCurrent ? TREND_UP : TREND_DW;
  }

//+------------------------------------------------------------------+
//| Get the small timeframe trend
//+------------------------------------------------------------------+
int CSignalEngineTrend::GetSmallTrend()
  {
   double macdCurrent=iMACD(NULL,0,SmallFastEMA,SmallSlowEMA,SmallSignalSMA,PRICE_CLOSE,MODE_MAIN,1);
   double signalCurrent=iMACD(NULL,0,SmallFastEMA,SmallSlowEMA,SmallSignalSMA,PRICE_CLOSE,MODE_SIGNAL,1);
   double macdPrevious=iMACD(NULL,0,SmallFastEMA,SmallSlowEMA,SmallSignalSMA,PRICE_CLOSE,MODE_MAIN,SmallCrossBars);
   double signalPrevious=iMACD(NULL,0,SmallFastEMA,SmallSlowEMA,SmallSignalSMA,PRICE_CLOSE,MODE_SIGNAL,SmallCrossBars);
// Get the cross signal
   if(macdCurrent > signalCurrent && macdPrevious <= signalPrevious)
      m_small_cross = CROSS_GLOD;
   else
      if(macdCurrent < signalCurrent && macdPrevious >= signalPrevious)
         m_small_cross = CROSS_DEAD;
      else
         m_small_cross = CROSS_NO;
// Get the trend signal
   if(macdCurrent == signalCurrent)
      return TREND_NO;
   return macdCurrent > signalCurrent ? TREND_UP : TREND_DW;
  }

//+------------------------------------------------------------------+
//| Get the short time trend                                                               |
//+------------------------------------------------------------------+
int CSignalEngineTrend::GetShortTrend()
  {
   if(Close[ShortTimeBars]==Close[1])
      return TREND_NO;
   return Close[ShortTimeBars]>Close[1] ? TREND_DW : TREND_UP;
  }

//+------------------------------------------------------------------+
//| Show original signal infomation on screen immediately                                                               |
//+------------------------------------------------------------------+
void CSignalEngineTrend::ShowOriginalSignalInfo()
  {
   ShowLable("SmallIndicator",StringConcatenate("SmallIndicator:",SmallFastEMA," ",SmallSlowEMA," ",SmallSignalSMA),0,0,20,10,"",Red);
   ShowLable("BigIndicator",StringConcatenate("BigIndicator:",BigFastEMA," ",BigSlowEMA," ",BigSignalSMA),0,0,40,10,"",Red);
   ShowLable("SmallTrend",StringConcatenate("SmallTrend:",m_small_trend),0,0,60,15,"",Red);
   ShowLable("SmallCross",StringConcatenate("SmallCross:",m_small_cross),0,0,80,15,"",Red);
   ShowLable("BigTrend",StringConcatenate("BigTrend:",m_big_trend),0,0,100,15,"",Red);
  }
//+------------------------------------------------------------------+