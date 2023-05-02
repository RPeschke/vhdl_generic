LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.axi_stream_s32.ALL;
USE work.axi_stream_pgk_32.ALL;
USE work.i2c_master_axi_interface_pack.ALL;
use work.axi_stream_s32_base.all;

ENTITY i2c_master_axi_interface IS
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;

    rx_m2s : IN axi_stream_32_m2s;
    rx_s2m : OUT axi_stream_32_s2m;

    tx_m2s : OUT axi_stream_32_m2s;
    tx_s2m : IN axi_stream_32_s2m;

    ena : OUT STD_LOGIC;
    addr : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    rw : OUT STD_LOGIC;
    data_wr : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    busy : IN STD_LOGIC;
    data_rd : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    ack_error : IN STD_LOGIC
  );
END ENTITY;

ARCHITECTURE rtl OF i2c_master_axi_interface IS
  
  SIGNAL tx : axi_stream_32_master := axi_stream_32_master_null;
  TYPE state_t IS (s_idle, s_busy, s_done);
  SIGNAL i_state : state_t := s_idle;
  signal i_i2c_m_buff : i2c_master_t;

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
BEGIN

  tx_m2s <= tx.m2s;
  tx.s2m <= tx_s2m;
  
--  rx.m2s <= rx_m2s;
  --rx_s2m <= rx.s2m;
 -- connect(rx, rx_m2s, rx_s2m);

  fifo : ENTITY work.fifo_cc_axi_32

    PORT MAP(
      clk => clk,
      rst => rst,
      RX_m2s => open,  --rx_m2s,
      RX_s2m => open, -- rx_s2m,

      TX_m2s => open, --rx.m2s,
      TX_s2m => open, --rx.s2m,
      counter => OPEN

    );

  PROCESS (clk) IS
    VARIABLE buff : i2c_master_t_s;
    VARIABLE i2c_m_buff : i2c_master_t;
    variable v_rx : axi_stream_32_slave_stream := axi_stream_32_slave_stream_null;
  BEGIN
    IF rising_edge(clk) THEN
      IF rst = '1' THEN
        
        reset(tx);

        addr <= (OTHERS => '0');
        rw <= '0';
        data_wr <= (OTHERS => '0');
        buff := (OTHERS => '0');
        i2c_m_buff := i2c_master_t_null;

      ELSE
        pull(v_rx ,rx_m2s );
        pull(tx);

        CASE (i_state) IS
          
          
          WHEN s_idle =>
            addr <= (OTHERS => '0');
            data_wr <= (OTHERS => '0');
            rw <= '0';
            ena <= '0';
            IF isReceivingData(v_rx) AND ready_to_send(tx) AND busy = '0' THEN
              i_state <= s_busy;
              read_data(v_rx, buff);
              i2c_m_buff := i2c_master_t_deserialize(buff);
              addr <= i2c_m_buff.addr;
              data_wr <= i2c_m_buff.data;
              rw <= i2c_m_buff.rw;
              ena <= '1';
            END IF;


          WHEN s_busy =>
            IF busy = '1' THEN
              i_state <= s_done;
              ena <= '0';
            END IF;


          WHEN s_done =>
            IF busy = '0' AND ready_to_send(tx) THEN
              i_state <= s_idle;
              i2c_m_buff.ack_error := ack_error;
              if i2c_m_buff.rw = i2c_read_c then 
                i2c_m_buff.data := convert_to_1_0(data_rd);
              end if;
              buff := i2c_master_t_serialize(i2c_m_buff);
              send_data(tx, buff);
            END IF;
        END CASE;
      END IF;
      i_i2c_m_buff  <= i2c_m_buff;
      push(v_rx ,rx_s2m );
    END IF;
  END PROCESS;
END ARCHITECTURE;