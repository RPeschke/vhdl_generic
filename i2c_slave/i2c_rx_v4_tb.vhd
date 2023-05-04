LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.i2c_rx_v3_pac.ALL;
ENTITY i2c_rx_v4_tb IS
  PORT (

    clk : IN STD_LOGIC; --system clock
    DReset : IN STD_LOGIC;
    ena : IN STD_LOGIC; --latch in command
    addr : IN STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
    rw : IN STD_LOGIC; --'0' is write, '1' is read
    data_wr : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
    busy : OUT STD_LOGIC; --indicates transaction in progress
    data_rd : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
    ack_error : OUT STD_LOGIC; --flag if improper acknowledge from slave
    sda : OUT STD_LOGIC; --serial data output of i2c bus
    scl : OUT STD_LOGIC; --serial clock output of i2c bus
    regisers_out : OUT i2c_data_t_a(7 DOWNTO 0)
  );
END ENTITY;

ARCHITECTURE rtl OF i2c_rx_v4_tb IS

  SIGNAL clk1 : STD_LOGIC;
  SIGNAL i_scl : STD_LOGIC;
  SIGNAL i_sda : STD_LOGIC;

  SIGNAL i_scl1 : STD_LOGIC;
  SIGNAL i_sda1 : STD_LOGIC;
  SIGNAL i_ack_error : STD_LOGIC;

  SIGNAL sda_out : STD_LOGIC;
  SIGNAL write_enable : STD_LOGIC;
  SIGNAL i_data_rd : STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave

  SIGNAL i_rd_addr : i2c_addr_t_a(4 DOWNTO 0);
  SIGNAL i_rd_data : i2c_data_t_a(4 DOWNTO 0);

  SIGNAL i_wr_addr : i2c_addr_t_a(4 DOWNTO 0);
  SIGNAL i_wr_data : i2c_data_t_a(4 DOWNTO 0);
  SIGNAL i_wr_data_trig : STD_LOGIC_VECTOR(i_wr_data'RANGE);
  SIGNAL asic_addr : i2c_addr_t;
  SIGNAL read_write_mode : STD_LOGIC;
  SIGNAL data_index : i2c_data_t;
  SIGNAL data_out : i2c_data_t;
  SIGNAL data_in : i2c_data_t;

  SIGNAL i_reset_n : STD_LOGIC;

  SIGNAL i_register_1_out : i2c_data_t;

  PURE FUNCTION to_one_zero(self : STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR IS
  VARIABLE ret : STD_LOGIC_VECTOR(self'RANGE);
BEGIN
  FOR i IN self'RANGE LOOP
    IF self(i) = '0' THEN
      ret(i) := '0';
    ELSE
      ret(i) := '1';
    END IF;
  END LOOP;
  RETURN ret;
END FUNCTION;
BEGIN

i_reset_n <= NOT DReset;
i_scl <= 'H';
i_sda <= 'H';

sda <= i_sda1;
scl <= i_scl1;
i_sda1 <= '0' WHEN i_sda = '0' ELSE
  '1';
i_scl1 <= '0' WHEN i_scl = '0' ELSE
  '1';
ack_error <= '0' WHEN i_ack_error = '0' ELSE
  '1';
data_rd <= to_one_zero(i_data_rd);
DUT_sender : ENTITY work.i2c_master
  GENERIC MAP(
    input_clk => 10,
    bus_clk => 1
    ) PORT MAP(

    clk => clk,
    reset_n => i_reset_n,
    ena => ena,
    addr => addr,
    rw => rw,
    data_wr => data_wr,
    busy => busy,
    data_rd => i_data_rd,
    ack_error => i_ack_error,
    sda => i_sda,
    scl => i_scl

  );

i_sda <= '0' WHEN write_enable = '1' AND sda_out = '0' ELSE
  'Z';
clk_gen : ENTITY work.ClockGenerator GENERIC MAP (CLOCK_period => 0.01 ns) PORT MAP (clk => clk1);
dut_receiver : ENTITY work.i2c_rx_v4_wrapper
  GENERIC MAP(
    nr_of_input_addresses => i_rd_data'length,
    nr_of_output_addresses => i_wr_data'length
  )
  PORT MAP(
    clk => clk1,
    DReset => DReset,

    scl => i_scl1,
    sda => i_sda1,
    sda_out => sda_out,
    write_enable => write_enable,

    asic_addr => asic_addr,
    i2c_data_in => i_rd_data,
    i2c_data_out => i_wr_data,
    i2c_data_out_trig => i_wr_data_trig

  );
asic_addr <= to_i2c_addr_t(53);
PROCESS (clk) IS
BEGIN
  IF rising_edge(clk) THEN
    IF DReset = '1' THEN
      i_rd_addr <= (OTHERS => (OTHERS => '0'));
      i_rd_data <= (OTHERS => (OTHERS => '0'));
      i_wr_addr <= (OTHERS => (OTHERS => '0'));
      data_in <= (OTHERS => '0');
      regisers_out <= (OTHERS => (OTHERS => '0'));
    END IF;
    set_addr_data(i_rd_addr, i_rd_data, 0, to_i2c_addr_t(53), x"12");
    set_addr_data(i_rd_addr, i_rd_data, 1, to_i2c_addr_t(12), x"31");
    set_addr_data(i_rd_addr, i_rd_data, 2, to_i2c_addr_t(12), x"32");
    set_addr_data(i_rd_addr, i_rd_data, 3, to_i2c_addr_t(12), x"33");

    --  set_addr_data_loop_back(i_rd_addr, i_rd_data, i_wr_addr, i_wr_data, 3, to_i2c_addr_t(20));
    --  set_addr_data_loop_back(i_rd_addr, i_rd_data, i_wr_addr, i_wr_data, 4, to_i2c_addr_t(21));

    --get_addr_data(i_wr_addr, i_wr_data, 5, to_i2c_addr_t(30) ,i_register_1_out );
    regisers_out(0) <= i_wr_data(0);
    regisers_out(1) <= i_wr_data(1);
    regisers_out(2) <= i_wr_data(2);
    regisers_out(3) <= i_wr_data(3);
    regisers_out(4) <= i_wr_data(4);

    --  regisers_out(1) <= i_rd_data(1);
    --  regisers_out(2) <= i_rd_data(2);
    --  regisers_out(3) <= i_rd_data(3);
    --  regisers_out(4) <= i_rd_data(4);
    --  regisers_out(5) <= i_register_1_out;
    IF data_index = x"01" THEN
      data_in <= x"AA";
    ELSIF data_index = x"02" THEN
      data_in <= x"BB";
    ELSIF data_index = x"03" THEN
      data_in <= x"CC";
    END IF;
    IF read_write_mode = '0' THEN
      IF data_index = x"01" THEN
        regisers_out(0) <= "0" & data_out(7 DOWNTO 1);
      ELSIF data_index = x"02" THEN
        regisers_out(1) <= data_out;
      ELSIF data_index = x"03" THEN
        regisers_out(2) <= data_out;
      END IF;
    END IF;

  END IF;
END PROCESS;
END ARCHITECTURE;