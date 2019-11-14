/*
* made by liuqingwei. only run in linux
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>    /* BSD and Linux */
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <sys/time.h>
#include <time.h>
#include <getopt.h>
#include <sys/signal.h>
#include <termios.h>
#include <linux/watchdog.h>

#include "lauxlib.h"
#include "lua.h"
#include "lualib.h"

static int m_linuxWatchdogFd = -1;

static int linuxWatchdogStart(lua_State *L)
{
	m_linuxWatchdogFd = open("/dev/watchdog", O_RDWR);
	if (m_linuxWatchdogFd == -1)
	{
		printf("cannot open linux watchdog");
		return 1;
	}
	ioctl(m_linuxWatchdogFd, WDIOC_SETOPTIONS, WDIOS_ENABLECARD);
	return 1;
}

static int linuxWatchdogTimeout(lua_State *L)
{
	lua_Integer timeout = 60;
	if (lua_isnumber(L, 1)) {
		timeout = lua_tointeger(L, 1);
	}
	ioctl(m_linuxWatchdogFd, WDIOC_SETTIMEOUT, &timeout);
	return 1;
}

static int linuxWatchdogStop(lua_State *L)
{
	if (m_linuxWatchdogFd != -1)
	{
		ioctl(m_linuxWatchdogFd, WDIOC_SETOPTIONS, WDIOS_DISABLECARD);
		close(m_linuxWatchdogFd);
	}
	return 1;
}

static int linuxWatchdogFeed(lua_State *L)
{
	if (m_linuxWatchdogFd != -1)
	{
		ioctl(m_linuxWatchdogFd, WDIOC_KEEPALIVE,NULL);
	}
	return 1;
}

static const luaL_reg lib_linuxWatchdog[] = {
    {"start",    linuxWatchdogStart},
	{"setTimeout",    linuxWatchdogTimeout},
	{"stop",     linuxWatchdogStop},
	{"feed",     linuxWatchdogFeed},
    {NULL, NULL}
};

LUALIB_API int luaopen_linuxWatchdog(lua_State *L) {
    luaL_register(L, "linuxWatchdog", lib_linuxWatchdog);
 //   lua_pop(L, 1);
    return 1;
}
