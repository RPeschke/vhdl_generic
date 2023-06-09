library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  USE work.axi_stream_s32.ALL;
  USE work.i2c_master_axi_interface_pack.ALL;
  use work.axi_stream_s32_base.all;
  use work.i2c_master_pkg.all;

entity i2c_master_axi is
  GENERIC(
    input_clk : INTEGER := 50_000_000; --input clock speed from user logic in Hz
    bus_clk   : INTEGER := 400_000   --speed the i2c bus (scl) will run at in Hz
  );
  port (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;

    rx_m2s : IN axi_stream_32_m2s;
    rx_s2m : OUT axi_stream_32_s2m;

    tx_m2s : OUT axi_stream_32_m2s;
    tx_s2m : IN axi_stream_32_s2m;
    sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
    scl       : INOUT  STD_LOGIC                     --serial clock output of i2c bus

  );
end entity;

architecture rtl of i2c_master_axi is
    signal rst_n :  STD_LOGIC;

    signal scl_out   :   STD_LOGIC;
    signal sda_out   :   STD_LOGIC :='0';

    signal i2c_m2s :  i2c_master_m2s := i2c_master_m2s_null;
    signal i2c_s2m :  i2c_master_s2m := i2c_master_s2m_null;
begin
i2c_axi  : ENTITY work.i2c_master_axi_interface PORT map(
    clk => clk,
    rst => rst,

    rx_m2s => rx_m2s,
    rx_s2m => rx_s2m,

    tx_m2s => tx_m2s,
    tx_s2m => tx_s2m,

    i2c_m2s => i2c_m2s,
    i2c_s2m => i2c_s2m
  );

    rst_n <= not rst;
i2c : ENTITY work.i2c_master GENERIC map(
    input_clk => input_clk, 
    bus_clk   => bus_clk) PORT map(
    clk => clk,
    reset_n => rst_n,
    i2c_m2s => i2c_m2s,
    i2c_s2m => i2c_s2m,
    sda     => sda,
    scl     => scl,
    scl_out  => scl_out,
    sda_out   =>sda_out   
    );

end architecture;