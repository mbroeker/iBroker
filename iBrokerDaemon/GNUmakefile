include $(GNUSTEP_MAKEFILES)/common.make

TOOL_NAME = iBrokerDaemon
ADDITIONAL_INCLUDE_DIRS += -IBrokerage -ICommon
ADDITIONAL_OBJCFLAGS += -fexceptions -fobjc-nonfragile-abi -fblocks
ADDITIONAL_LDFLAGS += -lCommonCrypto -lgnustep-gui

iBrokerDaemon_Tool_HEADERS = \
	Helper.h \
	Brokerage.h \
	Brokerage+Bittrex.h \
	Brokerage+Crypto.h \
	Brokerage+External.h \
	Brokerage+JSON.h \
	Brokerage+Poloniex.h \
	Calculator.h \
	KeychainWrapper.h

iBrokerDaemon_OBJC_FILES = \
	main.m \
	Common/Calculator.m \
	Common/Helper.m \
	Common/KeychainWrapper.m \
	Brokerage/Brokerage.m \
	Brokerage/Categories/Brokerage+Bittrex.m \
	Brokerage/Categories/Brokerage+External.m \
	Brokerage/Categories/Brokerage+Crypto.m \
	Brokerage/Categories/Brokerage+JSON.m \
	Brokerage/Categories/Brokerage+Poloniex.m

iBrokerDaemon_RESOURCES_FILES =

include $(GNUSTEP_MAKEFILES)/tool.make
