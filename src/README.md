## Background
An **audio equalizer** is a signal-processing system that modifies the amplitude of specific frequency components of an audio signal. In this project, the equalizer is implemented using VHDL and digital signal-processing techniques. The design uses the Short-Time Fourier Transform (STFT) to analyze small blocks of incoming samples and convert them into frequency amplitudes. A gain-control stage then scales each frequency component independently, allowing selective boosting or reduction of particular bands. After modification, the Inverse STFT (ISTFT) reconstructs the time-domain signal, which is finally converted back into an analog voltage.

### Features
- Converts analog audio to digital using ADC
- Converts digital to analog using DAC
- Performs STFT and ISTFT
- Supports per-frequency gain control
- Modular VHDL design (ADC, sampler, buffer, STFT, gain, ISTFT, DAC)
- Testbench support using .txt audio samples

### Project Structure
- `audio_equalizer.vhd` Main entity.
- `types.vhd` Common type declarations for all entities.
- `adc.vhd` Analog-to-Digital converter.
- `dac.vhd` Digital-to-Analog converter
- `sampler.vhd` Sampling block.
- `sample_buffer.vhd` Stores window of samples
- `stft.vhd` Short-time Fourier transform
- `stft_gain.vhd` Gain control for each frequency
- `istft.vhd` Inverse STFT
- `cos_lookup_table.vhd` cosine lookup table for transforms
- `frequency.vhd` frequency bin definitions
- `fixed_point.vhd` fixed-point representation utilities
- `audio_equalizer_tb.vhd` testbench
- `AudioParser.c` WAV to TXT audio parser

## Tool Used
- ModelSim/Vivado (vhdl simulator)
- QuartusPrime/Vivado (synthesis)
- Audio Parser in C

## How to Use
1. Convert audio file `.wav` to `.txt`  using the audio parser
2. Place the `.txt` file in the src folder
3. Open Modelsim/Vivado
4. Compile all VHDL source
5. Run testbench
6. Output will be generated in `output_sample.txt`

## How it Works
<img width="1632" height="1440" alt="image" src="https://github.com/user-attachments/assets/7800783b-564d-4906-9ef8-c3471b59267a" />
The equalizer processes audio by converting it into the frequency domain, adjusting specific frequency levels, and converting it back. First, the analog audio input is converted into a digital signal through the ADC. These digital samples are collected in a buffer, forming a frame of data. Once the buffer is full, the frame is sent to the Short-Time Fourier Transform (STFT) module, which breaks the audio into its frequency components. Each frequency can then be boosted or reduced using the gain controller. This is where the equalizer applies its effect—changing bass, mids, or highs by modifying the amplitudes of selected frequencies. After the gain changes, the Inverse STFT (ISTFT) reconstructs the modified frame back into a time-domain signal. This digital output is then passed through the DAC to convert it back into an analog audio signal.

## Limitation
- Gain control is static
- Need to convert audio file to .txt beforehand
