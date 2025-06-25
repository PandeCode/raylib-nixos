# === Paths ===
RAYLIB  ?= ./external/raylib-5.5/src
SRC     := $(wildcard src/*.c)
OUTDIR  := bin
TARGET  := $(OUTDIR)/game

# === Tools ===
CC      := clang
LD      := clang
LD_FLAGS:= -fuse-ld=mold
BEAR    := bear --append --output compile_commands.json --

# === Flags ===
INCLUDE := -I$(RAYLIB)
LIBS    := -L$(RAYLIB) -lraylib -lGL -lm -lpthread -ldl -lrt -lX11
WARNINGS:= -Wall -Wextra -Wpedantic -Werror -Wshadow -Wconversion -Wno-sign-conversion

# === Build Modes ===
DEBUG_FLAGS   := -O0 -g -DDEBUG $(WARNINGS)
RELEASE_FLAGS := -O3 -DNDEBUG $(WARNINGS)

MODE ?= debug

ifeq ($(MODE),release)
    CFLAGS := $(RELEASE_FLAGS) $(INCLUDE)
    BEAR_CMD :=
else
    CFLAGS := $(DEBUG_FLAGS) $(INCLUDE)
    BEAR_CMD := $(BEAR)
endif

# === Targets ===
all: $(TARGET)

$(TARGET): $(SRC)
	@echo "==> Building Raylib..."
	$(MAKE) -C $(RAYLIB) PLATFORM=PLATFORM_DESKTOP

	@echo "==> Compiling ($(MODE) mode) with Clang and linking with Mold..."
	mkdir -p $(OUTDIR)
	$(BEAR_CMD) $(CC) $(SRC) -o $(TARGET) $(CFLAGS) $(LIBS) $(LD_FLAGS)

run: $(TARGET)
	@echo "==> Running $(TARGET)..."
	./$(TARGET)

clean:
	@echo "==> Cleaning..."
	rm -rf $(OUTDIR) compile_commands.json
	$(MAKE) -C $(RAYLIB) clean
