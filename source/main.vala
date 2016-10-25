public static int main(string[] args)
{
    Environment.init();

    Engine engine = new Engine();
    if (!engine.init())
        return -1;

    while (true)
    {
        engine.set_multisampling(2);

        bool fullscreen = false;
        var wnd = engine.create_window("Synth", 1280, 720, fullscreen);
        if (wnd == null)
        {
            print("main: Could not create window!\n");
            return -1;
        }

        var context = engine.create_context(wnd);
        if (context == null)
        {
            print("main: Could not create graphics context!\n");
            return -1;
        }

        SDLWindowTarget sdlWindow = new SDLWindowTarget((owned)wnd, (owned)context, fullscreen);
        OpenGLRenderer renderer = new OpenGLRenderer(sdlWindow);
        MainWindow window = new MainWindow(sdlWindow, renderer);

        if (!renderer.start())
            return -1;

        window.show();
        break;
    }

    return 0;
}

/*static void music()
{
    MusicGenerator generator = new MusicGenerator();
    generator.start();
}*/
