//+------------------------------------------------------------------+
//|                                               history_search.mq4 |
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input int      pattern_len=5;
input int      back_search_len=20000;
input int      history=40000;
input double   correlation_thresh=93;

/////////////////////////////////////////////////////////////////class
class Pattern
{
  public:
   Pattern();
   Pattern(const double &_src[],int _src_start, int _size);
   int size;
   double close[];
   double absolute_diffs;
   void set_data(const double &_src[],int _src_start, int _size);
   void log_to_file(int file_handle);
   int operator&(const Pattern &p2)const;
  private:
   double calculate_absolute_diff();
};
int Pattern::operator&(const Pattern &p2)const
{  //TODO
   return 1;
}
double Pattern::calculate_absolute_diff()
{  //TODO
   return 0;
}
void Pattern::log_to_file(int file_handle)
{  //TODO
}
Pattern::Pattern(const double &_src[],int _src_start,int _size)
{
   size = _size;
   ArrayResize(close,size);
   ArrayCopy(close,_src,0,_src_start,size);
   absolute_diffs = calculate_absolute_diff();
}
Pattern::Pattern(void)
{
}
void Pattern::set_data(const double &_src[],int _src_start, int _size)
{
   size = _size;
   ArrayResize(close,size);
   ArrayCopy(close,_src,0,_src_start,size);
   absolute_diffs = calculate_absolute_diff();
}
/////////////////////////////////////////////////////////////////class
class ExamineBar
{
  public:
   ExamineBar(int _barno, Pattern* _pattern);
   int barno;
   Pattern* pattern;
   
   int number_of_hits,c1_higher_cnt;
   double ave_c1;
   
   void log_to_file(int file_handle);

};
ExamineBar::ExamineBar(int _barno, Pattern* _pattern)
{
   barno=_barno; pattern=_pattern;
   number_of_hits=0;c1_higher_cnt=0;
   ave_c1=0;
}


void ExamineBar::log_to_file(int file_handle)
{  //TODO
}
/////////////////////////////////////////////////////////////////class
class Screen
{
  public:
   void clear_L1_comment();
   void add_L1_comment(string str); //add to residual comment
   void clear_L2_comment();
   void add_L2_comment(string str); //add to semi-volatile comment
   void clear_L3_comment();
   void add_L3_comment(string str); //add to volatile comment
  private:
   string L1_str,L2_str,L3_str;
   void show_it();
};
void Screen::clear_L1_comment(void)
{
   L1_str="";
   show_it();
}
void Screen::add_L1_comment(string str)
{
   L1_str+=str;
   show_it();
}
void Screen::clear_L2_comment(void)
{
   L2_str="";
   show_it();
}
void Screen::add_L2_comment(string str)
{
   L2_str+=str;
   show_it();
}
void Screen::clear_L3_comment(void)
{
   L3_str="";
   show_it();
}
void Screen::add_L3_comment(string str)
{
   L3_str+=str;
   show_it();
}
void Screen::show_it(void)
{
   Comment(L1_str,"\r\n",L2_str,"\r\n",L3_str,"\r\n");
}
/////////////////////////////////////////////////////////////////class
class MyMath
{
}
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
   int history_size=min(Bars,history);
   screen.add_L1_comment("CalculatingBars:"+IntegerToString(history_size)+"-");

   Pattern* p_pattern;
   ExamineBar* p_bar;
   for(int _ref=10;_ref<history_size-back_search_len;_ref++)
   {
      p_pattern=new Pattern(Close[],_ref,pattern_len);
      p_bar=new ExamineBar(_ref,p_pattern);
   }

}
//+------------------------------------------------------------------+
