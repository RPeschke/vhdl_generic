LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.axi_stream_s32_base.all;



 -------------------- 
 -- There is a bug on pynq boards with the axi stream interface
 
PACKAGE axi_stream_s32 IS


  -- Starting Pseudo class axi_stream_32_master
  -- signal tx : axi_stream_32_master := axi_stream_32_master_null;
  TYPE axi_stream_32_master IS RECORD
    m2s : axi_stream_32_m2s;
    s2m : axi_stream_32_s2m;
  END RECORD;

  CONSTANT axi_stream_32_master_null : axi_stream_32_master :=
  (
  m2s => axi_stream_32_m2s_null,
  s2m => axi_stream_32_s2m_null
  );

  PROCEDURE pull(SIGNAL self : INOUT axi_stream_32_master);
  FUNCTION ready_to_send(self : axi_stream_32_master) RETURN BOOLEAN;
  PROCEDURE send_data(SIGNAL self : INOUT axi_stream_32_master; datain : IN STD_LOGIC_VECTOR);
  PROCEDURE Send_end_Of_Stream(SIGNAL self : INOUT axi_stream_32_master);

  -- End Pseudo class axi_stream_32_master

  -- Starting Pseudo class axi_stream_32_slave

  TYPE axi_stream_32_data_t IS RECORD
    data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    isLast : STD_LOGIC;
    isvalid : STD_LOGIC;
  END RECORD;

  CONSTANT axi_stream_32_data_t_null : axi_stream_32_data_t := (
    data => (OTHERS => '0'),
    isLast => '0',
    isvalid => '0'
  );

  CONSTANT axi_stream_32_data_t_z : axi_stream_32_data_t := (
    data => (OTHERS => 'Z'),
    isLast => 'Z',
    isvalid => 'Z'
  );

  -- signal rx : axi_stream_32_slave := axi_stream_32_slave_null;
  TYPE axi_stream_32_slave IS RECORD
    m2s : axi_stream_32_m2s;
    s2m : axi_stream_32_s2m;

    data_internal : axi_stream_32_data_t;

  END RECORD;

  CONSTANT axi_stream_32_slave_null : axi_stream_32_slave := (
    m2s => axi_stream_32_m2s_null,
    s2m => axi_stream_32_s2m_null,
    data_internal => axi_stream_32_data_t_null
  );

  TYPE axi_stream_32_slave_a IS ARRAY (NATURAL RANGE <>) OF axi_stream_32_slave;

  FUNCTION IsEndOfStream(self : axi_stream_32_slave) RETURN BOOLEAN;
  FUNCTION isReceivingData(self : axi_stream_32_slave) RETURN BOOLEAN;
  PROCEDURE read_data(SIGNAL self : INOUT axi_stream_32_slave; data_out : OUT STD_LOGIC_VECTOR);
  PROCEDURE read_data_s(SIGNAL self : INOUT axi_stream_32_slave;SIGNAL data_out : OUT STD_LOGIC_VECTOR);
  PROCEDURE observe_data(SIGNAL self : INOUT axi_stream_32_slave; data_out : OUT STD_LOGIC_VECTOR);

  PROCEDURE pull(SIGNAL self : INOUT axi_stream_32_slave);
  


  PROCEDURE connect(SIGNAL data_in : INOUT axi_stream_32_slave; SIGNAL data_out : INOUT axi_stream_32_master);


END PACKAGE;




PACKAGE BODY axi_stream_s32 IS


  PROCEDURE pull(SIGNAL self : INOUT axi_stream_32_master) IS
  BEGIN
    --self.s2m <= axi_stream_32_s2m_Z;
    IF (self.s2m.ready = '1' AND self.m2s.valid = '1') THEN
      self.m2s <= axi_stream_32_m2s_null;
    END IF;

  END PROCEDURE;


  FUNCTION ready_to_send(self : axi_stream_32_master) RETURN BOOLEAN IS
  BEGIN
    RETURN (self.s2m.ready = '1' AND self.m2s.valid = '1') OR self.m2s.valid = '0';
  END FUNCTION;


  PROCEDURE send_data(SIGNAL self : INOUT axi_stream_32_master; datain : IN STD_LOGIC_VECTOR) IS
  BEGIN
    self.s2m <= axi_stream_32_s2m_Z;
    self.m2s.data               <=(OTHERS => '0');
    self.m2s.data(datain'range) <= datain;
    self.m2s.valid <= '1';
  END PROCEDURE;


  PROCEDURE Send_end_Of_Stream(SIGNAL self : INOUT axi_stream_32_master) IS
  BEGIN
    self.s2m <= axi_stream_32_s2m_Z;
    self.m2s.last <= '1';
  END PROCEDURE;


  PROCEDURE pull(SIGNAL self : INOUT axi_stream_32_slave) IS
  BEGIN
    self.m2s <= axi_stream_32_m2s_Z;
    self.s2m.ready <= '1';
    IF self.m2s.valid = '1' AND self.s2m.ready = '1' THEN
      self.s2m.ready <= '0';
      self.data_internal.data <= self.m2s.data;
      self.data_internal.isLast <= self.m2s.last;
      self.data_internal.isvalid <= self.m2s.valid;
    END IF;

    IF self.data_internal.isvalid = '1' THEN
      self.s2m.ready <= '0';
    END IF;

  END PROCEDURE;
  





  FUNCTION IsEndOfStream(self : axi_stream_32_slave) RETURN BOOLEAN IS
  BEGIN
    RETURN (self.data_internal.isvalid = '1' AND self.data_internal.isLast = '1') OR (self.m2s.valid = '1' AND self.s2m.ready = '1' AND self.m2s.last = '1');
  END FUNCTION;


  FUNCTION isReceivingData(self : axi_stream_32_slave) RETURN BOOLEAN IS
  BEGIN
    RETURN self.data_internal.isvalid = '1' OR (self.m2s.valid = '1' AND self.s2m.ready = '1');
  END FUNCTION;


  PROCEDURE read_data(SIGNAL self : INOUT axi_stream_32_slave; data_out : OUT STD_LOGIC_VECTOR) IS
  BEGIN
    self.m2s <= axi_stream_32_m2s_Z;
    IF self.data_internal.isvalid = '1' THEN
      data_out := self.data_internal.data(data_out'range);

    ELSIF self.s2m.ready = '1' AND self.m2s.valid = '1' THEN
      data_out := self.m2s.data(data_out'range);
      self.s2m.ready <= '1';
    END IF;

    self.data_internal <= axi_stream_32_data_t_null;

  END PROCEDURE;


  PROCEDURE read_data_s(SIGNAL self : INOUT axi_stream_32_slave;SIGNAL data_out : OUT STD_LOGIC_VECTOR) IS
    VARIABLE v_data_out : STD_LOGIC_VECTOR(data_out'range) := (OTHERS => '0');
  BEGIN

    read_data(self, v_data_out);
    data_out <= v_data_out;
  END PROCEDURE;

  PROCEDURE observe_data(SIGNAL self : INOUT axi_stream_32_slave; data_out : OUT STD_LOGIC_VECTOR) is

  begin 
    self.m2s <= axi_stream_32_m2s_Z;
    IF self.data_internal.isvalid = '1' THEN
      data_out := self.data_internal.data(data_out'range);
    ELSIF self.s2m.ready = '1' AND self.m2s.valid = '1' THEN
      data_out := self.m2s.data(data_out'range);
    END IF;

    
  end procedure;

  PROCEDURE connect(SIGNAL data_in : INOUT axi_stream_32_slave; SIGNAL data_out : INOUT axi_stream_32_master) IS
  BEGIN
    data_in.s2m <= axi_stream_32_s2m_Z;
    data_out.m2s <= axi_stream_32_m2s_Z;
    data_in.data_internal <= axi_stream_32_data_t_z;

    data_in.m2s <= data_out.m2s;
    data_out.s2m <= data_in.s2m;

  END PROCEDURE;


END PACKAGE BODY;