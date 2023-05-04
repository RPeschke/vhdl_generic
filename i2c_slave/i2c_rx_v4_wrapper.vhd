LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.i2c_rx_v3_pac.ALL;
ENTITY i2c_rx_v4_wrapper IS
  GENERIC (
    nr_of_input_addresses : INTEGER := 1;
    nr_of_output_addresses : INTEGER := 1
  );
  PORT (
    clk : IN STD_LOGIC;
    DReset : IN STD_LOGIC;
    asic_addr : IN i2c_addr_t;
    scl : IN STD_LOGIC;
    sda : IN STD_LOGIC;
    sda_out : OUT STD_LOGIC;
    write_enable : OUT STD_LOGIC;
    i2c_data_in : IN i2c_data_t_a(nr_of_input_addresses - 1 DOWNTO 0);
    i2c_data_out : OUT i2c_data_t_a(nr_of_output_addresses - 1 DOWNTO 0);
    i2c_data_out_trig : OUT STD_LOGIC_VECTOR(nr_of_output_addresses - 1 DOWNTO 0)
  );
END ENTITY;

ARCHITECTURE rtl OF i2c_rx_v4_wrapper IS
  SIGNAL read_write_mode : STD_LOGIC;
  SIGNAL data_index : i2c_data_t;
  SIGNAL data_out : i2c_data_t;
  SIGNAL data_in : i2c_data_t;

  SIGNAL i_addr : i2c_data_t;
  SIGNAL i_data : i2c_data_t;

  PURE FUNCTION maximum1(a, b : INTEGER) RETURN INTEGER IS
BEGIN

  IF a > b THEN
    RETURN a;
  END IF;

  RETURN b;
END FUNCTION;

CONSTANT maximum_number_of_packages : INTEGER := maximum1(nr_of_output_addresses, nr_of_input_addresses) + 10;
BEGIN
u_i2c : ENTITY work.i2c_rx_v4
  GENERIC MAP(
    maximum_number_of_packages => maximum_number_of_packages
  )
  PORT MAP(
    clk => clk,
    DReset => DReset,
    scl => scl,
    sda => sda,
    sda_out => sda_out,
    write_enable => write_enable,
    asic_addr => asic_addr,

    read_write_mode => read_write_mode,
    data_index => data_index,
    data_out => data_out,
    data_in => data_in
  );

PROCESS (clk) IS
BEGIN
  IF rising_edge(clk) THEN
    IF DReset = '1' THEN
      i2c_data_out <= (OTHERS => (OTHERS => '0'));
      data_in <= (OTHERS => '0');

    END IF;
    i2c_data_out_trig <= (OTHERS => '0');
    IF read_write_mode = '0' THEN
      IF data_index = x"02" THEN
        i_addr <= data_out;
      ELSIF data_index = x"03" THEN
        IF to_integer(unsigned(i_addr)) < i2c_data_out'length THEN
          i2c_data_out(to_integer(unsigned(i_addr))) <= data_out;
          i2c_data_out_trig(to_integer(unsigned(i_addr))) <= '1';
        END IF;
      END IF;
    END IF;
    IF 0 < to_integer(unsigned(data_index)) AND to_integer(unsigned(data_index)) < i2c_data_in'length THEN
      data_in <= i2c_data_in(to_integer(unsigned(data_index)) - 1);
    ELSE
      data_in <= (OTHERS => '1');
    END IF;
  END IF;
END PROCESS;
END ARCHITECTURE;