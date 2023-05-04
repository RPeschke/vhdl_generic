library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


package i2c_rx_v3_pac is 
  
  subtype i2c_data_t is std_logic_vector(8-1 downto 0);
  type i2c_data_t_a is array (natural range <>) of i2c_data_t;


  subtype i2c_addr_t is std_logic_vector(8-2 downto 0);
  type i2c_addr_t_a is array (natural range <>) of i2c_addr_t;

  procedure reset_s(signal  self : out i2c_data_t_a);

  procedure set_addr_data(  signal addr_self : out i2c_addr_t_a ; signal data_self : out i2c_data_t_a; id : integer ; addr : i2c_addr_t ; data : i2c_data_t );
   procedure set_addr_data_loop_back(  signal addr_self : out i2c_addr_t_a ; signal data_self : out i2c_data_t_a; signal addr_self_in : out i2c_addr_t_a ; signal data_self_in : in i2c_data_t_a;  id : integer ; addr : i2c_addr_t );
  pure function to_i2c_addr_t(addr : integer ) return i2c_addr_t;
end package;

package body i2c_rx_v3_pac is

  procedure reset_s(signal self : out i2c_data_t_a) is 
  begin
    self<= ( others => ( others => '0'));
  end procedure;
  procedure set_addr_data(  signal addr_self : out i2c_addr_t_a ; signal data_self : out i2c_data_t_a; id : integer ; addr : i2c_addr_t ; data : i2c_data_t ) is 
  begin 
    if id > addr_self'length then
      return ;
    end if;

    addr_self(id) <= addr;
    data_self(id) <= data;
  end procedure;

    procedure set_addr_data_loop_back(  signal addr_self : out i2c_addr_t_a ; signal data_self : out i2c_data_t_a; signal addr_self_in : out i2c_addr_t_a ; signal data_self_in : in i2c_data_t_a;  id : integer ; addr : i2c_addr_t ) is 
  begin 
    if id > addr_self'length then
      return ;
    end if;
    addr_self_in(id) <= addr;
    addr_self(id) <= addr;
    data_self(id) <= data_self_in(id);
  end procedure;

  pure function to_i2c_addr_t(addr : integer ) return i2c_addr_t is
  begin
  -- convert integer to std_logic_vector
    return std_logic_vector(to_unsigned(addr,7));
    
  end function;
end package body;