using PortAudio;
using Gee;

public class MusicGenerator
{
    private AudioSampleBuffer buffer = new AudioSampleBuffer();
    private bool run = true;

    public MusicGenerator()
    {
    }

    private void init()
    {
        /*arp = new Arpeggiator(44100, 0.05f, 0.05f);
        arp.add_note(new ArpeggiatorNote(200));
        arp.add_note(new ArpeggiatorNote(200));
        arp.add_note(new ArpeggiatorNote(200));
        arp.add_note(new ArpeggiatorNote(0));*/
    }

    /*private ComplexGenerator gen  = new ComplexGenerator(44100, 0, 1);
    private SineGenerator cplfo  = new SineGenerator(44100, 1.0f, 1);
    private Arpeggiator arp;

    private SineGenerator lfo  = new SineGenerator(44100, 0, 1);
    private SawGenerator  lfo2 = new SawGenerator (44100, 10.5f, 1);
    private SineGenerator lfo3 = new SineGenerator(44100, 5.3f, 1);
    private LowPassFilter lpf  = new LowPassFilter(0, 0.4f);
    private ReverbFilter rev = new ReverbFilter(44100, 0.4f, 0.4f);

    float derp = 0;*/
    private ArrayList<SoundSample?>? generate_samples(int count)
    {
        /*float lfofreq = 10.8f;

        print("Generating " + count.to_string() + "samples\n");
        ArrayList<SoundSample?> samples = new ArrayList<SoundSample?>();

        for (int i = 0; i < count; i++)
        {
            float l2 = lfo2.get_sample().left;
            lfo.frequency = lfofreq + lfofreq * l2;

            float samp = lfo.get_sample().left;
            float freq = arp.get_signal().frequency;
            gen.frequency = freq + freq * samp * 0.05f;
            gen.mix = (1 + cplfo.get_sample().left) * 0.5f;

            lpf.cutoff = 0.5f + lfo3.get_sample().left * 0.35f;

            SoundSample sample = gen.get_sample();
            if (gen.samples < 44100 * 0.5f)
            {
                sample.left  *= derp   / (44100 * 0.5f);
                sample.right *= derp++ / (44100 * 0.5f);
            }
            else if (gen.samples > 44100 * 10)
            {
                sample.left  *= Math.fmaxf(0, 1 - (derp   / 44100));
                sample.right *= Math.fmaxf(0, 1 - (derp++ / 44100));
            }
            else
                derp = 0;

            sample = lpf.filter(sample);
            sample = rev.filter(sample);

            samples.add(sample);
        }

        return samples;*/
        return null;
    }
}

public class ModuleTree
{
    private Mutex mutex = Mutex();
    private ArrayList<SynthModule> modules = new ArrayList<SynthModule>();
    private OutputModule? output;

    private AudioSampleBuffer buffer = new AudioSampleBuffer();
    private bool run = true;

    public void add_module(SynthModule module)
    {
        mutex.lock();
        modules.add(module);
        mutex.unlock();
    }

    public void remove_module(SynthModule module)
    {
        mutex.lock();
        modules.remove(module);
        mutex.unlock();
    }

    public void set_output_module(OutputModule? module)
    {
        output = module;
    }

    public void start()
    {
        Threading.start0(worker);
    }

    public void stop()
    {
        run = false;
        buffer.close();
    }

    private void worker()
    {
        while (run)
        {
            int sample_count = buffer.open_samples;

            if (sample_count > 0)
            {
                ArrayList<SoundSample?> samples = generate_samples(sample_count);
                buffer.buffer_list(samples);

                if (!buffer.started)
                {
                    if (!buffer.start())
                    {
                        print("Could not start buffer.\n");
                        return;
                    }
                }
            }
            else
                Thread.usleep(1000);
        }
    }

    private ArrayList<SoundSample?> generate_samples(int count)
    {
        ArrayList<SoundSample?> samples = new ArrayList<SoundSample?>();

        //print("Generating " + count.to_string() + " samples.\n");

        mutex.lock();
        for (int i = 0; i < count; i++)
        {
            foreach (SynthModule module in modules)
                module.process();

            SoundSample sample;
            if (output != null)
                sample = output.output.sample;
            else
                sample = SoundSample(0, 0);
            samples.add(sample);
        }
        mutex.unlock();

        return samples;
    }
}

public interface ITransferable : Object {}

public class TransferSample : Object, ITransferable
{
    public SoundSample sample { get; set; }
}

public class TransferSignal : Object, ITransferable
{
    public ControlSignal signal { get; set; }
}

public struct SoundSample
{
    public SoundSample(float left, float right)
    {
        this.left = left;
        this.right = right;
    }

    float left;
    float right;
}

public struct ControlSignal
{
    public ControlSignal(float amplitude)
    {
        this.amplitude = amplitude;
    }

    float amplitude;
}

private class AudioSampleBuffer
{
    private const int NUM_INPUT_CHANNELS = 0;
    private const int NUM_OUTPUT_CHANNELS = 2;
    private const int SAMPLE_RATE = 44100;
    private const int FRAMES_PER_BUFFER = 128;
    private const SampleFormat SAMPLE_FORMAT = FLOAT_32;

    private Stream stream;
    private SampleRingBuffer ring_buffer = new SampleRingBuffer(2048);
    private Mutex mutex = Mutex();

    public AudioSampleBuffer()
    {
        //open_samples = ring_buffer.open_samples;
    }

    public bool start()
    {
        initialize();
        PortAudio.Error error = Stream.open_default
        (
            out stream,
            NUM_INPUT_CHANNELS,
            NUM_OUTPUT_CHANNELS,
            SAMPLE_FORMAT,
            SAMPLE_RATE,
            FRAMES_PER_BUFFER,
            stream_callback
        );

        if (error != ErrorCode.NO_ERROR)
            return false;

        if (stream.start() != ErrorCode.NO_ERROR)
            return false;

        started = true;

        return true;
    }

    public void close()
    {
        // TODO: Close
    }

    public void buffer_list(ArrayList<SoundSample?> samples)
    {
        //mutex.lock();
        //print("Adding " + samples.size.to_string() + " samples\n");
        ring_buffer.add_list(samples);
        //open_samples = ring_buffer.open_samples;
        //mutex.unlock();
    }

    /*public void buffer_array(SoundSample[] samples)
    {
        mutex.lock();
        ring_buffer.add_array(samples);
        open_samples = ring_buffer.open_samples;
        mutex.unlock();
    }*/

    private int stream_callback
    (
        void* input,
        void* output,
        ulong frame_count,
        Stream.CallbackTimeInfo time_info,
        Stream.CallbackFlags status_flags
    )
    {
        float *data = (float*)output;

        //for (int i = 0; i < 4; i++)
        {
            //if (ring_buffer.size - ring_buffer.open_samples >= FRAMES_PER_BUFFER)
            //    break;
            Thread.usleep(1000);
        }

        //mutex.lock();
        //print("Eating: " + FRAMES_PER_BUFFER.to_string() + " samples.\n");
        for (int i = 0; i < FRAMES_PER_BUFFER; i++)
        {
            SoundSample sample = ring_buffer.pop();
            data[i*2]   = sample.left;
            data[i*2+1] = sample.right;
        }
        //open_samples = ring_buffer.open_samples;
        //mutex.unlock();

        return ErrorCode.NO_ERROR;
    }

    public bool started { get; private set; }
    public int open_samples
    {
        get { return ring_buffer.open_samples; }
    }
}

private class SampleRingBuffer
{
    private int read_position;
    private int write_position;
    private SoundSample[] samples;
    private Mutex mutex = Mutex();

    public SampleRingBuffer(int size)
    {
        samples = new SoundSample[size];
        open_samples = size;
    }

    public void add_sample(SoundSample sample)
    {
        samples[write_position] = sample;
        write_position = (write_position + 1) % this.samples.length;
        open_samples = int.max(open_samples - 1, 0);
    }

    public void add_list(ArrayList<SoundSample?> samples)
    {
        for (int i = 0; i < samples.size; i++)
        {
            this.samples[write_position] = samples[i];
            write_position = (write_position + 1) % this.samples.length;
        }

        mutex.lock();
        open_samples = int.max(open_samples - samples.size, 0);
        mutex.unlock();
    }

    public void add_array(SoundSample[] samples)
    {
        for (int i = 0; i < samples.length; i++)
        {
            this.samples[write_position] = samples[i];
            write_position = (write_position + 1) % this.samples.length;
        }

        mutex.lock();
        open_samples = int.max(open_samples - samples.length, 0);
        mutex.unlock();
    }

    public SoundSample pop()
    {
        SoundSample sample = samples[read_position];
        read_position = (read_position + 1) % this.samples.length;
        mutex.lock();
        open_samples = int.min(samples.length, open_samples + 1);
        mutex.unlock();

        return sample;
    }

    public SoundSample get(int i)
    {
        return samples[(samples.length + read_position - (i % samples.length)) % samples.length];
    }

    public void resize(int size)
    {
        // TODO: Find efficient resizing algo
    }

    public void set(int i, SoundSample sample)
    {
        samples[(samples.length + write_position - (i % samples.length)) % samples.length] = sample;
    }

    public int open_samples { get; private set; }
    public int size { get { return samples.length; } }
}

public abstract class SynthModule
{
    public abstract void process();
}



/*public class SawGenerator : SynthModule
{
    private const float D_PI = 6.283185307179f;
    private float phase;
    private int sample;

    public SawGenerator(float rate, TransferSignal? input)
    {
        this.rate = rate;
        this.input = input;
        frequency = 1;
        amplitude = 1;
        output = new TransferSample();
    }

    public override void process()
    {
        if (input != null)
        {
            if (frequency != input.signal.frequency)
            {
                float time = get_time();

                float cur  = Math.fmodf(time * frequency * D_PI + phase, D_PI);
                float next = Math.fmodf(time * input.signal.frequency * D_PI, D_PI);

                phase = cur - next;
                frequency = input.signal.frequency;
            }

            amplitude = input.signal.amplitude;
        }

        float val = (Math.fmodf(get_time() * frequency + phase / D_PI + 0.5f, 1) - 0.5f) * amplitude;
        SoundSample out = SoundSample(val, val);
        output.sample = out;

        sample++;
    }

    private float get_time()
    {
        return sample / rate;
    }

    public float rate { get; private set; }
    public float amplitude { get; private set; }
    public float frequency { get; private set; }

    public TransferSample output { get; private set; }
    public TransferSignal? input { get; set; }
}*/

/*private class SawGenerator
{
    private const float D_PI = 6.283185307179f;
    private float _frequency;
    private float phase;
    public int sample;

    public SawGenerator(float rate, float frequency, float amplitude)
    {
        this.rate = rate;
        this.frequency = frequency;
        this.amplitude = amplitude;
    }

    public SoundSample get_sample()
    {
        float val = (Math.fmodf(get_time() * frequency + phase / D_PI + 0.5f, 1) - 0.5f) * amplitude;
        SoundSample sample = SoundSample(val, val);
        this.sample++;
        return sample;
    }

    private float get_time()
    {
        return sample / rate;
    }

    public float rate { get; private set; }
    public float amplitude { get; set; }
    public float frequency
    {
        get { return _frequency; }
        set
        {
            if (_frequency != value)
            {
                float time = get_time();

                float cur  = Math.fmodf(time * _frequency * D_PI + phase, D_PI);
                float next = Math.fmodf(time * value * D_PI, D_PI);

                phase = cur - next;
                _frequency = value;
            }
        }
    }
}*/

/*public class ComplexGenerator : SynthModule
{
    private SawGenerator saw;
    private SineGenerator sine;
    private float mix_val = 0.5f;

    public ComplexGenerator(float rate, TransferSignal? frequency, TransferSignal? mix)
    {
        this.mix = mix;
        saw = new SawGenerator(rate, frequency);
        sine = new SineGenerator(rate, frequency);
        output = new TransferSample();
    }

    public override void process()
    {
        sine.process();
        saw.process();

        if (mix != null)
            mix_val = mix.signal.amplitude;

        SoundSample si = sine.output.sample;
        SoundSample sw = saw.output.sample;

        float lval = sw.left  * mix_val + si.left  * (1 - mix_val);
        float rval = sw.right * mix_val + si.right * (1 - mix_val);

        output.sample = SoundSample(lval, rval);
    }

    public float rate
    {
        get { return sine.rate; }
    }

    public TransferSignal? frequency
    {
        get { return sine.input; }
        set
        {
            sine.input = value;
            saw.input = value;
        }
    }

    public TransferSignal? mix { get; set; }
    public TransferSample output { get; private set; }
}*/

public class LowFrequencyOscillator : SynthModule
{
    private FrequencyGenerator generator;
    private TransferSignal gen_freq;

    public LowFrequencyOscillator(float rate, TransferSignal? frequency, TransferSignal? width, TransferSignal? offset, TransferSignal? mix)
    {
        gen_freq = new TransferSignal();
        generator = new FrequencyGenerator(rate, gen_freq, null, mix);
        this.frequency = frequency;
        this.width = width;
        this.offset = offset;
        output = new TransferSignal();
    }

    public override void process()
    {
        float f = 1;
        if (frequency != null)
            f = frequency.signal.amplitude;
        f /= 10;

        gen_freq.signal = ControlSignal(f);
        generator.process();

        if (width != null && offset != null)
        {
            SoundSample s = generator.output.sample;
            float val = offset.signal.amplitude * (1 - width.signal.amplitude) + ((1 + s.left) / 2) * width.signal.amplitude;
            output.signal = ControlSignal(val);
        }
        else
            output.signal = ControlSignal(0);
    }

    public TransferSignal? frequency { get; set; }
    public TransferSignal? width { get; set; }
    public TransferSignal? offset { get; set; }

    public TransferSignal? mix
    {
        get { return generator.mix; }
        set { generator.mix = value; }
    }

    public TransferSignal output { get; private set; }
}

public class LowPassFilter : SynthModule
{
    private float lv0;
    private float lv1;
    private float rv0;
    private float rv1;
    private float smear;
    private float smear_amp = 0.1f;

    private float cut;
    private float res;

    public LowPassFilter(TransferSample? input, TransferSignal? cutoff, TransferSignal? resonance)
    {
        this.input = input;
        this.cutoff = cutoff;
        this.resonance = resonance;
        output = new TransferSample();
    }

    public override void process()
    {
        if (cutoff != null)
            cut    = (float)Math.pow(0.5, 8 - cutoff.signal.amplitude * 8);
        if (resonance != null)
            res = (float)Math.pow(0.5, 8 * resonance.signal.amplitude + 1.5f);

        if (input != null)
        {
            lv0 = (1 - res * cut) * lv0 - cut * lv1 + cut * input.sample.left;
            lv1 = (1 - res * cut) * lv1 + cut * lv0 * ((float)Math.cos(smear) * smear_amp + 1);

            rv0 = (1 - res * cut) * rv0 - cut * rv1 + cut * input.sample.right;
            rv1 = (1 - res * cut) * rv1 + cut * rv0 * ((float)Math.sin(smear) * smear_amp + 1);

            smear += 0.1f;

            output.sample = SoundSample(lv1, rv1);
        }
        else
            output.sample = SoundSample(0, 0);
    }

    public TransferSample? input { get; set; }
    public TransferSignal? cutoff { get; set; }
    public TransferSignal? resonance { get; set; }
    public TransferSample output { get; private set; }
}

public class ReverbFilter : SynthModule
{
    private const float OFFSET = 0.98786f;

    private float _delay;
    private float rate;
    private float up_rate = 0.3f;
    private SampleRingBuffer lbuffer;
    private SampleRingBuffer rbuffer;
    private float smear;

    public ReverbFilter(float rate, TransferSample? input, TransferSignal? amplitude)
    {
        float delay = 0.4f;
        lbuffer = new SampleRingBuffer((int)(rate * delay) * 2);
        rbuffer = new SampleRingBuffer((int)(rate * delay * OFFSET) * 2);

        this.rate = rate;
        _delay = delay;
        this.input = input;
        this.amplitude = amplitude;

        output = new TransferSample();
    }

    public override void process()
    {
        if (amplitude != null && input != null)
        {
            float lval = (input.sample.left  + lbuffer[lbuffer.size - 1].left  * amplitude.signal.amplitude) * 0.5f;
            float rval = (input.sample.right + rbuffer[rbuffer.size - 1].right * amplitude.signal.amplitude) * 0.5f;
            lbuffer.pop();
            rbuffer.pop();

            SoundSample s = SoundSample(lval, rval);
            lbuffer.add_sample(s);
            rbuffer.add_sample(s);

            int max = 32;
            for (int i = 1; i < max; i++)
            {
                int l = lbuffer.size / 2 - (lbuffer.size / 2 / (max - i));
                int r = rbuffer.size / 2 - (rbuffer.size / 2 / (max - i));

                SoundSample ss = SoundSample(lval + lbuffer[l].left, rval + rbuffer[r].right);
                lbuffer[l] = ss;
                rbuffer[r] = ss;

                lval *= up_rate * (float)Math.cos(smear);
                rval *= up_rate * (float)Math.sin(smear);
                smear += 0.1f;
            }

            output.sample = s;
        }
        else if (input != null)
            output.sample = input.sample;
        else
            output.sample = SoundSample(0, 0);
    }

    public float delay
    {
        get { return _delay; }
        set
        {
            _delay = value;
            lbuffer.resize((int)(rate * _delay) * 2);
            rbuffer.resize((int)(rate * _delay * OFFSET) * 2);
        }
    }

    public TransferSample? input { get; set; }
    public TransferSignal? amplitude { get; set; }
    public TransferSample output { get; set; }
}

private class Arpeggiator
{
    private int rate;
    //private float amplitude;

    private float sample;
    private int note;
    private State state = State.NOTE;

    private ArrayList<ArpeggiatorNote> sequence = new ArrayList<ArpeggiatorNote>();

    public Arpeggiator(int rate, float on_time, float off_time)
    {
        this.rate = rate;
        this.on_time = on_time;
        this.off_time = off_time;
        //amplitude = 1;
    }

    public void add_note(ArpeggiatorNote note)
    {
        sequence.add(note);
    }

    /*public void set_active_signal(ControlSignal sig)
    {
        amplitude = sig.amplitude;
    }*/

    public ControlSignal get_signal()
    {
        if (sequence.size != 0)
        {
            if (state == State.NOTE)
            {
                if (sample++ <= rate * on_time)
                    return ControlSignal(sequence[note].frequency);
                else
                {
                    sample = 0;
                    state = State.DELAY;
                }
            }
            else if (sample++ > rate * off_time)
            {
                sample = 0;
                state = State.NOTE;
                note = (note + 1) % sequence.size;
            }
        }

        return ControlSignal(0);
    }

    public float delay { get; set; }
    public float on_time { get; set; }
    public float off_time { get; set; }

    private enum State
    {
        NOTE,
        DELAY
    }
}

private class ArpeggiatorNote
{
    public class ArpeggiatorNote(float frequency)
    {
        this.frequency = frequency;
    }

    public float frequency { get; set; }
}

private class ADSR
{
    private float rate;
    private float time;
    private float frequency;
    private Phase phase = Phase.NONE;

    public ADSR(float rate, float attack, float decay, float sustain_level, float release)
    {
        this.rate = rate;
        this.attack = attack;
        this.decay = decay;
        this.sustain = sustain;
        this.release = release;
    }

    public void set_signal(ControlSignal sig)
    {
        frequency = sig.amplitude;
    }

    public ControlSignal get_signal()
    {
        if (phase == Phase.ATTACK)
        {

        }

        return ControlSignal(0);
    }

    public float attack { get; set; }
    public float decay { get; set; }
    public float sustain { get; set; }
    public float release { get; set; }

    private enum Phase
    {
        ATTACK,
        DECAY,
        SUSTAIN,
        RELEASE,
        NONE
    }
}

public class OutputModule : SynthModule
{
    public OutputModule(TransferSample? input, TransferSignal? volume)
    {
        this.input = input;
        this.volume = volume;
        this.output = new TransferSample();
    }

    public override void process()
    {
        SoundSample out;
        if (input != null)
        {
            out = input.sample;

            if (volume != null)
            {
                out.left = out.left * volume.signal.amplitude;
                out.right = out.right * volume.signal.amplitude;
            }
        }
        else
            out = SoundSample(0, 0);

        output.sample = out;
    }

    public void volume_set(ITransferable volume)
    {
        volume = (TransferSignal)volume;
    }

    public TransferSample? input { get; set; }
    public TransferSignal? volume { get; set; }
    public TransferSample output { get; private set; }
}
