using SDL;
using GL;

public class MainWindow : RenderWindow
{
    private SynthView synth;

    public MainWindow(IWindowTarget window, RenderTarget renderer)
    {
        base(window, renderer);
        back_color = Color(0, 0.01f, 0.02f, 1);
        synth = new SynthView();
    }

    protected override void shown()
    {
        set_icon("./Data/Icon.png");

        main_view.add_child(synth);
    }

    protected override bool key_press(KeyArgs key)
    {
        if (key.scancode == ScanCode.F12)
        {
            if (key.down)
                fullscreen = !fullscreen;
            return true;
        }
        else if (key.scancode == ScanCode.ESCAPE)
        {
            finish();
            return true;
        }

        return false;
    }
}
