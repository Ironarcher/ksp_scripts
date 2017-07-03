clearscreen.
lock throttle to 0.5.
SAS ON.
BRAKES OFF.
GEAR OFF.

//Set landing spot
set lz1 to ship:geoposition.

print ship:geoposition:lng.
print ship:geoposition:lat.

until ship:maxthrust > 0 {
    wait 0.5.
    print "Liftoff!".
    Stage. //ignition
}.

LOCK steering to up.

SET stop_alt to 500.
SET radar_correction to 6.

wait until alt:radar - radar_correction > stop_alt.
lock throttle to 0.0.
wait until verticalspeed < 0.

print "Begin descent profile.".
SAS OFF.
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


//Update directional controls
declare deltax to 0.
declare deltay to 0.
set Kp2 to 1.
set Ki2 to 0.6.
set Ix to 0.
set Iy to 0.
lock Px to (ship:geoposition:lng- lz1:lng) * 10430.
lock Py to (lz1:lat - ship:geoposition:lat) * 10430.
lock deltax to Kp * Px + Ki * Ix.
lock deltay to Kp * Py + Ki * Iy.
set steer_x to 0.
set steer_y to 0.

until alt:radar - radar_correction < 1{
	SET dt TO TIME:SECONDS - t0.
    IF dt > 0 {
        SET I TO I + P * dt.
		//Adjust the throttle setting
		SET current_throttle to new_throttle + current_throttle.
		SET P0 TO P.
		
		set Ix to Ix + Px * dt.
		set Iy to Iy + Py * dt.
		
		// If Ki2 is non-zero, then limit Ki2*I to [-1,1]
		IF Ki > 0 {
			SET Ix TO MIN(1.0/Ki2, MAX(-1.0/Ki2, Ix)).
			SET Iy TO MIN(1.0/Ki2, MAX(-1.0/Ki2, Iy)).
		}
		
		//Limit steering to certain range
		//Can only travel maximum 7 m/s sideways in each direction
		set steer_x to MIN(10, MAX(-10, steer_x + deltax)).
		set steer_y to MIN(10, MAX(-10, steer_y + deltay)).
		print "X  " + Px.
		print "Y  " + Py.
		lock steering to R(0,0,0) * V(-steer_x,-steer_y,0).
        SET t0 TO TIME:SECONDS.
    }
    wait 0.001.
}.
lock throttle to 0.0.