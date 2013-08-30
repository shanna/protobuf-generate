CFLAGS := -g -Wall -Werror -std=c11

all: test

protobufs:
	bundle exec ../../bin/protobuf-generate c99 alltypes.proto

test: protobufs test.c alltypes.c
	$(CC) $(CFLAGS) -o $@ test.c alltypes.c
	./test

clean:
	rm -f test

real-clean: clean
