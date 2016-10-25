public class SynthView : View2D
{
    private SynthModuleView module = new SynthModuleView();
    private SynthMenuView menu = new SynthMenuView();

    public override void added()
    {
        add_child(module);
        add_child(menu);

        menu.lfo_pressed.connect(create_lfo);
        menu.lpf_pressed.connect(create_lpf);
        menu.reverb_pressed.connect(create_reverb);
        menu.generator_pressed.connect(create_generator);
    }

    private void create_lfo() { module.create_lfo(); }
    private void create_lpf() { module.create_lpf(); }
    private void create_reverb() { module.create_reverb(); }
    private void create_generator() { module.create_generator(); }
}
