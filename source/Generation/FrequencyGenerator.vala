public class FrequencyGenerator : SynthModule
{
    private const float D_PI = 6.283185307179f;
    private float rate;
    private float freq = 100;
    private float saved_freq = 0.1f;
    private float amp = 1;
    private float mixing = 0.5f;
    private float phase;

    private int sample;

    public FrequencyGenerator(float rate, TransferSignal? frequency, TransferSignal? amplitude, TransferSignal? mix)
    {
        this.rate = rate;
        this.frequency = frequency;
        this.amplitude = amplitude;
        this.mix = mix;

        output = new TransferSample();
    }

    public override void process()
    {
        if (frequency != null)
        {
            if (saved_freq != frequency.signal.amplitude)
            {
                float time = get_time();

                float cur  = Math.fmodf(time * freq * D_PI + phase, D_PI);

                freq = frequency.signal.amplitude * 100;
                freq *= freq;

                float next = Math.fmodf(time * freq * D_PI, D_PI);

                phase = cur - next;
                saved_freq = frequency.signal.amplitude;
            }
        }

        if (amplitude != null)
            amp = amplitude.signal.amplitude;

        if (mix != null)
            mixing = mix.signal.amplitude;

        float val = get_value(mixing) * amp;
        SoundSample out = SoundSample(val, val);
        output.sample = out;

        sample++;
    }

    private float get_value(float mix)
    {
        float sine = (float)Math.sin(get_time() * freq * D_PI + phase);
        float saw = Math.fmodf(get_time() * freq + phase / D_PI + 0.5f, 1) * 2 - 1;

        return sine * mix + saw * (1 - mix);
    }

    private float get_time()
    {
        return sample / rate;
    }

    public TransferSignal? frequency { get; set; }
    public TransferSignal? amplitude { get; set; }
    public TransferSignal? mix { get; set; }
    public TransferSample output { get; private set; }
}
