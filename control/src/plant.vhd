library ieee;
context ieee.ieee_std_context;

entity plant is
  port (
    CLK: in  std_logic;
    RST: in  std_logic;
    EN:  in  std_logic;
    I:   in  std_logic;
    O:   out std_logic_vector(7 downto 0)
  );
end entity;

---

architecture arch of plant is
  signal s: std_logic_vector(7 downto 0);
begin

  process(CLK)
  begin
    if rising_edge(CLK) then
      if RST then
        s <= (others=>'0');
      elsif EN then
        s <= std_logic_vector(signed(s)+1) when I ='1' else
             std_logic_vector(signed(s)-1) when I ='0' else s;
      end if;
    end if;
  end process;

  O <= s;

end arch;