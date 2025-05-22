library ieee;
context ieee.ieee_std_context;

entity actuator is
  port (
    CLK: in  std_logic;
    RST: in  std_logic;
    EN:  in  std_logic;
    I:   in  std_logic_vector(7 downto 0);
    O:   out std_logic
  );
end entity;

---

architecture arch of actuator is

begin

O <= I(0) OR I(1) OR I(2) OR I(3) OR I(4) OR I(5) OR I(6) OR I(7);

end arch;