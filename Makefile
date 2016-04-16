MOOR = moor

SPEC_DIR = spec
BIN_DIR = bin
PATCH = patch.sh

BUSTED = busted
CD = cd
CP = cp
LUAROCKS = luarocks
MKDIR = mkdir
MOONC = moonc
RM = rm
SED = sed
WC = wc

LUA_PATH_MAKE = $(shell $(LUAROCKS) path --lr-path | $(SED) -e "s/?.*//")
LUA_BIN_MAKE = $(shell $(LUAROCKS) path --lr-bin | $(SED) -e "s/:.*//")

.PHONY: install compile luarocks-make test test-list watch clean lines

test: spec-patch
	#) '---test--'
	$(BUSTED) --verbose --keep-going

install: compile
	#) '--install--'
	$(MKDIR) -pv $(LUA_PATH_MAKE)$(MOOR)
	$(CP) -rv $(MOOR)/*.lua $(LUA_PATH_MAKE)$(MOOR)
	$(CP) -rv $(BIN_DIR)/$(MOOR)  $(LUA_BIN_MAKE)/

luarocks-make:
	#) '--luarocks-make--'
	$(LUAROCKS) --local make moor-v3.0-1.rockspec

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

