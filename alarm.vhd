library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity alarm is
    generic (
        N: natural
    );
    port (
        sensors: in std_logic_vector(0 to N-1);
        key: in std_logic;
        clock: in std_logic;
        siren: out std_logic
    );
end entity;

architecture behavioral of alarm is
    type state_type is (off, arming, armed, siren_delay, siren_on);
    signal current_state, next_state: state_type;
    signal sensor_detected: std_logic;
    signal counter: integer := 0;
    constant delay_time: integer := 30;
begin
    process(clock)
    begin
        if rising_edge(clock) then
            if current_state = siren_delay or current_state = arming then
                if counter < delay_time then
                    counter <= counter + 1;
                end if;
            else
                counter <= 0;
            end if;
            current_state <= next_state;
        end if;
    end process;

    process(current_state, key, sensors, counter)
    begin
        siren <= '0';
        sensor_detected <= '0';

        for i in 0 to N-1 loop
            if sensors(i) = '1' then
                sensor_detected <= '1';
            end if;
        end loop;

        case current_state is
            when off =>
                if key = '1' then
                    next_state <= arming;
                else
                    next_state <= off;
                end if;
                
            when arming =>
                if key = '0' then
                    next_state <= off;
                elsif counter = delay_time then
                    next_state <= armed;
                else
                    next_state <= arming;
                end if;

            when armed =>
                if key = '0' then
                    next_state <= off;
                elsif sensor_detected = '1' then
                    next_state <= siren_delay;
                else
                    next_state <= armed;
                end if;

            when siren_delay =>
                if key = '0' then
                    next_state <= off;
                elsif counter = delay_time then
                    next_state <= siren_on;
                else
                    next_state <= siren_delay;
                end if;

            when siren_on =>
                if key = '0' then
                    next_state <= off;
                else
                    siren <= '1';
                    next_state <= siren_on;
                end if;

            when others =>
                next_state <= off;

        end case;
    end process;
end architecture;