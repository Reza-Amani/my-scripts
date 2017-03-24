//+------------------------------------------------------------------+
//|                                                       filing.mq4 |
//|                                                             Reza |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Reza"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property script_show_inputs
//--- input parameters
input int      pattern_len=10;
input int      back_search_len=2000;
input int      history=20000;
input double   correlation_thresh=3*95;
//----macros
//----globals
string logstr = "";
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
//---
   add_log("script started");
   int outfilehandle=FileOpen("./trydata/go_through_history_"+Symbol()+EnumToString(ENUM_TIMEFRAMES(_Period))+".csv",FILE_WRITE|FILE_CSV,',');
   if(outfilehandle<0)
   {
      Comment("file error");
      Print("Failed to open the file");
      Print("Error code ",GetLastError());
      return;
   }
   add_log("file ok");
   add_log("Bar: ");
   
   int history_size=min(Bars,history);
   int number_of_hits,no_of_b1_higher,no_of_b2_higher,no_of_b3_higher;
   double corrH,corrL,corrS;
   for(int _ref=10;_ref<history_size-back_search_len;_ref++)
   {
      number_of_hits = 0;
      no_of_b1_higher=0;
      no_of_b2_higher=0;
      no_of_b3_higher=0;
      for(int j=10;j<back_search_len-pattern_len;j++)
      {
         corrH = correlation_high(_ref,_ref+j,pattern_len);
         corrL = correlation_low(_ref,_ref+j,pattern_len);
         corrS = correlation_bar_size(_ref,_ref+j,pattern_len);
         if(corrH+corrL+corrS>correlation_thresh)
         {
            number_of_hits++;
            if(High[_ref+j-1]>High[_ref+j])
               no_of_b1_higher++;
            if(High[_ref+j-2]>High[_ref+j])
               no_of_b2_higher++;
            if(High[_ref+j-3]>High[_ref+j])
               no_of_b3_higher++;

/*            if(Close[_ref]<Close[_ref-len/2])   //uptrend hereafter
            {
               if(Close[j]<Close[j-len/2])
                  FileWrite(_filehandle,High[_ref],j,1);
               else
                  FileWrite(_filehandle,High[_ref],j,-1);
            }
            else
            {  //downtrend hereafter
               if(Close[j]>Close[j-len/2])
                  FileWrite(_filehandle,High[_ref],j,1);
               else
                  FileWrite(_filehandle,High[_ref],j,-1);
            }
*/                  
         }
      }
      if(number_of_hits>10)
      {
         int b1_higher=1,b2_higher=1,b3_higher=1;
         if(High[_ref-1]<High[_ref])
            b1_higher=-1;
         if(High[_ref-2]<High[_ref])
            b2_higher=-1;
         if(High[_ref-3]<High[_ref])
            b3_higher=-1;
         FileWrite(outfilehandle,_ref,High[_ref],number_of_hits,no_of_b1_higher,b1_higher,no_of_b2_higher,b2_higher,no_of_b3_higher,b3_higher);
      }
      show_log_plus(_ref);
   }
   FileClose(outfilehandle);
   Print("Done");
  
}

void add_log(string str)
{
   logstr+=str;
   Comment(logstr);
}
void show_log_plus(string str)
{
   Comment(logstr,str);
}
void show_log_plus(int i)
{
   Comment(logstr,i);
}
void reset_log()
{
   logstr="";
}
/*void evaluating_later_bar(int &hits, int &good_hits, int _ref, int _late_bar, int _history_size)
{  //_ref is the last bar of the reference pattern. others are to be compared with this one
   int j;
   hits=0;
   good_hits=0;
   double corrH,corrL,corrS;
   for(j=0;j<_history_size;j++)
   {
      corrH = correlation_high(_ref,j,len);
      corrL = correlation_low(_ref,j,len);
      corrS = correlation_bar_size(_ref,j,len);
      if(corrH+corrL+corrS>correlation_thresh)
      {
         hits++;
         if(Close[_ref]<Close[_ref-_late_bar])   //uptrend hereafter
         {
            if(Close[j]<Close[j-_late_bar])
               good_hits++;
            else
               good_hits--;
         }
         else
         {  //downtrend hereafter
            if(Close[j]>Close[j-_late_bar])
               good_hits++;
            else
               good_hits++;
         }
               
      }
   }
}
*/
double correlation_bar_size(int pattern1, int pattern2, int _len)
{  //pattern1&2 are the end indexes of 2 arrays
   //sigma(x-avgx)(y-avgy)/sqrt(sigma(x-avgx)2*sigma(y-avgy)2)
   double x,y;
   double avg1=0,avg2=0;
   int i;
   for(i=0; i<_len; i++)
   {
      x = High[i+pattern1]-Low[i+pattern1];
      y = High[i+pattern2]-Low[i+pattern2];
      avg1 += x;
      avg2 += y;
   }
   avg1 /= _len;
   avg2 /= _len;
   
   double x_xby_yb=0,x_xb2=0,y_yb2=0;
   for(i=0; i<_len; i++)
   {
      x = High[i+pattern1]-Low[i+pattern1];
      y = High[i+pattern2]-Low[i+pattern2];
      x_xby_yb += (x-avg1)*(y-avg2);
      x_xb2 += (x-avg1)*(x-avg1);
      y_yb2 += (y-avg2)*(y-avg2);
   }
   
   if(x_xb2 * x_xb2 == 0)
      return 0;
      
   return 100*x_xby_yb/MathSqrt(x_xb2 * y_yb2);
      
}
double correlation_high(int pattern1, int pattern2, int _len)
{  //pattern1&2 are the end indexes of 2 arrays
   //sigma(x-avgx)(y-avgy)/sqrt(sigma(x-avgx)2*sigma(y-avgy)2)
   double x,y;
   double avg1=0,avg2=0;
   int i;
   for(i=0; i<_len; i++)
   {
      x = High[i+pattern1];
      y = High[i+pattern2];
      avg1 += High[i+pattern1];
      avg2 += High[i+pattern2];
   }
   avg1 /= _len;
   avg2 /= _len;
   
   double x_xby_yb=0,x_xb2=0,y_yb2=0;
   for(i=0; i<_len; i++)
   {
      x = High[i+pattern1];
      y = High[i+pattern2];
      x_xby_yb += (x-avg1)*(y-avg2);
      x_xb2 += (x-avg1)*(x-avg1);
      y_yb2 += (y-avg2)*(y-avg2);
   }
   
   if(x_xb2 * x_xb2 == 0)
      return 0;
      
   return 100*x_xby_yb/MathSqrt(x_xb2 * y_yb2);
      
}
double correlation_low(int pattern1, int pattern2, int _len)
{  //pattern1&2 are the end indexes of 2 arrays
   //sigma(x-avgx)(y-avgy)/sqrt(sigma(x-avgx)2*sigma(y-avgy)2)
   double x,y;
   double avg1=0,avg2=0;
   int i;
   for(i=0; i<_len; i++)
   {
      x = Low[i+pattern1];
      y = Low[i+pattern2];
      avg1 += Low[i+pattern1];
      avg2 += Low[i+pattern2];
   }
   avg1 /= _len;
   avg2 /= _len;
   
   double x_xby_yb=0,x_xb2=0,y_yb2=0;
   for(i=0; i<_len; i++)
   {
      x = Low[i+pattern1];
      y = Low[i+pattern2];
      x_xby_yb += (x-avg1)*(y-avg2);
      x_xb2 += (x-avg1)*(x-avg1);
      y_yb2 += (y-avg2)*(y-avg2);
   }
   
   if(x_xb2 * x_xb2 == 0)
      return 0;
      
   return 100*x_xby_yb/MathSqrt(x_xb2 * y_yb2);
      
}
//general funcs
//+------------------------------------------------------------------+
double max(double v1, double v2=-1, double v3=-1, double v4=-1, double v5=-1, double v6=-1)
{
   double result = v1;
   if(v2>result)  result=v2;
   if(v3>result)  result=v3;
   if(v4>result)  result=v4;
   if(v5>result)  result=v5;
   if(v6>result)  result=v6;
   return result;
}
double min(double v1, double v2=65535, double v3=65535, double v4=65535, double v5=65535, double v6=65535)
{
   double result = v1;
   if(v2<result)  result=v2;
   if(v3<result)  result=v3;
   if(v4<result)  result=v4;
   if(v5<result)  result=v5;
   if(v6<result)  result=v6;
   return result;
}

/*   if(iClose("EURUSD", PERIOD_M5, 0) > iHigh("EURUSD", PERIOD_M5, 1) &&
      iClose("EURCHF", PERIOD_M5, 0) > iHigh("EURCHF", PERIOD_M5, 1) &&
      iClose("EURAUD", PERIOD_M5, 0) > iHigh("EURAUD", PERIOD_M5, 1) &&
      iClose("EURJPY", PERIOD_M5, 0) > iHigh("EURJPY", PERIOD_M5, 1)   ){
      Print("EUR is strong!");
*/
//+------------------------------------------------------------------+
