
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

package i2c_master_axi_interface_pack is 

    type i2c_master_t is record
        addr      :      STD_LOGIC_VECTOR(6 DOWNTO 0); 
        rw        :      STD_LOGIC;                    
        data      :      STD_LOGIC_VECTOR(7 DOWNTO 0); 
        ack_error :      STD_LOGIC                    ;
    end record;
    constant  i2c_master_t_null :   i2c_master_t :=(
        addr      =>   (others => '0'),
        rw        =>   '0',
        data      =>   (others => '0'),
        ack_error =>   '0'
    );
      
    

    function i2c_master_t_serialize  ( self    :      i2c_master_t ) return std_logic_vector;
    function i2c_master_t_deserialize( self    :  std_logic_vector ) return     i2c_master_t;

    function i2c_read( addr      :      STD_LOGIC_VECTOR ) return i2c_master_t;

    function i2c_write( addr      :      STD_LOGIC_VECTOR ; data      :      STD_LOGIC_VECTOR  ) return i2c_master_t;
    
    subtype  i2c_master_t_s is  std_logic_vector( i2c_master_t.addr'length + i2c_master_t.data'length + 1 downto 0) ;

    constant i2c_read_c : std_logic := '1';
    constant i2c_write_c : std_logic := '0';
end package;


package body i2c_master_axi_interface_pack is 

    function i2c_master_t_serialize  ( self    :      i2c_master_t ) return std_logic_vector is 
        variable ret : std_logic_vector( self.addr'length + self.data'length + 1 downto 0) := (others =>'0');
    begin 
        ret(self.addr'length -1 downto 0) := self.addr;
        ret(self.data'length + self.addr'length -1 downto self.addr'length) := self.data;
        ret(self.data'length + self.addr'length) := self.rw;
        ret(self.data'length + self.addr'length + 1) := self.ack_error;
        return ret;
    end function;
    
    function i2c_master_t_deserialize( self    :  std_logic_vector ) return     i2c_master_t is 
        variable ret : i2c_master_t;
    begin 
        ret.ack_error := self(ret.data'length + ret.addr'length + 1                      );
        ret.rw        := self(ret.data'length + ret.addr'length                          );
        ret.data      := self(ret.data'length + ret.addr'length -1 downto ret.addr'length);
        ret.addr      := self(                  ret.addr'length -1 downto               0);
        return ret;
    end function;

    function i2c_read( addr      :      STD_LOGIC_VECTOR ) return i2c_master_t is 
        variable ret : i2c_master_t :=i2c_master_t_null;
    begin 
        ret.addr := addr(ret.addr'range);
        ret.rw   := i2c_read_c;
        return ret; 
    end function;

    function i2c_write( addr      :      STD_LOGIC_VECTOR ; data      :      STD_LOGIC_VECTOR  ) return i2c_master_t is 
        variable ret : i2c_master_t :=i2c_master_t_null;
    begin 
        ret.addr := addr(ret.addr'range);
        ret.rw   := i2c_write_c;
        ret.data := data(ret.data'range);
        return ret; 
    end function;

end package body;