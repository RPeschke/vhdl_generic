library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;



  
package bram_sdp_cc_pkg is 


    type mem_handler_t_m2s is record
        wea    :  std_logic;
        addra  :  std_logic_vector(32-1 downto 0); 
        dina   :  std_logic_vector(32-1 downto 0);
        addrb  :  std_logic_vector(32-1 downto 0);

    end record;

    constant mem_handler_t_m2s_null : mem_handler_t_m2s := (
        wea    =>'0',
        addra  =>(others => '0'),
        dina   =>(others => '0'),
        addrb  =>(others => '0')
        
    );


    type mem_handler_t_s2m is record
        addrb_out :  std_logic_vector(32-1 downto 0);
        doutb  :  std_logic_vector(32-1 downto 0);
      
    end record;

    constant mem_handler_t_s2m_null : mem_handler_t_s2m := (
        addrb_out => (others => '0'),
        doutb  => (others => '0')
        
    );


    type mem_handler_t is record
        m2s : mem_handler_t_m2s;
        s2m : mem_handler_t_s2m;
        do_push_back  : std_logic;

    end record;

    constant mem_handler_t_null : mem_handler_t := (
        m2s => mem_handler_t_m2s_null,
        s2m => mem_handler_t_s2m_null,
        do_push_back => '0'

    );


    procedure pull(self: inout mem_handler_t ; s2m : in mem_handler_t_s2m ) ;
    procedure push(self: inout mem_handler_t ; signal m2s : out mem_handler_t_m2s ) ;
    procedure push_back(self: inout mem_handler_t ; data :in  std_logic_vector) ;
    procedure write_data(self: inout mem_handler_t ; addr :in  std_logic_vector; data :in  std_logic_vector) ;
    procedure reset(self: inout mem_handler_t  ) ;
    
    procedure set_read_addr(self: inout mem_handler_t ; addr :in  std_logic_vector) ;
    procedure set_read_addr(self: inout mem_handler_t ; addr :in  integer) ;
    function  is_read_addr(self : mem_handler_t ;addr : std_logic_vector ) return boolean ;
    procedure set_read_addr_next(self: inout mem_handler_t) ;
    function  is_read_current(self : mem_handler_t ) return boolean ;
    function  is_done_streaming(self : mem_handler_t ) return boolean ;
    procedure read_data(self: inout mem_handler_t ; data :out  std_logic_vector) ;
    procedure read_data_s(self: inout mem_handler_t ; signal data :out  std_logic_vector) ;
    function read_data(self:  mem_handler_t) return  std_logic_vector ;
end package;

package body bram_sdp_cc_pkg is 


    procedure push_back(self: inout mem_handler_t ; data :in  std_logic_vector) is 
    begin 
            self.m2s.wea := '1';
            self.do_push_back := '1';
            self.m2s.dina := (others => '0');
            self.m2s.dina(data'range)  :=  data;
            
    end procedure;
    
    procedure write_data(self: inout mem_handler_t ; addr :in  std_logic_vector; data :in  std_logic_vector) is 
    begin 

            self.m2s.wea := '1';
        
            self.m2s.addra := (others => '0');
            self.m2s.addra(addr'range) :=  addr;
            self.m2s.dina:= (others => '0');
            self.m2s.dina(data'range)  :=  data;
    end procedure;

    procedure pull(self: inout mem_handler_t ; s2m : in mem_handler_t_s2m ) is 
    begin 
        self.s2m := s2m;
        self.m2s.wea := '0';
        self.m2s.dina := (others => '0');
        if self.do_push_back = '1' then 
            self.m2s.addra := std_logic_vector( unsigned( self.m2s.addra) + 1);
        end if;

        self.do_push_back := '0';
    end procedure;

    procedure push(self: inout mem_handler_t ; signal m2s : out mem_handler_t_m2s ) is 
    begin 

        m2s <= self.m2s;
    end procedure;

    procedure reset(self: inout mem_handler_t  ) is 
    begin 
        self.m2s := mem_handler_t_m2s_null;
        self.s2m := mem_handler_t_s2m_null;
    end procedure;

    procedure set_read_addr(self: inout mem_handler_t ; addr :in  std_logic_vector) is 
    begin 
        self.m2s.addrb(addr'range) := addr;
    end procedure;
    procedure set_read_addr(self: inout mem_handler_t ; addr :in  integer)  is 
        variable addr_v : std_logic_vector(self.m2s.addrb'range);
    begin
        addr_v := std_logic_vector(to_unsigned(addr, addr_v'length));
        self.m2s.addrb(addr_v'range) := addr_v;
    end procedure;

    function  is_read_addr(self : mem_handler_t ;addr : std_logic_vector ) return boolean is 
    begin 
        return self.s2m.addrb_out(addr'range) = addr;
    end function;

    
    procedure set_read_addr_next(self: inout mem_handler_t) is 
    begin 
        self.m2s.addrb := std_logic_vector( unsigned( self.m2s.addrb) + 1);
    end procedure;

    function  is_read_current(self : mem_handler_t ) return boolean is 
    begin 
        return self.m2s.addrb = self.s2m.addrb_out;
    end function;

    function  is_done_streaming(self : mem_handler_t ) return boolean is 
    begin 
        return unsigned( self.m2s.addra)  = unsigned( self.s2m.addrb_out);
    end function;

    procedure read_data(self: inout mem_handler_t ; data :out  std_logic_vector) is 
    begin 
        
        data := self.s2m.doutb(data'range);
    end procedure;

    procedure read_data_s(self: inout mem_handler_t ; signal data :out  std_logic_vector) is 
    begin 
        data <= self.s2m.doutb(data'range);
    end procedure;
    
    function read_data(self:  mem_handler_t) return  std_logic_vector  is 
    begin 
        return self.s2m.doutb;
    end function;

end package body;

