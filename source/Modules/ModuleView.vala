using Gee;

public abstract class ModuleView : Control
{
    private ArrayList<ConnectorControl> connectors = new ArrayList<ConnectorControl>();
    private ArrayList<KnobControl> knobs = new ArrayList<KnobControl>();
    private Background background;
    private LabelControl name_label;
    private string name;

    public signal void start_cable(ModuleView module, ConnectorControl connector, Vec2 start_position);
    public signal void move_cable(ModuleView module, Vec2 position);
    public signal void drop_cable(ModuleView module);

    public ModuleView(string name)
    {
        background = new Background();
        name_label = new LabelControl();
        this.name = name;
    }

    protected override void added()
    {
        add_child(background);
        add_child(name_label);

        background.selectable = true;
        background.cursor_type = CursorType.NORMAL;
        background.moved.connect(background_mouse_moved);

        name_label.text = name;
        name_label.outer_anchor = Vec2(0.5f, 1);
        name_label.inner_anchor = Vec2(0.5f, 1);

        module_added();

        resize_style = ResizeStyle.ABSOLUTE;
        size = Size2(200, 600);
        selectable = true;
    }

    private void background_mouse_moved(Vec2 position)
    {
        this.position = Vec2(this.position.x + position.x, this.position.y + position.y);
    }

    protected override void resized()
    {
        background.size = size;
    }

    protected void add_knob(KnobControl knob, string name)
    {
        LabelControl label = new LabelControl();
        add_child(label);
        label.text = name;

        ConnectorControl connector = new ConnectorControl(true, ConnectorType.SIGNAL, knob.change_input, null);
        add_child(knob);
        knobs.add(knob);

        knob.position = Vec2(0, -knobs.size * (knob.size.height + label.size.height));
        knob.outer_anchor = Vec2(0.5f, 1);
        label.position = Vec2(knob.position.x, knob.position.y + knob.size.height / 2 + label.size.height / 2);
        label.outer_anchor = knob.outer_anchor;

        add_connector(connector);
        connector.position = Vec2(knob.position.x - knob.size.width / 2 - connector.size.width / 2, knob.position.y);
        connector.outer_anchor = knob.outer_anchor;
    }

    protected void add_connector(ConnectorControl connector)
    {
        connectors.add(connector);
        connector.start_cable.connect(connector_start_cable);
        connector.move_cable.connect(connector_move_cable);
        connector.drop_cable.connect(connector_drop_cable);

        add_child(connector);
    }

    protected void connector_start_cable(ConnectorControl connector)
    {
        Vec2 pos = connector.normal_position;
        pos = Vec2(pos.x + connector.size.width / 2, pos.y + connector.size.height / 2);
        start_cable(this, connector, pos);
    }

    protected void connector_move_cable(ConnectorControl connector, Vec2 position)
    {
        move_cable(this, position);
    }

    protected void connector_drop_cable(ConnectorControl connector)
    {
        drop_cable(this);
    }

    public bool cable_test(CableControl cable, Vec2i position)
    {
        foreach (ConnectorControl connector in connectors)
        {
            if (connector.hover_check(position))
                if (cable.do_connect(connector))
                    return true;
        }

        return false;
    }

    protected abstract void module_added();
    public abstract SynthModule synth_module { get; }

    private class Background : ImageControl
    {
        public signal void moved(Vec2 pos);

        private Vec2 start;

        public Background()
        {
            base("SingleModule");
        }

        public override void on_mouse_down(Vec2 pos)
        {
            start = pos;
        }

        public override void on_mouse_move(Vec2 pos)
        {
            if (mouse_down)
                moved(Vec2(pos.x - start.x, pos.y - start.y));
        }
    }
}
