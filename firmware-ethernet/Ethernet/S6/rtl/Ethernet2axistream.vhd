

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.UtilityPkg.all;
  use work.GigabitEthPkg.all;
  use work.axi_stream_s32.all;
library UNISIM;
use UNISIM.VComponents.all;


entity Ethernet2axistream is
    generic (
      NUM_IP_G        : integer := 2
    );
    port (
      clk             : out sl;

      gtTxP           : out sl;
      gtTxN           : out sl;
      gtRxP           :  in sl;
      gtRxN           :  in sl;
      gtClkP          :  in sl;
      gtClkN          :  in sl;
	  fabClkP         :  in sl;
	  fabClkN         :  in sl;
      -- SFP transceiver disable pin
      txDisable       : out sl;

      macAddr         : in  MacAddrType := MAC_ADDR_DEFAULT_C;
      ipAddrs         : in  IpAddrArray(NUM_IP_G-1 downto 0) := (others => IP_ADDR_DEFAULT_C);
      udpPorts        : in  Word16Array(NUM_IP_G-1 downto 0) := (others => (others => '0'));

      RX_m2s          : out  axi_stream_32_m2s_a(NUM_IP_G-1 downto 0);
      RX_s2m          : in   axi_stream_32_s2m_a(NUM_IP_G-1 downto 0);

      TX_m2s          : in   axi_stream_32_m2s_a(NUM_IP_G-1 downto 0);
      TX_s2m          : out  axi_stream_32_s2m_a(NUM_IP_G-1 downto 0)

  );
end entity;

architecture rtl of Ethernet2axistream is
    signal fabClk       : sl;
    signal ethClk62     : sl;
    signal ethClk125    : sl;
    signal led          : slv(15 downto 0);
    
    signal ethRxLinkSync  : sl;
    signal ethAutoNegDone : sl;
    signal userRst     : sl;


   -- User Data interfaces
   signal userTxDataChannels : Word32Array(NUM_IP_G-1 downto 0);
   signal userTxDataValids   : slv(NUM_IP_G-1 downto 0);
   signal userTxDataLasts    : slv(NUM_IP_G-1 downto 0);
   signal userTxDataReadys   : slv(NUM_IP_G-1 downto 0);
   signal userRxDataChannels : Word32Array(NUM_IP_G-1 downto 0);
   signal userRxDataValids   : slv(NUM_IP_G-1 downto 0);
   signal userRxDataLasts    : slv(NUM_IP_G-1 downto 0);
   signal userRxDataReadys   : slv(NUM_IP_G-1 downto 0);

begin

    connect : for i in 0 to NUM_IP_G-1 generate
        RX_m2s(i).data <= userRxDataChannels(i);
        RX_m2s(i).valid <= userRxDataValids(i);
        RX_m2s(i).last <= userRxDataLasts(i);
        userRxDataReadys(i) <= RX_s2m(i).ready;

        userTxDataChannels(i) <= TX_m2s(i).data;
        userTxDataValids(i) <= TX_m2s(i).valid;
        userTxDataLasts(i) <= TX_m2s(i).last;
        TX_s2m(i).ready <= userTxDataReadys(i);


    end generate;


    clk  <= ethClk125;            

   U_IBUFGDS : IBUFGDS port map ( I => fabClkP, IB => fabClkN, O => fabClk);

   --------------------------------
   -- Gigabit Ethernet Interface --
   --------------------------------
   U_S6EthTop : entity work.S6EthTop
      generic map (
         NUM_IP_G     => NUM_IP_G
      )
      port map (
         -- Direct GT connections
         gtTxP           => gtTxP,
         gtTxN           => gtTxN,
         gtRxP           => gtRxP,
         gtRxN           => gtRxN,
         gtClkP          => gtClkP,
         gtClkN          => gtClkN,
         -- Alternative clock input from fabric
         fabClkIn        => fabClk,
         -- SFP transceiver disable pin
         txDisable       => txDisable,
         -- Clocks out from Ethernet core
         ethUsrClk62     => ethClk62,
         ethUsrClk125    => ethClk125,
         -- Status and diagnostics out
         ethSync         => ethRxLinkSync,
         ethReady        => ethAutoNegDone,
         led             => led,
         -- Core settings in 
         macAddr         => macAddr,
         ipAddrs         => ipAddrs,
         udpPorts        => udpPorts,
         -- User clock inputs
         userClk         => ethClk125,
         userRstIn       => '0',
         userRstOut      => userRst,
         -- User data interfaces
         userTxData      => userTxDataChannels,
         userTxDataValid => userTxDataValids,
         userTxDataLast  => userTxDataLasts,
         userTxDataReady => userTxDataReadys,
         userRxData      => userRxDataChannels,
         userRxDataValid => userRxDataValids,
         userRxDataLast  => userRxDataLasts,
         userRxDataReady => userRxDataReadys
      );

end architecture;