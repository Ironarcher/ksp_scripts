clearscreen.
lock throttle to 1.0.
SAS ON.
BRAKES OFF.
GEAR OFF.
SET radar_correction to alt:radar.
print alt:radar.

until ship:maxthrust > 0 {
    wait 0.5.
    print "Liftoff!".
    Stage. //ignition
}.

//Set landing spot
set lz1 to ship:geoposition.

//wait until ship:altitude > 100.
lock steering to up.
wait until ship:altitude > 150.
lock throttle to 0.0.

//wait until ship:altitude > 500.
//wait until ship:altitude < 500.
SET g TO KERBIN:MU / KERBIN:RADIUS^2.
LOCK accvec TO SHIP:SENSORS:ACC - SHIP:SENSORS:GRAV.
LOCK gforce TO accvec:MAG / g.
SAS OFF.
print "Landing legs down.".
print "Begin landing burn.".
//Lower landing gear
GEAR ON.
//BRAKES ON.

//Throttle settings and PID loop control
SET current_throttle to 0.25.
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

declare deltax to 0.
declare deltay to 0.
set Kp2 to 1.
set Ki2 to 0.6.
set Ix to 0.
set Iy to 0.
lock Px to (ship:geoposition:lng - lz1:lng) * 10430.
lock Py to (ship:geoposition:lat - lz1:lat) * 10430.
lock deltax to Kp2 * Px + Ki2 * Ix.
lock deltay to Kp2 * Py + Ki2 * Iy.
set steer_x to 0.
set steer_y to 0.
until alt:radar - radar_correction < 1{
	SET dt TO TIME:SECONDS - t0.
    IF dt > 0 {
        SET I TO I + P * dt.
		//Adjust the throttle setting
		SET current_throttle to new_throttle + current_throttle.
		IF new_throttle + current_throttle < 0.1 {
			SET current_throttle to 0.1.
		}
		SET P0 TO P.
		
		set Ix to Ix + Px * dt.
		set Iy to Iy + Py * dt.
		
		//If Ki2 is non-zero, then limit Ki2*I to [-1,1]
		IF Ki2 > 0 {
			SET Ix TO MIN(1.0/Ki2, MAX(-1.0/Ki2, Ix)).
			SET Iy TO MIN(1.0/Ki2, MAX(-1.0/Ki2, Iy)).
		}
		
		//Limit steering to certain range
		//Can only travel maximum 10 m/s sideways in each direction
		set steer_x to MIN(1, MAX(-1, steer_x + deltax)).
		set steer_y to MIN(1, MAX(-1, steer_y + deltay)).
		print "x" + steer_x.
		print "y" + steer_y.
		//lock steering to R(0,0,0) * V(steer_x,steer_y,0).
		if deltax > 0 {
       		set ship:control:yaw to 0.2.
	    }else {
	        set ship:control:yaw to -0.2.
	        print "going".
	    }
	    if deltay > 0 {
	        set ship:control:pitch to 0.2.
	    }else {
	        set ship:control:pitch to -0.2.
	    }
        SET t0 TO TIME:SECONDS.
    }
    wait 0.001.
}.
lock throttle to 0.0.
lock steering to up.
print "Craft landed".
//Lock throttle to 0 to prevent thrust after the end of the program
set ship:control:pilotmainthrottle to 0.