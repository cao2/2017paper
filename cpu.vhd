library ieee,std;
use ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use work.defs.all;
use work.rand.all;
use work.util.all;
use work.test.all;

use ieee.std_logic_textio.all;
use std.textio.all;

entity cpu is
  Port(reset   : in  std_logic;
       Clock   : in  std_logic;
       cpu_id   : in  integer;
       cpu_res_in : in  std_logic_vector(72 downto 0);
       cpu_req_out : out std_logic_vector(72 downto 0);
       full_c  : in  std_logic -- an input signal from cache, enabled when
                               -- cache is full TODO confirm
       );
end cpu;

architecture Behavioral of cpu is
  type states is (init, send, idle);
  signal st, next_st : states;
  signal addr,data: std_logic_vector(31 downto 0);
    
  ----* TODO is this a fun to create a power_req?
  --procedure power(variable cmd : in  std_logic_vector(1 downto 0);
  --                signal req   : out std_logic_vector(72 downto 0);
  --                variable hw  : in  std_logic_vector(1 downto 0)) is
  --begin
  --  req <= "111000000" & cmd & hw & "00000000" & "00000000" & "00000000" &
  --         "00000000" & "00000000" & "00000000" & "00000000" & "0000";
  --  -- TODO maybe wait statements here need to go, however power is not being
  --  -- called, so why does simulation fail?
  --  wait for 3 ps;
  --  req <= (others => '0');
  --  wait until cpu_res(72 downto 72) = "1";
  --  wait for 50 ps;
  --end power;

  --procedure run_petersons (rst, clk: in std_logic) is
  --begin
    
  --end;
  
begin
  --* t1: CPU1_R_TEST cpu1 sends a read req msg
  --* t2: CPU2_W_TEST cpu2 sends a write req msg
  --* t3: PETERSONS_TEST executes petersons algorithm
  cpu_test : process(reset, Clock)
    variable st : natural := 0;
    variable t1, t2, t3, t4 : boolean := false;
    
    variable t1_ct : natural;

    variable t2_ct : natural;
    
    variable t3_ct1, t3_ct2, t3_ct3 : natural;
    variable t3_adr_me, t3_adr_other: ADR_T; -- flag0 and flag1
    variable t3_dat1 : DAT_T := (0=>'1',others=>'0'); -- to cmp val of data=1

    variable t4_adr : ADR_T;
    variable t4_dat : DAT_T;
    variable t4_ct, t4_tot, t4_tot_ct : natural := 0;
  begin
    -- Set up tests
    if is_tset(CPU1_R_TEST) then
      t1 := true;
    end if;
    if is_tset(CPU2_W_TEST) then
      t2 := true;
    end if;
    if is_tset(PETERSONS_TEST) then
      t3 := true;
      -- assumming m[shared] is set to 0 TODO set in top.vhd
      if cpu_id = 1 then
        t3_adr_me := PT_VAR_FLAG0;
        t3_adr_other := PT_VAR_FLAG1;
      elsif cpu_id = 2 then
        t3_adr_me := PT_VAR_FLAG1;
        t3_adr_other := PT_VAR_FLAG0;
      end if;
    end if;
    if is_tset(CPU_W20_TEST) then
      t4 := true;
    end if;
      
    if reset = '1' then
      cpu_req_out <= (others => '0');
      -- Set initial rnd delays for each test
      if t1 and (cpu_id = 1)then
        t1_ct := rand_nat(to_integer(unsigned(CPU1_R_TEST)));
        --t1_ct := rand_int(RAND_MAX_DELAY, to_int(t1_ct'instance_name),
        --                  to_integer(unsigned(CPU1_R_TEST)));
        --report "t1.delay is " & integer'image(t1_ct);
      end if;
      if t2 and (cpu_id = 2) then
        t2_ct := rand_nat(to_integer(unsigned(CPU2_W_TEST)));
      end if;
      if t4 then
        t4_ct := rand_nat(to_integer(unsigned(CPU_W20_TEST))); 
      end if;
      st := 0;
    elsif (rising_edge(Clock)) then
      if st = 0 then -- wait
        if t1 and (cpu_id = 1) then
          delay(t1_ct, st, 1);
        end if;
        if t2 and (cpu_id = 2) then
          delay(t2_ct, st, 1);
        end if;
        if t3 then
          st := 100; -- petersons algorithm starts at state 100
        end if;
        if t4 then
          delay(t4_ct, st, 20); -- CPU_W20_TEST starts at state 20
        end if;
      elsif st = 1 then -- send
        -- send a random msg
        if t1 and (cpu_id = 1) then
          report "cpu1_r_test @ " & integer'image(time'pos(now));
          cpu_req_out <= "1" & READ_CMD &
                         "10000000000000000000000000000000" &
                         ZEROS32;
          st := 2;
        elsif t2 and (cpu_id = 2) then
          report "cpu2_w_test @ " & integer'image(time'pos(now));
          cpu_req_out <= "1" & WRITE_CMD &
                         "10000000000000000000000000000000" &
                         ZEROS32;
          st := 2;
        end if;
      elsif st = 2 then -- done
        -- TODO wait for resp
        cpu_req_out<=(others =>'0');
      -- CPU_W20_TEST starts here
      elsif st = 20 then
        t4_adr := rand_vect_range(2**6-1,7) & "000000000" & "0000000000000000";
        t4_dat := rand_vect_range(2**15-1,16) & "0000000000000000";
      elsif st = 21 then
        if t4_tot_ct < t4_tot then
          cpu_req_out <= "1" & WRITE_CMD & t4_adr & t4_dat;
          t4_tot_ct := t4_tot_ct + 1;
          st := 20;
        else
          st := 22;
        end if;
      elsif st = 22 then
        cpu_req_out <= (others => '0');
      -- petersons algorithm starts here
      elsif st = 100 then -- line 1 (for loop)
        if t3_ct1 < 500 then
          st := 101; -- TODO* test then replace with delay(t3_ct3, st, 101)
        else
          st := 2; -- done
        end if;
      elsif st = 101 then -- line 2
        cpu_req_out <= "1" & WRITE_CMD &
                   t3_adr_me &
                   t3_dat1; -- flag[me] = 1; (req)
        st := 102; -- TODO*
      elsif st = 102 then -- line 3
        cpu_req_out <= ZERO_MSG;
        if is_valid(cpu_res_in) then -- TODO check if check is ok
          cpu_req_out <= "1" & WRITE_CMD &
                         PT_VAR_TURN &
                         t3_dat1; -- turn = 1; (req)
          st := 103; --TODO*
        end if;
      elsif st = 103 then -- line 4 part 1 (read flag[other] -- 1st cond of while stmt)
        cpu_req_out <= ZERO_MSG;
        if is_valid(cpu_res_in) then
          cpu_req_out <= "1" & READ_CMD &
                         t3_adr_other &
                         ZEROS32; -- read flag[other]
          st := 104; --TODO*
        end if;
      elsif st = 104 then -- line 4 part 2 (read turn -- 2nd cond of while stmt)
        if is_valid(cpu_res_in) then
          if (get_dat(cpu_res_in) = t3_dat1) then -- if flag[other] = 1
            cpu_req_out <= "1" & READ_CMD &
                           PT_VAR_TURN &
                           ZEROS32; -- read turn
            st := 105; --TODO*
          else
            st := 108; -- jump out of loop
          end if;
        end if;
      elsif st = 105 then -- line 4 part 3 (get val of turn and jmp)
        if is_valid(cpu_res_in) then
          if (get_dat(cpu_res_in) = t3_dat1) then -- if turn=1
            st := 106; --TODO*
          else
            st := 108; -- jump out of loop
          end if;
        end if;
      elsif st = 106 then -- gen rand delay
        st := 107;
      elsif st = 107 then -- line 5 (busy wait)
        -- TODO* delay(t3_ct3, st, 103)
        st := 103;
      elsif st = 108 then -- line 6 (get val of shared)
        cpu_req_out <= "1" & READ_CMD &
                       PT_VAR_SHARED &
                       ZEROS32;
        st := 109; --TODO*
      elsif st = 109 then
        if is_valid(cpu_res_in) then
          cpu_req_out <= "1" & WRITE_CMD &
                         PT_VAR_SHARED &
                         std_logic_vector(unsigned(get_dat(cpu_res_in)) +
                                          unsigned(t3_dat1));
          st := 110; --TODO*
        end if;
      elsif st = 110 then
        if is_valid(cpu_res_in) then
          cpu_req_out <= "1" & WRITE_CMD &
                         t3_adr_other &
                         ZEROS32;
          st := 111; --TODO*
        end if;
      elsif st = 111 then -- jmp to FOR_LOOP_START
        if is_valid(cpu_res_in) then
          st := 100; --TODO*
        end if;
      end if;
    end if;
  end process;    
end Behavioral;
