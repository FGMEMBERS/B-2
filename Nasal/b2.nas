#compatible with version 0.9.10
###
# Door functions
###

togglehatch = func {
    if (getprop("/controls/gear/brake-parking") == 1) {
        b2.hatch.toggle();
    } else {
        b2.hatch.close();
    }
}

    # Doors
    bombbay = aircraft.door.new("sim/model/doors/bombbay", 3.0);
    fuelhatch = aircraft.door.new("sim/model/doors/fuelhatch", 2.0);
    hatch = aircraft.door.new("sim/model/doors/hatch", 6.0);
    fuel = aircraft.door.new("sim/model/doors/fuel", 0.1);# fuel display

###
#startup-properties--------------------------------------------------------------------
###
init_delay = func {
setprop("/sim/current-view/field-of-view", 60);
#setprop("/sim/panel-hotspots", 1);
controls.syst(1);
controls.syst3(1);
#fuelflowlb();
print ("Aircraft not ready yet!");
settimer(yaw_control, 10);
}

yaw_control = func {

   rudder_loop();
   onground_loop();

#  yaw_deg = getprop("/autopilot/internal/addrudder");
#  rudder_c = getprop("/controls/flight/rudder");
#  kias = getprop("/velocities/airspeed-kt");
#
#  if(kias > 150) {
#    rudder_norm = yaw_deg + rudder_c;
#      setprop("/controls/flight/rudder", rudder_norm);
#      setprop("/controls/flight/spoilers", 0.4);
#      settimer(yaw_control, 0);
# } else {
#      setprop("/controls/flight/flaps", 0.10);
#      settimer(yaw_control, 0.1);
#  }
}
#--------------------------------------------------------------------
#start_up = func {
#  setlistener("/velocities/airspeed-kt", yaw_control);
#}
###
#sets-rudder-trim-to-0-when-another-AP-mode-is-activated-------------
###
rudder_loop = func {

   wing_l = getprop("/autopilot/locks/heading");
   if(wing_l == "nav1-hold") {
     setprop("/controls/flight/rudder-trim", 0);
   }
   if(wing_l == "dg-heading-hold") {
     setprop("/controls/flight/rudder-trim", 0);
   }
   if(wing_l == "true-heading-hold") {
     setprop("/controls/flight/rudder-trim", 0);
   }
     settimer(rudder_loop, 1);
}
###
#activates-AP-at-takeoff/when-no-AP-was-selected---------------
###
takeoff_loop = func {

#  alt = getprop("/position/altitude-ft");
#  kias = getprop("/velocities/airspeed-kt");
  apmo = getprop("/autopilot/locks/heading");
  WOW = getprop("/gear/gear[1]/wow");

if(apmo = "disabled") {

  if(WOW == 0) {
     setprop("/autopilot/locks/heading", "wing-leveler");
     onground_loop();
   } else {
     settimer(takeoff_loop, 0.2);
   }
 }
}
###
#disactivates-AP-when-on-ground---------------------------------
###
onground_loop = func {

 WOW = getprop("/gear/gear[1]/wow");

if(WOW == 1) {

     setprop("/autopilot/locks/heading", "");
     setprop("/controls/flight/rudder-trim", 0);
     takeoff_loop();
} else {
        settimer(onground_loop, 0.5);
       }
}
###
#switches-glas2-cockpit---------------------------------
###
controls.fuel = func(on){
	
	if (on > 0) {
setprop("sim/model/doors/fuel/position-norm",1);
setprop("sim/model/doors/eng/position-norm",0);
setprop("sim/model/doors/ctrl/position-norm",0);
setprop("sim/model/doors/syst/position-norm",0);
}
	elsif (on < 0) {setprop("sim/model/doors/fuel/position-norm", 0);}
} # end function

controls.eng = func(on){
	
	if (on > 0) {
setprop("sim/model/doors/eng/position-norm",1);
setprop("sim/model/doors/fuel/position-norm",0);
setprop("sim/model/doors/ctrl/position-norm",0);
setprop("sim/model/doors/syst/position-norm",0);
}
	elsif (on < 0) {setprop("sim/model/doors/fuel/position-norm", 0);}
} # end function

controls.ctrl = func(on){
	
	if (on > 0) {
setprop("sim/model/doors/ctrl/position-norm",1);
setprop("sim/model/doors/fuel/position-norm",0);
setprop("sim/model/doors/eng/position-norm",0);
setprop("sim/model/doors/syst/position-norm",0);
}
	elsif (on < 0) {setprop("sim/model/doors/ctrl/position-norm", 0);}
} # end function

controls.syst = func(on){
	
	if (on > 0) {
setprop("sim/model/doors/syst/position-norm",1);
setprop("sim/model/doors/fuel/position-norm",0);
setprop("sim/model/doors/eng/position-norm",0);
setprop("sim/model/doors/ctrl/position-norm", 0);
}
	elsif (on < 0) {setprop("sim/model/doors/syst/position-norm", 0);}
} # end function


###
#switches-glas3-cockpit---------------------------------
###
controls.fuel3 = func(on){
	
	if (on > 0) {
setprop("sim/model/doors/fuel3/position-norm",1);
setprop("sim/model/doors/aplt/position-norm",0);
setprop("sim/model/doors/wpns/position-norm",0);
setprop("sim/model/doors/syst3/position-norm",0);
}
	elsif (on < 0) {setprop("sim/model/doors/fuel3/position-norm", 0);}
} # end function

controls.aplt = func(on){
	
	if (on > 0) {
setprop("sim/model/doors/aplt/position-norm",1);
setprop("sim/model/doors/fuel3/position-norm",0);
setprop("sim/model/doors/wpns/position-norm",0);
setprop("sim/model/doors/syst3/position-norm",0);
}
	elsif (on < 0) {setprop("sim/model/doors/aplt/position-norm", 0);}
} # end function

controls.wpns = func(on){
	
	if (on > 0) {
setprop("sim/model/doors/wpns/position-norm",1);
setprop("sim/model/doors/fuel3/position-norm",0);
setprop("sim/model/doors/aplt/position-norm",0);
setprop("sim/model/doors/syst3/position-norm",0);
}
	elsif (on < 0) {setprop("sim/model/doors/wpns/position-norm", 0);}
} # end function

controls.syst3 = func(on){
	
	if (on > 0) {
setprop("sim/model/doors/syst3/position-norm",1);
setprop("sim/model/doors/fuel3/position-norm",0);
setprop("sim/model/doors/aplt/position-norm",0);
setprop("sim/model/doors/wpns/position-norm", 0);
}
	elsif (on < 0) {setprop("sim/model/doors/syst3/position-norm", 0);}
} # end function

###
#autopilot-modes--------------------------------############################
###
###
#autopilot-TakeOff--------------------------------
###
controls.apmodeto = func {

if(getprop("/velocities/airspeed-kt") > 250) {
#   settimer(controls.apmodefl,1);
} else {

#if (on > 0) {
  setprop("sim/model/doors/apmodeto/position-norm", 1);
  setprop("/autopilot/locks/speed", "speed-with-throttle");
  setprop("/autopilot/settings/target-speed-kt", 250);
  setprop("/controls/flight/spoilers", 0);
  setprop("/controls/gear/gear-down", "true");
  setprop("/controls/flight/flaps", 0);
  setprop("/controls/gear/brake-parking", 0);
  setprop("sim/model/doors/apmodela/position-norm", 0);
    if(getprop("/velocities/airspeed-kt") > 210) {
      setprop("/autopilot/settings/target-speed-kt", 290);
      setprop("/controls/gear/gear-down", "false");
      setprop("sim/model/doors/apmodeto/position-norm", 0);
      settimer(controls.apmodefl, 5);
			} else {
    settimer(controls.apmodeto, 1);
}
#            }
}
}

###
#autopilot-FLight(manual)--------------------------------
###
controls.apmodefl = func {

 WOW = getprop("/gear/gear[1]/wow");

if(WOW == 1) {
} else {
  setprop("/autopilot/locks/speed", "");
  setprop("/autopilot/settings/target-speed-kt", 280);
  setprop("/autopilot/locks/altitude", "");
  setprop("/controls/flight/flaps", 0);
  setprop("/autopilot/locks/heading", "wing-leveler");
  setprop("sim/model/doors/apmodeap/position-norm", 0);
}
}

###
#autopilot-AutoPilot--------------------------------
###
controls.apmodeap = func {
 WOW = getprop("/gear/gear[1]/wow");

if(WOW == 1) {
} else {
#  orhe = getprop("/orientation/heading-deg");

  setprop("sim/model/doors/apmodeap/position-norm", 1);
  setprop("sim/model/doors/apmodeast/position-norm",0);
  setprop("/autopilot/locks/speed", "");
  setprop("/autopilot/settings/target-speed-kt", 290);
  setprop("/autopilot/locks/altitude", "altitude-hold");
  setprop("/autopilot/settings/target-climb-rate-fpm", 2000);
  setprop("/autopilot/settings/target-descent-rate-fpm", 2000);
  setprop("/autopilot/settings/vertical-speed-fpm", 2000);
  setprop("/controls/flight/spoilers", 0);
  setprop("/controls/gear/gear-down", "false");
  setprop("/controls/flight/flaps", 0);
#  setprop("/autopilot/settings/true-heading-deg", orhe);
  setprop("/autopilot/locks/heading", "true-heading-hold");
  setprop("/autopilot/settings/max-roll-deg", 30);
}
}

###
#autopilot-AutopilotStealth--------------------------------
###
controls.apmodeast = func {

 WOW = getprop("/gear/gear[1]/wow");

if(WOW == 1) {
} else {

  setprop("sim/model/doors/apmodeast/position-norm",1);
  setprop("sim/model/doors/apmodeap/position-norm",0);
  setprop("/autopilot/locks/altitude", "altitude-hold");
  settimer(stealth, 0.5);
}
}

stealth = func {

#  alti = getprop("/autopilot/settings/target-altitude-ft");
#  hdng = getprop("/autopilot/settings/true-heading-deg");
#  aupo = getprop("sim/model/doors/apmodeap/position-norm");


  setprop("/autopilot/locks/speed", "Off");
  setprop("/controls/engines/engine[0]/throttle", 0.6);
  setprop("/controls/engines/engine[1]/throttle", 0.6);
  setprop("/controls/engines/engine[2]/throttle", 0.6);
  setprop("/controls/engines/engine[3]/throttle", 0.6);
  setprop("/autopilot/settings/target-climb-rate-fpm", 200);
  setprop("/autopilot/settings/target-descent-rate-fpm", 200);
  setprop("/autopilot/settings/vertical-speed-fpm", 200);
  setprop("/controls/flight/spoilers", 0);
  setprop("/controls/gear/gear-down", "false");
  setprop("/controls/flight/flaps", 0);
  setprop("/autopilot/locks/heading", "true-heading-hold");
  setprop("/autopilot/settings/max-roll-deg", 5);
  setprop("/autopilot/internal/max-roll-deg", 5);
if(getprop("sim/model/doors/apmodeap/position-norm") == 0) {
  settimer(stealth, 0.5);
  } else {
          settimer(controls.apmodeap, 1);
	}
}

###
#autopilot-LAnding--------------------------------
###
controls.apmodela = func {

kias = getprop("/velocities/airspeed-kt");

 setprop("sim/model/doors/apmodela/position-norm", 1);
 setprop("/autopilot/locks/speed", "speed-with-throttle");
 setprop("/autopilot/settings/target-speed-kt", 200);
 setprop("/controls/flight/spoilers", 0.4);
  if(kias < 210) {
    setprop("/controls/flight/spoilers", 0.7);
    setprop("/autopilot/settings/target-speed-kt", 160);
    setprop("/controls/gear/gear-down", "true");
      settimer(touchdown, 1);
          } else {
        settimer(controls.apmodela, 1);
	}
} # end function

touchdown = func {

if(getprop("/position/altitude-agl-ft") < 60) {
    setprop("/controls/flight/spoilers", 1.0);
    setprop("/autopilot/settings/target-speed-kt", 0);
    setprop("/controls/gear/gear-down", "true");
        if(getprop("/gear/gear[1]/wow") == 1) {
           setprop("/autopilot/locks/heading", "");
           setprop("/autopilot/locks/speed", "");
           setprop("/autopilot/locks/altitude", "");
           setprop("/controls/flight/elevator-trim", 0);
           setprop("sim/model/doors/apmodela/position-norm",0);
           } else {
                   settimer(touchdown,1);
			}
} else {
    setprop("/autopilot/locks/speed", "speed-with-throttle");
    setprop("/autopilot/settings/target-speed-kt", 160);
    settimer(touchdown, 1);
}
}
###
#fuelflow-totlb--------------------------------
###
#fuelflowlb = func {

#ffgph0 = getprop("/engines/engine[0]/fuel-flow-gph");
#ffgph1 = getprop("/engines/engine[1]/fuel-flow-gph");
#ffgph2 = getprop("/engines/engine[2]/fuel-flow-gph");
#ffgph3 = getprop("/engines/engine[3]/fuel-flow-gph");

#fflbtot = (ffgph0 * 33);
#setprop("/engines/engine[0]/fuel-flow-pph", fflbtot);

#fuelflowlb();
#}
