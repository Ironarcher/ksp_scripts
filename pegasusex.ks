clearscreen.
lock throttle to 0.8.
SAS ON.
BRAKES OFF.
GEAR OFF.

//Begin test procedure
print "Control surface check".
set ship:control:neutralize to false.
set ship:control:yaw to 1.0.
wait 1.
set ship:control:yaw to -1.0.
wait 1.
set ship:control:yaw to 0.0.
set ship:control:pitch to 1.0.
wait 1.
set ship:control:pitch to -1.0.
wait 1.
set ship:control:pitch to 0.0.

//Set landing spot
set lz1 to ship:geoposition.

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

wait until ship:altitude > 100.
lock steering to up.
print "Roll Maneuver".

wait until ship:apoapsis > 100500.
lock throttle to 0.0.

//Landing maneuvers and reentry burn
wait until ship:altitude > 90000.
wait until ship:altitude < 25000.
declare deltax to 0.
declare deltay to 0.
until ship:altitude < 10000{
    set deltax to ship:geoposition:lng - lz1:lng.
    set deltay to ship:geoposition:lat - lz1:lat.
    print deltax.
    print deltay.
    if deltax > 0 {
        set ship:control:yaw to 0.2.
    }else {
        set ship:control:yaw to -1.0.
        print "going".
    }
    if deltay > 0 {
        set ship:control:pitch to 0.2.
    }else {
        set ship:control:pitch to -1.0.
    }
    set throttle to 0.05.
    wait 1.
}.
set steering to up.

wait until alt:radar < 7000.
BRAKES ON.

wait until alt:radar < 500.
print "Landing legs down.".
print "Begin landing burn.".
GEAR ON.
declare a to 0.
declare vi to 0.
declare d to 0.
declare m to 0.
declare a_req to 0.
declare a_net to 0.
declare engine_power to 0.
until alt:radar - 6 < 1{
    set a to ship:sensors:acc:z.
    set d to alt:radar - 6.
    set vi to verticalspeed.
    set m to ship:mass * 1000.
    set a_req to -((4 - vi^2)/2/d).
    set a_net to a_req - a.
    set engine_power to (a_net * m)/ship:maxthrust.
    lock throttle to engine_power.
    print "Radio Altimeter: " + d.
    print "Current acceleration: " + a.
    print "Vertical speed: " + vi.
    print "Current mass: " + m.
    print "Required acceleration: " + a_req.
    print "Net acceleration: " + a_net.
    print "Throttle: " + engine_power.
    wait 0.01.
}.
lock throttle to 0.0.