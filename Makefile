APP_NAME   = MailGen
BUNDLE_ID  = com.mailgen.app
VERSION    = 1.0.0
BUILD_DIR  = .build/release
APP_DIR    = $(APP_NAME).app
BINARY     = $(BUILD_DIR)/$(APP_NAME)
PLIST      = $(APP_DIR)/Contents/Info.plist

.PHONY: all build app run install clean kill

all: app

build:
	swift build -c release

app: build
	mkdir -p $(APP_DIR)/Contents/MacOS
	mkdir -p $(APP_DIR)/Contents/Resources
	cp $(BINARY) $(APP_DIR)/Contents/MacOS/$(APP_NAME)
	/usr/bin/plutil -create xml1 $(PLIST)
	/usr/bin/plutil -insert CFBundleName              -string "$(APP_NAME)"  $(PLIST)
	/usr/bin/plutil -insert CFBundleIdentifier        -string "$(BUNDLE_ID)" $(PLIST)
	/usr/bin/plutil -insert CFBundleVersion           -string "$(VERSION)"   $(PLIST)
	/usr/bin/plutil -insert CFBundleShortVersionString -string "$(VERSION)"  $(PLIST)
	/usr/bin/plutil -insert CFBundleExecutable        -string "$(APP_NAME)"  $(PLIST)
	/usr/bin/plutil -insert CFBundlePackageType       -string "APPL"         $(PLIST)
	/usr/bin/plutil -insert NSPrincipalClass          -string "NSApplication" $(PLIST)
	/usr/bin/plutil -insert LSUIElement               -bool true             $(PLIST)
	/usr/bin/plutil -insert NSHighResolutionCapable   -bool true             $(PLIST)
	/usr/bin/plutil -insert LSMinimumSystemVersion    -string "13.0"         $(PLIST)
	codesign --force --deep --sign - $(APP_DIR)
	@echo "✓ Built $(APP_DIR)"

run: kill app
	open $(APP_DIR)

install: app
	cp -r $(APP_DIR) /Applications/$(APP_DIR)
	@echo "✓ Installed to /Applications/$(APP_DIR)"

kill:
	@pkill -x $(APP_NAME) 2>/dev/null || true

clean:
	rm -rf $(APP_DIR) .build
	@echo "✓ Cleaned"
