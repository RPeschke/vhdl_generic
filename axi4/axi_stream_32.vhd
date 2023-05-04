
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.axi_stream_s32_base.ALL;

PACKAGE axi_stream_32 IS

  -- Starting Pseudo class axi_stream_32_m

  TYPE axi_stream_32_m IS RECORD
    m2s : axi_stream_32_m2s;
    s2m : axi_stream_32_s2m;
  END RECORD;

  CONSTANT axi_stream_32_m_null : axi_stream_32_m := (
    m2s => axi_stream_32_m2s_null, 
    s2m => axi_stream_32_s2m_null
    );

  FUNCTION ready_to_send(self : axi_stream_32_m) RETURN BOOLEAN;
  PROCEDURE send_data(self : INOUT axi_stream_32_m; datain : IN STD_LOGIC_VECTOR);
  PROCEDURE Send_end_Of_Stream(self : INOUT axi_stream_32_m);
  PROCEDURE pull(self : INOUT axi_stream_32_m; SIGNAL DataIn : IN axi_stream_32_s2m);
  PROCEDURE push(self : INOUT axi_stream_32_m; SIGNAL DataOut : OUT axi_stream_32_m2s);
  PROCEDURE reset(self : INOUT axi_stream_32_m);
  -- End Pseudo class axi_stream_32_m

  -- Starting Pseudo class axi_stream_32_s

  TYPE axi_stream_32_s IS RECORD
    m2s      : axi_stream_32_m2s;
    s2m      : axi_stream_32_s2m;
    internal : axi_stream_32_m2s;
  END RECORD;

  CONSTANT axi_stream_32_s_null : axi_stream_32_s := (
    m2s => axi_stream_32_m2s_null, 
    s2m => axi_stream_32_s2m_null,
    internal => axi_stream_32_m2s_null
    );

  FUNCTION IsEndOfStream(self : axi_stream_32_s) RETURN BOOLEAN;
  FUNCTION isReceivingData(self : axi_stream_32_s) RETURN BOOLEAN;
  PROCEDURE read_data(self : INOUT axi_stream_32_s; datain : OUT STD_LOGIC_VECTOR);
  PROCEDURE pull(self : INOUT axi_stream_32_s; SIGNAL DataIn : IN axi_stream_32_m2s);
  PROCEDURE push(self : INOUT axi_stream_32_s; SIGNAL DataOut : OUT axi_stream_32_s2m);
  PROCEDURE reset(self : INOUT axi_stream_32_s);

  -- End Pseudo class axi_stream_32_s


END PACKAGE;


PACKAGE BODY axi_stream_32 IS
  -- Starting Pseudo class axi_stream_32_m
  FUNCTION ready_to_send(self : axi_stream_32_m) RETURN BOOLEAN IS 
  BEGIN

    RETURN self.m2s.valid = '0';

  END FUNCTION ready_to_send;

  PROCEDURE send_data(self : INOUT axi_stream_32_m; datain : IN STD_LOGIC_VECTOR) IS 
  BEGIN

    self.m2s.valid := '1';
    self.m2s.data(datain'RANGE) := datain;
  END PROCEDURE;

  PROCEDURE Send_end_Of_Stream(self : INOUT axi_stream_32_m) IS 
  BEGIN
    self.m2s.last := '1';

  END PROCEDURE;

  PROCEDURE pull(self : INOUT axi_stream_32_m; SIGNAL DataIn : IN axi_stream_32_s2m) IS 
  BEGIN

    self.s2m := DataIn;

    IF (self.s2m.ready = '1') THEN
      self.m2s := axi_stream_32_m2s_null;
    END IF;

  END PROCEDURE;

  PROCEDURE push(self : INOUT axi_stream_32_m; SIGNAL DataOut : OUT axi_stream_32_m2s) IS 
  BEGIN
    DataOut  <= self.m2s;
  END PROCEDURE;

  PROCEDURE reset(self : INOUT axi_stream_32_m) is 
  begin 
    self := axi_stream_32_m_null;
  end procedure;
  -- End Pseudo class axi_stream_32_m

  -- Starting Pseudo class axi_stream_32_s
  FUNCTION IsEndOfStream(self : axi_stream_32_s) RETURN BOOLEAN IS 
  BEGIN

    RETURN self.internal.valid = '1' AND self.internal.last = '1';

  END FUNCTION;

  FUNCTION isReceivingData(self : axi_stream_32_s) RETURN BOOLEAN IS 
  BEGIN

    RETURN self.internal.valid = '1';

  END FUNCTION;

  PROCEDURE read_data(self : INOUT axi_stream_32_s; datain : OUT STD_LOGIC_VECTOR) IS 
  BEGIN
    IF (self.internal.valid = '1') THEN
      datain := self.internal.data(datain'RANGE);
    END IF;
    self.internal := axi_stream_32_m2s_null;

  END PROCEDURE;

  PROCEDURE pull(self : INOUT axi_stream_32_s; SIGNAL DataIn : IN axi_stream_32_m2s) IS 
  BEGIN

    self.m2s := DataIn;
    IF (self.s2m.ready = '1') THEN
      self.internal := self.m2s;
    END IF;

  END PROCEDURE;

  PROCEDURE push(self : INOUT axi_stream_32_s; SIGNAL DataOut : OUT axi_stream_32_s2m) IS 
  BEGIN

    self.s2m.ready := not  self.internal.valid;
    DataOut  <= self.s2m;

  END PROCEDURE;
  
  PROCEDURE reset(self : INOUT axi_stream_32_s) is 
  begin
    self := axi_stream_32_s_null;
  end procedure;

  -- End Pseudo class axi_stream_32_s

END PACKAGE BODY;