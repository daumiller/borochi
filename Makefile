COMPILER = clang

RELEASE_CC_FLAGS   = -fcolor-diagnostics -std=c99
RELEASE_CC_ERRORS  = -Wall
RELEASE_LN_FLAGS   = -framework AppKit -framework WebKit -lobjc
RELEASE_OBJECTS    = main.o
RELEASE_TARGET     = shiny

DEBUG_CC_FLAGS  = $(RELEASE_CC_FLAGS) --debug
DEBUG_CC_ERRORS = $(RELEASE_CC_ERRORS)
DEBUG_LN_FLAGS  = -framework AppKit -framework WebKit -lobjc
DEBUG_OBJECTS   = main-debug.o
DEBUG_TARGET    = shiny-debug

all: release

release: $(RELEASE_OBJECTS)
	$(COMPILER) $(RELEASE_LN_FLAGS) $(RELEASE_OBJECTS) -o $(RELEASE_TARGET)
	cp $(RELEASE_TARGET) ./Shiny.app/Contents/MacOS

debug: $(DEBUG_OBJECTS)
	$(COMPILER) $(DEBUG_LN_FLAGS) $(DEBUG_OBJECTS) -o $(DEBUG_TARGET)

%.o: %.c
	$(COMPILER) $(RELEASE_CC_FLAGS) $(RELEASE_CC_ERRORS) -c $^ -o $@

%.o: %.m
	$(COMPILER) $(RELEASE_CC_FLAGS) $(RELEASE_CC_ERRORS) -c $^ -o $@

%-debug.o: %.c
	$(COMPILER) $(DEBUG_CC_FLAGS) $(DEBUG_CC_ERRORS) -c $^ -o $@

%-debug.o: %.m
	$(COMPILER) $(DEBUG_CC_FLAGS) $(DEBUG_CC_ERRORS) -c $^ -o $@

clean:
	rm -f $(RELEASE_OBJECTS)
	rm -f $(DEBUG_OBJECTS)

veryclean: clean
	rm -f $(RELEASE_TARGET)
	rm -f $(DEBUG_TARGET)

rerelease: veryclean release

redebug: veryclean debug
