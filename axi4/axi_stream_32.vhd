
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.axi_stream_s32_base.all;

package axi_stream_pgk_32 is





-- Starting Pseudo class axi_stream_32_master_stream
 
type axi_stream_32_master_stream is record 
data : std_logic_vector(31 downto 0); 
last : std_logic; 
ready : std_logic; 
valid : std_logic; 

end record axi_stream_32_master_stream; 

constant  axi_stream_32_master_stream_null: axi_stream_32_master_stream := (data => (others=>'0'),
last => '0',
ready => '0',
valid => '0');

 function  ready_to_send( this :   axi_stream_32_master_stream) return boolean;
 procedure send_data( this : inout axi_stream_32_master_stream; datain :in std_logic_vector);
 procedure Send_end_Of_Stream( this : inout axi_stream_32_master_stream);
 procedure pull( this : inout axi_stream_32_master_stream; signal DataIn : in  axi_stream_32_s2m);
 procedure push( this : inout axi_stream_32_master_stream; signal DataOut : out  axi_stream_32_m2s);
 
-- End Pseudo class axi_stream_32_master_stream



-- Starting Pseudo class axi_stream_32_slave_stream
 
type axi_stream_32_slave_stream is record 
data : std_logic_vector(31 downto 0); 
data_internal2 : std_logic_vector(31 downto 0); 
data_internal_isLast2 : std_logic; 
data_internal_isvalid2 : std_logic; 
data_internal_was_read2 : std_logic; 
data_isvalid : std_logic; 
last : std_logic; 
ready : std_logic; 
valid : std_logic; 

end record axi_stream_32_slave_stream; 

constant  axi_stream_32_slave_stream_null: axi_stream_32_slave_stream := (data => (others=>'0'),
data_internal2 => (others=>'0'),
data_internal_isLast2 => '0',
data_internal_isvalid2 => '0',
data_internal_was_read2 => '0',
data_isvalid => '0',
last => '0',
ready => '0',
valid => '0');

 function  IsEndOfStream( this :   axi_stream_32_slave_stream) return boolean;
 function  isReceivingData( this :   axi_stream_32_slave_stream) return boolean;
 procedure read_data( this : inout axi_stream_32_slave_stream; datain :out std_logic_vector);
 procedure pull( this : inout axi_stream_32_slave_stream; signal DataIn : in  axi_stream_32_m2s);
 procedure push( this : inout axi_stream_32_slave_stream; signal DataOut : out  axi_stream_32_s2m);
 
-- End Pseudo class axi_stream_32_slave_stream

type AXis_send_type_32 is ( 
  normal,
  endOfStream
 );
end axi_stream_pgk_32;


package body axi_stream_pgk_32 is
   

-- Starting Pseudo class axi_stream_32_master_stream
  function  ready_to_send( this :   axi_stream_32_master_stream) return boolean is begin 

    return this.valid = '0';
 
end function ready_to_send; 

 procedure send_data( this : inout axi_stream_32_master_stream; datain :in std_logic_vector) is begin 

   this.valid   := '1';
   this.data(datain'range)     := datain; 

 
end procedure ; 

 procedure Send_end_Of_Stream( this : inout axi_stream_32_master_stream) is begin 

      this.last := '1';  
     
end procedure ; 

 procedure pull( this : inout axi_stream_32_master_stream; signal DataIn : in  axi_stream_32_s2m) is begin 

this.ready := DataIn.ready;

        if (this.ready = '1') then 
          this.valid   := '0'; 
          this.last := '0';  
          this.data := (others => '0');
        end if;
 
end procedure ; 

 procedure push( this : inout axi_stream_32_master_stream; signal DataOut : out  axi_stream_32_m2s) is begin 

DataOut.data <= this.data;
DataOut.last <= this.last;
DataOut.valid <= this.valid;

 
end procedure ; 

 
-- End Pseudo class axi_stream_32_master_stream



-- Starting Pseudo class axi_stream_32_slave_stream
  function  IsEndOfStream( this :   axi_stream_32_slave_stream) return boolean is begin 

    return  this.data_internal_isvalid2 = '1' and  this.data_internal_isLast2 = '1';
 
end function ; 

 function  isReceivingData( this :   axi_stream_32_slave_stream) return boolean is begin 

    return  this.data_internal_isvalid2 = '1' ;
 
end function ; 

 procedure read_data( this : inout axi_stream_32_slave_stream; datain :out std_logic_vector) is begin 


    if(this.data_internal_isvalid2 = '1') then
        datain := this.data_internal2(datain'range);
        this.data_internal_was_read2 :='1';
    end if;
 
end procedure ; 

 procedure pull( this : inout axi_stream_32_slave_stream; signal DataIn : in  axi_stream_32_m2s) is begin 

this.data := DataIn.data;
this.last := DataIn.last;
this.valid := DataIn.valid;


    if( this.ready = '1'  and this.valid ='1') then 
        this.data_isvalid := '1';
    end if;

    this.data_internal_was_read2 := '0';
    this.ready := '0';


    if (this.data_isvalid ='1' and  this.data_internal_isvalid2 = '0') then
        this.data_internal2:= this.data ;
        this.data_internal_isvalid2 := this.data_isvalid;
        this.data_internal_isLast2 := this.last;
        this.data_isvalid:='0';

    end if;


    
 
end procedure ; 

 procedure push( this : inout axi_stream_32_slave_stream; signal DataOut : out  axi_stream_32_s2m) is begin 


    if (this.data_internal_was_read2 = '1'   ) then
      this.data_internal_isvalid2 := '0';
    end if;


    if (this.data_isvalid = '0'   and this.data_internal_isvalid2 = '0' ) then 
        this.ready := '1';
    end if;
    
DataOut.ready <= this.ready;

 
end procedure ; 

 
-- End Pseudo class axi_stream_32_slave_stream

end package body ;

