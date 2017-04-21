library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defs.all;
use work.util.all;

entity pwr is
  Port (  Clock: in std_logic;
          reset: in std_logic;
          
          req_i   : in MSG_T;
          res_o  : out MSG_T;
          full_preq: out std_logic:='0';
          
          gfx_res_i  : in MSG_T;
          gfx_req_o : out MSG_T;

          uart_res_i : in MSG_T;
          uart_req_o : out MSG_T;
          
          usb_res_i : in MSG_T;
          usb_req_o : out MSG_T;

          audio_res_i : in MSG_T;
          audio_req_o : out MSG_T
          );            
end pwr;

architecture rtl of pwr is
  signal tmp_req: MSG_T;
  signal in1,out1 : MSG_T;
  signal in2,out2 : MSG_T;
  signal we1,re1,emp1,we2,re2,emp2 : std_logic:='0';
begin

  pwr_req_fifo: entity work.fifo(rtl) 
	generic map(
      DATA_WIDTH => MSG_WIDTH,
      FIFO_DEPTH => 16
     )
	port map(
      CLK=>Clock,
      RST=>reset,
      DataIn=>in1,
      WriteEn=>we1,
      ReadEn=>re1,
      DataOut=>out1,
      Full=>full_preq,
      Empty=>emp1
      );
  
  pwr_req_fifo_handler: process (Clock)      
  begin
    if reset='1' then
      we1<='0';
    elsif rising_edge(Clock) then
      if is_valid(req_i) then
        in1 <= req_i;
        we1 <= '1';
      else
        we1 <= '0';
      end if;
    end if;
  end process;

  --* Forwards req from ic to dev,
  --*    waits for resp from dev, and
  --*    forwards res back to ic
  req_handler : process (reset, Clock)
    variable st: integer :=0;
  begin
    if (reset = '1') then
      gfx_req_o <= (others => '0');
      audio_req_o <= (others => '0');
      usb_req_o <= (others => '0');
      uart_req_o <= (others => '0');
    elsif rising_edge(Clock) then
      res_o <= (others => '0');
      if st =0 then
        gfx_req_o <= (others => '0');
        audio_req_o <= (others => '0');
        usb_req_o <= (others => '0');
        uart_req_o <= (others => '0');
        if re1 = '0' and emp1 ='0' then
          re1 <= '1';
          st := 1;
        end if;
        
      elsif st = 1 then
        re1 <= '0';
        if is_valid(out1) then
          tmp_req <= out1;
          if get_dat(out1) = pad32(GFX_ID) then
            st := 2;
          --elsif out1(1 downto 0) = AUDIO_ID then
          --  state := 3;
          --elsif out1(1 downto 0) = USB_ID then
          --  state := 4;
          --elsif out1(1 downto 0) = UART_ID then
          --  state := 5;
          end if;
        end if;
      elsif st = 2 then
        gfx_req_o <= tmp_req;
        st := 6;
      --elsif state = 3 then
      --  audio_req_o <= tmp_req(REQ_WIDTH - 1 downto DATA_WIDTH - 1);
      --  state := 7;
      --elsif state = 4 then
      --  usb_req_o <= tmp_req(REQ_WIDTH - 1 downto DATA_WIDTH - 1);
      --  state := 8;
      --elsif state = 5 then
      --  uart_req_o<=tmp_req(REQ_WIDTH - 1 downto DATA_WIDTH - 1);
      --  state := 9;
      elsif st = 6 then
        gfx_req_o <= (others => '0');
        if is_valid(gfx_res_i) then
          res_o <= gfx_res_i;
          st :=0;
        end if;
      --elsif state = 7 then
      --  audio_req_o <= (others => '0');
      --  if audio_res_i(DATA_WIDTH - 1 downto DATA_WIDTH - 1) = "1" then
      --    res_o <= tmp_req;
      --    state :=0;
      --  end if;
      --elsif state = 8 then
      --  usb_req_o <= (others => '0');
      --  if usb_res_i(DATA_WIDTH - 1 downto DATA_WIDTH - 1) = "1" then
      --    res_o <= tmp_req;
      --    state :=0;
      --  end if;
      --elsif state = 9 then
      --  uart_req_o <= (others => '0');
      --  if uart_res_i(DATA_WIDTH - 1 downto DATA_WIDTH - 1) = "1" then
      --    res_o <= tmp_req;
      --    state :=0;
      --  end if;
      end if;
    end if;
  end process;
  
end rtl;
