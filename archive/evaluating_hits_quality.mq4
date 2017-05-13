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
input int referenced_pattern=3902;
input int evaluation_len=5;
//----macros
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
//---
   Comment("script started, ",len,"\n");
   
   string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);
   string filename="analysis.csv";
   int filehandle=FileOpen(filename,FILE_WRITE|FILE_CSV,',');
   if(filehandle<0)
     {
      Comment("file error 1");
      Print("Failed to open the file by the absolute path ");
      Print("Error code ",GetLastError());
      return;
     }
   Comment("file ok");
//   FileWrite(filehandle,TimeCurrent(),Symbol(), EnumToString(ENUM_TIMEFRAMES(_Period)));

   int history_size=min(history,Bars-len);
//   evaluating_each_matched_pattern(filehandle,referenced_pattern,history_size);
   evaluating_halflen_later(filehandle,referenced_pattern,history_size);

   FileClose(filehandle);
   Print("Done");
  
}


void evaluating_halflen_later(int _filehandle,int _ref,int _history_size)
{  //_ref is the last bar of the reference pattern. others are to be compared with this one
   int j;
   double corrH,corrL,corrS;
   for(j=0;j<_history_size;j++)
   {
      corrH = correlation_high(_ref,j,len);
      corrL = correlation_low(_ref,j,len);
      corrS = correlation_bar_size(_ref,j,len);
      if(corrH+corrL+corrS>correlation_thresh)
      {
         if(Close[_ref]<Close[_ref-len/2])   //uptrend hereafter
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
               
      }
   }
}

void evaluating_each_matched_pattern(int _filehandle,int _ref,int _history_size)
{  //_ref is the last bar of the reference pattern. others are to be compared with this one
   int j;
   double corrH,corrL,corrS;
   for(j=0;j<_history_size;j++)
   {
      corrH = correlation_high(_ref,j,len);
      corrL = correlation_low(_ref,j,len);
      corrS = correlation_bar_size(_ref,j,len);
      if(corrH+corrL+corrS>correlation_thresh)
      {
         corrH = correlation_high(_ref-evaluation_len+2,j-evaluation_len+2,evaluation_len);
         corrL = correlation_low(_ref-evaluation_len+2,j-evaluation_len+2,evaluation_len);
         corrS = correlation_bar_size(_ref-evaluation_len+2,j-evaluation_len+2,evaluation_len);
         FileWrite(_filehandle,High[_ref],j,corrH,corrL,corrS,corrH+corrL+corrS);
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
