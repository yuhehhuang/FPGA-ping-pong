library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity ping_pong_FPGA is 
port(
clk:in std_logic;
reset:in std_logic;
Player1:in std_logic;
Player2:in std_logic;
L:out std_logic_vector(9 downto 0);
HEX0:out std_logic_vector(6 downto 0); --player1的小分
HEX1:out std_logic_vector(7 downto 0);--player1的大分
HEX2:out std_logic_vector(7 downto 0);--player2的大分
HEX3:out std_logic_vector(6 downto 0)--player2的小分
);
end ping_pong_FPGA;
architecture ping_pong_FPGA of ping_pong_FPGA is
type state is (s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16,s17,s18,s19,s20,s21,s22,s23);
signal present_state:state;
signal next_state:state;
signal dcnt:std_logic_vector(24 downto 0);
signal clk2hz:std_logic;
signal point1:std_logic_vector(3 downto 0);--紀錄小分
signal point2:std_logic_vector(3 downto 0);
signal bigpoint1:std_logic_vector(3 downto 0); --紀錄大分
signal bigpoint2:std_logic_vector(3 downto 0);
signal plus:std_logic;
begin
process(clk)
begin
if clk'event and clk='1' then
if dcnt =24999999 then
dcnt<="0000000000000000000000000";
else
 dcnt<=dcnt +1;
 end if;
 end if;
 end process;
 clk2hz<=dcnt(24);

process(clk2hz,reset)
begin
if
reset='0' then
present_state<=s0;
elsif clk2hz'event and clk2hz='1' then
present_state <= next_state;
end if;
end process;
process(Player1,present_state,Player2)
begin
case present_state is
 when s0=>
  if player1 ='0' then
     next_state <=s1;
  else
     next_state <=s0;
  end if;
  L <="0000000000";
  plus<='0';
    when s1=>
  next_state<=s2;
  L<="1000000000";
    when s2=>
  next_state<=s3;
  L<="0100000000";
    when s3=>
  next_state<=s4;
  L<="0010000000";
    when s4=>
  next_state<=s5;
  L<="0001000000";
    when s5=>
  next_state<=s6;
  L<="0000100000";
    when s6=>
  next_state<=s7;
  L<="0000010000";
    when s7=>
  next_state<=s8;
  L<="0000001000";
    when s8=>
  next_state<=s9;
  L<="0000000100";
    when s9=>
  if player2 ='0' then --提早揮拍
     next_state <=s22;
  else
     next_state <=s10;
  end if;
  L<="0000000010";
    when s10=>
  if player2 ='1' then --該揮拍沒揮
     next_state <=s22;
  else
     next_state <=s11;
  end if;
  L<="0000000001";
  when s11=>
  next_state<=s12;
  L<="0000000010";
  when s12=>
  next_state<=s13;
  L<="0000000100";
    when s13=>
  next_state<=s14;
  L<="0000001000";
    when s14=>
  next_state<=s15;
  L<="0000010000";
    when s15=>
  next_state<=s16;
  L<="0000100000";
    when s16=>
  next_state<=s17;
  L<="0001000000";
    when s17=>
  next_state<=s18;
  L<="0010000000";
      when s18=>
 if player1 ='0' then --player1提早揮拍輸了改由player2發球
     next_state <=s23;
  else
     next_state <=s19;
  end if;
  L<="0100000000";
      when s19=>
   if player1 ='1' then --player1應揮拍沒揮拍，輸了，改由player2發球
     next_state <=s23;
  else
     next_state <=s2; --player1揮到球，繼續
  end if;
  L<="1000000000";
    when s20=>  --s20是B的發球狀態
	if player2 ='1' then  --未發球，狀態保持
     next_state <= s20;
   else	--發球
     next_state <=s21;
	end if; 
  L <="0000000000";
  plus <= '0';
    when s21=>
	next_state<=s11;
  L<="0000000001";
   when s22 =>
				next_state <= s0;
				L <= "0000000000";
				plus <= '1';
   when s23 =>
				next_state <= s0;
				L <= "0000000000";
				plus <= '1';
end case;	
end process;
process(plus,reset,present_state,point1,point2,bigpoint1,bigpoint2)
begin
if reset='0' then point1<="0000";
                  point2<="0000";
						bigpoint1<="0000";
						bigpoint2<="0000";
elsif point1=5 and present_state = s22 then
point1<="0000";
point2<="0000";
bigpoint1<=bigpoint1+1;
elsif point2=5 and present_state = s20 then
point1<="0000";
point2<="0000";
bigpoint2<=bigpoint2+1;
elsif plus'event and plus = '1' then 
if point1<5 and present_state = s22 then 
point1 <=point1 +1;
elsif point2<5 and present_state = s23 then
point2 <= point2 +1;
end if;
end if;				
end process;

		HEX0 <=	"1000000" when point1 = 0 else
			"1111001" when point1 = 1 else   
			"0100100" when point1 = 2 else
			"0110000" when point1 = 3 else
			"0011001" when point1 = 4 else
			"1000000" when point1 = 5 else
			"1111111";
		HEX1<="11000000"when bigpoint1=0 else
		"11111001"      when bigpoint1=1 else
		"10100100"      when bigpoint1=2 else
		"01111111"; --只亮HEX1的小燈表示player1贏
		HEX2<="11000000"when bigpoint2=0 else
		"11111001"      when bigpoint2=1 else
		"10100100"      when bigpoint2=2 else
		"01111111"; --只亮HEX2的小燈表示player2贏
		HEX3<=	"1000000" when point2=0 else
			"1111001" when point2 = 1 else
			"0100100" when point2 = 2 else
			"0110000" when point2 = 3 else
			"0011001" when point2 = 4 else
			"1000000" when point2 = 5 else
			"1111111";

end ping_pong_FPGA;