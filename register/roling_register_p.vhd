library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

package roling_register_p is

  type registerT is record 
    address : std_logic_vector(15 downto 0);
    value   : std_logic_vector(15 downto 0);
  end record;

  constant registerT_null : registerT := (
    address => (others => '0'),
    value   => (others => '0')
  );

  type registerT_a is array (natural range <>) of registerT;


  
  -- procedure read_data(self : in registerT; value :out  STD_LOGIC_VECTOR; addr :in integer);

  function registerT_serialize(self : registerT) return std_logic_vector;
  function registerT_deserialize(self : std_logic_vector ) return registerT;
  procedure read_data_s(self : in registerT; signal value :out  STD_LOGIC_VECTOR ; addr :in integer);

end package;

package body roling_register_p is
  
  function registerT_serialize(self : registerT) return std_logic_vector is 
  begin 
    return self.address & self.value;
  end function;


  function registerT_deserialize(self : std_logic_vector ) return registerT is 
  variable ret :registerT := registerT_null;
  begin 
    ret.address := self(31 downto 16);
    ret.value   := self(15 downto 0);
    return ret;
  end function;

  
  procedure read_data_s(self : in registerT;signal value :out  std_logic_vector ; addr :in integer) is 
    variable m1 : integer := 0;
    variable m2 : integer := 0;
    variable m : integer := 0;
  begin
    m1 := value'length;
    m2 := self.value'length;

    if (m1 < m2) then 
      m := m1;
    else 
      m := m2;
    end if;

    if to_integer(signed(self.address)) = addr then
      value(m - 1 downto 0) <= self.value(  m - 1 downto 0);
    end if; 
  end procedure;

end package body;