--###############################
--# Project Name : 
--# File         : 
--# Author       : 
--# Description  : 
--# Modification History
--#
--###############################

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-------------------------------------------------------------
-------------------------------------------------------------
---- Based on the Heap Sort described in the book      ------
---- Algorithms in a Nutshell by Gary Pollice,         ------
---- Stanley Selkow, George T. Heineman				   ------
-------------------------------------------------------------
-------------------------------------------------------------
---- https://www.oreilly.com/library/view/algorithms-in-a/9780596516246/ch04s06.html



entity heapsort is
	port(
		MCLK		: in	std_logic;
		nRST		: in	std_logic;
		RAMD		: out	std_logic_vector(7 downto 0);
		RAMWE		: out	std_logic;
		RAMQ		: in	std_logic_vector(7 downto 0);
		RAMA		: out	std_logic_vector(7 downto 0);
		SIZE		: in	std_logic_vector(7 downto 0);
		START		: in	std_logic;
		DONE		: out	std_logic
	);
end heapsort;

architecture rtl of heapsort is
type t_state is (S_IDLE, S_BUILDHEAP,S_HEAPIFY, S_HEAPIFY0, S_HEAPIFY1, S_HEAPIFY2, S_HEAPIFY3, S_HEAPIFY4,
	S_HEAPIFY5, S_SORT, S_SORT0, S_SORT1, S_SORT2, S_SORT3, S_OUT);
signal state : t_state;
signal state0 : t_state;
signal idx 	 : std_logic_vector(7 downto 0);
signal maxi  : std_logic_vector(7 downto 0);
signal idx21 : std_logic_vector(8 downto 0);
signal idx22 : std_logic_vector(8 downto 0);
signal vidx  : std_logic_vector(7 downto 0);
signal largest   : std_logic_vector(7 downto 0);
signal vlargest  : std_logic_vector(7 downto 0);
signal swap : std_logic;	 -- swap inside HEAPIFY
signal overrun : std_logic;  -- 2*idx+2 >= max
signal bhcount : std_logic_vector(7 downto 0);

signal debug : std_logic_vector(7 downto 0); -- for debug display

begin
	idx21 <= idx & '1';
	idx22 <= std_logic_vector(unsigned(idx21)+1);

	POTO: process( MCLK, nRST)
		variable tmp : std_logic_vector(7 downto 0);
	begin
		if ( nRST = '0') then
			state <= S_IDLE;
			RAMD <= (others=>'0');
			RAMA <= (others=>'0');
			RAMWE <= '0';
			DONE <= '0';
			swap <= '0';
			overrun <= '0';
			idx <= (others=>'0');
			maxi <= (others=>'0');
		elsif ( MCLK'event and MCLK = '1') then
			if (state = S_IDLE) then
				RAMD <= (others=>'0');
				RAMA <= (others=>'0');
				RAMWE <= '0';
				DONE <= '0';
				swap <= '0';
				overrun <= '0';
				idx <= (others=>'0');
				maxi <= (others=>'0');
				if (start = '1') then
-----------------------------------------------------------------------------------
---------- 							BUILDHEAP init						 ----------
-----------------------------------------------------------------------------------
					state0 <= S_BUILDHEAP;
					state <= S_HEAPIFY;
					tmp := std_logic_vector(unsigned('0' & SIZE(7 downto 1))-1); -- /2 - 1
					idx <= tmp;
					RAMA <= tmp;
					bhcount <= tmp;
					maxi <=SIZE;
				end if;
-----------------------------------------------------------------------------------
---------- 							HEAPIFY	begin						 ----------
-----------------------------------------------------------------------------------
			elsif (state = S_HEAPIFY) then
				--report "idx: " & INTEGER'image(to_integer(unsigned(idx))) & " maxi: " & INTEGER'image(to_integer(unsigned(maxi)));
				RAMWE <= '0';
				swap <= '0';
				overrun <= '0';
				if (unsigned(idx21) >=  unsigned('0' & maxi)) then
					state <= state0;
					--report "--> 2*idx+1 >= max";
				else
					RAMA <= idx21(7 downto 0);
					state <=  S_HEAPIFY0;
				end if;				
			elsif (state = S_HEAPIFY0) then
				vidx <= RAMQ; --
				if (unsigned(idx22) >=  unsigned('0' & maxi)) then
					overrun <= '1';
					--report "--> 2*idx+2 >= max";
				else
					RAMA <= idx22(7 downto 0);
					overrun <= '0';
				end if;	
				state <=  S_HEAPIFY1;			
			elsif (state = S_HEAPIFY1) then
				if (unsigned(vidx) >= unsigned(RAMQ)) then
					largest <= idx;
					vlargest <= vidx;
					swap <= '0';
				else
					vlargest <= RAMQ; --
					largest <= idx21(7 downto 0);
					swap <= '1';					
				end if;
				state <= S_HEAPIFY2;
			elsif (state = S_HEAPIFY2) then
				if (overrun = '0') then
					if (unsigned(vlargest) < unsigned(RAMQ)) then
						vlargest <= RAMQ; --
						largest <= idx22(7 downto 0);
						swap <= '1';
					end if;
				end if;
				overrun <= '0';
				state <=  S_HEAPIFY3;
			elsif (state = S_HEAPIFY3) then
-----------------------------------------------------------------------------------
---------- 							HEAPIFY	swap						 ----------
-----------------------------------------------------------------------------------
				if (swap = '1') then
					RAMA <= idx;
					RAMD <= vlargest;
					RAMWE <= '1';
					state <=  S_HEAPIFY4;
				else
					state <= state0;
					swap <= '0';
				end if;
			elsif (state = S_HEAPIFY4) then
				RAMA <= largest;
				RAMD <= vidx;
				RAMWE <= '1';
				--report "H " & INTEGER'image(to_integer(unsigned(vidx))) & " <-> " & INTEGER'image(to_integer(unsigned(vlargest))) & 
				--		" (" & INTEGER'image(to_integer(unsigned(idx))) & "," & INTEGER'image(to_integer(unsigned(largest))) & ")" ;
				state <=  S_HEAPIFY5;
			elsif (state = S_HEAPIFY5) then	
				idx <= largest;
				RAMA <= largest;
				state <= S_HEAPIFY;    -- recursive HEAPIFY
-----------------------------------------------------------------------------------
---------- 							BUILDHEAP loop						 ----------
-----------------------------------------------------------------------------------
			elsif (state = S_BUILDHEAP) then
				RAMWE <= '0';
				if (to_integer(unsigned(bhcount)) = 0) then
					RAMA <= (others=>'0');
					if (to_integer(unsigned(maxi)) = 1) then
						state <= S_OUT;
						--report "--> BuildHeap finished and maxi == 1";
					else
						--report INTEGER'image(to_integer(unsigned(maxi)));
						maxi <= std_logic_vector(unsigned(maxi)-1);
						idx <= (others=>'0');
						state <= S_SORT0;
					end if;
				else
					tmp := std_logic_vector(unsigned(bhcount)-1);
					idx <= tmp;
					RAMA <= tmp;
					bhcount <= tmp;
					state <= S_HEAPIFY;
				end if;
-----------------------------------------------------------------------------------
---------- 							SORT init		 				         ----------
-----------------------------------------------------------------------------------
			elsif (state = S_SORT0) then
				RAMA <= maxi;
				state <= S_SORT1;
-----------------------------------------------------------------------------------
---------- 							SORT swap						     ----------
-----------------------------------------------------------------------------------
			elsif (state = S_SORT1) then
				RAMA <= maxi;
				RAMD <= RAMQ;
				debug <= RAMQ;  -- for debug display
				--report INTEGER'image(to_integer(unsigned(maxi)));
				--report INTEGER'image(to_integer(unsigned(RAMQ)));
				RAMWE <= '1';
				state <= S_SORT2;
			elsif (state = S_SORT2) then
				RAMA <= (others=>'0');
				RAMD <= RAMQ;
				report "S " & INTEGER'image(to_integer(unsigned(debug))) & " <-> " & INTEGER'image(to_integer(unsigned(RAMQ)))& 
							" (" & INTEGER'image(to_integer(unsigned(maxi))) & "," & INTEGER'image(to_integer(unsigned(idx))) & ")" ;
				RAMWE <= '1';
				state <= S_HEAPIFY;
				state0 <= S_SORT;
-----------------------------------------------------------------------------------
---------- 							SORT loop						     ----------
-----------------------------------------------------------------------------------
			elsif (state = S_SORT) then
				RAMWE <= '0';
				RAMA <= (others=>'0');
				if (to_integer(unsigned(maxi)) = 1) then
					state <= S_OUT;
				else
					maxi <= std_logic_vector(unsigned(maxi)-1);
					idx <= (others=>'0');
					RAMA <= (others=>'0');
					state <= S_SORT0;
				end if;		
			elsif (state = 	S_OUT) then
				DONE <= '1';
				state <= S_IDLE;
			else 
				state <= S_IDLE;
			end if;
		end if;
	end process POTO;

end rtl;

