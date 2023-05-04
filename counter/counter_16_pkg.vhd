

library IEEE;

  use IEEE.numeric_std.all;
  use IEEE.std_logic_1164.all;
  
  use ieee.std_logic_unsigned.all;


package counter_16_pkg is 


  type counter_state is ( 
    idle,
    running,
    done
  );

  -------------------------------------------------------------------------
  ------- Start Psuedo Class time_span16 -------------------------

  type time_span16 is record 
    max : std_logic_vector(15 downto 0); 
    min : std_logic_vector(15 downto 0); 
  end record;


  constant time_span16_null : time_span16:= (
    max => (others => '0'),
    min => (others => '0')
  );


  type time_span16_a is array (natural range <>) of time_span16;

  ------- End Psuedo Class time_span16 -------------------------
  -------------------------------------------------------------------------


  -------------------------------------------------------------------------
  ------- Start Psuedo Class counter_16 -------------------------

  type counter_16 is record 
    Count : std_logic_vector(15 downto 0); 
    MaxCount : std_logic_vector(15 downto 0); 
    state : counter_state; 
  end record;


  constant counter_16_null : counter_16:= (
    Count => (others => '0'),
    MaxCount => (others => '0'),
    state => idle
  );


  type counter_16_a is array (natural range <>) of counter_16;

  procedure pull ( self : inout counter_16);
  -- empty procedure removed. name: 'push'
  procedure StartCountTo (self : inout counter_16; MaxCount :  in  std_logic_vector);
  procedure StartCountFromTo (self : inout counter_16; MinCount :  in  std_logic_vector; MaxCount :  in  std_logic_vector);
  procedure stopCounter (self : inout counter_16);
  function isReady (  self : counter_16) return boolean;
  function isRunning (  self : counter_16) return boolean;
  function isDone (  self : counter_16) return boolean;
  procedure reset (self : inout counter_16);
  function InTimeWindowSLV (  self : counter_16; TimeMin :   std_logic_vector; TimeMax :   std_logic_vector; DataIn :   std_logic_vector) return std_logic_vector;
  function InTimeWindowSl (  self : counter_16; TimeMin :   std_logic_vector; TimeMax :   std_logic_vector) return std_logic;
  function InTimeWindowSLV_r (  self : counter_16; TimeSpan : time_span16; DataIn :   std_logic_vector) return std_logic_vector;
  
  function InTimeWindowSLV_r_a (  self : counter_16; TimeSpan : time_span16_a; DataIn :   std_logic_vector) return std_logic_vector;
  
  function InTimeWindowSl_r (  self : counter_16; TimeSpan : time_span16) return std_logic;
  
  function InTimeWindowSl_r_a (  self : counter_16; TimeSpan : time_span16_a) return std_logic;
  ------- End Psuedo Class counter_16 -------------------------
  -------------------------------------------------------------------------


end package;


package body counter_16_pkg is

  -------------------------------------------------------------------------
  ------- Start Psuedo Class time_span16 -------------------------
  ------- End Psuedo Class time_span16 -------------------------
  -------------------------------------------------------------------------


  -------------------------------------------------------------------------
  ------- Start Psuedo Class counter_16 -------------------------
  procedure pull (  self : inout counter_16) is

  begin 


    -- Start Connecting


    -- End Connecting

    if (isRunning(self)) then 
      self.Count := self.Count + 1;

    end if;

    if (( isRunning(self) and self.Count >= self.MaxCount) ) then 
      self.state := done;
      self.Count :=  (others => '0');

    end if;


  end procedure;

  -- empty procedure removed. name: 'push'
  procedure StartCountTo ( self : inout counter_16; MaxCount :  in  std_logic_vector) is

  begin 

    if (isReady(self)) then 
      self.state := running;
      self.MaxCount := MaxCount;
      self.Count :=  (others => '0');

    end if;

  end procedure;

  procedure StartCountFromTo ( self : inout counter_16; MinCount :  in  std_logic_vector; MaxCount :  in  std_logic_vector) is

  begin 

    if (isReady(self)) then 
      self.state := running;
      self.MaxCount := MaxCount;
      self.Count := MinCount;

    end if;

  end procedure;

  procedure stopCounter ( self : inout counter_16) is

  begin 
    self.state := done;

  end procedure;

  function isReady (  self : counter_16) return boolean is

  begin 
    return self.state = idle;

  end function;

  function isRunning (  self : counter_16) return boolean is

  begin 
    return self.state = running;

  end function;

  function isDone (  self : counter_16) return boolean is

  begin 
    return self.state = done;

  end function;

  procedure reset ( self : inout counter_16) is

  begin 
    self.state := idle;
    self.Count :=  (others => '0');

  end procedure;

  function InTimeWindowSLV (  self : counter_16; TimeMin :   std_logic_vector; TimeMax :   std_logic_vector; DataIn :   std_logic_vector) return std_logic_vector is
    variable DataOut : std_logic_vector(DataIn'length -1 downto 0) := (others => '0'); 

  begin 
    DataOut :=  (others => '0');

    if (( isRunning(self) and TimeMin <= self.Count and self.Count < TimeMax) ) then 
      DataOut := DataIn;

    end if;
    return DataOut;

  end function;

  function InTimeWindowSl (  self : counter_16; TimeMin :   std_logic_vector; TimeMax :   std_logic_vector) return std_logic is
    variable DataOut : std_logic := '0'; 

  begin 
    DataOut := '0';

    if (( isRunning(self) and TimeMin <= self.Count and self.Count < TimeMax) ) then 
      DataOut := '1';

    end if;
    return DataOut;

  end function;

  function InTimeWindowSLV_r (  self : counter_16; TimeSpan : time_span16; DataIn :   std_logic_vector) return std_logic_vector is
    variable DataOut : std_logic_vector(DataIn'length -1 downto 0) := (others => '0'); 

  begin 
    DataOut :=  (others => '0');

    if (( isRunning(self) and TimeSpan.min <= self.Count and self.Count < TimeSpan.max) ) then 
      DataOut := DataIn;

    end if;
    return DataOut;

  end function;
  
  function InTimeWindowSLV_r_a (  self : counter_16; TimeSpan : time_span16_a; DataIn :   std_logic_vector) return std_logic_vector  is
    variable DataOut : std_logic_vector(DataIn'length -1 downto 0) := (others => '0'); 
  begin 
    DataOut :=  (others => '0');
    for i1 in 0 to TimeSpan'length -1 loop 
     if  InTimeWindowSl_r(self, TimeSpan(i1)) = '1' then 
       DataOut := DataIn;
       return DataOut;
     end if;
    end loop;
    return DataOut;
  end function;
  
  function InTimeWindowSl_r (  self : counter_16; TimeSpan : time_span16) return std_logic is
    variable DataOut : std_logic := '0'; 

  begin 
    DataOut := '0';

    if (( isRunning(self) and TimeSpan.min <= self.Count and self.Count < TimeSpan.max) ) then 
      DataOut := '1';

    end if;
    return DataOut;

  end function;

  function InTimeWindowSl_r_a (  self : counter_16; TimeSpan : time_span16_a) return std_logic is 
  begin 
    for i1 in 0 to TimeSpan'length -1 loop 
     if  InTimeWindowSl_r(self, TimeSpan(i1)) = '1' then 
      return '1';
     end if;
    end loop;

    return '0';
  end function;

  ------- End Psuedo Class counter_16 -------------------------
  -------------------------------------------------------------------------


end package body;
