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
#define _min_hit 5
//----globals
double alpha_H1[100],alpha_L1[100];
string logstr = "";
int no_of_hits_p0=0;
int no_of_hits_pthresh=0;
int no_of_output_lines=0;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
//---
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
   int number_of_hits,no_of_b1_higher,no_of_b2_higher;
   double corrH,corrL,corrS;
   double aH,aL;
   for(int _ref=10;_ref<history_size-back_search_len;_ref++)
   {
      number_of_hits = 0;
      no_of_b1_higher=0;
      no_of_b2_higher=0;
      for(int j=10;j<back_search_len-pattern_len;j++)
      {
         corrH = correlation_high(_ref,_ref+j,pattern_len);
         corrL = correlation_low(_ref,_ref+j,pattern_len);
         corrS = correlation_bar_size(_ref,_ref+j,pattern_len);
         if(corrH+corrL+corrS>correlation_thresh)
         {
            aH=alpha(High[_ref+j], Low[_ref+j], High[_ref+j-1]);
            aL=alpha(High[_ref+j], Low[_ref+j], Low[_ref+j-1]);
            aH=min(aH,3.0);
            aL=max(aL,-2);
            alpha_H1[number_of_hits] = aH;
            alpha_L1[number_of_hits] = aL;

            if(High[_ref+j-1]>High[_ref+j])
               no_of_b1_higher++;
            if(High[_ref+j-2]>High[_ref+j])
               no_of_b2_higher++;

//            FileWrite(outfilehandle,High[_ref],High[_ref+j], Low[_ref+j], High[_ref+j-1],aH, Low[_ref+j-1],aL);
            number_of_hits++;
            if(number_of_hits>=100)
               break;
         }
      }  //end of search for sisters
      
      if(number_of_hits>_min_hit)
      {
         int b1_higher=1,b2_higher=1;
         if(High[_ref-1]<High[_ref])
            b1_higher=-1;
         if(High[_ref-2]<High[_ref])
            b2_higher=-1;
         
         double ave_alphaH = array_ave(alpha_H1,number_of_hits);
         double ave_alphaL = array_ave(alpha_L1,number_of_hits);
         
         if( (no_of_b1_higher/number_of_hits <0.3)||(no_of_b1_higher/number_of_hits >0.7)
            ||(no_of_b2_higher/number_of_hits <0.3)||(no_of_b2_higher/number_of_hits >0.7))
         {
            FileWrite(outfilehandle,_ref,High[_ref],number_of_hits,no_of_b1_higher,b1_higher,no_of_b2_higher,b2_higher, 100*no_of_b1_higher/number_of_hits,ave_alphaH,ave_alphaL);
            no_of_output_lines++;
         }  //end of logging/trading selected patterns
      }  //end of sisters process
      if(number_of_hits>0)
         no_of_hits_p0++;
      if(number_of_hits>_min_hit)
         no_of_hits_pthresh++;
      show_log_plus("Bar: ",_ref," /",history_size-back_search_len,"\r\nno_of_hits_p0 ",no_of_hits_p0,"\r\nno_of_hits_p10 ",no_of_hits_pthresh,"\r\nno_of_output_lines ",no_of_output_lines);
   }
   FileClose(outfilehandle);
   Print("Done");
  
}

double array_ave(double &array[], int size)
{
   double result=0;
   if(size==0)
      return 0;
   for(int i=0; i<size; i++)
      result+=array[i];
   return result/size;
}
double alpha(double refH, double refL, double in)
{
   if(refH==refL)
      return 99;
   else
      return (in-refL)/(refH-refL);
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
void show_log_plus(string s1,int i1,string s2,int i2,string s3,int i3,string s4,int i4,string s5,int i5)
{
   Comment(logstr,s1,i1,s2,i2,s3,i3,s4,i4,s5,i5);
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
   
   if(x_xb2 * y_yb2 == 0)
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
   
   if(x_xb2 * y_yb2 == 0)
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
   
   if(x_xb2 * y_yb2 == 0)
      return 0;
      
   return 100*x_xby_yb/MathSqrt(x_xb2 * y_yb2);
      
}
//general funcs
//+------------------------------------------------------------------+
double max(double v1, double v2=-DBL_MAX, double v3=-DBL_MAX, double v4=-DBL_MAX, double v5=-DBL_MAX, double v6=-DBL_MAX)
{
   double result = v1;
   if(v2>result)  result=v2;
   if(v3>result)  result=v3;
   if(v4>result)  result=v4;
   if(v5>result)  result=v5;
   if(v6>result)  result=v6;
   return result;
}
double min(double v1, double v2=DBL_MAX, double v3=DBL_MAX, double v4=DBL_MAX, double v5=DBL_MAX, double v6=DBL_MAX)
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
