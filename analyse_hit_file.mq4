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
input int      len=10;
input int history=20000;
input double   correlation_thresh=285;
//input int referenced_pattern=3902;
//input int evaluation_len=5;
//----macros
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
//---
   Comment("script started, ",len,"\n");
   int ref,i=0,hit_no1,good_hits1,hit_no2,good_hits2,hit_no3,good_hits3;
   int infilehandle=FileOpen("hit_count_in.csv",FILE_READ|FILE_CSV,',');
   int outfilehandle=FileOpen("hit_analyse.csv",FILE_WRITE|FILE_CSV,',');
   if((infilehandle<0) || (outfilehandle<0))
     {
      Comment("file error 1");
      Print("Failed to open the file by the absolute path ");
      Print("Error code ",GetLastError());
      return;
     }
   Comment("file ok");
   while(!FileIsEnding(infilehandle))
   {
      i++;
      Comment(i);
      ref=FileReadString(infilehandle);
      evaluating_later_bar(hit_no1,good_hits1,ref,1,history);
      evaluating_later_bar(hit_no2,good_hits2,ref,2,history);
      evaluating_later_bar(hit_no3,good_hits3,ref,3,history);
      FileWrite(outfilehandle,High[ref],ref,1111,hit_no1,good_hits1,hit_no2,good_hits2,hit_no3,good_hits3);
   }
   FileClose(infilehandle);
   FileClose(outfilehandle);
   Print("Done");
  
}


void evaluating_later_bar(int &hits, int &good_hits, int _ref, int _late_bar, int _history_size)
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
