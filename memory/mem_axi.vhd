library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
------------------------------------------------------------------------
---- AXI FIFO with common clock
------------------------------------------------------------------------



entity fifo_cc_axi is
  generic(
    DATA_WIDTH : natural := 16;
    DEPTH : natural := 5 ;
    use_last : boolean := false
  ); 

  port(
    clk       : in  std_logic := '0'; 
    rst       : in  std_logic := '0'; 
    RX_Data   : in  std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0'); 
    RX_Valid  : in  std_logic := '0'; 
    RX_Last   : in  std_logic := '0'; 
    RX_Ready  : out std_logic := '0'; 
    TX_Data   : out std_logic_vector(DATA_WIDTH-1 downto 0):= (others => '0');
    TX_Valid  : out std_logic := '0'; 
    TX_Last   : out std_logic := '0'; 
    TX_Ready  : in  std_logic := '0' ;
    counter : out std_logic_vector(DEPTH-1 downto 0) := (others => '0')
    
  );
end entity;

architecture rtl of fifo_cc_axi is


  function get_data_with(DATA_WIDTH : natural; use_last : boolean) return natural is
  begin
    if use_last then
      return DATA_WIDTH + 1;
    end if;
    return DATA_WIDTH;

  end function;

  constant  DATA_WIDTH1 : natural := get_data_with(DATA_WIDTH, use_last);

  signal  din   :  std_logic_vector(DATA_WIDTH1 -1  downto 0) := (others => '0'); 
  signal  wen   : std_logic := '0';
  signal  ren   : std_logic := '0';
  signal  ren_proto   : std_logic := '0';
  signal  dout  : std_logic_vector(DATA_WIDTH1 -1 downto 0)  := (others => '0');
  signal  full  : std_logic := '0';
  signal  empty : std_logic := '0';


begin
  e_fifo_cc : entity work.fifo_cc_v2 generic map(
    DATA_WIDTH =>  DATA_WIDTH1 ,
    DEPTH =>  DEPTH 
  ) port map (
    clk   => clk,
    rst   => rst,
    
    din   => din,
    wen   => wen,
    full  => full,


    ren   => ren,
    dout  => dout,
    empty => empty
    
  );
  gen : if use_last generate
    din      <=  RX_Last & RX_Data ;
  end generate gen;

  gen1 : if not use_last generate
    din      <=   RX_Data ;
  end generate gen1;


  
  wen      <= RX_Valid when full = '0' else '0';
  RX_Ready <= '1' when full ='0'  else '0'; 
  ren      <= ren_proto;-- when empty = '0' else '0';

  p_readout : process(clk) is
    variable fifo_buffer  : std_logic_vector(DATA_WIDTH1 - 1 downto 0)  := (others => '0');
    variable fifo_buffer_valid  : std_logic :=  '0';
    variable fifo_buffer1  : std_logic_vector(DATA_WIDTH1 -1 downto 0)  := (others => '0');
    variable fifo_buffer_valid1  : std_logic :=  '0';
    variable TX_Valid_buffer   : std_logic := '0';
    variable ReadEnable1 : std_logic := '0';
    variable reciving_data : std_logic := '0';

  begin
    if rising_edge(clk) then 

      if (ReadEnable1 = '1'  ) then 
        reciving_data := '1';
      end if;
      if empty = '0' then 
        ReadEnable1 := ren_proto;
      else 
        ReadEnable1 := '0';
      end if;

      ren_proto <= '0';




      if TX_Valid_buffer = '1' and TX_Ready = '1' then 
        TX_Valid_buffer := '0';
        TX_Data <= (others => '0');
        TX_Last <= '0';
      end if;

      
      
      if reciving_data = '1' and fifo_buffer_valid1 = '0' then 
        fifo_buffer1       := dout;
        fifo_buffer_valid1 := '1';
        reciving_data      := '0';
      end if;


      if fifo_buffer_valid1 = '1' and fifo_buffer_valid = '0' then 
        fifo_buffer := fifo_buffer1;
        fifo_buffer_valid := fifo_buffer_valid1;
        fifo_buffer_valid1 := '0';
      end if;


      if  fifo_buffer_valid = '1' and TX_Valid_buffer = '0' then 
        if use_last then
          TX_Data <= fifo_buffer(DATA_WIDTH -1  downto 0);
          TX_Last <= fifo_buffer(DATA_WIDTH);
        else
          TX_Data <= fifo_buffer(DATA_WIDTH -1  downto 0);
        end if;
        TX_Valid_buffer := '1';
        fifo_buffer_valid := '0';
      end if;


      if fifo_buffer_valid = '0' and empty ='0'  then 
        ren_proto <= '1';
      end if;


      TX_Valid <= TX_Valid_buffer;
    end if;
  end process;
end architecture;

