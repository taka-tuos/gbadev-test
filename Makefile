ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

include $(DEVKITARM)/gba_rules


TARGET		:=	test
SOURCES		:=	src
RESOURCES	:=	res
BUILD		:=	bld
INCLUDE		:=	inc
DEPSDIR		:=	$(CURDIR)

LD			:=	$(CC)

ARCH		:=	-mthumb -mthumb-interwork

CFLAGS		:=	-g -Wall -O2\
			-mcpu=arm7tdmi -mtune=arm7tdmi\
			$(ARCH)

CFLAGS		+=	-I$(LIBGBA)/include -I$(INCLUDE)
ASFLAGS		:=	-g $(ARCH)
LDFLAGS		=	-g $(ARCH) -Wl,-Map,$(notdir $*.map)

LIBS		:= -lmm -lgba

LIBPATHS	:=	-L$(LIBGBA)/lib

CFILES		:=	$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.c)))
SFILES		:=	$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.s)))

PNGFILES	:=	$(foreach dir,$(RESOURCES),$(notdir $(wildcard $(dir)/*.png)))
TXTFILES	:=	$(foreach dir,$(RESOURCES),$(notdir $(wildcard $(dir)/*.txt)))

SFILES_PNG	:=	$(patsubst %.png,$(BUILD)/%.s,$(PNGFILES))
SFILES_TXT	:=	$(patsubst %.txt,$(BUILD)/%.s,$(TXTFILES))

OFILES_SRC	:=	$(patsubst %.c,$(SOURCES)/%.o,$(CFILES)) $(patsubst %.s,$(SOURCES)/%.o,$(SFILES))
OFILES_PNG	:=	$(patsubst %.s,%.o,$(SFILES_PNG))
OFILES_TXT	:=	$(patsubst %.s,%.o,$(SFILES_TXT))
OFILES		:=	$(OFILES_SRC) $(OFILES_PNG) $(OFILES_TXT)

$(BUILD)/%.s	:	$(RESOURCES)/%.png Makefile
	@grit $< -ff$(RESOURCES)/$*.grit -o$(BUILD)/$*
	@mv $(BUILD)/$*.h $(INCLUDE)/res/

$(BUILD)/%.s	:	$(RESOURCES)/%.txt Makefile
	@bin2s $< > $(BUILD)/$*.s
	@echo "extern unsigned char *$*_txt;" > $(INCLUDE)/res/$*.h


$(TARGET).elf	:	$(SFILES_PNG) $(SFILES_TXT) $(OFILES_SRC) $(OFILES_PNG) $(OFILES_TXT) Makefile
$(TARGET).gba	:	$(TARGET).elf Makefile

.PHONY : all clean

all:
	@make -r $(TARGET).gba

clean:
	-rm $(BUILD)/*.o
	-rm $(BUILD)/*.d
	-rm $(SOURCES)/*.o
	-rm $(SOURCES)/*.d
	-rm $(INCLUDE)/res/*.h
	-rm $(TARGET).map
	-rm $(TARGET).elf
	-rm $(TARGET).gba

-include $(DEPSDIR)/*.d
