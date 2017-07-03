clearscreen.
lock throttle to 0.8.
SAS ON.
BRAKES OFF.
GEAR OFF.

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

wait until alt:radar - 6 < 1000.
print "Landing legs down.".
print "Begin landing burn.".
GEAR ON.
//Throttle settings and PID loop control
SET current_throttle to 0.0.
SET new_throttle to 0.0.
SET Kp to 0.05.
SET I to 0.
SET Ki to 0.006.
LOCK P to (a_net * m)/ship:availablethrust.
SET t0 TO TIME:SECONDS.
LOCK new_throttle to Kp * P + Ki * I.

LOCK throttle to current_throttle.
LOCK a to ship:sensors:acc:mag.
LOCK d to alt:radar - 6.
LOCK vi to verticalspeed.
//Mass in tons and thrust in kN.
LOCK m to ship:mass.
LOCK a_req to -((4 - vi^2)/2/d).
LOCK a_net to a_req - a.
until alt:radar - 6 < 1{
	SET dt TO TIME:SECONDS - t0.
    IF dt > 0 {
        SET I TO I + P * dt.
		SET current_throttle to new_throttle + current_throttle.
		SET P0 TO P.
        SET t0 TO TIME:SECONDS.
    }
    wait 0.001.
}.
lock throttle to 0.0.
print "Craft landed".
set ship:control:pilotmainthrottle to 0.