/*
  Mini Unit

  Shamelessly taken and tweaked to taste from
  http://www.jera.com/techinfo/jtns/jtn002.html
*/

#pragma once

static unsigned int unit_tests      = 0;
static unsigned int unit_assertions = 0;

#define unit_assert(test, message) \
  do { \
    unit_assertions++; \
    if (!(test)) return message; \
  } while (0)

#define unit_run(test) \
  do { \
    unit_tests++; \
    char *message = test(); \
    if (message) return message; \
  } while (0)

