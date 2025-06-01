// ******************************************************
// [GLOBAL TEMPERATURE SAFETY CHECK] 
// ******************************************************

"CentrifugeData".Temperature := DINT_TO_REAL(WORD_TO_DINT("Temp_Sensor")) * (100.0 / 65535.0);


IF ("CentrifugeData".Temperature < "CentrifugeData".Temp_Min) OR ("CentrifugeData".Temperature > "CentrifugeData".Temp_Max) THEN           //"Temp_Fault" THEN  
    //Raising alarm
    "CentrifugeData".Temp_Fault := TRUE;
    // Reseting all timers
    "CentrifugeData".Big_FillTimer(IN := FALSE,
                                   PT := T#50s);
    "CentrifugeData".Big_AccelTimer(IN := FALSE, PT := T#50s);
    "CentrifugeData".Big_RunTimer(IN := FALSE, PT := T#50s);
    "CentrifugeData".Big_EmptyTimer(IN := FALSE, PT := T#50s);
    
    "CentrifugeData".Small_FillTimer(IN := FALSE, PT := T#50s);
    "CentrifugeData".Small_AccelTimer(IN := FALSE, PT := T#50s);
    "CentrifugeData".Small_RunTimer(IN := FALSE, PT := T#50s);
    "CentrifugeData".Small_EmptyTimer(IN := FALSE, PT := T#50s);
    
    // Reseting critical variables
    "CentrifugeData".Big_W := 0.0;
    "CentrifugeData".Small_W := 0.0;
    
    RETURN;  // Exiting immediately - skip all state logic below
END_IF;
















// Big Centrifuge Logic
IF "CentrifugeData".Big_State = 0 THEN
    "CentrifugeData".Big_W := 0.0;
    "CentrifugeData".Big_CycleCount := 0;
    "CentrifugeData".rotation_cycle_big := 0;
    "CentrifugeData".Big_FillTimer(IN := FALSE,
                                   PT := T#50s);
    "CentrifugeData".Big_RunTimer(IN := FALSE,
                                  PT := T#50s);
    "CentrifugeData".Big_AccelTimer(IN := FALSE,
                                    PT := T#50s);
    "CentrifugeData".Big_EmptyTimer(IN := FALSE,
                                    PT := "CentrifugeData".Big_EmptyTime);
    
    IF "I1" AND "Start" AND "Enable" THEN
        "CentrifugeData".Big_State := 1;
    END_IF;
    
ELSIF "CentrifugeData".Big_State = 1 THEN
    "CentrifugeData".Big_FillTimer(IN := TRUE,
                                   PT := T#50s);
    
    IF NOT "I1" THEN
        "CentrifugeData".Total_Big_FillTime := "CentrifugeData".Total_Big_FillTime + "CentrifugeData".Big_FillTimer.ET;
        "CentrifugeData".Big_FillTimer(IN := FALSE,
                                       PT := T#50s);
    END_IF;
    
    IF ("CentrifugeData".Total_Big_FillTime + "CentrifugeData".Big_FillTimer.ET) >= "CentrifugeData".Big_FillTime THEN
        "CentrifugeData".Big_FillED := TRUE;
        IF NOT "I1" THEN
            "CentrifugeData".Total_Big_FillTime := T#0s;
            //IF NOT "I3" THEN // AND "CentrifugeData".Small_State = 1 THEN
            "CentrifugeData".Big_State := 2;
            // END_IF;
        END_IF;
    END_IF;
    
ELSIF "CentrifugeData".Big_State = 2 THEN
    "CentrifugeData".Big_AccelTimer(IN := TRUE,
                                    PT := T#50s);
    "CentrifugeData".Big_W := "CentrifugeData".Big_A * DINT_TO_REAL(TIME_TO_DINT("CentrifugeData".Big_AccelTimer.ET)) / 1000.0;
    
    IF "CentrifugeData".Big_W >= "CentrifugeData".Big_MaxSpeed THEN
        "CentrifugeData".Big_W := "CentrifugeData".Big_MaxSpeed; //clipping
        "CentrifugeData".deceleration_time_big := "CentrifugeData".Big_AccelTimer.ET;
        "CentrifugeData".Big_AccelTimer(IN := FALSE,
                                        PT := T#50s);
        "CentrifugeData".Big_State := 3;
    END_IF;
    
ELSIF "CentrifugeData".Big_State = 3 THEN
    "CentrifugeData".Big_RunTimer(IN := TRUE,
                                  PT := T#50s);
    IF "CentrifugeData".Big_RunTimer.ET >= ("CentrifugeData".Big_RunTime - "CentrifugeData".deceleration_time_big - "CentrifugeData".deceleration_time_big) THEN
        "CentrifugeData".Big_RunTimer(IN := FALSE,
                                      PT := T#50s);
        "CentrifugeData".Big_State := 4;
    END_IF;
    
ELSIF "CentrifugeData".Big_State = 4 THEN
    "CentrifugeData".Big_AccelTimer(IN := TRUE,
                                    PT := T#50s);
    "CentrifugeData".Big_W := "CentrifugeData".Big_MaxSpeed - "CentrifugeData".Big_A * DINT_TO_REAL(TIME_TO_DINT("CentrifugeData".Big_AccelTimer.ET) / 1000.0);
    
    IF "CentrifugeData".Big_W <= 0.0 THEN
        "CentrifugeData".Big_W := 0.0;
        "CentrifugeData".Big_AccelTimer(IN := FALSE,
                                        PT := T#50s);
        IF "CentrifugeData".rotation_cycle_big < "CentrifugeData".rotation_max_cycles THEN
            "CentrifugeData".Big_State := 2;
            "CentrifugeData".rotation_cycle_big := "CentrifugeData".rotation_cycle_big + 1;
        ELSE
            "CentrifugeData".Big_State := 5;
        END_IF;
    END_IF;
    
ELSIF "CentrifugeData".Big_State = 5 THEN
    "CentrifugeData".Big_FillED := FALSE;
    "CentrifugeData".Big_EmptyTimer(IN := TRUE,
                                    PT := "CentrifugeData".Big_EmptyTime);
    IF "CentrifugeData".Big_EmptyTimer.Q THEN
        "CentrifugeData".Big_EmptyTimer(IN := FALSE,
                                        PT := "CentrifugeData".Big_EmptyTime);
        "CentrifugeData".Big_CycleCount := "CentrifugeData".Big_CycleCount + 1;
        "CentrifugeData".Big_State := 6;
    END_IF;
    
ELSIF "CentrifugeData".Big_State = 6 THEN
    IF "CentrifugeData".Big_CycleCount < 2 THEN
        "CentrifugeData".Big_State := 1;
        "CentrifugeData".rotation_cycle_big := 0;
    ELSE
        "CentrifugeData".Big_State := 0;//back to idle
    END_IF;
END_IF;

// Small Centrifuge Logic 
IF "CentrifugeData".Small_State = 0 THEN
    "CentrifugeData".Small_W := 0.0;
    "CentrifugeData".Small_CycleCount := 0;
    "CentrifugeData".rotation_cycle_small := 0;
    "CentrifugeData".Small_FillTimer(IN := FALSE,
                                     PT := T#50s);
    "CentrifugeData".Small_RunTimer(IN := FALSE,
                                    PT := T#50s);
    "CentrifugeData".Small_AccelTimer(IN := FALSE,
                                      PT := T#50s);
    "CentrifugeData".Small_EmptyTimer(IN := FALSE,
                                      PT := "CentrifugeData".Small_EmptyTime);
    
    IF "I3" AND "Start" AND "Enable" THEN
        "CentrifugeData".Small_State := 1;
    END_IF;
    
ELSIF "CentrifugeData".Small_State = 1 THEN
    "CentrifugeData".Small_FillTimer(IN := TRUE,
                                     PT := T#50s);
    
    IF NOT "I3" THEN
        "CentrifugeData".Total_Small_FillTime := "CentrifugeData".Total_Small_FillTime + "CentrifugeData".Small_FillTimer.ET;
        "CentrifugeData".Small_FillTimer(IN := FALSE,
                                         PT := T#50s);
    END_IF;
    
    IF ("CentrifugeData".Total_Small_FillTime + "CentrifugeData".Small_FillTimer.ET) >= "CentrifugeData".Small_FillTime THEN
        "CentrifugeData".Small_FillED := TRUE;
        IF NOT "I3" THEN
            "CentrifugeData".Total_Small_FillTime := T#0s;
            //IF NOT "I1" THEN //AND "CentrifugeData".Big_State = 1 THEN
            "CentrifugeData".Small_State := 2;
            //END_IF;
        END_IF;
    END_IF;
    
ELSIF "CentrifugeData".Small_State = 2 THEN
    "CentrifugeData".Small_AccelTimer(IN := TRUE,
                                      PT := T#50s);
    "CentrifugeData".Small_W := "CentrifugeData".Small_A * (DINT_TO_REAL(TIME_TO_DINT("CentrifugeData".Small_AccelTimer.ET)) / 1000.0);
    IF "CentrifugeData".Small_W >= "CentrifugeData".Small_MaxSpeed THEN
        "CentrifugeData".Small_W := "CentrifugeData".Small_MaxSpeed;
        "CentrifugeData".deceleration_time_small := "CentrifugeData".Small_AccelTimer.ET;
        "CentrifugeData".Small_AccelTimer(IN := FALSE,
                                          PT := T#50s);
        "CentrifugeData".Small_State := 3;
    END_IF;
    
ELSIF "CentrifugeData".Small_State = 3 THEN
    "CentrifugeData".Small_RunTimer(IN := TRUE,
                                    PT := T#50s);
    IF "CentrifugeData".Small_RunTimer.ET >= ("CentrifugeData".Small_RunTime - "CentrifugeData".deceleration_time_small - "CentrifugeData".deceleration_time_small) THEN
        "CentrifugeData".Small_RunTimer(IN := FALSE,
                                        PT := T#50s);
        "CentrifugeData".Small_State := 4;
    END_IF;
    
ELSIF "CentrifugeData".Small_State = 4 THEN
    "CentrifugeData".Small_AccelTimer(IN := TRUE,
                                      PT := T#50s);
    "CentrifugeData".Small_W := "CentrifugeData".Small_MaxSpeed - "CentrifugeData".Small_A * DINT_TO_REAL(TIME_TO_DINT("CentrifugeData".Small_AccelTimer.ET) / 1000.0);
    
    IF "CentrifugeData".Small_W <= 0.0 THEN
        "CentrifugeData".Small_W := 0.0;
        "CentrifugeData".Small_AccelTimer(IN := FALSE,
                                          PT := T#50s);
        IF "CentrifugeData".rotation_cycle_small < "CentrifugeData".rotation_max_cycles THEN
            "CentrifugeData".Small_State := 2;
            "CentrifugeData".rotation_cycle_small := "CentrifugeData".rotation_cycle_small + 1;
        ELSE
            "CentrifugeData".Small_State := 5;
        END_IF;
    END_IF;
    
ELSIF "CentrifugeData".Small_State = 5 THEN
    "CentrifugeData".Small_FillED := FALSE;
    "CentrifugeData".Small_EmptyTimer(IN := TRUE,
                                      PT := "CentrifugeData".Small_EmptyTime);
    IF "CentrifugeData".Small_EmptyTimer.Q THEN
        "CentrifugeData".Small_EmptyTimer(IN := FALSE,
                                          PT := "CentrifugeData".Small_EmptyTime);
        "CentrifugeData".Small_CycleCount := "CentrifugeData".Small_CycleCount + 1;
        "CentrifugeData".Small_State := 6;
    END_IF;
    
ELSIF "CentrifugeData".Small_State = 6 THEN
    IF "CentrifugeData".Small_CycleCount < 2 THEN
        "CentrifugeData".rotation_cycle_small := 0;
        "CentrifugeData".Small_State := 1;
    ELSE
        "CentrifugeData".Small_State := 0;
    END_IF;
END_IF;