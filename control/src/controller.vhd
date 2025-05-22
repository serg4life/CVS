library ieee;
context ieee.ieee_std_context;
use ieee.fixed_pkg.all;
use ieee.fixed_float_types.all;

entity controller is
    -- Aqui algo esta mal no? Tienen que ser vectores!
    GENERIC(b2d : sfixed := to_sfixed(-0.0657, 0, -12);
            b1d : sfixed := to_sfixed(-120, 12, 0);
            b0d : sfixed := to_sfixed(-54800, 17, 0);
            a2d : sfixed := to_sfixed(0, 0, 0);
            a1d : sfixed := to_sfixed(0.7796, 0, -6));               
            
    Port (  CLK  : in STD_LOGIC;
            RST  : in STD_LOGIC;
            EN   : in STD_LOGIC;
            R    : in std_logic_vector (11 downto 0);
            I    : in std_logic_vector(15 downto 0);
            O    : out std_logic_vector (23 downto 0));
            
end controller;

architecture Behavioral of controller is
    signal ef   : sfixed (1 downto -20);
    signal spf  : sfixed (3 downto -8);
    signal posf : sfixed (1 downto -14);
    
    -- Señales auxiliares
    signal eq        : sfixed (1 downto -20);   -- Cambiar bits (revisar)
    signal e_aux     : sfixed (1 downto -20);   -- Cambiar bits
    signal u_aux     : sfixed (3 downto -20);   -- Cambiar bits
    signal u_aux_sat : sfixed (3 downto -20);
    signal b12_d     : sfixed (7 downto -8);    -- Igual que b1_d
    
    -- Parametros
    signal a1_d : sfixed (0 downto -13);
    signal a2_d : sfixed (0 downto 0);    --En matlab no me dejaba poner menos que 2, (solo queremos un bit)
    signal b0_d : sfixed (15 downto -8);
    signal b1_d : sfixed (7 downto -8);
    signal b2_d : sfixed (5 downto -8);
    
    -- Señales de los registros
    signal q1, q2   : sfixed (2 downto -20) := (others => '0');     --Cambiar los bits

begin
    spf <= sfixed(R);
    posf <= sfixed(I);
    --ef <= resize(spf-posf, ef, FIXED_TRUNCATE, FIXED_SATURATE);     --Es necesario hacerlo asi?

    ef <= resize(spf - posf, ef);
    e_aux <= resize(ef - a1_d, e_aux);
    eq <= resize(e_aux - a2_d, eq);
    
    -- Realimentaciones
    a1_d <= resize(a1d*q1, a1_d);
    a2_d <= resize(a2d*q2, a2_d);
    b0_d <= resize(b0d*eq, b0_d);
    b1_d <= resize(b1d*q1, b1_d);
    b2_d <= resize(b2d*q2, b2_d);

    
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '0' then
                if EN = '1' then
                    q1 <= resize(eq + q1, q1);  --Delta simple 1
                end if;
            else
                q1 <= (others => '0');
            end if;
        end if;
    end process;
    
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RST= '0' then
                if EN = '1' then
                    q2 <= resize(q1 + q2, q2);  --Delta simple 2
                end if;
            else
                q2 <= (others => '0');
            end if;
        end if;
    end process;
    
    b12_d <= resize(b2_d + b1_d, b12_d);
    u_aux <= resize(b12_d + b0_d, u_aux);
    
    -- ZOH
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '0' then
                if EN = '1' then
                    O <= to_slv(u_aux);
                end if;
            else
                O <= (others => '0');
            end if;
        end if;
    end process;

end Behavioral;
