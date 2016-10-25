public class CableControl : Control
{
    private LineControl line;
    private ImageControl moving_plug;
    private ImageControl connector_plug;
    private bool connected = false;

    public CableControl(ConnectorControl connector)
    {
        line = new LineControl();
        moving_plug = new ImageControl("Plug");
        connector_plug = new ImageControl("Plug");

        if (connector.is_input)
            input = connector;
        else
            output = connector;
    }

    public override void added()
    {
        base.added();
        add_child(moving_plug);
        add_child(connector_plug);
        add_child(line);
        line.width = 15;
    }

    public bool do_connect(ConnectorControl connector)
    {
        if (connector.is_input)
        {
            if (output == null || output.connector_type != connector.connector_type)
                return false;

            input = connector;
            connected = true;
        }
        else
        {
            if (input == null || input.connector_type != connector.connector_type)
                return false;

            output = connector;
            connected = true;
        }

        input.do_connect(output);

        return true;
    }

    protected override void do_process(DeltaArgs delta)
    {
        if (!connected)
            return;

        Vec2 start = Vec2( input.rect.x +  input.rect.width / 2,  input.rect.y +  input.rect.height / 2);
        Vec2 end   = Vec2(output.rect.x + output.rect.width / 2, output.rect.y + output.rect.height / 2);
        start = to_parent_local(start);
        end   = to_parent_local(end);

        position = start;
        distance = end.minus(start);
        outer_anchor = Vec2(0, 0);
    }

    public Vec2 distance
    {
        get { return line.distance; }
        set
        {
            line.distance = value;
            moving_plug.position = value;
        }
    }

    public ConnectorControl?  input { get; private set; }
    public ConnectorControl? output { get; private set; }
}

public enum ConnectorType
{
    SIGNAL,
    SAMPLE
}
