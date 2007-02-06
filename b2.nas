
########
#
# Door functions
#
########

togglehatch = func {
    if (getprop("/controls/gear/brake-parking") == 1) {
        b2.hatch.toggle();
    } else {
        b2.hatch.close();
    }
}



    # Doors
    bombbay = aircraft.door.new("sim/model/doors/bombbay", 3.5);
    fuelhatch = aircraft.door.new("sim/model/doors/fuelhatch", 2.0);
    hatch = aircraft.door.new("sim/model/doors/hatch", 6.0);


#startup-properties--------------------------------------------------------------------

yaw_control = func {

   setprop("/autopilot/locks/heading", "nav1-hold");
   setprop("/sim/current-view/field-of-view", 60);
   rudder_loop();

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

#sets-rudder-trim-to-0-when-another-AP-mode-is-activated-------------
rudder_loop = func {

   wing_l = getprop("/autopilot/locks/heading");
   if(wing_l == "wing-leveler") {
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

