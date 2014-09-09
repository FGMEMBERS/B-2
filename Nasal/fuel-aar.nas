# Properties under /consumables/fuel/tank[n]:
# + level-gal_us    - Current fuel load.  Can be set by user code.
# + level-lbs       - OUTPUT ONLY property, do not try to set
# + selected        - boolean indicating tank selection.
# + density-ppg     - Fuel density, in lbs/gallon.
# + capacity-gal_us - Tank capacity 
#
# Properties under /engines/engine[n]:
# + fuel-consumed-lbs - Output from the FDM, zeroed by this script
# + out-of-fuel       - boolean, set by this code.

UPDATE_PERIOD = 0.3;


initialized = 0;
enabled = 0;

print ("running aar");

fuelUpdate = func {
#print ("fuel update running ");
    if(getprop("/sim/freeze/fuel" or !initialised)) { return registerTimer(); }
    
    AllEngines = props.globals.getNode("engines").getChildren("engine");
    
        Refueling = props.globals.getNode("/systems/refuel/contact");
        AllAircraft = props.globals.getNode("ai/models").getChildren("aircraft");
				AllMultiplayer = props.globals.getNode("ai/models").getChildren("multiplayer");
        Aircraft = props.globals.getNode("ai/models/aircraft");
        
#   select all tankers which are in contact. For now we assume that it must be in 
#		contact	with us.
                
        selectedTankers = [];
        
        if ( enabled ) { # check that AI Models are enabled, otherwise don't bother
            foreach(a; AllAircraft) {
                contact_node = a.getNode("refuel/contact");
                id_node = a.getNode("id");
                tanker_node = a.getNode("tanker");
                
                contact = contact_node.getValue();
                id = id_node.getValue();
                tanker = tanker_node.getValue();
                
#				print ("contact ", contact , " tanker " , tanker );
                            
                if (tanker and contact) {
                    append(selectedTankers, a);
                }
            }
						
						foreach(m; AllMultiplayer) {
                contact_node = m.getNode("refuel/contact");
                id_node = m.getNode("id");
                tanker_node = m.getNode("tanker");
                
                contact = contact_node.getValue();
                id = id_node.getValue();
                tanker = tanker_node.getValue();
                
#			print (" mp contact ", contact , " tanker " , tanker );
                            
                if (tanker and contact) {
                    append(selectedTankers, m);
                }
            }
        }
         
#		print ("tankers ", size(selectedTankers) );

        if ( size(selectedTankers) >= 1 ){
            Refueling.setBoolValue(1);
        } else {
            Refueling.setBoolValue(0);
        }
         
    # Sum the consumed fuel
    total = 0;
    foreach(e; AllEngines) {
        fuel = e.getNode("fuel-consumed-lbs", 1);
        consumed = fuel.getValue();
        if(consumed == nil) { consumed = 0; }
                total = total + consumed;
                fuel.setDoubleValue(0);
    }
        
        # Calculate fuel received
        
        if ( Refueling.getValue() ) {
            # assume max flow rate is 6000 lbs/min (for KC135)
                received = 100 * UPDATE_PERIOD; # lbs per sec
                total = total - received;
            # print ( "received " , received, " total ", total);
        }
        
    # Unfortunately, FDM initialization hasn't happened when we start
    # running.  Wait for the FDM to start running before we set any output
    # properties.  This also prevents us from mucking with FDMs that
    # don't support this fuel scheme.
    if(total == 0) { return registerTimer(); }
    if(!initialized) { initialize(); }

    AllTanks = props.globals.getNode("consumables/fuel").getChildren("tank");

    # Build a list of selected tanks.  Note the filtering for
    # "zero-capacity" tanks.  The FlightGear code likes to define
    # zombie tanks that have no meaning to the FDM, so we have to take
    # measures to ignore them here.
    selectedTanks = [];
    foreach(t; AllTanks) {
                cap = t.getNode("capacity-gal_us", 1).getValue();
        if(cap != nil and cap > 0.01) {
            if(t.getNode("selected", 1).getBoolValue()) {
                append(selectedTanks, t);
            }
        }
    }

    # Subtract fuel from tanks, set auxilliary properties.  Set out-of-fuel
    # when all tanks are dry.
        
    outOfFuel = 0;
    if(size(selectedTanks) == 0) {
        outOfFuel = 1;
    } else {
                if ( total >= 0 ) {
                        fuelPerTank = total / size(selectedTanks);
                        foreach(t; selectedTanks) {
                                ppg = t.getNode("density-ppg").getValue();
                                lbs = t.getNode("level-gal_us").getValue() * ppg;
                                lbs = lbs - fuelPerTank;
                                if(lbs < 0) {
                                        lbs = 0; 
                                        # Kill the engines if we're told to, otherwise simply
                                        # deselect the tank.
                                        if(t.getNode("kill-when-empty", 1).getBoolValue()) { outOfFuel = 1; }
                                        else { t.getNode("selected", 1).setBoolValue(0); }
                                }
                
                            gals = lbs / ppg;
                            t.getNode("level-gal_us").setDoubleValue(gals);
                            t.getNode("level-lbs").setDoubleValue(lbs);
        }
            } elsif ( total < 0 ) {
            
                    #find the number of tanks which can accept fuel
                    
                    available = 0;
                    
                    foreach(t; selectedTanks) {
                            ppg = t.getNode("density-ppg").getValue();
                            capacity = t.getNode("capacity-gal_us").getValue() * ppg;
                            lbs = t.getNode("level-gal_us").getValue()* ppg;
                            
                            if ( lbs < capacity ) {
                                    available = available + 1;
                            } # endif
                    } # end foreach
                    
                    if ( available > 0 ) {
                            
                            fuelPerTank = total / available;
                            
                            # add fuel to each available tank
                            
                            foreach(t; selectedTanks) {
                                    ppg = t.getNode("density-ppg").getValue();
                                    capacity = t.getNode("capacity-gal_us").getValue() * ppg;
                                    lbs = t.getNode("level-gal_us").getValue() * ppg;
                                    
                                    if ( capacity - lbs >= fuelPerTank) {
                                            lbs = lbs - fuelPerTank;
                                    } elsif (capacity - lbs < fuelPerTank) {
                                            lbs = capacity;
                                    }# endif
                                    
                                    gals = lbs / ppg;
                                    t.getNode("level-gal_us").setDoubleValue(gals);
                                    t.getNode("level-lbs").setDoubleValue(lbs);
                            } # end foreach
                                            
                    # print ("available ", available , " fuelPerTank " , fuelPerTank);
                    
                    }#	endif		
            } # end elsif
        } #endif
   
    
    # Total fuel properties
    gals = lbs = cap = 0;
    foreach(t; AllTanks) {
        cap = cap + t.getNode("capacity-gal_us").getValue();
        gals = gals + t.getNode("level-gal_us").getValue();
        lbs = lbs + t.getNode("level-lbs").getValue();
    } # end foreach
    setprop("/consumables/fuel/total-fuel-gals", gals);
    setprop("/consumables/fuel/total-fuel-lbs", lbs);
    setprop("/consumables/fuel/total-fuel-norm", gals/cap);

    foreach(e; AllEngines) {
        e.getNode("out-of-fuel").setBoolValue(outOfFuel);
    } # end foreach

    registerTimer();
}

# Initalize: Make sure all needed properties are present and accounted
# for, and that they have sane default values.

initialize = func {
    AllEngines = props.globals.getNode("engines").getChildren("engine");
    AllTanks = props.globals.getNode("consumables/fuel").getChildren("tank");
    AI_Enabled = props.globals.getNode("sim/ai/enabled");
    Refueling = props.globals.getNode("/systems/refuel/contact",1);
            
    Refueling.setBoolValue(0);
    enabled = AI_Enabled.getValue();
        
    foreach(e; AllEngines) {
        e.getNode("fuel-consumed-lbs", 1).setDoubleValue(0);
        e.getNode("out-of-fuel", 1).setBoolValue(0);
    }

    foreach(t; AllTanks) {
        initDoubleProp(t, "level-gal_us", 0);
        initDoubleProp(t, "level-lbs", 0);
        initDoubleProp(t, "capacity-gal_us", 0.01); # Not zero (div/zero issue)
        initDoubleProp(t, "density-ppg", 6.0); # gasoline

        if(t.getNode("selected") == nil) {
            t.getNode("selected", 1).setBoolValue(1);
        }
    }
        
    initialized = 1;
}

initDoubleProp = func {
    node = arg[0]; prop = arg[1]; val = arg[2];
    if(node.getNode(prop) != nil) {
        val = num(node.getNode(prop).getValue());
    }
    node.getNode(prop, 1).setDoubleValue(val);
}

# Fire it up
registerTimer = func {
    settimer(fuelUpdate, UPDATE_PERIOD);
}
registerTimer();
