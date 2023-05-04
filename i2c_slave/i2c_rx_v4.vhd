LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.i2c_rx_v3_pac.ALL;
ENTITY i2c_rx_v4 IS
	GENERIC (
		maximum_number_of_packages : INTEGER := 5
	);
	PORT (
		clk : IN STD_LOGIC;
		DReset : IN STD_LOGIC;

		scl : IN STD_LOGIC;
		sda : IN STD_LOGIC;
		sda_out : OUT STD_LOGIC;
		write_enable : OUT STD_LOGIC;
		asic_addr : IN i2c_addr_t;

		read_write_mode : OUT STD_LOGIC;
		data_index : OUT i2c_data_t;
		data_out : OUT i2c_data_t;
		data_in : IN i2c_data_t

	);
END ENTITY;

ARCHITECTURE rtl OF i2c_rx_v4 IS
	TYPE state_t IS (
		WRITE_DATA,
		SEND_ACK,
		READ_DATA,
		SEND_ACK3,
		WAIT_FOR_NEW_START
	);
	SIGNAL clk_slow : unsigned(15 DOWNTO 0);
	SIGNAL start : STD_LOGIC;
	SIGNAL prev_sda : STD_LOGIC;

	PROCEDURE reset_s(SIGNAL self : OUT STD_LOGIC_VECTOR) IS
	BEGIN
		self <= (OTHERS => '0');
	END PROCEDURE;

	PROCEDURE reset_s(SIGNAL self : OUT STD_LOGIC) IS
	BEGIN
		self <= '0';
	END PROCEDURE;
	TYPE i2c_handler IS RECORD
		state : state_t;
		asic_addr_extern : i2c_addr_t;
		asic_addr : i2c_addr_t;

		wr : STD_LOGIC;
		data_in : i2c_data_t;
		data_out : i2c_data_t;
		byte_counter : NATURAL RANGE 0 TO 255;
		counter : NATURAL RANGE 0 TO 7;

		rising_edge_scl : STD_LOGIC;
		falling_edge_scl : STD_LOGIC;
		sda : STD_LOGIC;
		scl : STD_LOGIC;
		prev_scl : STD_LOGIC;
		sda_out : STD_LOGIC;
		write_enable : STD_LOGIC;
	END RECORD;

	CONSTANT i2c_handler_init : i2c_handler := (
		state => WRITE_DATA,
		asic_addr_extern => (OTHERS => '0'),
		asic_addr => (OTHERS => '0'),

		wr => '0',
		data_in => (OTHERS => '0'),
		data_out => (OTHERS => '0'),
		byte_counter => 0,
		counter => 7,

		rising_edge_scl => '0',
		falling_edge_scl => '0',
		sda => '1',
		scl => '1',
		prev_scl => '1',
		sda_out => '0',
		write_enable => '0'
	);

	SIGNAL i2c_handler_s : i2c_handler;
	PROCEDURE pull(SIGNAL self : INOUT i2c_handler; sda : IN STD_LOGIC; scl : IN STD_LOGIC; start : IN STD_LOGIC) IS
	BEGIN
		self.prev_scl <= self.scl;
		self.scl <= scl;
		self.sda <= sda;
		self.rising_edge_scl <= start AND NOT self.prev_scl AND self.scl;
		self.falling_edge_scl <= self.prev_scl AND NOT self.scl;

		IF start = '0' THEN
			self <= i2c_handler_init;
		END IF;

		IF self.state = READ_DATA THEN
			self.write_enable <= '1';
			self.sda_out <= self.data_out(self.counter);
		END IF;

		IF self.byte_counter = 0 THEN
			self.asic_addr <= self.data_in(7 DOWNTO 1);
			self.wr <= self.data_in(0);
		END IF;

		IF self.rising_edge_scl = '1' THEN
			self.sda_out <= '1';
			self.write_enable <= '0';
			CASE(self.state) IS
				WHEN WRITE_DATA =>
				self.data_in(self.counter) <= sda;
				self.counter <= self.counter - 1;
				IF self.counter = 0 THEN
					self.counter <= 7;
					self.state <= SEND_ACK;
				END IF;

				WHEN SEND_ACK =>
				IF self.asic_addr = self.asic_addr_extern THEN
					IF self.wr = '1' THEN
						self.state <= READ_DATA;
					ELSE
						self.state <= WRITE_DATA;
					END IF;
				ELSE
					self.state <= WAIT_FOR_NEW_START;
				END IF;

				WHEN READ_DATA =>
				self.counter <= self.counter - 1;

				IF self.counter = 0 THEN
					self.counter <= 7;
					self.state <= SEND_ACK3;
				END IF;

				WHEN SEND_ACK3 =>

				IF self.sda = '1' THEN
					self.state <= WRITE_DATA;
				ELSE
					self.state <= READ_DATA;
				END IF;

			END CASE;

		END IF;
	END PROCEDURE;
	PROCEDURE push(SIGNAL self : INOUT i2c_handler; SIGNAL sda_out : OUT STD_LOGIC; SIGNAL write_enable : OUT STD_LOGIC) IS
	BEGIN
		IF self.falling_edge_scl = '1' THEN
			sda_out <= self.sda_out;
			write_enable <= self.write_enable;
			IF self.state = SEND_ACK THEN
				self.byte_counter <= self.byte_counter + 1;
				IF self.asic_addr = self.asic_addr_extern THEN
					sda_out <= '0';
					write_enable <= '1';
				END IF;
			ELSIF self.state = SEND_ACK3 THEN
				self.byte_counter <= self.byte_counter + 1;
			END IF;
		END IF;
	END PROCEDURE;

	FUNCTION is_reading(SIGNAL self : i2c_handler) RETURN BOOLEAN IS
	BEGIN
		RETURN self.wr = '1';

	END FUNCTION;

	FUNCTION is_writing(SIGNAL self : i2c_handler) RETURN BOOLEAN IS
	BEGIN
		RETURN self.wr = '0';

	END FUNCTION;

BEGIN

	PROCESS (clk) IS
	BEGIN

		IF rising_edge(clk) THEN

			IF clk_slow(15) = '1' THEN
				clk_slow <= clk_slow(14 DOWNTO 0) & '0';
			ELSE
				clk_slow <= clk_slow(14 DOWNTO 0) & '1';
			END IF;
			prev_sda <= sda;
			IF (DReset = '1') THEN
				start <= '0';
			ELSIF sda = '0' AND start = '0' AND scl = '1'THEN
				start <= '1'; -- Start detect
			ELSIF sda = '1' AND prev_sda = '0' AND scl = '1'THEN
				start <= '0'; -- // Stop detect
			END IF;
		END IF;
	END PROCESS;
	PROCESS (clk_slow(15)) IS
	BEGIN

		IF rising_edge(clk_slow(15)) THEN
			pull(i2c_handler_s, sda, scl, start);
			i2c_handler_s.asic_addr_extern <= asic_addr;

			IF (DReset = '1') THEN
				reset_s(sda_out);
				reset_s(write_enable);
				reset_s(read_write_mode);
				reset_s(data_index);
				reset_s(data_out);

				i2c_handler_s <= i2c_handler_init;
			END IF;
			i2c_handler_s.data_out <= data_in;
			IF i2c_handler_s.rising_edge_scl = '1' THEN
				data_index <= STD_LOGIC_VECTOR(to_unsigned(i2c_handler_s.byte_counter, data_index'length));
			END IF;

			IF i2c_handler_s.state = SEND_ACK AND i2c_handler_s.rising_edge_scl = '1' THEN
				read_write_mode <= i2c_handler_s.wr;
				data_out <= i2c_handler_s.data_in;
			END IF;

			push(i2c_handler_s, sda_out, write_enable);
			IF i2c_handler_s.byte_counter > maximum_number_of_packages THEN
				i2c_handler_s <= i2c_handler_init;
			END IF;
		END IF;
	END PROCESS;

END ARCHITECTURE;