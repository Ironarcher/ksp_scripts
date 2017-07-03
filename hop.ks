clearscreen.
lock throttle to 1.0.
SAS ON.
BRAKES OFF.
GEAR OFF.

until ship:maxthrust > 0 {
    wait 0.5.
    print "Liftoff!".
    Stage. //ignition
}.

set steering to up.
wait until ship:altitude > 3000.
lock throttle to 0.0.

wait until ship:altitude < 3000.
BRAKES on.

//Radar correction is based on the height of your spacecraft above the ground.
SET radar_correction to 6.
SET burn_start_altitude to 2000.

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