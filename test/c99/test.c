#include "alltypes.h"
#include "unit.h"

#include <float.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>

#define xstr(s) str(s)
#define str(s)  #s

#define assert_encode_decode(name, io_value, message) \
  do { \
    size_t  size; \
    uint8_t buffer[256]; \
    name ## _t in = {io_value}; \
    name ## _t io = {io_value}; \
    name ## _encode(&io, buffer, sizeof(buffer), &size); \
    name ## _decode(&io, buffer, size, &size); \
    unit_assert(memcmp(&io.value, &in.value, sizeof(in.value)) == 0, "encode decode " message); \
  } while (0)

static char *test_int32() {
  assert_encode_decode(proto_int32, 0,         "int32  1 byte value 0");
  assert_encode_decode(proto_int32, 1,         "int32  1 byte value 1");
  assert_encode_decode(proto_int32, 1234,      "int32  2 byte value 1234");
  assert_encode_decode(proto_int32, 123456,    "int32  3 byte value 123456");
  assert_encode_decode(proto_int32, 12345678,  "int32  4 byte value 12345678");
  assert_encode_decode(proto_int32, INT32_MAX, "int32  5 byte value " xstr(INT32_MAX));

  assert_encode_decode(proto_int32, -1,        "int32 10 byte value -1");
  assert_encode_decode(proto_int32, -1234,     "int32 10 byte value -1234");
  assert_encode_decode(proto_int32, -123456,   "int32 10 byte value -123456");
  assert_encode_decode(proto_int32, -12345678, "int32 10 byte value -12345678");
  assert_encode_decode(proto_int32, INT32_MIN, "int32 10 byte value " xstr(INT32_MIN));
  return 0;
}

static char *test_int64() {
  assert_encode_decode(proto_int64, 0,         "int64  1 byte value 0");
  assert_encode_decode(proto_int64, 1,         "int64  1 byte value 1");
  assert_encode_decode(proto_int64, 1234,      "int64  2 byte value 1234");
  assert_encode_decode(proto_int64, 123456,    "int64  3 byte value 123456");
  assert_encode_decode(proto_int64, 12345678,  "int64  4 byte value 12345678");
  assert_encode_decode(proto_int64, INT64_MAX, "int64 10 byte value " xstr(INT64_MAX));

  assert_encode_decode(proto_int64, -1,        "int64 10 byte value -1");
  assert_encode_decode(proto_int64, -1234,     "int64 10 byte value -1234");
  assert_encode_decode(proto_int64, -123456,   "int64 10 byte value -123456");
  assert_encode_decode(proto_int64, -12345678, "int64 10 byte value -12345678");
  assert_encode_decode(proto_int64, INT64_MIN, "int64 10 byte value " xstr(INT64_MIN));
  return 0;
}

static char *test_uint32() {
  assert_encode_decode(proto_uint32, 0,          "uint32 1 byte value 0");
  assert_encode_decode(proto_uint32, 1,          "uint32 1 byte value 1");
  assert_encode_decode(proto_uint32, 1,          "uint32 1 byte value 1");
  assert_encode_decode(proto_uint32, UINT32_MAX, "uint32 5 byte value " xstr(UINT32_MAX));
  return 0;
}

static char *test_uint64() {
  assert_encode_decode(proto_uint64, 0,          "uint64  1 byte value 0");
  assert_encode_decode(proto_uint64, 1,          "uint64  1 byte value 1");
  assert_encode_decode(proto_uint64, 1,          "uint64  1 byte value 1");
  assert_encode_decode(proto_uint64, UINT64_MAX, "uint64 10 byte value " xstr(UINT64_MAX));
  return 0;
}

static char *test_sint32() {
  assert_encode_decode(proto_sint32, 0,         "sint32  1 byte value 0");
  assert_encode_decode(proto_sint32, 1,         "sint32  1 byte value 1");
  assert_encode_decode(proto_sint32, 1234,      "sint32  2 byte value 1234");
  assert_encode_decode(proto_sint32, 123456,    "sint32  3 byte value 123456");
  assert_encode_decode(proto_sint32, 12345678,  "sint32  4 byte value 12345678");
  assert_encode_decode(proto_sint32, INT32_MAX, "sint32  5 byte value " xstr(INT32_MAX));

  assert_encode_decode(proto_sint32, -1,        "sint32 10 byte value -1");
  assert_encode_decode(proto_sint32, -1234,     "sint32 10 byte value -1234");
  assert_encode_decode(proto_sint32, -123456,   "sint32 10 byte value -123456");
  assert_encode_decode(proto_sint32, -12345678, "sint32 10 byte value -12345678");
  assert_encode_decode(proto_sint32, INT32_MIN, "sint32 10 byte value " xstr(INT32_MIN));
  return 0;
}

static char *test_sint64() {
  assert_encode_decode(proto_sint64, 0,         "sint64 value 0");
  assert_encode_decode(proto_sint64, 1,         "sint64 value 1");
  assert_encode_decode(proto_sint64, 1234,      "sint64 value 1234");
  assert_encode_decode(proto_sint64, 123456,    "sint64 value 123456");
  assert_encode_decode(proto_sint64, 12345678,  "sint64 value 12345678");
  assert_encode_decode(proto_sint64, INT64_MAX, "sint32 value " xstr(INT64_MAX));

  assert_encode_decode(proto_sint64, -1,        "sint64 value -1");
  assert_encode_decode(proto_sint64, -1234,     "sint64 value -1234");
  assert_encode_decode(proto_sint64, -123456,   "sint64 value -123456");
  assert_encode_decode(proto_sint64, -12345678, "sint64 value -12345678");
  assert_encode_decode(proto_sint64, INT64_MIN, "sint64 value " xstr(INT64_MIN));
  return 0;
}

static char *test_bool() {
  assert_encode_decode(proto_bool, true,  "bool value true");
  assert_encode_decode(proto_bool, false, "bool value false");
  assert_encode_decode(proto_bool, 1,     "bool value 1");
  assert_encode_decode(proto_bool, 0,     "bool value 0");
  return 0;
}

static char *test_enum() {
  assert_encode_decode(proto_enum, PROTO_ENUM_TYPE_ONE,         "enum value " str(PROTO_ENUM_TYPE_ONE));
  assert_encode_decode(proto_enum, PROTO_ENUM_TYPE_TWO,         "enum value " str(PROTO_ENUM_TYPE_TWO));
  assert_encode_decode(proto_enum, PROTO_ENUM_TYPE_NINETY_NINE, "enum value " str(PROTO_ENUM_TYPE_NINETY_NINE));
  return 0;
}

static char *test_fixed64() {
  assert_encode_decode(proto_fixed64, 0,          "fixed64  1 byte value 0");
  assert_encode_decode(proto_fixed64, 1,          "fixed64  1 byte value 1");
  assert_encode_decode(proto_fixed64, 1,          "fixed64  1 byte value 1");
  assert_encode_decode(proto_fixed64, UINT64_MAX, "fixed64 10 byte value " xstr(UINT64_MAX));
  return 0;
}

static char *test_sfixed64() {
  assert_encode_decode(proto_sfixed64, 0,         "sfixed64 value 0");
  assert_encode_decode(proto_sfixed64, 1,         "sfixed64 value 1");
  assert_encode_decode(proto_sfixed64, 1234,      "sfixed64 value 1234");
  assert_encode_decode(proto_sfixed64, 123456,    "sfixed64 value 123456");
  assert_encode_decode(proto_sfixed64, 12345678,  "sfixed64 value 12345678");
  assert_encode_decode(proto_sfixed64, INT64_MAX, "sfixed32 value " xstr(INT64_MAX));

  assert_encode_decode(proto_sfixed64, -1,        "sfixed64 value -1");
  assert_encode_decode(proto_sfixed64, -1234,     "sfixed64 value -1234");
  assert_encode_decode(proto_sfixed64, -123456,   "sfixed64 value -123456");
  assert_encode_decode(proto_sfixed64, -12345678, "sfixed64 value -12345678");
  assert_encode_decode(proto_sfixed64, INT64_MIN, "sfixed64 value " xstr(INT64_MIN));
  return 0;
}

static char *test_double() {
  assert_encode_decode(proto_double, DBL_MAX, "double value " xstr(DBL_MAX));
  assert_encode_decode(proto_double, DBL_MIN, "double value " xstr(DBL_MIN));
  return 0;
}

static char *test_all() {
  unit_run(test_int32);
  unit_run(test_int64);
  unit_run(test_uint32);
  unit_run(test_uint64);
  unit_run(test_sint32);
  unit_run(test_sint64);
  unit_run(test_bool);
  unit_run(test_enum);
  unit_run(test_fixed64);
  unit_run(test_sfixed64);
  unit_run(test_double);
  return 0;
}

int main(int argc, char **argv) {
  char *result = test_all();
  printf("tests:      %u\n", unit_tests);
  printf("assertions: %u\n", unit_assertions);

  if (result != 0) printf("failed:     %s\n", result);
  else printf("passed:     all\n");

  return result != 0;
}
