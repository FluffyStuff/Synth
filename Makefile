DIRS  = \
	../Engine/*.vala \
	../Engine/Audio/*.vala \
	../Engine/Files/*.vala \
	../Engine/Helper/*.vala \
	../Engine/Properties/*.vala \
	../Engine/Rendering/*.vala \
	../Engine/Rendering/OpenGLRenderer/*.vala \
	../Engine/Window/*.vala \
	../Engine/Window/Controls/*.vala \
	source/*.vala \
	source/Controls/*.vala \
	source/Generation/*.vala \
	source/Menu/*.vala \
	source/Modules/*.vala

PKGS  = \
	--thread \
	--target-glib 2.32 \
	--pkg gio-2.0 \
	--pkg glew \
	--pkg gee-0.8 \
	--pkg gl \
	--pkg sdl2-image \
	--pkg sdl2 \
	--pkg SOIL \
	--pkg pangoft2 \
	--pkg sfml-audio-2 \
	--pkg sfml-system-2 \
	--pkg portaudio

WLIBS = \
	-X lib/SOIL/libSOIL.a \
	-X lib/SDL/SDL2_image.lib \
	-X lib/SDL/SDL2.lib \
	-X lib/GLEW/libglew32.a \
	-X lib/GL/libopengl32.a \
	-X lib/GEE/libgee.dll.a \
	-X lib/SFML/libcsfml-audio.a \
	-X lib/SFML/libcsfml-system.a \
	-X lib/PORTAUDIO/libportaudio.dll.a

MLIBS = \
	-X lib/SOIL/libSOIL.mac.a \
	-X -lsdl2_image \
	-X -lcsfml-audio \
	-X -framework -X OpenGL \
	-X -framework -X CoreFoundation

LLIBS = \
	-X /usr/lib/libSOIL.so \
	-X lib/SDL/SDL2.lib \
	-X lib/GLEW/glew32s.lib \
	-X lib/GL/libopengl32.a \
	-X -lm

LL64  = \
	-X /usr/lib/x86_64-linux-gnu/libSDL2_image.so \
	-X /usr/lib/x86_64-linux-gnu/libcsfml-audio.so \
	-X /usr/lib/x86_64-linux-gnu/libcsfml-system.so \
	-X /usr/lib/x86_64-linux-gnu/libsfml-audio.so \
	-X /usr/lib/x86_64-linux-gnu/libsfml-system.so

LL32  = \
	-X /usr/local/lib/libSDL2_image.a \
	-X lib/SFML/linux32/libcsfml-audio.so \
	-X lib/SFML/linux32/libcsfml-system.so

VALAC = valac
NAME  = Synth
VAPI  = --vapidir=vapi
#-w = Supress C warnings (Since they stem from the vala code gen)
OTHER = -X -w -X -DGLEW_STATIC -X -Iinclude
O     = -o bin/$(NAME)
DEBUG = --save-temps --enable-checking -g

all: debug

debug:
	$(VALAC) $(DEBUG) $(O) $(DIRS) $(PKGS) $(LLIBS) $(LL64) $(VAPI) $(OTHER)

release:
	$(VALAC) $(O) $(DIRS) $(PKGS) $(LLIBS) $(LL64) $(VAPI) $(OTHER) -X -O4

macDebug:
	$(VALAC) $(DEBUG) $(O) $(DIRS) $(PKGS) $(MLIBS) $(VAPI) $(OTHER) -D MAC

macRelease:
	$(VALAC) $(O) $(DIRS) $(PKGS) $(MLIBS) $(VAPI) $(OTHER) -D MAC
	-mkdir rsc/archive/$(NAME).app
	-cp bin/$(NAME) rsc/archive/$(NAME).app/
	-cp -r bin/Data rsc/archive/$(NAME).app/
	-cp Icon.icns rsc/archive/$(NAME).app/
	-cp rsc/other/Info.plist rsc/archive/$(NAME).app/
	-zip -r rsc/archive/$(NAME).mac.zip rsc/archive/$(NAME).app

clean:
	rm bin/$(NAME)
	rm -r *.c

WindowsDebug:
#	$(eval SHELL = C:/Windows/System32/cmd.exe)
#	$(VALAC) $(DEBUG) $(O) $(VAPI) -X -w \
#	source/main.vala \
#	source/Engine/Audio/MusicGenerator.vala \
#	source/Engine/Helper/Threading.vala \
#	source/Engine/Helper/Networking.vala \
#	--thread \
#	--target-glib 2.32 \
#	--pkg gio-2.0 \
#	--pkg gee-0.8 \
#	--pkg portaudio \
#	-X lib/GEE/libgee.dll.a \
#	-X lib/PORTAUDIO/libportaudio.dll.a

	$(VALAC) $(DEBUG) $(O) $(DIRS) $(PKGS) $(WLIBS) $(VAPI) $(OTHER)

WindowsRelease:
	$(eval SHELL = C:/Windows/System32/cmd.exe)
	$(VALAC) -X -mwindows $(O) $(DIRS) $(PKGS) $(WLIBS) $(VAPI) $(OTHER)
	-RCEDIT /I bin\$(NAME).exe Icon.ico

	-robocopy bin rsc/archive/$(NAME) *.* /MIR
	-robocopy rsc/dlls/main rsc/archive/$(NAME) *.*
	-rm rsc/archive $(NAME).rar
	-C:\Program Files\WinRAR\rar a -r0 rsc\archive\$(NAME).rar rsc\archive\$(NAME) -ep1

cleanWindowsDebug: cleanWindows

cleanWindowsRelease: cleanWindows

cleanWindows:
	rm bin $(NAME).exe
	rm source *.c
	rm source/Engine/Audio *.c
	rm source/Engine/Files *.c
	rm source/Engine/Helper *.c
	rm source/Engine/Properties *.c
	rm source/Engine/Rendering *.c
	rm source/Engine/Rendering/OpenGLRenderer *.c
	rm source/Engine/Window *.c
	rm source/Engine/Window/Controls *.c
	rm source/Game *.c
	rm source/Game/Logic *.c
	rm source/Game/Rendering *.c
	rm source/Game/Rendering/Menu *.c
	rm source/GameServer *.c
	rm source/GameServer/Bots *.c
	rm source/GameServer/GameState *.c
	rm source/GameServer/Server *.c
	rm source/MainMenu *.c
	rm source/MainMenu/Lobby *.c
