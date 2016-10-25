public class KnobControl : Control
{
    private const float LIMIT = 0.75f;

    public signal void input_changed();

    private ImageControl image;
    private float down_rot;
    private float down_theta;
    private float _rotation;

    private TransferSignal internal_signal = new TransferSignal();
    private bool internal = true;

    public KnobControl()
    {
        image = new ImageControl("Knob");
        internal_signal = new TransferSignal();
        signal = internal_signal;
    }

    public void change_input(ITransferable? trans)
    {
        if (trans == null)
        {
            signal = internal_signal;
            internal = true;
        }
        else
        {
            signal = (TransferSignal)trans;
            internal = false;
        }

        input_changed();
    }

    protected override void added()
    {
        float s = 75;
        add_child(image);
        image.size = Size2(s, s);
        resize_style = ResizeStyle.ABSOLUTE;
        size = Size2(s, s);
        selectable = true;

        rotation = 0.5f;
        internal_signal.signal = ControlSignal(rotation);
    }

    protected override void do_process(DeltaArgs delta)
    {
        if (!internal)
        {
            rotation = signal.signal.amplitude;
        }
    }

    protected override void on_mouse_down(Vec2 position)
    {
        down_theta = get_theta(position);
        down_rot = image.rotation;
    }

    private float get_theta(Vec2 pos)
    {
        float x = pos.x - size.width  / 2;
        float y = pos.y - size.height / 2;
        return (float)(Math.atan2(-x, y) / Math.PI) + 1;
    }

    protected override void on_mouse_move(Vec2 position)
    {
        if (mouse_down && internal)
        {
            float theta = get_theta(position);
            float rot = down_rot + (theta - down_theta);
            rot = float.max(rot, -LIMIT);
            rot = float.min(rot, LIMIT);
            image.rotation = rot;

            rotation = 1 - (rot / LIMIT + 1) / 2;
            internal_signal.signal = ControlSignal(rotation);

            //value_changed(this);
        }
    }

    protected override void resized()
    {
        image.size = size;
    }

    public float rotation
    {
        get { return _rotation; }
        set
        {
            _rotation = value;
            image.rotation = -((value * 2) - 1) * LIMIT;
        }
    }

    public TransferSignal signal { get; private set; }
}
