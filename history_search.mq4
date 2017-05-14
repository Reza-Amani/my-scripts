//+------------------------------------------------------------------+
//|                                               history_search.mq4 |
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
/////////////////////////////////////////////////////////////////class
class Pattern
{
  public:
   int size;
   double close[];
   double absolute_diffs;
   void set_close(const double &_src[],int _src_start, int _size);
   void log_to_file(int file_handle);
  private:
   double calculate_absolute_diff();
};
double Pattern::calculate_absolute_diff()
{  //TODO
}
void Pattern::log_to_file(int file_handle)
{  //TODO
}
void Pattern::set_close(const double &_src[],int _src_start, int _size)
{
   size = _size;
   ArrayResize(close,size);
   ArrayCopy(close,_src,0,_src_start,size);
   absolute_diffs = calculate_absolute_diff();
}
/////////////////////////////////////////////////////////////////class
class examine_bar
{
  public:
   int barno;
   Pattern pattern;
   int number_of_hits,c1_higher_cnt;
   double ave_c1;
   
   void log_to_file(int file_handle);

}
void examine_bar::log_to_file(int file_handle)
{  //TODO
}
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   add_log("script started");
   int outfilehandle=FileOpen("./trydata/go_through_history_"+Symbol()+EnumToString(ENUM_TIMEFRAMES(_Period))+"_"+IntegerToString(pattern_len)+"_"+IntegerToString(correlation_thresh)+".csv",FILE_WRITE|FILE_CSV,',');
   if(outfilehandle<0)
     {
      Comment("file error");
      Print("Failed to open the file");
      Print("Error code ",GetLastError());
      return;
     }
   add_log("file ok\r\n");
   int history_size=min(Bars,history);


   for(int _ref=10;_ref<history_size-back_search_len;_ref++)
   {
   }
}
//+------------------------------------------------------------------+
