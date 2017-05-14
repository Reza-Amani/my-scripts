//+------------------------------------------------------------------+
//|                                               history_search.mq4 |
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <MyHeaders\MyMath.mqh>
#include <MyHeaders\Pattern.mqh>
#include <MyHeaders\ExamineBar.mqh>
#include <MyHeaders\Screen.mqh>
input int      pattern_len=5;
input int      back_search_len=20000;
input int      history=40000;
input int   correlation_thresh=93;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Screen screen;
   screen.add_L1_comment("script started-");
   int outfilehandle=FileOpen("./trydata/go_through_history_"+Symbol()+EnumToString(ENUM_TIMEFRAMES(_Period))+"_"+IntegerToString(pattern_len)+"_"+IntegerToString(correlation_thresh)+".csv",FILE_WRITE|FILE_CSV,',');
   if(outfilehandle<0)
     {
      screen.add_L1_comment("file error");
      Print("Failed to open the file");
      Print("Error code ",GetLastError());
      return;
     }
   screen.add_L1_comment("file ok-");
   int history_size=(int)MyMath::min(Bars,history);
   screen.add_L1_comment("CalculatingBars:"+IntegerToString(history_size)+"-");

   Pattern* p_pattern;
   ExamineBar* p_bar;
   for(int _ref=10;_ref<history_size-back_search_len;_ref++)
   {
      p_pattern=new Pattern(Close,_ref,pattern_len);
      p_bar=new ExamineBar(_ref,p_pattern);
   }

}
//+------------------------------------------------------------------+
