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
  signal vel_actual : unsigned(7 downto 0) := (others => '0');
  constant MAX_VAL  : unsigned(7 downto 0) := x"FF"; -- 255

begin
  process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                vel_actual <= (others => '0');
            elsif EN = '1' then
                if I = '1' then
                    -- Acelerar: incrementar velocidad (hasta un máximo)
                    if vel_actual < MAX_VAL - 1 then
                        vel_actual <= vel_actual + 1;
                    end if;
                else
                    -- Desacelerar: disminuir velocidad (hasta 0)
                    if vel_actual > 0 then
                      vel_actual <= vel_actual + 1 when vel_actual < MAX_VAL - 4 else vel_actual; --Simula una respuesta lenta del motor.
                    end if;
                end if;
            end if;
        end if;
    end process;

    O <= std_logic_vector(vel_actual);
end arch;