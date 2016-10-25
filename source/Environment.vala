public class Environment
{
    private Environment() {}

    public static void init()
    {
        set_working_dir();
    }

    private static void set_working_dir()
    {
	// This makes relative paths work by changing directory to the Resources folder inside the .app bundle
	#if MAC
        void *mainBundle = CFBundleGetMainBundle();
        void *resourcesURL = CFBundleCopyResourcesDirectoryURL(mainBundle);
        char path[PATH_MAX];
        if (!CFURLGetFileSystemRepresentation(resourcesURL, true, (uint8*)path, PATH_MAX))
        {
            // error!
        }
        CFRelease(resourcesURL);

        GLib.Environment.set_current_dir((string)path);
	#endif
    }
}

#if MAC
static extern const int PATH_MAX;
static extern void* CFBundleGetMainBundle();
static extern void* CFBundleCopyResourcesDirectoryURL(void *bundle);
static extern bool CFURLGetFileSystemRepresentation(void *url, bool b, uint8 *path, int max_path);
static extern void CFRelease(void *url);
#endif
