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
input int      len=5;
input double   correlation_thresh=196;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
//---
   Comment("script started, ",len,"\n");
   
   string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);
   string filename="test.csv";
   int filehandle=FileOpen(filename,FILE_WRITE|FILE_CSV,',');
   if(filehandle<0)
     {
      Comment("file error 1");
      Print("Failed to open the file by the absolute path ");
      Print("Error code ",GetLastError());
      return;
     }
   Comment("file ok");
   FileWrite(filehandle,TimeCurrent(),Symbol(), EnumToString(ENUM_TIMEFRAMES(_Period)));

   double corrH,corrL;
   int i,j,thresh_hit_cnt;
   int history_size = Bars-len;
   history_size = 1000;
/*   for(i=0;i<history_size;i++)
   {
      thresh_hit_cnt=0;
      for(j=0;j<Bars-len;j++)
      {
         corrH = correlation_high(j,i,len);
         corrL = correlation_low(j,i,len);
         if(corrH+corrL>correlation_thresh)
            thresh_hit_cnt++;
      }
      Comment(i,"/",history_size);
      FileWrite(filehandle,High[i],thresh_hit_cnt);
   }
*/   i=258;
   for(j=0;j<Bars-len;j++)
   {
      corrH = correlation_high(j,i,len);
      corrL = correlation_low(j,i,len);
      if(corrH+corrL>correlation_thresh)
      {
         corrH = correlation_high(j-2,i-2,3);
         corrL = correlation_low(j-2,i-2,3);
         FileWrite(filehandle,High[i],j,corrH,corrL);
      }
   }



   FileClose(filehandle);
   Print("Done");
  
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
double min(double v1, double v2=1000, double v3=1000, double v4=1000, double v5=1000, double v6=1000)
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
