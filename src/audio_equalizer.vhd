library ieee;
use ieee.std_logic_1164.all;

use work.types.all;
use work.angle.all;
use work.fixed_point.all;
use work.complex.all;
use work.frequency.all;

entity audio_equalizer is
    port (
        audio_input : in audio_voltage_t;
        audio_output : out audio_voltage_buffer_t;
        start : in std_logic;
        sampling, done, output_ready : out std_logic
    );
end entity audio_equalizer;

architecture arch of audio_equalizer is
    type eq_state_t is (EQ_IDLE, EQ_SAMPLING, EQ_STFT, EQ_MIXING, EQ_INVERSE_STFT);
    signal state : eq_state_t := EQ_IDLE;

    constant CLOCK_PERIOD : time := 10 ns;
    signal clock : std_logic;

    signal quantized_input : fixed_point_t;
    signal sample : fixed_point_t;

    signal samples : samples_t;
    signal sample_buffer_enable : std_logic;
    signal sample_buffer_ready : std_logic;

    signal angle_transformer : fixed_point_t;
    signal cosine : fixed_point_t;
    signal sine : fixed_point_t;

    signal transformer_mode, transformer_start, transformer_done : std_logic;
    signal dft_frequency_datum : complex_t;
    signal dft_frequency_data : frequency_data_t;

    signal gain_frequency_data : frequency_data_t;

    signal gain : frequency_data_t :=
    (
        others => to_complex(1.0, 1.0)
    );

    signal gain_enable : std_logic := '1';

    signal idft_signal_point : fixed_point_t;
    signal idft_signal : samples_t;
begin
    clock_gen: entity work.clock_generator(rtl)
        port map (
            clock => clock
        );

    adc : entity work.adc(arch)
        port map (
            raw => audio_input,
            quantized => quantized_input
        );

    sampler : entity work.sampler(arch)
        port map (
            clock => clock,
            quantized => quantized_input,
            sample => sample
        );
    
    sample_buffer : entity work.sample_buffer(arch)
        port map (
            clock => clock,
            enable => sample_buffer_enable,
            ready => sample_buffer_ready,
            sample => sample,
            samples => samples
        );

    trig_lookup_table : entity work.trig_lookup_table(arch)
        port map (
            clock => clock,
            angle => angle_transformer,
            cosine => cosine,
            sine => sine
        );

    transformer : entity work.transformer(arch)
        port map (
            clock => clock,
            mode => transformer_mode,
            start => transformer_start,
            done => transformer_done,

            dft_samples => samples,
            dft_frequency_datum => dft_frequency_datum,
            dft_frequency_data => dft_frequency_data,
            
            idft_frequency_data => gain_frequency_data,
            idft_signal_point => idft_signal_point,
            idft_signal => idft_signal,

            trig_angle => angle_transformer,
            cosine => cosine,
            sine => sine
        );


    -- to loop gain for each freq
    generate_gain : for i in 0 to FREQUENCY_COUNT-1 generate
    begin
        gain_block : entity work.frequency_gain(rtl)
            PORT MAP (
                en => gain_enable, 
                clk => clock,
                freq_amp  => dft_frequency_data(i),
                gain_val => gain(i),
                eq_amp => gain_frequency_data(i)
            );
    end generate;

    generate_dac : for i in 0 to UPPER_INDEX - LOWER_INDEX generate
    begin
        dac : entity work.dac(arch)
            port map(
                digital_in => idft_signal(LOWER_INDEX + i),
                analog_out => audio_output(i)
            );
    end generate;
    

    process(clock)
    begin
        if rising_edge(clock) then
            case state is
                when EQ_IDLE =>
                    if (start = '1') then
                        state <= EQ_SAMPLING;
                        done <= '0';
                        sampling <= '1';
                        sample_buffer_enable <= '1';
                    end if;
                when EQ_SAMPLING =>
                    if (sample_buffer_ready = '1') then
                        sample_buffer_enable <= '0';
                        transformer_mode <= '0';
                        transformer_start <= '1';
                        sampling <= '0';
                        state <= EQ_STFT;
                    end if;
                when EQ_STFT =>
                    if transformer_done = '1' then
                        transformer_start <= '0';
                        gain_enable <= '1';
                        state <= EQ_MIXING;
                    end if;
                when EQ_MIXING =>
                    transformer_mode <= '1';
                    transformer_start <= '1';
                    state <= EQ_INVERSE_STFT;
                when EQ_INVERSE_STFT =>
                    if transformer_done = '1' then
                        state <= EQ_IDLE;
                        done <= '1';
                    end if;
            end case;
        end if;
    end process;
end architecture arch;