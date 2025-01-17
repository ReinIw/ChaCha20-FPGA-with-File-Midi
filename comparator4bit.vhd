-- Nama		: Muhammad Iqbal Arsyad
-- NIM		: 33223302
-- Koordinator Asisten Praktikum Sistem Digital EL2102
-- Semester 1 Tahun Ajaran 2024/2025
-- 26 Oktober 2024
-- Percobaan 3
-- Deskripsi
-- Berfungsi untuk membandingkan nilai A dan B. Jika nilai A lebih kecil dari B,
-- maka FLAG akan bernilai 1. selain itu nilainya 0.
-- input:
--				A		nilai A
--				less	flag jika nilai A kurang dari B

-- Library
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Define entity
entity comparator4bit is
	port	(
				A		:	in		std_logic_vector (3 downto 0);	-- nilai A
				Le		:	out	std_logic								-- flag nilai A kurang dari B
			);
end comparator4bit;

-- Define architecture
architecture rtl of comparator4bit is
	signal Bcomparator: std_logic_vector (3 downto 0);
begin
	Bcomparator <= "1011"; 
	-- flag akan bernilai 1 jika A lebih kecil dari B. selain itu nilainya 0.
	Le <= '1' when (A < Bcomparator) else '0';
	
end rtl;
