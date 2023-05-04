library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

  use work.i2c_rx_v3_pac.all;
Library UNISIM;
use UNISIM.vcomponents.all;

entity i2c_rx_v3_resender is
  generic (
    start_addr : integer := 10;
    num_of_registers : integer := 10
  );
  port (

    clk : in std_logic;
    rst : in std_logic;

    sda : inout std_logic;
    scl : inout std_logic;

    sda_out_o      : out std_logic;
	  write_enable_o : out std_logic
    



  );
end entity;


architecture rtl of i2c_rx_v3_resender is
  	signal sda_out      : std_logic;
	signal write_enable : std_logic;  
  
  signal sda_in      : std_logic;

    constant nr_of_input_addresses  : integer := num_of_registers;
    constant nr_of_output_addresses : integer := num_of_registers;

    signal  i2c_address_in  : i2c_addr_t_a(nr_of_input_addresses-1 downto 0);
    signal i2c_data_in     : i2c_data_t_a(nr_of_input_addresses-1 downto 0);

    signal i2c_address_out  : i2c_addr_t_a(nr_of_output_addresses-1 downto 0);
    signal i2c_data_out     : i2c_data_t_a(nr_of_output_addresses-1 downto 0);
    signal i2c_data_out_trig: std_logic_vector(nr_of_output_addresses-1 downto 0);
begin
    scl <= 'Z';
    sda_out_o <=sda_out;
    write_enable_o <= write_enable;


u_i2c :  entity work.i2c_rx_v3 generic map (
      nr_of_input_addresses => nr_of_input_addresses,
      nr_of_output_addresses => nr_of_output_addresses
  ) port map (
	clk    => clk,
	DReset => rst ,


	scl         => SCL,
	sda         => sda_in,
	sda_out      => sda_out,
	write_enable => write_enable,  

    i2c_address_in  => i2c_address_in,
    i2c_data_in    => i2c_data_in,

    i2c_address_out  => i2c_address_out,
    i2c_data_out     => i2c_data_out,
    i2c_data_out_trig => i2c_data_out_trig

  );


   -- SDA <= sda_out when write_enable ='1' else 'Z';
    IOBUF_inst : IOBUF
generic map (
   DRIVE => 12,
   IOSTANDARD => "DEFAULT",
   SLEW => "SLOW")
port map (
   O => sda_in,     -- Buffer output
   IO => SDA,   -- Buffer inout port (connect directly to top-level port)
   I => sda_out,     -- Buffer input
   T => not write_enable      -- 3-state enable input, high=input, low=output
);


    
    process (clk) is 
    begin 
    if rising_edge (clk) then 
        for i in i2c_address_in'range loop
            set_addr_data_loop_back(i2c_address_in, i2c_data_in, i2c_address_out, i2c_data_out, i,  to_i2c_addr_t(start_addr+i) );
        end loop;
    end if;
    end process;

end architecture;