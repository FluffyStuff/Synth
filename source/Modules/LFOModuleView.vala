public class LFOModuleView : ModuleView
{
    private KnobControl frequency_knob;
    private KnobControl width_knob;
    private KnobControl offset_knob;
    private KnobControl mix_knob;
    private ConnectorControl connector;

    public LFOModuleView()
    {
        base("LFO");

        frequency_knob = new KnobControl();
        frequency_knob.input_changed.connect(frequency_changed);

        width_knob = new KnobControl();
        width_knob.input_changed.connect(width_changed);

        offset_knob = new KnobControl();
        offset_knob.input_changed.connect(offset_changed);

        mix_knob = new KnobControl();
        mix_knob.input_changed.connect(mix_changed);

        module = new LowFrequencyOscillator(44100, frequency_knob.signal, width_knob.signal, offset_knob.signal, mix_knob.signal);
        connector = new ConnectorControl(false, ConnectorType.SIGNAL, null, module.output);
    }

    private void frequency_changed()
    {
        module.frequency = frequency_knob.signal;
    }

    private void width_changed()
    {
        module.width = width_knob.signal;
    }

    private void offset_changed()
    {
        module.offset = offset_knob.signal;
    }

    private void mix_changed()
    {
        module.mix = mix_knob.signal;
    }

    protected override void module_added()
    {
        add_knob(frequency_knob, "Frequency");
        add_knob(width_knob, "Width");
        add_knob(offset_knob, "Offset");
        add_knob(mix_knob, "Mix");
        add_connector(connector);

        connector.outer_anchor = Vec2(0.5f, 0);
        connector.inner_anchor = Vec2(0.5f, 0);
        connector.position = Vec2(0, 10);
    }

    public LowFrequencyOscillator module { get; private set; }
    public override SynthModule synth_module { get { return module; } }
}
