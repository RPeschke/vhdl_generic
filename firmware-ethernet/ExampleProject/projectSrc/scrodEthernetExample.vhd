----------------------------------------------------------------------------------
-- Company: 
-- Engineer:  
-- 
-- Create Date:    13:21:31 07/23/2015 
-- Design Name: 
-- Module Name:    scrodEthernetExample - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
   use IEEE.STD_LOGIC_1164.ALL;
   use work.UtilityPkg.all;
   use work.GigabitEthPkg.all;
   use work.axi_stream_s32.all;


entity scrodEthernetExample is
   generic (
      NUM_IP_G        : integer := 2
   );
   port ( 
      -- Direct GT connections
      gtTxP        : out std_logic;
      gtTxN        : out std_logic;
      gtRxP        :  in std_logic;
      gtRxN        :  in std_logic;
      gtClkP       :  in std_logic;
      gtClkN       :  in std_logic;
      -- Alternative clock input
		fabClkP      :  in std_logic;
		fabClkN      :  in std_logic;
      -- SFP transceiver disable pin
      txDisable    : out std_logic
--      -- Status and diagnostics out

   );
end entity;

architecture rtl of scrodEthernetExample is
   signal clk    : sl;
   -- User Data interfaces
   signal RX_m2s          :   axi_stream_32_m2s_a(NUM_IP_G-1 downto 0);
   signal RX_s2m          :    axi_stream_32_s2m_a(NUM_IP_G-1 downto 0);

   signal TX_m2s          :    axi_stream_32_m2s_a(NUM_IP_G-1 downto 0);
   signal TX_s2m          :   axi_stream_32_s2m_a(NUM_IP_G-1 downto 0);

   signal ethCoreIpAddr  : IpAddrType  := (3 => x"C0", 2 => x"A8", 1 => x"02", 0 => x"20");
   signal ethCoreIpAddr1 : IpAddrType  := (3 => x"C0", 2 => x"A8", 1 => x"02", 0 => x"21");

   signal ipAddrs         :   IpAddrArray(NUM_IP_G-1 downto 0) := (0 => ethCoreIpAddr, 1 => ethCoreIpAddr1);
   signal udpPorts        :   Word16Array(NUM_IP_G-1 downto 0) := (others => x"07D0");

begin



   --------------------------------
   -- Gigabit Ethernet Interface --
   --------------------------------
   U_Ethernet2axistream : entity work.Ethernet2axistream
      generic map (
         NUM_IP_G   => NUM_IP_G
      )  port map (

         clk           => clk,
         -- Direct GT connections
         gtTxP           => gtTxP,
         gtTxN           => gtTxN,
         gtRxP           => gtRxP,
         gtRxN           => gtRxN,
         gtClkP          => gtClkP,
         gtClkN          => gtClkN,
         -- Alternative clock input from fabric



	      fabClkP       => fabClkP,
	      fabClkN       => fabClkN,
          -- SFP transceiver disable pin
         txDisable      => txDisable,

         macAddr       => MAC_ADDR_DEFAULT_C,
         ipAddrs       => ipAddrs ,     
         udpPorts      => udpPorts,

         RX_m2s       => RX_m2s,
         RX_s2m       => RX_s2m,

         TX_m2s       => TX_m2s,
         TX_s2m       => TX_s2m          
      );



lbl: for var in 0 to NUM_IP_G - 1 generate
   TX_m2s(var) <= RX_m2s(var);
   RX_s2m(var) <= TX_s2m(var);
end generate;
         
end architecture;

