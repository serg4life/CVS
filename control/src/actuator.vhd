library IEEE;
context ieee.ieee_std_context;
use ieee.fixed_pkg.all;
use ieee.fixed_float_types.all;
--use work.fixed_pkg.to_sfixed;
--use work.fixed_pkg.to_slv;

entity actuator is
    generic (WIDTH : natural := 12);
    
    port (
        CLK: in  std_logic;
        RST: in  std_logic;
        I:   in  std_logic_vector(7 downto 0);
        O:   out std_logic
    );
end entity;

architecture Behavioral of actuator is

    signal counter          : std_logic_vector (WIDTH-1 downto 0) := (others => '0');
    signal duty_maped       : std_logic_vector (WIDTH-1 downto 0) := (others => '0');
    signal signal_enable    : std_logic := '0';
    signal duty_fixed       : sfixed (6 downto -1) := to_sfixed(0, 6, -1);
    --signal map_value      : natural := (2**(WIDTH-1))-1;
    constant map_value        : sfixed (WIDTH-1 downto 0) := to_sfixed(2**(WIDTH-1)-1, WIDTH-1, 0);
    constant offset           : sfixed (duty_fixed'left downto duty_fixed'right) := to_sfixed(2**7, duty_fixed);

begin
    
    duty_fixed <= to_sfixed(I, duty_fixed);

    process(CLK, RST)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                counter <= (others => '0');
            else
                counter <= std_logic_vector(signed(counter) + 1);
            end if;
        end if;
    end process;

-- Mapeado de valores en coma fija a valores naturales del contador
duty_maped <= std_logic_vector(resize((duty_fixed + offset) * map_value, WIDTH-1, 0, FIXED_SATURATE, FIXED_TRUNCATE)); -- REVISAR TAMBIEN

-- Lógica combinacional para generar la señal PWM
signal_enable <= OR(duty_maped);
O <= signal_enable when duty_maped >= counter else '0';

end Behavioral;