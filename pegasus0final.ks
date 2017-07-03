clearscreen.
lock throttle to 0.8.
SAS ON.
BRAKES OFF.
GEAR OFF.
SET radar_correction to alt:radar.

//countdown
PRINT "Counting down:".

FROM {local countdown is 10.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {

    PRINT "..." + countdown.

    WAIT 1. // pauses the script here for 1 second.

}

until ship:maxthrust > 0 {
    wait 0.5.
    print "Liftoff!".
    Stage. //ignition
}.

SET g TO KERBIN:MU / KERBIN:RADIUS^2.
LOCK accvec TO SHIP:SENSORS:ACC - SHIP:SENSORS:GRAV.
LOCK gforce TO accvec:MAG / g.
WHEN gforce < 0.5 THEN {
	print "Weightless".
	print "G's: " + gforce.
}

wait until ship:altitude > 100.
lock steering to up.
print "Roll Maneuver".

wait until ship:apoapsis > 100500.
lock throttle to 0.0.

set steering to up.

wait until ship:altitude > 100000.
print "You're in space!".
wait until alt:radar < 30000.
BRAKES ON.

SET burn_start_altitude to 3000.

wait until alt:radar - radar_correction < burn_start_altitude.
print "Landing legs down.".
print "Begin landing burn.".
//Lower landing gear
GEAR ON.

//Throttle settings and PID loop control
SET current_throttle to 0.0.
SET new_throttle to 0.0.
SET Kp to 0.05.
SET I to 0.
SET Ki to 0.006.
//Calculate the throttle level required (thrust required/available thrust)
LOCK P to (a_net * m)/ship:availablethrust.
SET t0 TO TIME:SECONDS.
//PI control loop (Proportional and Integral)
LOCK new_throttle to Kp * P + Ki * I.

//Set conditions needed for 
LOCK throttle to current_throttle.
LOCK a to ship:sensors:acc:mag.
LOCK d to alt:radar - radar_correction.
LOCK vi to verticalspeed.
//Mass in tons and thrust in kN.
LOCK m to ship:mass.

//Calculate the required acceleration of the ship
LOCK a_req to -((4 - vi^2)/2/d).
//Calculate the delta acceleration to place the ship at the correct acceleration
LOCK a_net to a_req - a.
//Update the feedback loop until 1 meter above the surface
until alt:radar - radar_correction < 1{
	SET dt TO TIME:SECONDS - t0.
    IF dt > 0 {
        SET I TO I + P * dt.
		//Adjust the throttle setting
		SET current_throttle to new_throttle + current_throttle.
		SET P0 TO P.
        SET t0 TO TIME:SECONDS.
    }
    wait 0.001.
}.
lock throttle to 0.0.
print "Craft landed".
//Lock throttle to 0 to prevent thrust after the end of the program
set ship:control:pilotmainthrottle to 0.