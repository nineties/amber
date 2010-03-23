#
# rowlOS -
# Copyright (C) 2010 nineties
#
# $Id: Makefile 2010-03-23 15:46:07 nineties $
#

IMAGE=rowlos.img
LINK=rowlos.ls
SOURCES=boot.s

all: $(SOURCES)
	make image

image: $(SOURCES:%.s=%.o)
	ld $^  -T $(LINK) -o $(IMAGE)

clean:
	rm -f $(IMAGE) $(SOURCES:%.s=%.o)
