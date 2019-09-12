ARCHS = arm64
TARGET = appletv
export GO_EASY_ON_ME=1
export SDKVERSION=10.2

include theos/makefiles/common.mk

TWEAK_NAME = ATVHue

ATVHue_FILES = Tweak.xm ATVTopWindow.xm
ATVHue_LIBRARIES = substrate
ATVHue_FRAMEWORKS = Foundation UIKit
ATVHue_CFLAGS = -fobjc-arc

export ARCHS = arm64
ATVHue_ARCHS = arm64

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 PineBoard"