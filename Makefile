MOOR = moor

SPEC_DIR = spec
BIN_DIR = bin
PATCH = patch.sh

ROCKSPEC = moor-v3.0-1.rockspec

BUSTED = busted
CD = cd
CP = cp
ECHO = echo
LUAROCKS = luarocks
MAKE = make
MKDIR = mkdir
MOONC = moonc
RM = rm
SED = sed
WC = wc

LUA_PATH_MAKE ?= $(shell $(LUAROCKS) path --lr-path | $(SED) -e "s/?.*//")
LUA_BIN_MAKE  ?= $(shell $(LUAROCKS) path --lr-bin | $(SED) -e "s/:.*//")

.PHONY: install compile luarocks-make test test-list watch clean lines

test: spec-patch
	#) '---test--'
	@$(BUSTED) --verbose --keep-going

install: compile
	#) '--install--'
	$(MKDIR) -pv $(LUA_PATH_MAKE)$(MOOR)
	$(CP) -v $(MOOR)/*.lua $(LUA_PATH_MAKE)$(MOOR)
	$(CP) -v $(BIN_DIR)/$(MOOR)  $(LUA_BIN_MAKE)

luarocks-make:
	#) '--luarocks-make--'
	$(LUAROCKS) --local make

compile:
	#) '--compile--'
	$(MOONC) $(MOOR)/

spec-patch:
	#) '--spec-patch--'
	$(CD) $(SPEC_DIR); ./$(PATCH)

test-list:
	#) '---test-list--'
	@$(BUSTED) --list

watch:
	#) '--watch--'
	$(MOONC) $(MOOR)/
	$(MOONC) -w $(MOOR)/

clean:
	#) '--clean--'
	-$(RM) $(MOOR)/*.lua $(BIN_DIR)/*.lua

lines:
	#) '--lines--'
	$(WC) -l */*.moon $(BIN_DIR)/$(MOOR)

travis-ci:
	#) '--travis-ci--'
	$(LUAROCKS) build $(ROCKSPEC) --only-deps
	LUA_PATH_MAKE=install/luarocks LUA_BIN_MAKE=install/luarocks/bin $(LUAROCKS) make
	install/luarocks/bin/$(MOOR) -Linspect -e 'print (require"inspect") {"hello", "world"}'
