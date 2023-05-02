
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package axi_stream_s32_base is


-- Starting Pseudo class axi_stream_32_connection
 
type axi_stream_32_m2s is record 
  data : std_logic_vector(31 downto 0); 
  last : std_logic; 
  valid : std_logic; 

end record axi_stream_32_m2s; 

constant  axi_stream_32_m2s_null: axi_stream_32_m2s := 
  ( 
    data => (others=>'0'),
    last => '0',
    valid => '0'
  );

constant  axi_stream_32_m2s_Z: axi_stream_32_m2s := 
  ( 
    data => (others=>'Z'),
    last => 'Z',
    valid => 'Z'
  );
 
type axi_stream_32_s2m is record 
  ready : std_logic; 
end record axi_stream_32_s2m; 

constant  axi_stream_32_s2m_null: axi_stream_32_s2m := (ready => '0');
constant  axi_stream_32_s2m_Z: axi_stream_32_s2m := (ready => 'Z');
 

 end package;
