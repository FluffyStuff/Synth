using Gee;

public class SynthMenuView : View2D
{
    private ArrayList<MenuTextButton> buttons = new ArrayList<MenuTextButton>();
    private MenuTextButton lfo;
    private MenuTextButton lpf;
    private MenuTextButton reverb;
    private MenuTextButton generator;

    public signal void lfo_pressed();
    public signal void lpf_pressed();
    public signal void reverb_pressed();
    public signal void generator_pressed();

    public override void added()
    {
        lfo = new MenuTextButton("MenuButtonSmall", "LFO");
        lpf = new MenuTextButton("MenuButtonSmall", "LPF");
        reverb = new MenuTextButton("MenuButtonSmall", "Reverb");
        generator = new MenuTextButton("MenuButtonSmall", "Generator");

        lfo.clicked.connect(press_lfo);
        lpf.clicked.connect(press_lpf);
        reverb.clicked.connect(press_reverb);
        generator.clicked.connect(press_generator);

        buttons.add(lfo);
        buttons.add(lpf);
        buttons.add(reverb);
        buttons.add(generator);

        foreach (var button in buttons)
        {
            add_child(button);
            button.inner_anchor = Vec2(0.5f, 1);
            button.outer_anchor = Vec2(0.5f, 1);
            button.font_size = 24;
        }

        position_buttons();
    }

    private void position_buttons()
    {
        float p = 0;
        float width = 0;

        foreach (var button in buttons)
            width += button.size.width / 2;

        foreach (var button in buttons)
        {
            button.position = Vec2(button.size.width / 2 - width + p, 0);
            p += button.size.width;
        }
    }

    private void press_lfo() { lfo_pressed(); }
    private void press_lpf() { lpf_pressed(); }
    private void press_reverb() { reverb_pressed(); }
    private void press_generator() { generator_pressed(); }
}
