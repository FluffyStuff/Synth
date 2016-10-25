public class GeneratorModuleView : ModuleView
{
    private KnobControl frequency_knob;
    private KnobControl mix_knob;
    private ConnectorControl connector;

    public GeneratorModuleView()
    {
        base("Generator");

        frequency_knob = new KnobControl();
        frequency_knob.input_changed.connect(frequency_changed);

        mix_knob = new KnobControl();
        mix_knob.input_changed.connect(mix_changed);

        module = new FrequencyGenerator(44100, frequency_knob.signal, null, mix_knob.signal);
        connector = new ConnectorControl(false, ConnectorType.SAMPLE, null, module.output);
    }

    private void frequency_changed()
    {
        module.frequency = frequency_knob.signal;
    }

    private void mix_changed()
    {
        module.mix = mix_knob.signal;
    }

    protected override void module_added()
    {
        add_knob(frequency_knob, "Frequency");
        add_knob(mix_knob, "Mix");
        add_connector(connector);

        connector.outer_anchor = Vec2(0.5f, 0);
        connector.inner_anchor = Vec2(0.5f, 0);
        connector.position = Vec2(0, 10);
    }

    public FrequencyGenerator module { get; private set; }
    public override SynthModule synth_module { get { return module; } }
}
