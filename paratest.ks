clearscreen.
SAS ON.

//Ignite solid rocket booster
Stage.
print "Ignition".

wait until ship:altitude > 1000.
wait until ship:altitude > 50000.
Stage.
print "Stage separation".

wait until ship:altitude < 50000.
wait until ship:altitude < 2000.
Stage.
print "parachute deployed".

wait until alt:radar < 5.
Stage.