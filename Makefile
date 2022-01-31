COMPILER = clang
APP_NAME = borochi

RELEASE_CC_FLAGS   = -fcolor-diagnostics -std=c99 -I./header -fobjc-arc
RELEASE_CC_ERRORS  = -Wall
RELEASE_LN_FLAGS   = -framework AppKit -framework WebKit -lobjc
RELEASE_OBJECTS    = build/main.o               \
                     build/BBApplication.o      \
                     build/BBBrowser.o          \
                     build/BBAddressBar.o       \
                     build/BBWebView.o          \
                     build/BBAutocompleteMock.o \
                     build/BBAddressBar_TableRowView.o
RELEASE_TARGET     = build/$(APP_NAME)

DEBUG_CC_FLAGS  = $(RELEASE_CC_FLAGS) --debug
DEBUG_CC_ERRORS = $(RELEASE_CC_ERRORS)
DEBUG_LN_FLAGS  = $(RELEASE_LN_FLAGS)
DEBUG_OBJECTS   = build/main-debug.o               \
                  build/BBApplication-debug.o      \
                  build/BBBrowser-debug.o          \
                  build/BBAddressBar-debug.o       \
                  build/BBWebView-debug.o          \
                  build/BBAutocompleteMock-debug.o \
                  build/BBAddressBar_TableRowView-debug.o
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
