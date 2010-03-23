/*
 * rowlOS -
 * Copyright (C) 2010 nineties
 *
 * $Id: rowlos.ls 2010-03-23 15:46:36 nineties $
 */

OUTPUT_FORMAT(binary)
OUTPUT_ARCH(i386)

SECTIONS {
    . = 0x7c00;
    .text : { *(.text) }
}
