#
# Copyright 2023, UNSW
#
# SPDX-License-Identifier: BSD-2-Clause
#

ifeq ($(strip $(MICROKIT_SDK)),)
$(error MICROKIT_SDK must be specified)
endif

ifeq ($(strip $(LIBGCC)),)
LIBGCC := $(shell dirname $$(aarch64-none-elf-gcc --print-file-name libgcc.a))
endif

MICROKIT_CONFIG ?= debug
MICROKIT_BOARD := odroidc4
CPU := cortex-a55

TOOLCHAIN := clang
CC := clang
LD := ld.lld
TARGET := aarch64-none-elf
MICROKIT_TOOL ?= $(MICROKIT_SDK)/bin/microkit
DTC := dtc

BOARD_DIR := $(MICROKIT_SDK)/board/$(MICROKIT_BOARD)/$(MICROKIT_CONFIG)
LIBVMM_DIR := ${LionsOS}/vmm

VMM_IMAGE_DIR := ${EXAMPLE_DIR}/vmm
LINUX := $(VMM_IMAGE_DIR)/Linux
INITRD := $(VMM_IMAGE_DIR)/initrd.gz

IMAGES := vmm.elf 
CFLAGS := \
	-mtune=$(CPU) \
	-mstrict-align \
	-ffreestanding \
	-g \
	-O0 \
	-Wall \
	-Wno-unused-function \
	-I$(BOARD_DIR)/include \
	-target $(TARGET) \
	-I$(LIBVMM_DIR)/src/arch/aarch64 \
	-I$(LIBVMM_DIR)/src \
	-I$(LIBVMM_DIR)/src/util \
	-DBOARD_$(MICROKIT_BOARD) \
	-I$(SDDF)/include \
	-DMAC_BASE_ADDRESS=$(MAC_BASE_ADDRESS)

vpath=${LIBVMM_DIR}:vmm

LDFLAGS := -L$(BOARD_DIR)/lib
LIBS := -lmicrokit -Tmicrokit.ld

IMAGE_FILE := $(BUILD_DIR)/vmdev.img
REPORT_FILE := $(BUILD_DIR)/report.txt

VMM_OBJS := vmm.o  package_guest_images.o

all: $(IMAGE_FILE)

%.dtb: %.dts
	$(DTC) -q -I dts -O dtb $< > $@

${notdir $(ORIGINAL_DTB:.dtb=.dts)}: ${ORIGINAL_DTB}
	$(DTC) -q -I dtb -O dts $< > $@

dtb.dts: ${notdir $(ORIGINAL_DTB:.dtb=.dts)} ${DT_OVERLAYS}
	${LionsOS}/vmm/tools/dtscat ${notdir $(ORIGINAL_DTB:.dtb=.dts)} ${DT_OVERLAYS} > $@

package_guest_images.o: $(LIBVMM_DIR)/tools/package_guest_images.S  $(LINUX) $(INITRD) dtb.dtb
	$(CC) -c -g3 -x assembler-with-cpp \
					-DGUEST_KERNEL_IMAGE_PATH=\"$(LINUX)\" \
					-DGUEST_DTB_IMAGE_PATH=\"dtb.dtb\" \
					-DGUEST_INITRD_IMAGE_PATH=\"$(INITRD)\" \
					-target $(TARGET) \
					$< -o $@


vmm.elf: ${VMM_OBJS} libvmm.a
	$(LD) $(LDFLAGS) $^ $(LIBS) -o $@

$(IMAGE_FILE) $(REPORT_FILE): $(IMAGES) ${EXAMPLE_DIR}/vmm.system vmm.elf
	$(MICROKIT_TOOL) ${EXAMPLE_DIR}/vmm.system --search-path $(BUILD_DIR) --board $(MICROKIT_BOARD) --config $(MICROKIT_CONFIG) -o $(IMAGE_FILE) -r $(REPORT_FILE)

FORCE: ;

# How to build libvmm.a
include ${LIBVMM_DIR}/vmm.mk

