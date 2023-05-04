LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.axi_stream_s32.ALL;
USE work.axi_stream_32.ALL;
USE work.i2c_master_axi_interface_pack.ALL;
use work.axi_stream_s32_base.all;
  use work.i2c_master_pkg.all;

ENTITY i2c_master_axi_interface IS
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;

    rx_m2s : IN axi_stream_32_m2s;
    rx_s2m : OUT axi_stream_32_s2m;

    tx_m2s : OUT axi_stream_32_m2s;
    tx_s2m : IN axi_stream_32_s2m;


    i2c_m2s : out  i2c_master_m2s := i2c_master_m2s_null;
    i2c_s2m : in  i2c_master_s2m := i2c_master_s2m_null
    
  );
END ENTITY;

ARCHITECTURE rtl OF i2c_master_axi_interface IS


BEGIN


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
    variable tx : axi_stream_32_m := axi_stream_32_m_null;
    variable rx : axi_stream_32_s := axi_stream_32_s_null;
    variable i2c_tx : i2c_master_ht := i2c_master_null;
  BEGIN
    IF rising_edge(clk) THEN
      IF rst = '1' THEN
        reset(tx);
        reset(rx);
        reset(i2c_tx);
        buff := (OTHERS => '0');
        i2c_m_buff := i2c_master_t_null;

      ELSE
        pull(rx,     rx_m2s);
        pull(tx,     tx_s2m);
        pull(i2c_tx, i2c_s2m);

        i2c_m_buff := i2c_master_t_null;

        IF isReceivingData(rx) AND ready_to_send(tx) AND is_ready(i2c_tx) THEN
          
          read_data(rx, buff);
          i2c_m_buff := i2c_master_t_deserialize(buff);
          if i2c_m_buff.rw = i2c_write_c then 
            send_data(i2c_tx, i2c_m_buff.addr, i2c_m_buff.data);
          else
            request_data(i2c_tx, i2c_m_buff.addr);
          end if;
              
              
        END IF;

        IF  ready_to_send(tx) AND is_done(i2c_tx) THEN
          read_data(i2c_tx, i2c_m_buff);
          send_data(tx, i2c_master_t_serialize(i2c_m_buff));
        end if;

   
      END IF;

   
      push(rx ,    rx_s2m );
      push(i2c_tx, i2c_m2s);
      push(tx,     tx_m2s);

    END IF;
  END PROCESS;
END ARCHITECTURE;