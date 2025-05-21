library ieee;
context ieee.ieee_std_context;

entity hold is
  port (
    CLK: in  std_logic;
    RST: in  std_logic;
    EN:  in  std_logic;
    I:   in  std_logic_vector(7 downto 0);
    O:   out std_logic_vector(7 downto 0)
  );
end entity;

---

architecture arch of hold is
  signal q: std_logic_vector(7 downto 0) := (others=>'0');

begin
  process(CLK)
  begin
    if rising_edge(CLK) then
      if RST = '1' then
        q <= (others=>'0');
      elsif EN = '1' then
        q <= I;
      end if;
    end if;
  end process;

  O <= q;

end arch;