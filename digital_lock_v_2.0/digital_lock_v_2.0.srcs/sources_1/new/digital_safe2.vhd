----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.03.2020 16:16:27
-- Design Name: 
-- Module Name: digital_safe - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;



-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity digital_safe2 is
 Port (
 num: in std_logic_vector(8 downto 0);
 Anode_Active: out std_logic_vector(7 downto 0);
 Led_out: out std_logic_vector(6 downto 0);
 reset: in std_logic;
 show: in std_logic;
 pass: in std_logic;
 clock100MHZ: in std_logic;
 o_led_drive : out std_logic_vector(15 downto 1);
 UNLOCK: out std_logic
  );
end digital_safe2;

architecture Behavioral of digital_safe2 is
signal LED_BCD: STD_LOGIC_VECTOR (8 downto 0);
signal refresh_counter: STD_LOGIC_VECTOR (19 downto 0);
-- creating 10.5ms refresh period
signal LED_activating_counter: std_logic_vector(2 downto 0);
signal D1: std_logic_vector(8 downto 0):="000000000";
signal D2: std_logic_vector(8 downto 0):="000000000";
signal D3: std_logic_vector(8 downto 0):="000000000";
signal D4: std_logic_vector(8 downto 0):="000000000";
signal D5: std_logic_vector(8 downto 0):="000000000";
signal D6: std_logic_vector(8 downto 0):="000000000";
signal D7: std_logic_vector(8 downto 0):="000000000";
signal D8: std_logic_vector(8 downto 0):="000000000";
signal err1:std_logic_vector(2 downto 0):="000";
signal err:std_logic_vector(2 downto 0):="000";
signal alert: std_logic:='0';


signal P1: std_logic_vector(8 downto 0):="000000001";
signal P2: std_logic_vector(8 downto 0):="000000010";
signal P3: std_logic_vector(8 downto 0):="000000100";
signal P4: std_logic_vector(8 downto 0):="000001000";


constant c_CNT_10HZ  : natural := 5000000;
signal r_CNT_10HZ  : natural range 0 to c_CNT_10HZ;
signal r_TOGGLE_10HZ  : std_logic := '0';



subtype state_type is integer range 0 to 18; 
signal state, nextstate: state_type; 
begin
process(LED_BCD)
begin
    case LED_BCD is
    when "000000000" => Led_out <= "0000001"; -- "0"     
    when "000000001" => Led_out <= "1001111"; -- "1" 
    when "000000010" => Led_out <= "0010010"; -- "2" 
    when "000000100" => Led_out <= "0000110"; -- "3" 
    when "000001000" => Led_out <= "1001100"; -- "4" 
    when "000010000" => Led_out <= "0100100"; -- "5" 
    when "000100000" => Led_out <= "0100000"; -- "6" 
    when "001000000" => Led_out <= "0001111"; -- "7" 
    when "010000000" => Led_out <= "0000000"; -- "8"     
    when "100000000" => Led_out <= "0000100"; -- "9" 
    when "110000000" => Led_out <= "0011000"; -- "p"
    when "111000000" => Led_out <= "0000010"; -- "a"
    when "111100000" => Led_out <= "0010000"; -- "e"
    when "111110000" => Led_out <= "0111001"; -- "r"
    when "111111000" => Led_out <= "0001000"; -- "A"
    when "111111100" => Led_out <= "1110001"; -- "L"
    when others => Led_out<="1111111";
    end case;
end process;

process(clock100Mhz,reset)
begin 
    if(reset='1') then
        refresh_counter <= (others => '0');
    elsif(rising_edge(clock100Mhz)) then
        refresh_counter <= refresh_counter + 1;
    end if;
end process;
 LED_activating_counter <= refresh_counter(19 downto 17);

process(LED_activating_counter)
begin
    case LED_activating_counter is
    when "000" =>
        Anode_Active <= "11111110"; 
        LED_BCD<=D1;
    when "001" =>
        Anode_Active <= "11111101";
        LED_BCD<=D2; 
    when "010" =>
        Anode_Active <= "11111011";
        LED_BCD<=D3; 
    when "011" =>
        Anode_Active <= "11110111"; 
        LED_BCD<=D4; 
    when "100" =>
        Anode_Active <= "11101111"; 
        LED_BCD<=D5; 
    when "101" =>
        Anode_Active <= "11011111"; 
        LED_BCD<=D6; 
    when "110" =>
        Anode_Active <= "10111111"; 
        LED_BCD<=D7;
    when "111" =>
        Anode_Active <= "01111111"; 
        LED_BCD<=D8;  
    end case;
end process;

 p_10_HZ : process (clock100Mhz) is
  begin
    if rising_edge(clock100Mhz) then
      if r_CNT_10HZ = c_CNT_10HZ-1 then  -- -1, since counter starts at 0
        r_TOGGLE_10HZ <= not r_TOGGLE_10HZ;
        r_CNT_10HZ    <= 0;
      else
        r_CNT_10HZ <= r_CNT_10HZ + 1;
      end if;
    end if;
  end process p_10_HZ;
  
  process(alert) is 
  begin 
  if (alert='1') then
  o_led_drive<=(others=>r_TOGGLE_10HZ);
  end if;
  end process;

process(num,state)
begin
    case state is
    when 0 => if(alert='1')then nextstate<=18;
              end if;
              if(pass='1'and alert='0') then nextstate<=10;
              elsif(pass='0'and alert='0') then
              if(num="000000000") then nextstate<=0;
              else nextstate<=1; D1<=num;
              end if; 
              end if;
    when 1 => if(num="000000000") then nextstate<=2;
              else nextstate<=1;
              end if;
    when 2 => if(num="000000000")then nextstate<=2; 
              else nextstate<=3; D2<=num;
              end if;
    when 3 => if(num="000000000") then nextstate<=4;
              else nextstate<=3;
              end if; 
    when 4 => if(num="000000000")then nextstate<=4;
              else nextstate<=5; D3<=num;
              end if;
    when 5 => if(num="000000000") then nextstate<=6;
              else nextstate<=5;
              end if;
    when 6 => if(num="000000000") then nextstate<=6;
              else nextstate<=7; D4<=num;
              end if;                 
    when 7 =>if(D1=P1) then
                    if(D2=P2) then
                        if(D3=P3)then 
                            if(D4=P4) then nextstate<=8;
                                else nextstate<=9;
                                end if;
                        else nextstate<=9;
                        end if;
                    else nextstate<=9;
                    end if;
                else nextstate<=9;
                end if;
    when 8=>    if(num="000000000") then 
                nextstate<=0;
                D1<=(others => '0');
                D2<=(others => '0');
                D3<=(others => '0');
                D4<=(others => '0');
                else nextstate<=8;
                end if;
    when 9=>    if(num="000000000") then 
                nextstate<=0;
                D1<=(others => '0');
                D2<=(others => '0');
                D3<=(others => '0');
                D4<=(others => '0');
                if(err="000") then err1<="010";
                elsif(err="001")then err1<="110";
                elsif(err="010") then err1<="001";
                elsif(err="110") then err1<="100";
                elsif(err="100") then err1<="111";
                else err1<="111";
                end if;
              else nextstate<=9;
              end if;    
    when 10=> if(num="000000000") then nextstate<=10;
              else nextstate<=11; P1<=num; D1<=num;
              end if;
    when 11=> if(num="000000000") then nextstate<=12;
              else nextstate<=11;
              end if;
    when 12=>if(num="000000000") then nextstate<=12;
              else nextstate<=13; P2<=num; D2<=num;
              end if;  
    when 13=>if(num="000000000") then nextstate<=14;
              else nextstate<=13;
              end if;  
    when 14=>if(num="000000000") then nextstate<=14;
              else nextstate<=15; P3<=num; D3<=num;
              end if;
    when 15=>if(num="000000000") then nextstate<=16;
              else nextstate<=15;
              end if;
    when 16=>if(num="000000000") then nextstate<=16;
              else nextstate<=17; P4<=num; D4<=num;
              end if;
    when 17=> if(pass='0')then
              if(num="000000000") then 
              nextstate<=0;
                D1<=(others => '0');
                D2<=(others => '0');
                D3<=(others => '0');
                D4<=(others => '0');
              else nextstate<=17;
              end if;
              else nextstate<=17;
              end if;
    when 18=> if(alert='1')then D1<="111110000";
              D2<="111100000";
              D3<="111111100";
              D4<="111111000";
              else  nextstate<=18;
              end if;
      end case;
    end process;
    
process(err)
begin
if(err="111") then alert<='1';
end if;
end process;

process(show)
begin
if(show='1')then
if(pass='0') then
D5<=P1;
D6<=P2;
D7<=P3;
D8<=P4;
elsif(pass='1')then
D5<="000010000";
D6<="000010000";
D7<="111000000";
D8<="110000000";
end if;
else 
if(err="000")then D5<=(others => '0');
                 D6<=(others => '0'); 
                 D7<=(others => '0');
                 D8<=(others => '0');
elsif(err="001")then D5<="000000001";
           D6<="111110000";
           D7<="111110000";
           D8<="111100000";
elsif(err="100")then D5<="000000010";
           D6<="111110000";
           D7<="111110000";
           D8<="111100000";
elsif(err="111") then D5<="000000100";
     D6<="111110000";
     D7<="111110000";
     D8<="111100000";
elsif(err="010")then D5<="100000000";
     D6<="111110000"; 
     D7<="111110000";
     D8<="111100000";
     else D5<="010000000";
     D6<="111110000";
     D7<="111110000";
     D8<="111100000";
     end if;    
end if;


end process;
process(state) 
begin 
  case state is 
     when 0 to 7  => UNLOCK <= '0'; 
     when  8 => UNLOCK <= '1'; 
     when 9 to 18=> UNLOCK <= '0';
  end case;  
end process; 

process(clock100MHZ) 
begin 
  if rising_edge(clock100MHZ) then 
     state <= nextstate;
     err <= err1;
  end if; 
end process; 
end Behavioral;
