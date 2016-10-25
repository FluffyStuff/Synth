public class ConnectorControl : Control
{
    private bool moving = false;
    private ImageControl image;
    private transferable_set? del;
    private ITransferable? transferable;

    public signal void start_cable(ConnectorControl connector);
    public signal void move_cable(ConnectorControl connector, Vec2 position);
    public signal void drop_cable(ConnectorControl connector);

    public delegate void transferable_set(ITransferable trans);

    public ConnectorControl(bool is_input, ConnectorType connector_type, transferable_set? del, ITransferable? transferable)
    {
        image = new ImageControl("Connector");
        this.is_input = is_input;
        this.connector_type = connector_type;
        this.transferable = transferable;
        this.del = del;
    }

    public override void added()
    {
        add_child(image);
        resize_style = ResizeStyle.ABSOLUTE;
        size = Size2(50, 50);
        selectable = true;
    }

    public void do_connect(ConnectorControl output)
    {
        del(output.transferable);
    }

    public void do_disconnect()
    {
        del(null);
    }

    protected override void on_mouse_down(Vec2 position)
    {
        if (!moving)
            start_cable(this);

        moving = true;
    }

    protected override void on_mouse_move(Vec2 position)
    {
        if (moving)
        {
            Vec2 pos = Vec2(position.x - size.width / 2, position.y - size.height / 2);
            move_cable(this, pos);
        }
    }

    protected override void on_mouse_up(Vec2 position)
    {
        if (moving)
            drop_cable(this);

        moving = false;
    }

    protected override void resized()
    {
        image.size = size;
    }

    public bool is_input { get; private set; }

    public ConnectorType connector_type { get; private set; }
}
