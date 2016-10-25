public class OutputModuleView : ModuleView
{
    private KnobControl volume_knob;
    private ConnectorControl connector;

    public OutputModuleView()
    {
        base("Output");

        volume_knob = new KnobControl();
        volume_knob.input_changed.connect(volume_changed);

        module = new OutputModule(null, volume_knob.signal);
        connector = new ConnectorControl(true, ConnectorType.SAMPLE, input_changed, null);
    }

    private void input_changed(ITransferable? transferable)
    {
        module.input = (TransferSample?)transferable;
    }

    private void volume_changed()
    {
        module.volume = volume_knob.signal;
    }

    protected override void module_added()
    {
        add_knob(volume_knob, "Volume");
        add_connector(connector);

        connector.outer_anchor = Vec2(0.5f, 0);
        connector.inner_anchor = Vec2(0.5f, 0);
        connector.position = Vec2(0, 10);
    }

    public OutputModule module { get; private set; }
    public override SynthModule synth_module { get { return module; } }
}
