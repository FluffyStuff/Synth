using Gee;

public class SynthModuleView : View2D
{
    private ModuleTree? tree = null;
    private CableControl cable;

    private ArrayList<ModuleView> modules = new ArrayList<ModuleView>();
    private ArrayList<CableControl> cables = new ArrayList<CableControl>();

    private OutputModuleView output;

    private bool moving = false;
    private Vec2i moving_start_mouse;
    private Vec2i moving_start_pos;

    ~SynthModuleView()
    {
        if (tree != null)
            tree.stop();
    }

    public override void added()
    {
        tree = new ModuleTree();

        output = new OutputModuleView();
        add_module(output);
        tree.set_output_module(output.module);
        tree.start();

        /*add_module(new LFOModuleView());
        add_module(new LFOModuleView());
        add_module(new LFOModuleView());
        add_module(new LPFModuleView());
        add_module(new ReverbModuleView());
        add_module(new GeneratorModuleView());*/
    }

    public void create_lfo() { add_module(new LFOModuleView()); }
    public void create_lpf() { add_module(new LPFModuleView()); }
    public void create_reverb() { add_module(new ReverbModuleView()); }
    public void create_generator() { add_module(new GeneratorModuleView()); }

    private void add_module(ModuleView module)
    {
        add_child(module);
        modules.add(module);
        tree.add_module(module.synth_module);

        module.start_cable.connect(start_cable);
        module.move_cable.connect(move_cable);
        module.drop_cable.connect(drop_cable);
    }

    private void start_cable(ModuleView module, ConnectorControl connector, Vec2 start_position)
    {
        if (connector.is_input)
            foreach (CableControl cable in cables)
            {
                if (cable.input == connector)
                {
                    connector.do_disconnect();
                    cables.remove(cable);
                    remove_child(cable);
                    break;
                }
            }

        cable = new CableControl(connector);
        add_child(cable);

        cable.position = module.normal_position.plus(start_position).minus(Vec2(size.width / 2, size.height / 2));
    }

    private void move_cable(ModuleView module, Vec2 position)
    {
        cable.distance = position;
    }

    private void drop_cable(ModuleView module)
    {
        foreach (ModuleView mod in modules)
            if (module != mod && mod.cable_test(cable, parent_window.cursor_position))
            {
                foreach (CableControl c in cables)
                {
                    if (c.input == cable.input)
                    {
                        cables.remove(c);
                        remove_child(c);
                        break;
                    }
                }

                cables.add(cable);
                return;
            }

        remove_child(cable);
    }

    protected override void do_mouse_event(MouseEventArgs mouse)
    {
        if (!mouse.down)
            moving = false;

        if (mouse.handled)
            return;

        mouse.handled = true;

        if (mouse.down)
        {
            moving = true;
            moving_start_pos = Vec2i((int)position.x, (int)position.y);
            moving_start_mouse = mouse.position;
        }
    }

    protected override void do_mouse_move(MouseMoveArgs mouse)
    {
        if (!moving)
            return;

        mouse.cursor_type = CursorType.HOVER;
        position = Vec2(mouse.position.x - moving_start_mouse.x + moving_start_pos.x, mouse.position.y - moving_start_mouse.y + moving_start_pos.y);
    }
}
