MAIN_FILE=netcheck
LIBEXT=so

LIBS=-llua 
CFLAGS_SHARED=-fPIC
LFLAGS=-fPIC -shared

CC:=gcc
AR:=ar
CP:=cp
CFLAGS:=$(CFLAGS) -std=gnu99 -Os -g
LFLAGS:=$(LFLAGS) 
WFLAGS:=$(WFLAGS) -Wall

build: shared
	$(CP) $(MAIN_FILE).$(LIBEXT) ../../ -f
	$(RM) $(MAIN_FILE).o $(MAIN_FILE).$(LIBEXT)

static: $(MAIN_FILE).c
	$(CC) -c $(CFLAGS) $(WFLAGS) -o $(MAIN_FILE).o $(MAIN_FILE).c
	$(AR) rv lib$(MAIN_FILE).a $(MAIN_FILE).o
	$(RM) $(MAIN_FILE).o

shared: $(MAIN_FILE).c
	$(CC) -c $(CFLAGS_SHARED) $(CFLAGS) $(WFLAGS) -o $(MAIN_FILE).o $(MAIN_FILE).c
	$(CC) $(LFLAGS) $(WFLAGS) -o $(MAIN_FILE).$(LIBEXT) $(MAIN_FILE).o $(LIBS)

clean:
	$(RM) *.o *.a *.so ../../$(MAIN_FILE).$(LIBEXT)
