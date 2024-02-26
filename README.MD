Simple VM with passthrough
================================

This directory contains what's needed to run a complete VM with
passthrough of all components on an Odroid C4.

Such a VM can be used to develop new LionsOS components, and is fairly
easy to adapt to other systems.

What you need
================

Build and Source dependencies
-----------------------------

It's easiest to build if you have a complete checkout of
[LionsOS](https://github.com/au-ts/LionsOS)

If you follow the instructions at [LionsOS
Docs](https://lionsos.org/docs/kitty/building/) you will have all the
prerequisites.

Payload
-------

You need a kernel, device tree and initrd that work already on your
target system.  The simplest way to get them is to extract them from
`/boot` on your system after it is running.

For Armbian-based systems, the files you need are `/boot/Image`
`/boot/initrd.img` and `/boot/dtb/amlogic/meson-sm1-odroid-c4.dtb`.
Use `scp` to transfer these files to your build machine.

Before building, you'll need to know the size of `initrd.img` rounded
up to a 4096-byte boundary.
