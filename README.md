# protobuf-generate

[source](https://bitbucket.org/shanehanna/protobuf-generate)

## Description

A multi-language concrete protobuf code generator in Ruby.

## Synopsis

A simple PEG parser, AST and template based approach to code generation.

[protobuf-embedded-c](https://code.google.com/p/protobuf-embedded-c/) uses the same approach but requires a page of
rage inducing instructions to install obsolete Eclipse plugins and Java bullshit if you want to be able to develop
and customize any of the C it generates. Ruby and scripting languages in general are ideal for this sort of thing
so that's what I've done.

## Install

```
gem install protobuf-generate
```

## Usage

```
protobuf-generate <language> <protofile>
```

## Languages

### C - Embedded

C99+ suitable for embedded systems.

#### string and byte

A fixed size string and byte structure is generated using a required @size_max meta attribute to avoid dynamic
allocation. Strings sent from other protobuf implementations that are too long for the structure will be truncated and
null terminated to fit within the maximum size. Bytes will just be truncated.

```
message Message {
  required string name = 1; // @size_max = 32
}
```

```
typedef struct message_t {
  struct {
    uint8_t data[32];
    site_t  size;
  } name;
} message_t;
```

