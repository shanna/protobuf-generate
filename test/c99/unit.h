/*
  Mini Unit

  Shamelessly taken and tweaked to taste from
  http://www.jera.com/techinfo/jtns/jtn002.html
*/

#pragma once

static unsigned int mu_tests      = 0;
static unsigned int mu_assertions = 0;

#define mu_assert(test, message) \
  do { \
    mu_assertions++; \
    if (!(test)) return message; \
  } while (0)

#define mu_run(test) \
  do { \
    mu_tests++; \
    char *message = test(); \
    if (message) return message; \
  } while (0)

