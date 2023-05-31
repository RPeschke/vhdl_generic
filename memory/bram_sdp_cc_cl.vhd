library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
    use work.bram_sdp_cc_pkg.all;


entity bram_sdp_cc_cl is
  generic (
    DATA     : integer := 16;
    ADDR     : integer := 10
  );
  port (

    clk   : in   std_logic;
    m2s   : in   mem_handler_t_m2s := mem_handler_t_m2s_null;
    s2m   : out  mem_handler_t_s2m := mem_handler_t_s2m_null

  );
end entity;


architecture rtl of bram_sdp_cc_cl is
  
begin






    u_mem_KLM_DIgits : entity work.bram_sdp_cc generic map(
        DATA   => DATA,
        ADDR    => ADDR
    ) port map(
        -- Port A
        clk    => clk ,
        wea    => m2s.wea  ,  
        addra  => m2s.addra(ADDR-1 downto 0) ,
        dina   => m2s.dina(DATA-1 downto 0) ,
        -- Port B
        addrb  => m2s.addrb(ADDR-1 downto 0) ,
        addrb_out => s2m.addrb_out(ADDR-1 downto 0) ,
        doutb  => s2m.doutb(DATA-1 downto 0)  
    );

end architecture;
