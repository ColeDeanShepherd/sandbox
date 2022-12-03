FROM archlinux:latest

RUN pacman --noconfirm -Syu --noconfirm llvm clang cmake make diffutils git

RUN git clone https://github.com/rpav/c2ffi.git \
    && cd c2ffi \
    && git checkout llvm-14.0.0

# Build c2ffi
RUN cd /c2ffi && \
    rm -rf build && mkdir -p build && cd build && \
    cmake -DBUILD_CONFIG=Release .. && make

# As a sanity check, make sure the binary we built can be executed
RUN /c2ffi/build/bin/c2ffi --help