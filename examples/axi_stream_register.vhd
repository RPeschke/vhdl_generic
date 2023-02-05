library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.axi_stream_s32.all;
  use work.UtilityPkg.all;

entity axi_stream_register is
  generic (
    number_of_inputs : integer := 8;
    number_of_outputs : integer := 8
  );
  port (
    clk : in std_logic;
    rst : in std_logic;

    rx_m2s : in axi_stream_32_m2s;
    rx_s2m : out axi_stream_32_s2m;

    tx_m2s : out axi_stream_32_m2s;
    tx_s2m : in axi_stream_32_s2m;

    w32_inputs : in Word32Array( 0 to number_of_inputs - 1);
    w32_ouputs : out Word32Array( 0 to number_of_outputs - 1)
    

  );
end entity;


architecture rtl of axi_stream_register is
  signal rx : axi_stream_32_slave := axi_stream_32_slave_null;
  signal tx : axi_stream_32_master := axi_stream_32_master_null;
  signal i_counter : integer := 0;
  type state_t is (reading_s, writing_s);
  signal i_state : state_t := read_data_s;
  signal i_w32_ouputs :  Word32Array( 0 to number_of_outputs - 1);
begin

    rx.m2s <= rx_m2s;
    rx_s2m <= rx.s2m;

    tx_m2s <= tx.m2s;
    tx.s2m <= tx_s2m;

process(clk) is 
    variable buff : std_logic_vector(31 downto 0) := (others => '0');
begin 
    if rst = '1' then 
        rx <= axi_stream_32_slave_null;
        tx <= axi_stream_32_master_null;
        i_counter <= 0;
  
        i_state <= read_data_s;
        i_w32_ouputs <= (others => (others =>'0'));
        w32_ouputs <= (others => (others =>'0'));
        
    elsif rising_edge(clk) then 


        pull(rx);
        pull(tx);

        case (i_state) is
            when reading_s =>
                if isReceivingData(rx) then 
                    read_data(rx, buff);
                    i_w32_ouputs(i_counter) <= buff;
                    i_counter <= i_counter + 1;
                    if i_counter = number_of_outputs -2 or IsEndOfStream(rx) then 
                        i_state <= writing_s;
                        i_counter <= 0;
                    end if;
                end if;
                
            when writing_s => 
                w32_ouputs <= i_w32_ouputs;
                if ready_to_send(tx) then 
                    buff := w32_inputs(i_counter);
                    send_data(tx , buff);

                    i_counter <= i_counter + 1;
                    if i_counter = number_of_inputs -2  then 
                        i_state <= reading_s;
                        i_counter <= 0;
                        Send_end_Of_Stream(tx);
                    end if;

                end if;
        end case;




    end if;
end process;
end architecture;