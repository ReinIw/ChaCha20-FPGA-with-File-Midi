-- Nama		: Muhammad Iqbal Arsyad
-- NIM		: 33223302
-- Koordinator Asisten Praktikum Sistem Digital EL2102
-- Semester 1 Tahun Ajaran 2024/2025
-- 26 Oktober 2024
-- Percobaan 3
-- Deskripsi
-- Berfungsi untuk memilih jalur data yang akan diteruskan. Terdapat 2 jalur data.
-- input
--			A		data A
--			B		data B
--			Sel	selector. 0 untuk data A dan 1 untuk data B.
-- output
--			Data	data yang diteruskan ke luaran.

-- Library
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Define entity
entity mux2to1_512bit is
	port	(
				A		:		in		std_logic_vector (511 downto 0);	-- data A
				B		:		in		std_logic_vector (511 downto 0);	-- data B
				Sel	:		in		std_logic;								-- selector
				Data	:		out	std_logic_vector (511 downto 0)		-- luaran data
			);
end mux2to1_512bit;

-- Define architecture
architecture rtl of mux2to1_512bit is
begin
	-- process yang mengamati perubahan di selector
	process (Sel, A, B)
	begin
		-- jika selector bernilai 1, maka data B yang diteruskan ke luaran.
		if (Sel = '1') then
			Data <= B;
		else
		-- jika selector bernilai 0, maka data A yang diteruskan ke luaran.
			Data <= A;
		end if;
	end process;
end rtl;