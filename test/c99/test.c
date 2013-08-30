#include "alltypes.h"
#include "unit.h"

#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>

#define assert_encode_decode(name, io_value, message) \
  do { \
    size_t  size; \
    uint8_t buffer[256]; \
    name ## _t in = {io_value}; \
    name ## _t io = {io_value}; \
    name ## _encode(&io, buffer, sizeof(buffer), &size); \
    name ## _decode(&io, buffer, size, &size); \
    mu_assert(memcmp(&io.value, &in.value, sizeof(in.value)) == 0, "encode decode " message); \
  } while (0)

static char *test_wire_varints() {
  assert_encode_decode(proto_int32, 0,          "int32 1 byte value 0");
  assert_encode_decode(proto_int32, 1,          "int32 1 byte value 1");
  assert_encode_decode(proto_int32, 333,        "int32 2 byte value 333");
  assert_encode_decode(proto_int32, 123456,     "int32 3 byte value 123456");
  assert_encode_decode(proto_int32, 12345678,   "int32 4 byte value 12345678");
  assert_encode_decode(proto_int32, 1234567890, "int32 5 byte value 1234567890");
  return 0;
}

static char *test_all() {
  mu_run(test_wire_varints);
  return 0;
}

int main(int argc, char **argv) {
  char *result = test_all();
  printf("tests:      %u\n", mu_tests);
  printf("assertions: %u\n", mu_assertions);

  if (result != 0) printf("failed:     %s\n", result);
  else printf("passed:     all\n");

  return result != 0;
}
