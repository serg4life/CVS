library IEEE;
context ieee.ieee_std_context;
use ieee.fixed_pkg.all;
use ieee.fixed_float_types.all;
--use work.fixed_pkg.to_sfixed;
--use work.fixed_pkg.to_slv;

entity actuator is
    GENERIC (WIDTH      : INTEGER := 12);
    Port (
        clk           : in  STD_LOGIC;                             -- Reloj del sistema
        reset         : in  STD_LOGIC;                             -- Reset síncrono
        measure       : in  STD_LOGIC_VECTOR(15 downto 0) := (others => '0');          -- Asumimos que es de 8 bits
        duty_cycle    : in  STD_LOGIC_VECTOR(7 downto 0); 
        pwm_out       : out STD_LOGIC                              -- Señal PWM resultante
    );
end actuator;

architecture Behavioral of actuator is

    signal counter          : std_logic_vector (WIDTH-1 downto 0) := (others => '0');
    signal duty_maped       : std_logic_vector (WIDTH-1 downto 0) := (others => '0');
    signal signal_enable    : std_logic := '0';
    signal measure_fixed    : sfixed (14 downto -1) := to_sfixed(1, 14, -1); -- 2 bits enteros y 6 de resolucion fraccional
    signal duty_fixed       : sfixed (9 downto -14) := to_sfixed(0, 9, -14);
    signal duty_fixed_n     : sfixed (9 downto -14) := to_sfixed(0, 9, -14);
    --signal map_value      : natural := (2**(WIDTH-1))-1;
    signal map_value        : sfixed (WIDTH-1 downto 0) := to_sfixed(2**(WIDTH-1)-1, WIDTH-1, 0);

begin
    
    measure_fixed <= to_sfixed(measure, measure_fixed);
    duty_fixed <= to_sfixed(std_logic_vector(resize(unsigned(duty_cycle), 24)), duty_fixed);
    process(clk)
    begin
        if rising_edge(clk) then
          if measure_fixed = 0 then
            report "Divisor cero detectado" severity warning;
          else
            duty_fixed_n <= resize(duty_fixed/measure_fixed, duty_fixed_n, FIXED_SATURATE, FIXED_TRUNCATE);
          end if;
        end if;
    end process;

    process(clk, reset)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                counter <= (others => '0');
            else
                counter <= std_logic_vector(signed(counter) + 1);
            end if;
        end if;
    end process;

-- Mapeado de valores en coma fija a valores naturales del contador
duty_maped <= std_logic_vector(resize(duty_fixed_n + map_value * map_value, WIDTH-1, 0, FIXED_SATURATE, FIXED_TRUNCATE)); -- REVISAR TAMBIEN

-- Lógica combinacional para generar la señal PWM
signal_enable <= OR(duty_maped);
pwm_out <= signal_enable when duty_maped >= counter else '0';

end Behavioral;