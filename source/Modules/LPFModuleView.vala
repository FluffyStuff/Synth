public class LPFModuleView : ModuleView
{
    private KnobControl cutoff_knob;
    private KnobControl resonance_knob;
    private ConnectorControl connector_in;
    private ConnectorControl connector_out;

    public LPFModuleView()
    {
        base("LPF");

        cutoff_knob = new KnobControl();
        cutoff_knob.input_changed.connect(cutoff_changed);

        resonance_knob = new KnobControl();
        resonance_knob.input_changed.connect(resonance_changed);

        module = new LowPassFilter(null, cutoff_knob.signal, resonance_knob.signal);

        connector_in  = new ConnectorControl(true,  ConnectorType.SAMPLE, input_changed, null);
        connector_out = new ConnectorControl(false, ConnectorType.SAMPLE, null, module.output);
    }

    private void input_changed(ITransferable? transferable)
    {
        module.input = (TransferSample?)transferable;
    }

    private void cutoff_changed()
    {
        module.cutoff = cutoff_knob.signal;
    }

    private void resonance_changed()
    {
        module.resonance = resonance_knob.signal;
    }

    protected override void module_added()
    {
        add_knob(cutoff_knob, "Cutoff");
        add_knob(resonance_knob, "Resonance");
        add_connector(connector_in);
        add_connector(connector_out);

        connector_in.outer_anchor = Vec2(0.5f, 0);
        connector_in.inner_anchor = Vec2(0.5f, 0);
        connector_in.position = Vec2(-connector_in.size.width, 10);

        connector_out.outer_anchor = Vec2(0.5f, 0);
        connector_out.inner_anchor = Vec2(0.5f, 0);
        connector_out.position = Vec2(connector_out.size.width, 10);
    }

    public LowPassFilter module { get; private set; }
    public override SynthModule synth_module { get { return module; } }
}
