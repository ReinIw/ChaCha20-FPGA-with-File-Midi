-- Nama		: Muhammad Iqbal Arsyad
-- NIM		: 33223302
-- Koordinator Asisten Praktikum Sistem Digital EL2102
-- Semester 1 Tahun Ajaran 2024/2025
-- 26 Oktober 2024
-- Percobaan 3
-- Deskripsi
-- Berfungsi untuk melakukan penghitungan secara naik (incremental). Berukuran 4bit.
-- input:
--				enable	sinyal untuk mengaktifkan penghitungan.
--				reset		sinyal untuk mengubah hasil perhitungan menjadi 0.
--				clock		sinyal clock
--	output:
--				count		hasil perhitungan

-- Library
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Define entity
entity counter4bit is
	port	(
				En		:		in		std_logic;							-- sinyal enable
				Res	:		in		std_logic;							-- sinyal reset
				Clk	:		in		std_logic;							-- sinyal clock
				Count	:		out	std_logic_vector (3 downto 0)	-- hasil penghitungan
			);
end counter4bit;

-- Define architecture
architecture rtl of counter4bit is
	-- sinyal penghitungan sementara
	signal	Count_temp	:	unsigned (3 downto 0)	:="0000";
	
begin
	-- proses yang mengamati perubahan sinyal clock
	process (Clk)
	begin
		-- jika clock mengalami perubahan dan bernilai 1
		if rising_edge(Clk) then
			-- jika nilai reset adalah 1, maka hasil penghitungan menjadi 0.
			if (Res = '1') then
				Count_temp <= "0000";
			else
			-- jika nilai reset adalah 0, maka...
				-- jika nilai enable adalah 1, maka hasil penghitungan sementara ditambah 1.
				if(En = '1') then
					Count_temp <= Count_temp + 1;
				end if;
			end if;
		end if;
	end process;
	-- hasil penghitungan sementara dimasukkan ke luaran hasil penghitungan. 
	Count <= std_logic_vector(Count_temp);
end rtl;
		
		