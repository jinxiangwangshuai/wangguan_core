# $Id: Makefile,v 1.36 2009/09/21 17:02:44 mascarenhas Exp $

T= lfs

CONFIG= ./config

include $(CONFIG)

SRCS= src/$T.c
OBJS= src/$T.o

lib: src/lfs.so

src/lfs.so: $(OBJS)
	$(CC) $(LIB_OPTION) -o src/lfs.so $(OBJS)
	cp src/lfs.so ../../ -f

test: lib
	LUA_CPATH=./src/?.so lua tests/test.lua

install:
#	mkdir -p $(DESTDIR)$(LUA_LIBDIR)
#	cp src/lfs.so $(DESTDIR)$(LUA_LIBDIR)
	cp src/lfs.so ../../ -f

clean:
	rm -f src/lfs.so $(OBJS)
