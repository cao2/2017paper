library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity arbiter7 is
	Generic (
		constant DATA_WIDTH  : positive := 73
	);
    Port (
            clock: in std_logic;
            reset: in std_logic;
            
            din1: 	in STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
            ack1: 	out STD_LOGIC;
            
            din2:	in std_logic_vector(DATA_WIDTH - 1 downto 0);
            ack2:	out std_logic;
            
            din3:	in std_logic_vector(DATA_WIDTH - 1 downto 0);
            ack3:	out std_logic;
            
            din4:	in std_logic_vector(DATA_WIDTH - 1 downto 0);
            ack4:	out std_logic;
            
            din5:	in std_logic_vector(DATA_WIDTH - 1 downto 0);
            ack5:	out std_logic;
            
            din6:	in std_logic_vector(DATA_WIDTH - 1 downto 0);
            ack6:	out std_logic;
				
				din7:	in std_logic_vector(DATA_WIDTH - 1 downto 0);
            ack7:	out std_logic;
            
            dout:	out std_logic_vector(DATA_WIDTH - 1 downto 0)
     );
end arbiter7;

-- version 2
architecture Behavioral of arbiter7 is

    signal s_ack1, s_ack2,s_ack3,s_ack4, s_ack5,s_ack6 ,s_ack7: std_logic;
    signal s_token : integer :=0;
		
begin  
 	process (reset, clock)
        variable nilreq : std_logic_vector(DATA_WIDTH - 1 downto 0):=(others => '0');
    begin
        if reset = '1' then
        	s_token <= 0;
        	s_ack1 <= '0';
        	s_ack2 <= '0';
        	s_ack3 <= '0';
        	s_ack4 <= '0';
        	s_ack5 <= '0';
        	s_ack6 <= '0';
			s_ack7 <= '0';
        	dout <=  nilreq;
        elsif rising_edge(clock) then
        	dout <= nilreq;
            s_ack1 <= '0';
            s_ack2 <= '0';   
            s_ack3 <= '0'; 
            s_ack4 <= '0';
            s_ack5 <= '0';   
            s_ack6 <= '0'; 
				s_ack7 <= '0';
            if din1(DATA_WIDTH-1 downto DATA_WIDTH-1 ) ="1" then
            	if s_ack1 = '0' then
                    dout <= din1;
                    s_ack1 <= '1';
                end if; 
            elsif din2(DATA_WIDTH-1 downto DATA_WIDTH-1 ) ="1" then
            	if s_ack2 = '0' then
                    dout <= din2;
                    s_ack2 <= '1';
                end if; 
         	elsif din3(DATA_WIDTH-1 downto DATA_WIDTH-1 ) ="1" then
            	if s_ack3 = '0' then
                    dout <= din3;
                    s_ack3 <= '1';
                end if; 
            elsif din4(DATA_WIDTH-1 downto DATA_WIDTH-1 ) ="1" then
            	if s_ack4 = '0' then
                    dout <= din4;
                    s_ack4 <= '1';
                end if; 
            elsif din5(DATA_WIDTH-1 downto DATA_WIDTH-1 ) ="1" then
            	if s_ack5 = '0' then
                    dout <= din5;
                    s_ack5 <= '1';
                end if; 
            elsif din6(DATA_WIDTH-1 downto DATA_WIDTH-1 ) ="1" then
            	if s_ack6 = '0' then
                    dout <= din6;
                    s_ack6 <= '1';
                end if; 
				elsif din7(DATA_WIDTH-1 downto DATA_WIDTH-1 ) ="1" then
            	if s_ack7 = '0' then
                    dout <= din7;
                    s_ack7<= '1';
                end if; 
            end if;
        end if;
        ack1 <= s_ack1;
        ack2 <= s_ack2;
        ack3 <= s_ack3;
        ack4 <= s_ack4;
        ack5 <= s_ack5;
        ack6 <= s_ack6;
		  ack7 <= s_ack7;
    end process;
end architecture Behavioral;   