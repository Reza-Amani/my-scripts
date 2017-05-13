//+------------------------------------------------------------------+
//|                                               history_search.mq4 |
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
/////////////////////////////////////////////////////////////////classes
class Pattern
{
  public:
   int size;
   double close[];
   void set_close(const double &_src[],int _src_start, int _size);
};
void Pattern::set_close(const double &_src[],int _src_start, int _size)
{
   size=_size;
   ArrayResize(close,size);
   ArrayCopy(close,_src,0,_src_start,size);
}
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("started");
   Pattern test_pattern;
   test_pattern.set_close(High,1,4);
   Print("-H",High[0],High[1],High[4],"-h",test_pattern.close[0],test_pattern.close[3]);      
   
}
//+------------------------------------------------------------------+
