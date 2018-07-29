//+------------------------------------------------------------------+
//|                                                CFractalPoint.mqh |
//|                                           Copyright 2016, denkir |
//|                           https://login.mql5.com/ru/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, denkir"
#property link      "https://login.mql5.com/ru/users/denkir"
//--- include
#include <ChartObjects\ChartObjectsChannels.mqh>
#include <Arrays\ArrayObj.mqh>
#include  "CisNewBar.mqh"
//+------------------------------------------------------------------+
//| Extremum type                                                    |
//+------------------------------------------------------------------+
enum ENUM_EXTREMUM_TYPE
    {
     EXTREMUM_TYPE_MIN=0, // minimum
     EXTREMUM_TYPE_MAX=1, // maximum
    };
//+------------------------------------------------------------------+
//| Type of the extremum points' set                                 |
//+------------------------------------------------------------------+
enum ENUM_SET_TYPE
    {
     SET_TYPE_NONE=0,     // not set
     SET_TYPE_MINMAX=1,   // min-max-min
     SET_TYPE_MAXMIN=2,   // max-min-max                       
    };
//+------------------------------------------------------------------+
//| Type of the relevant point                                       |
//+------------------------------------------------------------------+
enum ENUM_RELEVANT_EXTREMUM
    {
     RELEVANT_EXTREMUM_PREV=0, // previous
     RELEVANT_EXTREMUM_LAST=1, // last
    };
//+------------------------------------------------------------------+
//| Basic data of the fractal                                        |
//+------------------------------------------------------------------+
struct SFracData
{
    double            value; // value
    int               index; // bar index
    //--- constructor
    void SFracData::SFracData(void)
    {
        value=EMPTY_VALUE;
        index=WRONG_VALUE;
    }
};
//+------------------------------------------------------------------+
//| Class of the fractal point                                       |
//+------------------------------------------------------------------+
class CFractalPoint : public CObject
{
    //--- === Data members === --- 
private:
    datetime          m_date;           // date and time
    double            m_value;          // value
    ENUM_EXTREMUM_TYPE m_extreme_type;  // extremum type
    int               m_idx;            // index (from 0 to 2)

    //--- === Methods === --- 
public:
    //--- constructor/destructor
    void              CFractalPoint(void);
    void              CFractalPoint(datetime _date,double _value,
                                    ENUM_EXTREMUM_TYPE _extreme_type,int _idx);
    void             ~CFractalPoint(void){};
    //--- get-methods
    datetime          Date(void) const {return m_date;};
    double            Value(void) const {return m_value;};
    ENUM_EXTREMUM_TYPE FractalType(void) const {return m_extreme_type;};
    int               Index(void) const {return m_idx;};
    //--- set-methods
    void              Date(const datetime _date) {m_date=_date;};
    void              Value(const double _value) {m_value=_value;};
    void              FractalType(const ENUM_EXTREMUM_TYPE extreme_type) {m_extreme_type=extreme_type;};
    void              Index(const int _bar_idx){m_idx=_bar_idx;};
    //--- service
    void              Copy(const CFractalPoint &_source_frac);
    void              Print(void);
};
//+------------------------------------------------------------------+
//| Constructor by default                                           |
//+------------------------------------------------------------------+
void CFractalPoint::CFractalPoint(void)
{
    m_date=0;
    m_value=0.;
    m_extreme_type=-1;
    m_idx=WRONG_VALUE;
};
//+------------------------------------------------------------------+
//| Constructor with an initialization list                          |
//+------------------------------------------------------------------+
void CFractalPoint::CFractalPoint(datetime _date,double _value,
                                  ENUM_EXTREMUM_TYPE _extreme_type,int _idx):
    m_date(_date),
    m_value(_value),
    m_extreme_type(_extreme_type),
    m_idx(_idx){};
//+------------------------------------------------------------------+
//| Copy                                                             |
//+------------------------------------------------------------------+
void CFractalPoint::Copy(const CFractalPoint &_source_frac)
{
    m_date=_source_frac.m_date;
    m_value=_source_frac.m_value;
    m_extreme_type=_source_frac.m_extreme_type;
    m_idx=_source_frac.m_idx;
};
//+------------------------------------------------------------------+
//| Print                                                            |
//+------------------------------------------------------------------+
void CFractalPoint::Print(void)
{
    Print("\n---=== Fractal point data ===---");
    Print("Дата: ",TimeToString(m_date));
    Print("Цена: ",DoubleToString(m_value,_Digits));
    Print("Тип: ",EnumToString(m_extreme_type));
    Print("Индекс: ",IntegerToString(m_idx));
}
//+------------------------------------------------------------------+
//| Class of the fractal points' set                                 |
//+------------------------------------------------------------------+
class CFractalSet : protected CArrayObj
{
    //--- === Data members === --- 
private:
    ENUM_SET_TYPE     m_set_type;           // type of the points' set
    int               m_fractal_num;        // fixed number of points
    int               m_fractals_ha;        // handle of the fractal indicator 
    CisNewBar         m_new_bar;            // object of the new bar
    CArrayObj         m_channels_arr;       // object of the indicator array
    color             m_channel_colors[4];  // colors of channels
    bool              m_is_init;            // initialization flag
    //--- channel settings of
    int               m_prev_frac_num;      // previous fractals
    int               m_bars_beside;        // bars to the left/right side of the fractal
    int               m_bars_between;       // number of intermediate bars  
    bool              m_to_delete_prev;     // delete previous channels?
    bool              m_is_alt;             // alternative indicator of fractals?
    ENUM_RELEVANT_EXTREMUM m_rel_frac;      // relevant point
    bool              m_is_array;           // draw arrow?
    int               m_line_wid;           // line width
    bool              m_to_log;             // keep the log?

    //--- === Methods === --- 
public:
    //--- constructor/destructor
    void              CFractalSet(void);
    void              CFractalSet(const CFractalSet &_src_frac_set);
    void             ~CFractalSet(void){};
    //---
    void              operator=(const CFractalSet &_src_frac_set);
    //--- handlers
    bool              Init(
                           int _prev_frac_num,
                           int _bars_beside,
                           int _bars_between=0,
                           bool _to_delete_prev=true,
                           bool _is_alt=false,
                           ENUM_RELEVANT_EXTREMUM _rel_frac=RELEVANT_EXTREMUM_PREV,
                           bool _is_arr=false,
                           int _line_wid=3,
                           bool _to_log=true
                           );
    void              Deinit(void);
    void              Process(void);
    //--- service
    CChartObjectChannel *GetChannelByIdx(const int _ch_idx);
    int               ChannelsTotal(void) const {return m_channels_arr.Total();};

private:
    int               AddFrac(const int _buff_len);
    int               CheckSet(const SFracData &_fractals[]);
    ENUM_SET_TYPE     GetTypeOfSet(void) const {return m_set_type;};
    void              SetTypeOfSet(const ENUM_SET_TYPE _set_type) {m_set_type=_set_type;};
    bool              PlotChannel(void);
    bool              Crop(const uint _num_to_crop);
    void              BubbleSort(void);
};
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void CFractalSet::CFractalSet(void)
{
    m_set_type=WRONG_VALUE;
    m_fractal_num=3;
    m_prev_frac_num=0;
    //--- цвета
    m_channel_colors[0]=clrBlack;
    m_channel_colors[1]=clrGreen;
    m_channel_colors[2]=clrRed;
    m_channel_colors[3]=clrBlue;
    m_is_init=false;
};
//+------------------------------------------------------------------+
//| Constructor for copying                                          |
//+------------------------------------------------------------------+
void CFractalSet::CFractalSet(const CFractalSet &_src_frac_set)
{
    this.m_set_type=_src_frac_set.m_set_type;
    this.m_fractal_num=_src_frac_set.m_fractal_num;
    this.m_fractals_ha=_src_frac_set.m_fractals_ha;
    this.m_new_bar=_src_frac_set.m_new_bar;
    //--- copy arrays
    if(!this.m_channels_arr.AssignArray(GetPointer(_src_frac_set.m_channels_arr)))
    {
        PrintFormat(__FUNCTION__+": error of copy constructor!");
        return;
    }
    else
    {
        for(int idx=0;idx<ArraySize(m_channel_colors);idx++)
            m_channel_colors[idx]=_src_frac_set.m_channel_colors[idx];
    }
    //---
    this.m_prev_frac_num=_src_frac_set.m_prev_frac_num;
    this.m_bars_beside=_src_frac_set.m_bars_beside;
    this.m_bars_between=_src_frac_set.m_bars_between;
    this.m_to_delete_prev=_src_frac_set.m_to_delete_prev;
    this.m_is_alt=_src_frac_set.m_is_alt;
    this.m_rel_frac=_src_frac_set.m_rel_frac;
    this.m_is_array=_src_frac_set.m_is_array;
    this.m_line_wid=_src_frac_set.m_line_wid;
    this.m_to_log=_src_frac_set.m_to_log;
}
//+------------------------------------------------------------------+
//| Assignment operator                                              |
//+------------------------------------------------------------------+
void CFractalSet::operator=(const CFractalSet &_src_frac_set)
{
    this.m_set_type=_src_frac_set.m_set_type;
    this.m_fractal_num=_src_frac_set.m_fractal_num;
    this.m_fractals_ha=_src_frac_set.m_fractals_ha;
    this.m_new_bar=_src_frac_set.m_new_bar;
    if(!this.m_channels_arr.FreeMode())
        this.m_channels_arr.FreeMode(true);
    //--- copy arrays
    if(!this.m_channels_arr.AssignArray(GetPointer(_src_frac_set.m_channels_arr)))
    {
        PrintFormat(__FUNCTION__+": error of assignment operator!");
        return;
    }
    else
    {
        for(int idx=0;idx<ArraySize(m_channel_colors);idx++)
            m_channel_colors[idx]=_src_frac_set.m_channel_colors[idx];
    }
    this.m_prev_frac_num=_src_frac_set.m_prev_frac_num;
    this.m_bars_beside=_src_frac_set.m_bars_beside;
    this.m_bars_between=_src_frac_set.m_bars_between;
    this.m_to_delete_prev=_src_frac_set.m_to_delete_prev;
    this.m_is_alt=_src_frac_set.m_is_alt;
    this.m_rel_frac=_src_frac_set.m_rel_frac;
    this.m_is_array=_src_frac_set.m_is_array;
    this.m_line_wid=_src_frac_set.m_line_wid;
    this.m_to_log=_src_frac_set.m_to_log;
}
//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
bool CFractalSet::Init(
                       int _prev_frac_num,
                       int _bars_beside,
                       int _bars_between=0,
                       bool _to_delete_prev=true,
                       bool _is_alt=false,
                       ENUM_RELEVANT_EXTREMUM _rel_frac=RELEVANT_EXTREMUM_PREV,
                       bool _is_arr=false,
                       int _line_wid=3,
                       bool _to_log=true
                       )
{
    //--- check the number of previous fractal points
    if((_prev_frac_num<0) || (_prev_frac_num>3))
    {
        Print("The number of previous fractal points is set wrong!");
        return false;
    }
    //--- check the number of bars from the fractal
    if(_bars_beside<1)
    {
        Print("The number of bars on the left and right sides of the fractal is set wrong!");
        return false;
    }

    //--- memory management
    if(!this.FreeMode())
        this.FreeMode(true);
    if(!m_channels_arr.FreeMode())
        m_channels_arr.FreeMode(true);
    //--- choose the fractal indicator
    m_is_alt=_is_alt;
    if(m_is_alt)
        m_fractals_ha=iCustom(_Symbol,_Period,"X-bars_Fractals",_bars_beside,_bars_beside);
    else
        m_fractals_ha=iFractals(_Symbol,_Period);
    //---
    if(m_fractals_ha==INVALID_HANDLE)
    {
        Print("Error in creating the handle of the fractal indicator!");
        return false;
    }
    //--- members-data
    m_prev_frac_num=_prev_frac_num;
    m_bars_between=_bars_between;
    m_rel_frac=_rel_frac;
    m_is_array=_is_arr;
    m_to_delete_prev=_to_delete_prev;
    m_line_wid=_line_wid;
    m_bars_beside=_bars_beside;
    m_to_log=_to_log;
    //--- if previous fractal points are added
    if(m_prev_frac_num>0)
    {
        //--- 1) Loading history [start]
        bool synchronized=false;
        //--- loop counter
        int attempts=0;
        //--- 10 attempts to wait for synchronization
        while(attempts<10)
        {
            if(SeriesInfoInteger(_Symbol,0,SERIES_SYNCHRONIZED))
            {
                synchronized=true;
                //--- synchronization established, exit
                break;
            }
            //--- increase counter
            attempts++;
            //--- wait for 50 milliseconds until the next iteration
            Sleep(50);
        }
        //---
        if(!synchronized)
        {
            Print("Failed to obtain the number of bars on ",_Symbol);
            return false;
        }
        int curr_bars_num=Bars(_Symbol,_Period);
        if(curr_bars_num>0)
        {
            PrintFormat("Number of bars in the terminal history based on symbol-period at the current moment: %d",
                        curr_bars_num);
        }
        //--- 1) Loading history [end]

        //--- 2) Calculated data for the requested indicator [start]
        double Ups[];
        int i,copied=CopyBuffer(m_fractals_ha,0,0,curr_bars_num,Ups);
        if(copied<=0)
        {
            Sleep(50);
            for(i=0;i<100;i++)
            {
                if(BarsCalculated(m_fractals_ha)>0)
                    break;
                Sleep(50);
            }
            copied=CopyBuffer(m_fractals_ha,0,0,curr_bars_num,Ups);
            if(copied<=0)
            {
                Print("Failed to copy upper fractals. Error = ",GetLastError(),
                      "i=",i,"    copied= ",copied);
                return false;
            }
            else
            {
                if(m_to_log)
                    Print("Succeeded to copy upper fractals.",
                          " i = ",i,"    copied = ",copied);
            }
        }
        else
        {
            if(m_to_log)
                Print("Succeeded to copy upper fractals. ArraySize = ",ArraySize(Ups));
        }
        //--- 2) Calculated data for the requested indicator [end]

        //--- 3) Adding fractal points [start]
        int prev_fracs_num=AddFrac(curr_bars_num-1);
        if(m_to_log)
            if(prev_fracs_num>0)
                PrintFormat("Previous fractals added: %d",prev_fracs_num);
        //--- if the channel can be displayed
        if(prev_fracs_num==3)
            if(!this.PlotChannel())
                Print("Failed to display the channel!");
        //--- 3) Adding fractal points [end]
    }
    m_is_init=true;
    //---
    return true;
}
//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void CFractalSet::Deinit(void)
{
    //--- if testing mode - don't remove channels
    if(MQLInfoInteger(MQL_TESTER))
    {
        //--- memory management
        this.FreeMode(false);
        m_channels_arr.FreeMode(false);
    }
}
//+------------------------------------------------------------------+
//| Processing                                                       |
//+------------------------------------------------------------------+
void CFractalSet::Process(void)
{
    //--- obtain the time of opening the zero bar
    datetime times[1];
    if(CopyTime(_Symbol,_Period,0,1,times)!=1)
        return;
    //---
    bool is_new_bar=m_new_bar.isNewBar(times[0]);
    //--- checking for a new bar
    if(is_new_bar)
    {
        //--- Extend the current channel until the last bar
        //--- find the current channel
        int ch_num=m_channels_arr.Total();
        if(ch_num>0)
        {
            CChartObjectChannel  *ptr_curr_ch=m_channels_arr.At(ch_num-1);
            if(CheckPointer(ptr_curr_ch)==POINTER_DYNAMIC)
            {
                datetime time1,time2;
                time1=(datetime)ptr_curr_ch.GetInteger(OBJPROP_TIME,0);
                time2=(datetime)ptr_curr_ch.GetInteger(OBJPROP_TIME,1);
                //--- bars between first and second points
                datetime bars_dates[];
                int bars_between=CopyTime(_Symbol,_Period,
                                          time1,time2,bars_dates
                                          );
                if(bars_between>1)
                {
                    bars_between-=1;
                    double price1=ptr_curr_ch.GetDouble(OBJPROP_PRICE,0);
                    double price2=ptr_curr_ch.GetDouble(OBJPROP_PRICE,1);
                    //--- common differential
                    double price_differential=MathAbs(price1-price2);
                    //--- price speed (price change on the first bar)
                    double price_speed=price_differential/bars_between;
                    //--- bars between the second point and the zero bar
                    bars_between=CopyTime(_Symbol,_Period,
                                          time2,times[0],bars_dates
                                          );
                    if(bars_between>1)
                    {
                        bars_between-=1;
                        //--- if the channel is ascending
                        if(price1<price2)
                            price2+=(bars_between*price_speed);
                        //--- or if the channel is descending
                        else
                            price2-=(bars_between*price_speed);
                        //--- new coordinate of the second point
                        ptr_curr_ch.SetPoint(1,times[0],price2);
                        //--- redrawing the chart
                        ChartRedraw();
                    }
                }
            }
        }

        //--- checking for a new extremum
        int frac_num=AddFrac(1);
        //--- note in the log
        string code_str=NULL;
        if(frac_num<0)
        {
            code_str="\nservice error";
        }
        else if(frac_num>0)
        {
            code_str=StringFormat("\npoints in the set: %d",frac_num);
            if(frac_num==m_fractal_num)
            {
                //--- display the channel
                if(!this.PlotChannel())
                    Print("Failed to display the channel!");
                code_str+="\nNew set of points received.";
            }
        }
        //---
        if(m_to_log)
            if(code_str!=NULL)
                Print("\n--==Testing results==--"+code_str);
    }
}
//+------------------------------------------------------------------+
//| Channel indicator based on index                                 |
//+------------------------------------------------------------------+
CChartObjectChannel *CFractalSet::GetChannelByIdx(const int _ch_idx)
{
    CChartObjectChannel *ptr_curr_ch=NULL;
    //---
    if(m_channels_arr.Total()>0)
    {
        ptr_curr_ch=this.m_channels_arr.At(_ch_idx);
        if(ptr_curr_ch==NULL)
            PrintFormat("Error of obtaining the element based on the index %d",_ch_idx);
    }
    //---
    return ptr_curr_ch;
}
//+------------------------------------------------------------------+
//| Adding the fractal point                                         |
//+------------------------------------------------------------------+
int CFractalSet::AddFrac(const int _buff_len)
{
    int fractal_num=0;
    //--- checking for a new extremum
    double up_vals[];
    double down_vals[];
    int bars_num=_buff_len-m_bars_beside;
    if(bars_num<0)
        bars_num=1;

    //--- upper fractal
    if(CopyBuffer(m_fractals_ha,0,m_bars_beside,bars_num,up_vals)<0)
    {
        Print("Error of obtaining the upper fractal value.");
        return -1;
    }
    //--- lower fractal
    if(CopyBuffer(m_fractals_ha,1,m_bars_beside,bars_num,down_vals)<0)
    {
        Print("Error of obtaining the lower fractal value.");
        return -1;
    }
    //--- as time series
    ArraySetAsSeries(up_vals,true);
    ArraySetAsSeries(down_vals,true);
    //--- check that fractals are present
    for(int idx=0;idx<_buff_len;idx++)
    {
        SFracData fracs[2]; //  fractal's data array: [0]-lower, [1]-upper
        bool is_new_down=false,is_new_up=false;
        if((down_vals[idx]<DBL_MAX) && (down_vals[idx]>0.))
        {
            is_new_down=true;
            fracs[0].index=m_bars_beside+idx;
            if(m_to_log)
                PrintFormat("\nlower fractal: %."+IntegerToString(_Digits)+"f",down_vals[idx]);
        }
        if((up_vals[idx]<DBL_MAX) && (up_vals[idx]>0.))
        {
            is_new_up=true;
            fracs[1].index=m_bars_beside+idx;
            if(m_to_log)
                PrintFormat("\nUpper fractal: %."+IntegerToString(_Digits)+"f",up_vals[idx]);
        }
        //--- if there is a new fractal
        if(is_new_down || is_new_up)
        {
            double frac_vals[2];// fractal array: [0]-lower, [1]-upper
            fracs[0].value=down_vals[idx];
            fracs[1].value=up_vals[idx];
            //--- check the set's condition
            fractal_num=this.CheckSet(fracs);
            if(fractal_num==m_prev_frac_num)
                break;
        }
    }
    //--- if there was no initialization
    if(!m_is_init)
    {
        this.BubbleSort();
        //--- sorting
        if(!this.IsSorted(1))
        {
            Print("Error of sorting fractal points.");
            return -1;
        }
    }
    //---
    return fractal_num;
}
//+------------------------------------------------------------------+
//| Determine the type                                               |
//+------------------------------------------------------------------+
int CFractalSet::CheckSet(const SFracData &_fractals[])
{
    //---  to obtain historical data on the relevant bar
    MqlRates rates[];
    for(int idx=0;idx<ArraySize(_fractals);idx++)
        if(_fractals[idx].index>WRONG_VALUE)
        {
            if(CopyRates(_Symbol,_Period,_fractals[idx].index,1,rates)!=1)
            {
                Print("Error in obtaining historical data on the relevant bar.");
                return -1;
            }
            break;
        }
    //--- Adding fractal points to the time set
    CArrayObj temp_add_set;
    for(int idx=0;idx<ArraySize(_fractals);idx++)
        if((_fractals[idx].value<DBL_MAX) && (_fractals[idx].value>0.))
        {
            //--- to create the fractal point's object
            CFractalPoint *ptr_new_fractal=new CFractalPoint;
            if(CheckPointer(ptr_new_fractal)!=POINTER_DYNAMIC)
                return -1;
            //---
            ENUM_EXTREMUM_TYPE new_fractal_type=WRONG_VALUE;
            //--- To gather data for the fractal's point
            //--- 1) time
            ptr_new_fractal.Date(rates[0].time);
            //--- 2) price
            if(idx==1)
            {
                new_fractal_type=EXTREMUM_TYPE_MAX;
                ptr_new_fractal.Value(rates[0].high);
            }
            else
            {
                new_fractal_type=EXTREMUM_TYPE_MIN;
                ptr_new_fractal.Value(rates[0].low);
            }
            //--- 3) type
            ptr_new_fractal.FractalType(new_fractal_type);

            //--- adding to the set
            if(!temp_add_set.Add(ptr_new_fractal))
            {
                Print("Error of adding the fractal point!");
                delete ptr_new_fractal;
                return -1;
            }
        }
    //--- check the number of points added to the time set
    int frac_num_to_add=temp_add_set.Total();
    if(frac_num_to_add<1)
        return -1;
    //---
    bool is_emptied=false; // the set is emptied?
    int curr_fractal_num=0;
    //--- adding the point to the set
    for(int frac_idx=0;frac_idx<frac_num_to_add;frac_idx++)
    {
        CFractalPoint *ptr_temp_frac=temp_add_set.At(frac_idx);
        if(CheckPointer(ptr_temp_frac)!=POINTER_DYNAMIC)
        {
            Print("Error in obtaining the fractal point's object in the time set!");
            return -1;
        }
        //--- when checking the number of bars between the last and current points
        if(m_bars_between>0)
        {
            curr_fractal_num=this.Total();
            if(curr_fractal_num>0)
            {
                CFractalPoint *ptr_prev_frac=this.At(curr_fractal_num-1);
                if(CheckPointer(ptr_prev_frac)!=POINTER_DYNAMIC)
                {
                    Print("Error in obtaining the fractal point's object from the set!");
                    return -1;
                }
                datetime time1,time2;
                time1=ptr_prev_frac.Date();
                time2=ptr_temp_frac.Date();
                //--- bars between points
                datetime bars_dates[];
                int bars_between=CopyTime(_Symbol,_Period,
                                          time1,time2,bars_dates
                                          );
                if(bars_between<0)
                {
                    Print("Error of obtaining the bar opening time data!");
                    return -1;
                }
                bars_between-=2;
                //--- on various bars
                if(bars_between>=0)
                    //--- if intermediate bars are not sufficient 
                    if(bars_between<m_bars_between)
                    {
                        bool to_delete_frac=false;
                        if(m_to_log)
                            Print("Intermediate bars are not sufficient. One point will be skipped.");
                        //--- if the previous point is relevant
                        if(m_rel_frac==RELEVANT_EXTREMUM_PREV)
                        {
                            datetime curr_frac_date=time2;
                            //--- if there was initialization
                            if(m_is_init)
                            {
                                continue;
                            }
                            //--- if there was no initialization
                            else
                            {
                                //--- remove current point
                                to_delete_frac=true;
                                curr_frac_date=time1;
                            }
                            if(m_to_log)
                            {
                                PrintFormat("The current point was missed: %s",
                                            TimeToString(curr_frac_date));
                            }
                        }
                        //--- if the last point is relevant
                        else
                        {
                            datetime curr_frac_date=time1;
                            //--- if there was initialization
                            if(m_is_init)
                            {
                                //--- remove previous point
                                to_delete_frac=true;
                            }
                            //--- if there was no initialization
                            else
                            {
                                curr_frac_date=time2;
                            }
                            if(m_to_log)
                                PrintFormat("Previous point will be missed: %s",
                                            TimeToString(curr_frac_date));
                            if(curr_frac_date==time2)
                                continue;

                        }
                        //--- if the point is deleted
                        if(to_delete_frac)
                        {
                            if(!this.Delete(curr_fractal_num-1))
                            {
                                Print("Error in removing the last point in the set!");
                                return -1;
                            }
                        }
                    }
            }
        }
        //--- adding the fractal point in the current sent - copying
        CFractalPoint *ptr_new_fractal=new CFractalPoint;
        if(CheckPointer(ptr_new_fractal)==POINTER_DYNAMIC)
        {
            ptr_new_fractal.Copy(ptr_temp_frac);
            if(!this.Add(ptr_new_fractal))
            {
                Print("Error in adding the fractal's point in the current set!");
                delete ptr_new_fractal;
                return -1;
            }
            //--- the point's index
            ptr_new_fractal.Index(this.Total()-1);
        }
    }
    //--- set validation
    curr_fractal_num=this.Total();
    //--- if there are extra points
    if(curr_fractal_num>m_fractal_num)
    {
        uint num_to_crop=curr_fractal_num-m_fractal_num;
        //--- crop the set
        if(!this.Crop(num_to_crop))
        {
            Print("Error in removing extra points from the set!");
            return -1;
        }
        //--- to refresh the number of points in the set
        curr_fractal_num=this.Total();
    }
    //--- if points are sufficient
    if(curr_fractal_num==m_fractal_num)
    {
        //--- determine the type of the set
        int min_cnt,max_cnt; // counters
        min_cnt=max_cnt=0;
        for(int frac_idx=0;frac_idx<curr_fractal_num;frac_idx++)
        {
            //--- to obtain the point
            CFractalPoint *ptr_curr_frac=this.At(frac_idx);
            if(CheckPointer(ptr_curr_frac)!=POINTER_DYNAMIC)
            {
                Print("Error in obtaining the fractal point's object from the set!");
                return -1;
            }
            //--- to determine the type
            ENUM_EXTREMUM_TYPE curr_frac_type=ptr_curr_frac.FractalType();
            if(curr_frac_type==EXTREMUM_TYPE_MIN)
                min_cnt++;
            else if(curr_frac_type==EXTREMUM_TYPE_MAX)
                max_cnt++;
        }
        //--- if there are 2 minimums and 1 maximum
        if((min_cnt==2) && (max_cnt==1))
            this.SetTypeOfSet(SET_TYPE_MINMAX);
        //--- if there are 1 minimum and 2 maximums
        else if((min_cnt==1) && (max_cnt==2))
            this.SetTypeOfSet(SET_TYPE_MAXMIN);
        //--- otherwise remove the first and the last point, if the type is not set
        else
        {
            //--- if there was initialization - to remove the first
            if(m_is_init)
            {
                if(!this.Crop(1))
                {
                    Print("Error in deleting the first point in the same type set!");
                    this.Clear();
                    return false;
                }
                if(m_to_log)
                    Print("First point is deleted from the same type set.");
            }
            //--- if there was no initialization  - to delete the last
            else
            {
                if(!this.Delete(curr_fractal_num-1))
                {
                    Print("Error in removing the last point in the one type set!");
                    this.Clear();
                    return false;
                }
                if(m_to_log)
                    Print("Last point is removed from the one type set.");
            }
        }
    }
    //---
    return this.Total();
}
//+------------------------------------------------------------------+
//| Display channel                                                  |
//+------------------------------------------------------------------+
bool CFractalSet::PlotChannel(void)
{
    //--- obtain the point from the set
    bool is_1_point=false;
    datetime times[3];
    double prices[3];
    ArrayInitialize(times,0);
    ArrayInitialize(prices,0.);
    ENUM_SET_TYPE curr_set_type=this.GetTypeOfSet();
    if(curr_set_type<=SET_TYPE_NONE)
    {
        Print("The channel won't be drawn: the type of the extreme points' set is not set!");
        return false;
    }
    //--- collect time-price coordinates
    for(int frac_idx=0;frac_idx<m_fractal_num;frac_idx++)
    {
        CFractalPoint *ptr_curr_point=this.At(frac_idx);
        if(CheckPointer(ptr_curr_point)!=POINTER_DYNAMIC)
        {
            Print("Error in obtaining fractal's points.");
            return false;
        }
        ENUM_EXTREMUM_TYPE curr_frac_type=ptr_curr_point.FractalType();
        datetime curr_point_time=ptr_curr_point.Date();
        double curr_point_price=ptr_curr_point.Value();
        //--- searching points
        if(curr_set_type==SET_TYPE_MINMAX)
        {
            if(curr_frac_type==EXTREMUM_TYPE_MIN)
            {
                //--- first minimum
                if(!is_1_point)
                {
                    times[0]=curr_point_time;
                    prices[0]=curr_point_price;
                    is_1_point=true;
                }
                //--- second minimum
                else
                {
                    times[1]=curr_point_time;
                    prices[1]=curr_point_price;
                    //is_1_point=true;
                }
            }
            //--- the only maximum
            else
            {
                times[2]=curr_point_time;
                prices[2]=curr_point_price;
            }
        }
        else if(curr_set_type==SET_TYPE_MAXMIN)
        {
            if(curr_frac_type==EXTREMUM_TYPE_MAX)
            {
                //--- first maximum 
                if(!is_1_point)
                {
                    times[0]=curr_point_time;
                    prices[0]=curr_point_price;
                    is_1_point=true;
                }
                //--- second maximum
                else
                {
                    times[1]=curr_point_time;
                    prices[1]=curr_point_price;
                }
            }
            //--- only minimum
            else
            {
                times[2]=curr_point_time;
                prices[2]=curr_point_price;
            }
        }
    }
    //--- creating and drawing the channel
    int ch_num=m_channels_arr.Total();
    string ch_name="myChannel"+IntegerToString(ch_num+1);
    CChartObjectChannel  *ptr_new_channel=new CChartObjectChannel;
    if(CheckPointer(ptr_new_channel)==POINTER_DYNAMIC)
    {
        //--- to add the channel's object into array
        if(!m_channels_arr.Add(ptr_new_channel))
        {
            Print("Error in adding the channel's object!");
            delete ptr_new_channel;
            return false;
        }
        //--- 1) time coordinates
        //--- start of the channel
        int first_date_idx=ArrayMinimum(times);
        if(first_date_idx<0)
        {
            Print("Error in obtaining the time coordinates!");
            m_channels_arr.Delete(m_channels_arr.Total()-1);
            return false;
        }
        datetime first_point_date=times[first_date_idx];
        //--- end of the channel
        datetime dates[];
        if(CopyTime(_Symbol,_Period,0,1,dates)!=1)
        {
            Print("Error in obtaining the time of the last bar!");
            m_channels_arr.Delete(m_channels_arr.Total()-1);
            return false;
        }
        datetime last_point_date=dates[0];

        //--- 2) price coordinates
        //--- 2.1 angle of the line
        //--- bars between first and second points
        datetime bars_dates[];
        int bars_between=CopyTime(_Symbol,_Period,
                                  times[0],times[1],bars_dates
                                  );
        if(bars_between<2)
        {
            Print("Error in obtaining the number of bars between the points!");
            m_channels_arr.Delete(m_channels_arr.Total()-1);
            return false;
        }
        bars_between-=1;
        //--- common differential
        double price_differential=MathAbs(prices[0]-prices[1]);
        //--- price speed (price change on the first bar)
        double price_speed=price_differential/bars_between;
        //--- direction of the channel
        bool is_up=(prices[0]<prices[1]);

        //--- 2.2 new price of the first or third points  
        if(times[0]!=times[2])
        {
            datetime start,end;
            start=times[0];
            end=times[2];
            //--- if the third point is earlier than the first
            bool is_3_point_earlier=false;
            if(times[2]<times[0])
            {
                start=times[2];
                end=times[0];
                is_3_point_earlier=true;
            }
            //--- bars between the first and third points
            int bars_between_1_3=CopyTime(_Symbol,_Period,
                                          start,end,bars_dates
                                          );
            if(bars_between_1_3<2)
            {
                Print("Error in obtaining the number of bars between the points!");
                m_channels_arr.Delete(m_channels_arr.Total()-1);
                return false;
            }
            bars_between_1_3-=1;

            //--- if the channel is ascending
            if(is_up)
            {
                //--- if the third point was earlier
                if(is_3_point_earlier)
                    prices[0]-=(bars_between_1_3*price_speed);
                else
                    prices[2]-=(bars_between_1_3*price_speed);
            }
            //--- or if the channel is descending
            else
            {
                //--- if the third point was earlier
                if(is_3_point_earlier)
                    prices[0]+=(bars_between_1_3*price_speed);
                else
                    prices[2]+=(bars_between_1_3*price_speed);
            }
        }

        //--- 2.3 new price of the 2 point 
        if(times[1]<last_point_date)
        {
            datetime dates_for_last_bar[];
            //--- bars between the 2 point and the last bar
            bars_between=CopyTime(_Symbol,_Period,times[1],last_point_date,dates_for_last_bar);
            if(bars_between<2)
            {
                Print("Error in obtaining the number of bars between the points!");
                m_channels_arr.Delete(m_channels_arr.Total()-1);
                return false;
            }
            bars_between-=1;
            //--- if the channel is ascending
            if(is_up)
                prices[1]+=(bars_between*price_speed);
            //--- or if the channel is descending
            else
                prices[1]-=(bars_between*price_speed);
        }

        //--- final time coordinates 
        times[0]=times[2]=first_point_date;
        times[1]=last_point_date;
        //--- normalization of prices
        for(int idx=0;idx<m_fractal_num;idx++)
            prices[idx]=NormalizeDouble(prices[idx],_Digits);

        //--- creating the channel
        if(!ptr_new_channel.Create(0,ch_name,0,times[0],prices[0],times[1],prices[1],
                                   times[2],prices[2]))
        {
            Print("Error in creating the channel's object!");
            m_channels_arr.Delete(m_channels_arr.Total()-1);
            return false;
        }
        ptr_new_channel.RayRight(m_is_array);
        ptr_new_channel.SetInteger(OBJPROP_WIDTH,m_line_wid);
        int color_idx=ch_num%4;
        if(color_idx<ArraySize(m_channel_colors))
            ptr_new_channel.Color(m_channel_colors[color_idx]);

        //--- remove the first point
        if(!this.Crop(1)) // Delete(0)
        {
            Print("Error in removing the first point in the set!");
            this.Clear();
            return false;
        }
        //--- to redraw previous channels
        if(m_to_delete_prev || m_is_array)
            for(int ch_idx=0;ch_idx<ch_num;ch_idx++)
            {
                CChartObjectChannel  *ptr_curr_channel=m_channels_arr.At(ch_idx);
                if(CheckPointer(ptr_curr_channel)==POINTER_DYNAMIC)
                {
                    //--- to hide the previous channels
                    if(m_to_delete_prev)
                    {
                        if(ptr_curr_channel.GetInteger(OBJPROP_TIMEFRAMES)>0)
                            ptr_curr_channel.SetInteger(OBJPROP_TIMEFRAMES,0);
                    }
                    //--- or to the remove the arrow to the right
                    else if(m_is_array)
                        ptr_curr_channel.RayRight(false);
                }
            }
        //--- redrawing the chart
        ChartRedraw();
    }
    //---
    return true;
}
//+------------------------------------------------------------------+
//| Crop the set                                                     |
//+------------------------------------------------------------------+
bool CFractalSet::Crop(const uint _num_to_crop)
{
    //--- if the number of removed points is not set
    if(_num_to_crop<1)
        return false;
    //---
    if(!this.DeleteRange(0,_num_to_crop-1))
    {
        Print("Error in deleting fractal points!");
        return false;
    }
    //---
    return true;
}
//+------------------------------------------------------------------+
//| Bubble sorting                                                   |
//+------------------------------------------------------------------+
void CFractalSet::BubbleSort(void)
{
    m_sort_mode=-1;
    //---
    uint arr_size=this.Total();
    for(uint passes=0;passes<arr_size-1;passes++)
        for(uint j=0;j<(arr_size-passes-1);j++)
        {
            CFractalPoint *ptr_p1=this.At(j);
            CFractalPoint *ptr_p2=this.At(j+1);
            //--- compare values (by date)
            if(ptr_p1.Date()>ptr_p2.Date())
            {
                CFractalPoint *ptr_temp_p=new CFractalPoint;
                if(CheckPointer(ptr_temp_p)==POINTER_DYNAMIC)
                {
                    ptr_temp_p.Copy(ptr_p2);
                    if(!this.Insert(ptr_temp_p,j))
                        return;
                    if(!this.Delete(j+2))
                        return;
                }
                else
                    return;
            }
        }
    m_sort_mode=1;
}
//+------------------------------------------------------------------+
