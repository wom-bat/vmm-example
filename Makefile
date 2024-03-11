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

export EXAMPLE_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
export LionsOS ?= $(realpath ../LionsOS)

export MICROKIT_CONFIG ?= debug
export BUILD_DIR ?= $(abspath build)
export MICROKIT_BOARD := odroidc4
CPU := cortex-a55

TOOLCHAIN := clang
CC := clang
LD := ld.lld
TARGET := aarch64-none-elf
MICROKIT_TOOL ?= $(MICROKIT_SDK)/bin/microkit
DTC := dtc

LIBVMM_DIR := ${LionsOS}/vmm

export VMM_IMAGE_DIR := ${EXAMPLE_DIR}/vmm
export ORIGINAL_DTB := $(VMM_IMAGE_DIR)/meson-sm1-odroid-c4.dtb
export DT_OVERLAYS := $(VMM_IMAGE_DIR)/overlay.dts

IMAGE_FILE := $(BUILD_DIR)/vmdev.img
REPORT_FILE := $(BUILD_DIR)/report.txt

all: $(IMAGE_FILE)

${REPORT_FILE} ${IMAGE_FILE}: ${BUILD_DIR}/Makefile vmm.system FORCE
	${MAKE} -C ${BUILD_DIR}


${BUILD_DIR}/Makefile: vmm-dev.mk
	mkdir -p ${BUILD_DIR}
	cp $< ${BUILD_DIR}/Makefile

clean:
	${MAKE} -C ${BUILD_DIR} $@
clobber:
	rm -rf ${BUILD_DIR}

FORCE: ;

