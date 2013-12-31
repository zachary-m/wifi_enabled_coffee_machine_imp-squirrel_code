imp.configure("voltage reader", [], []);
hardware.pin5.configure(ANALOG_IN);

class power_input extends InputPort
{
  name = "Power On"
  type = "number"
 
  function set(value)
  { 
        // update the display
        
        //server.show("Power On");
        
        imp.sleep(2);
        hardware.pin8.configure(DIGITAL_OUT);
        hardware.pin8.write(1);
        imp.sleep(2); 
        hardware.pin8.configure(DIGITAL_OUT);
        hardware.pin8.write(0);
        server.show("Power on requested" +" "+ checkpin5());
  }
}


class power_off extends InputPort
{
  name = "Power Off"
  type = "number"
 
  function set(value)
  { 
        // update the display
        
        //server.show("Power Off");
        
        imp.sleep(2); // if a user sends an "on" request immediately after the sent an "off" request then voltage will be going through the off switch and voltage will be at the "on" switch so nothing will happen. The two second wait prevents to request at the same time.
        hardware.pin7.configure(DIGITAL_OUT);
        hardware.pin7.write(1);
        imp.sleep(2); 
        hardware.pin7.configure(DIGITAL_OUT);
        hardware.pin7.write(0);
        server.show("Power off requested" +" "+ checkpin5());
  }
}


class power_cup extends InputPort
{
  name = "Power for one cup"
  type = "number"
 
  function set(value)
  {   
       server.show("Power for one cup"); // this is to make one cup of coffee. The code  is written this way so the imp does not fall a sleep while the machine is making coffee 
imp.wakeup(2, 
 function() {
        hardware.pin8.configure(DIGITAL_OUT);
        hardware.pin8.write(1);
  imp.wakeup(2, 
  function() {
    hardware.pin8.write(0);
    server.show("One cup requested" +" "+ checkpin5());    
    imp.wakeup(20,  // this is the time that the machine will be running it is not the exact time that it takes to make one cup
    function() {
      hardware.pin7.configure(DIGITAL_OUT);
      hardware.pin7.write(1);
      imp.wakeup(2, function() {
        hardware.pin7.write(0);
        server.show("One cup requested" +" "+ checkpin5());
      })
    })
  })
});
  }
}


function checkpin5() 
{
  local v = (hardware.pin5.read() / 65535) * hardware.voltage(); //checks to see if there is a voltage on the blue LED that is on when the machine is on. If there is a read of voltage then the code will return that the machine is on
  server.log(format("pin5 is at %.2f volts", v));
  if (v > 1.0) 
    return "Machine status: brewing";
  else 
    return "Machine status: not brewing";
}

imp.configure("CoffeeControlCenter", [power_input(), power_off(), power_cup()], []); 