


library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  USE work.i2c_master_axi_interface_pack.ALL;

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

    type i2c_master_ht is record
        m2s : i2c_master_m2s;
        s2m : i2c_master_s2m;
        internal  :i2c_master_t;
        old_busy : std_logic;
        Internal_valid : std_logic;
    end record;

    constant i2c_master_null : i2c_master_ht := (
        m2s => i2c_master_m2s_null,
        s2m => i2c_master_s2m_null,
        internal  => i2c_master_t_null,
        old_busy => '0',
        Internal_valid => '0'
    );


    procedure pull(self : inout i2c_master_ht;  s2m         : in  i2c_master_s2m);
    procedure push(self : inout i2c_master_ht; signal  m2s         : out  i2c_master_m2s);
    function is_ready(self : i2c_master_ht) return boolean;
    procedure send_data(self : inout i2c_master_ht; addr : std_logic_vector ;  data : std_logic_vector);
    procedure request_data(self : inout i2c_master_ht; addr : std_logic_vector);
    procedure reset(self : inout i2c_master_ht);
    function is_done(self : i2c_master_ht) return boolean;
    procedure read_data(self : inout i2c_master_ht; data_out : out i2c_master_t);



end package;

package body i2c_master_pkg is 

      function convert_to_1_0 (data : STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
        variable result : STD_LOGIC_VECTOR(data'range) := (OTHERS => '1');
      begin

        for i in data'range loop
          if data(i) = '0' then
            result(i) := '0';
          end if;
        end loop;

        return result;
      end function; 

    procedure pull(self : inout i2c_master_ht;  s2m         : in  i2c_master_s2m) is 
    begin 
        
        self.old_busy := self.s2m.busy;
        self.s2m := s2m;

        if self.old_busy  = '1' and self.s2m.busy = '0' then 
            if self.internal.rw = i2c_read_c then 
                self.internal.data := convert_to_1_0(self.s2m.data_rd);
            end if;
            self.Internal_valid := '1';
            self.internal.ack_error := self.s2m.ack_error;
            
        end if;
        if self.s2m.busy = '1' then 
            reset(self);
        end if;

    end procedure;


    procedure push(self : inout i2c_master_ht; signal  m2s         : out  i2c_master_m2s) is 
    begin 
    
        m2s <= self.m2s;
    end procedure;

    function is_ready(self : i2c_master_ht) return boolean is 
    begin 
        return not self.m2s.ena= '1' and not self.s2m.busy = '1';
    end function;

    procedure send_data(self : inout i2c_master_ht; addr : std_logic_vector ;  data : std_logic_vector) is
    begin 
        self.m2s.ena := '1';
        self.m2s.addr := addr(self.m2s.addr'range);
        self.m2s.rw := '0';
        self.m2s.data_wr := data(self.m2s.data_wr'range);

        self.internal.addr := addr(self.internal.addr'range);
        self.internal.data := data(self.internal.data'range);
        self.internal.rw := i2c_write_c;
    end procedure;

    procedure reset(self : inout i2c_master_ht) is
    begin 
        self.m2s := i2c_master_m2s_null;
        self.old_busy := '0';
        self.Internal_valid := '0';
    end procedure;
    
    procedure request_data(self : inout i2c_master_ht; addr : std_logic_vector) is 
    begin 
        self.m2s.ena := '1';
        self.m2s.addr := addr(self.m2s.addr'range);
        self.m2s.rw := i2c_read_c;

        self.internal.addr := addr(self.internal.addr'range);
        self.internal.rw := i2c_read_c;
    end procedure;

    function is_done(self : i2c_master_ht) return boolean is 
    begin 
        return self.Internal_valid = '1';
    end function;
    
    procedure read_data(self : inout i2c_master_ht; data_out : out i2c_master_t) is 
    begin 
        data_out := self.internal;
        self.Internal_valid := '0';
    end procedure;
    

end package body;
