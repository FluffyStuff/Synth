public class ReverbModuleView : ModuleView
{
    private KnobControl amplitude_knob;

    private ConnectorControl connector_in;
    private ConnectorControl connector_out;

    public ReverbModuleView()
    {
        base("Reverb");

        amplitude_knob = new KnobControl();
        amplitude_knob.input_changed.connect(amplitude_changed);

        module = new ReverbFilter(44100, null, amplitude_knob.signal);

        connector_in  = new ConnectorControl(true,  ConnectorType.SAMPLE, input_changed, null);
        connector_out = new ConnectorControl(false, ConnectorType.SAMPLE, null, module.output);
    }

    private void amplitude_changed()
    {
        module.amplitude = amplitude_knob.signal;
    }

    private void input_changed(ITransferable? transferable)
    {
        module.input = (TransferSample?)transferable;
    }

    protected override void module_added()
    {
        add_knob(amplitude_knob, "Amplitude");
        add_connector(connector_in);
        add_connector(connector_out);

        connector_in.outer_anchor = Vec2(0.5f, 0);
        connector_in.inner_anchor = Vec2(0.5f, 0);
        connector_in.position = Vec2(-connector_in.size.width, 10);

        connector_out.outer_anchor = Vec2(0.5f, 0);
        connector_out.inner_anchor = Vec2(0.5f, 0);
        connector_out.position = Vec2(connector_out.size.width, 10);
    }

    public ReverbFilter module { get; private set; }
    public override SynthModule synth_module { get { return module; } }
}
