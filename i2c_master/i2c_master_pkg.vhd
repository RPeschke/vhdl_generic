


library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

package i2c_master_pkg is 

    TYPE i2c_master_m2s IS RECORD
        ena       : STD_LOGIC;
        addr      : STD_LOGIC_VECTOR(6 DOWNTO 0);
        rw        : STD_LOGIC;
        data_wr   : STD_LOGIC_VECTOR(7 DOWNTO 0);
    END RECORD;

    CONSTANT i2c_master_m2s_null : i2c_master_m2s := (
        ena       => '0',
        addr      => (others => '0'),
        rw        => '0',
        data_wr   => (others => '0')
    );

    TYPE i2c_master_s2m is RECORD
        busy      : STD_LOGIC;
        data_rd   : STD_LOGIC_VECTOR(7 DOWNTO 0);
        ack_error : STD_LOGIC;
    END RECORD;   

    constant i2c_master_s2m_null : i2c_master_s2m := (
        busy      => '0',
        data_rd   => (others => '0'),
        ack_error => '0'
    );

    type i2c_master_t is record
        m2s : i2c_master_m2s;
        s2m : i2c_master_s2m;
    end record;

    constant i2c_master_null : i2c_master_t := (
        m2s => i2c_master_m2s_null,
        s2m => i2c_master_s2m_null
    );


    procedure pull(self : inout i2c_master_t;  s2m         : in  i2c_master_s2m);
    procedure push(self : inout i2c_master_t; signal  m2s         : out  i2c_master_m2s);
    function is_ready(self : i2c_master_t) return boolean;
    procedure send_data(self : inout i2c_master_t; addr : std_logic_vector ;  data : std_logic_vector);
    procedure reset(self : inout i2c_master_t);

end package;

package body i2c_master_pkg is 

    procedure pull(self : inout i2c_master_t;  s2m         : in  i2c_master_s2m) is 
    begin 
        self.s2m := s2m;
        if self.s2m.busy = '1' then 
            reset(self);
        end if;

    end procedure;


    procedure push(self : inout i2c_master_t; signal  m2s         : out  i2c_master_m2s) is 
    begin 
        m2s <= self.m2s;
    end procedure;

    function is_ready(self : i2c_master_t) return boolean is 
    begin 
        return not self.m2s.ena= '1' and not self.s2m.busy = '1';
    end function;

    procedure send_data(self : inout i2c_master_t; addr : std_logic_vector ;  data : std_logic_vector) is
    begin 
        self.m2s.ena := '1';
        self.m2s.addr := addr(self.m2s.addr'range);
        self.m2s.rw := '0';
        self.m2s.data_wr := data(self.m2s.data_wr'range);
    end procedure;

    procedure reset(self : inout i2c_master_t) is
    begin 
        self.m2s := i2c_master_m2s_null;
    end procedure;

end package body;
