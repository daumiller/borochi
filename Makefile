COMPILER = clang
APP_NAME = borochi

RELEASE_CC_FLAGS   = -fcolor-diagnostics -std=c99 -I./header -fobjc-arc
RELEASE_CC_ERRORS  = -Wall
RELEASE_LN_FLAGS   = -framework AppKit -framework WebKit -lobjc
RELEASE_SOURCES    = $(wildcard source/*.m)
RELEASE_OBJECTS    = $(patsubst source/%.m,build/%.o,$(RELEASE_SOURCES))
RELEASE_TARGET     = build/$(APP_NAME)

DEBUG_CC_FLAGS  = $(RELEASE_CC_FLAGS) --debug
DEBUG_CC_ERRORS = $(RELEASE_CC_ERRORS)
DEBUG_LN_FLAGS  = $(RELEASE_LN_FLAGS)
DEBUG_OBJECTS   = $(patsubst source/%.m,build/%-debug.o,$(RELEASE_SOURCES))
DEBUG_TARGET    = build/$(APP_NAME)-debug

all: app

app: release
	rm -rf build/$(APP_NAME).app
	cp -R resource/app-template build/$(APP_NAME).app
	mkdir -p build/$(APP_NAME).app/Contents/MacOS
	cp $(RELEASE_TARGET) build/$(APP_NAME).app/Contents/MacOS/
	touch build/$(APP_NAME).app

run:
	open ./build/borochi.app

release: $(RELEASE_OBJECTS)
	$(COMPILER) $(RELEASE_LN_FLAGS) $(RELEASE_OBJECTS) -o $(RELEASE_TARGET)

debug: $(DEBUG_OBJECTS)
	$(COMPILER) $(DEBUG_LN_FLAGS) $(DEBUG_OBJECTS) -o $(DEBUG_TARGET)

build/%.o: source/%.c
	$(COMPILER) $(RELEASE_CC_FLAGS) $(RELEASE_CC_ERRORS) -c $^ -o $@

build/%.o: source/%.m
	$(COMPILER) $(RELEASE_CC_FLAGS) $(RELEASE_CC_ERRORS) -c $^ -o $@

build/%-debug.o: source/%.c
	$(COMPILER) $(DEBUG_CC_FLAGS) $(DEBUG_CC_ERRORS) -c $^ -o $@

build/%-debug.o: source/%.m
	$(COMPILER) $(DEBUG_CC_FLAGS) $(DEBUG_CC_ERRORS) -c $^ -o $@

clean:
	rm -f $(RELEASE_OBJECTS)
	rm -f $(DEBUG_OBJECTS)

veryclean: clean
	rm -f $(RELEASE_TARGET)
	rm -f $(DEBUG_TARGET)
	rm -rf build/$(APP_NAME).app

rerelease: veryclean release

redebug: veryclean debug

remake: rerelease
