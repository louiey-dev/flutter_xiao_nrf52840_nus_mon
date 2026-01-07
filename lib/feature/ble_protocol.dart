/* BLE protocol with Xiao */
const int nusMsgNone = 0;
const int nusMsgLedCtrl = 1; // ID(2) | LEN(2) | LED_NUM(1) | LED_ONOFF(1)
const int nusMsgGetBattAdc = 2;
const int nusMsgSetPwmLedWidth = 3; // ID(2) | LEN(2) | PULSE_WIDTH(4)
const int nusMsgSetPrdTick = 4; // ID(2) | LEN(2) | PRD_TICK(2)
const int nusMsgGetRtc = 5;
const int nusMsgSetRtc = 6;
const int nusMsg05 = 7;
const int nusMsg06 = 8;
const int nusMsg07 = 9;
const int nusMsg08 = 10;
const int nusMsg09 = 11;
const int nusMsg10 = 12;
const int nusMsg11 = 13;
const int nusMsg12 = 14;
const int nusMsg13 = 15;
const int nusMsgNotifyImu =
    16; //nusMsg LEN(2) | ACC_X(2) | ACC_Y(2) | ACC_Z(2) | GYRO_X(2) | GYRO_Y(2) | GYRO_Z(2)
const int nusMsgNotifyRtc =
    17; //nusMsg LEN(2) | YEAR(2) | MON(2) | DAY(2) | WEEKDAY(2) | HOUR(2) | MIN(2) | SEC(2)
const int nusMsg16 = 18;
const int nusMsg17 = 19;
const int nusMsg18 = 20;
const int nusMsg19 = 21;
const int nusMsg20 = 22;
