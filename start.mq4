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
input int      Input1;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
//---
   Comment("script started, ",Input1,"\n");
   
   string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);
   string filename="test.csv";
   int filehandle=FileOpen(filename,FILE_WRITE|FILE_CSV,',');
   if(filehandle<0)
     {
           Comment("file error 1");
      Print("Failed to open the file by the absolute path ");
      Print("Error code ",GetLastError());
     }
   else
     {
           Comment("file ok");
      FileWrite(filehandle,TimeCurrent(),Symbol(), EnumToString(ENUM_TIMEFRAMES(_Period)));
      FileClose(filehandle);
      Print("FileOpen OK");
     }
  
}
//+------------------------------------------------------------------+
