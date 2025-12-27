FROM alpine:3.16 AS builder
ARG THREADS="4"
ARG SHA=""

WORKDIR /

RUN set -xe && \
    apk add --no-cache --virtual .build-tools git g++ build-base linux-headers cmake python3 ccache ninja && \
    apk add --no-cache --virtual .build-deps curl-dev rapidjson-dev pcre2-dev yaml-cpp-dev

# quickjspp
RUN set -xe && \
    git clone --no-checkout https://github.com/ftk/quickjspp.git && \
    cd quickjspp && \
    git fetch origin 0c00c48895919fc02da3f191a2da06addeb07f09 && \
    git checkout 0c00c48895919fc02da3f191a2da06addeb07f09 && \
    git submodule update --init && \
    cmake -DCMAKE_BUILD_TYPE=Release . && \
    make quickjs -j ${THREADS} && \
    install -d /usr/lib/quickjs/ && \
    install -m644 quickjs/libquickjs.a /usr/lib/quickjs/ && \
    install -d /usr/include/quickjs/ && \
    install -m644 quickjs/quickjs.h quickjs/quickjs-libc.h /usr/include/quickjs/ && \
    install -m644 quickjspp.hpp /usr/include

# libcron
RUN set -xe && \
    git clone https://github.com/PerMalmberg/libcron --depth=1 && \
    cd libcron && \
    git submodule update --init && \
    cmake -DCMAKE_BUILD_TYPE=Release . && \
    make libcron -j ${THREADS} && \
    install -m644 libcron/out/Release/liblibcron.a /usr/lib/ && \
    install -d /usr/include/libcron/ && \
    install -m644 libcron/include/libcron/* /usr/include/libcron/ && \
    install -d /usr/include/date/ && \
    install -m644 libcron/externals/date/include/date/* /usr/include/date/

# toml11
RUN set -xe && \
    git clone https://github.com/ToruNiina/toml11 --branch="v4.3.0" --depth=1 && \
    cd toml11 && \
    cmake -DCMAKE_CXX_STANDARD=11 . && \
    make install -j ${THREADS}

# build subconverter from THIS repository source (provided by build context)
WORKDIR /src
COPY . /src

RUN set -xe && \
    [ -n "${SHA}" ] && sed -i 's/\(v[0-9]\.[0-9]\.[0-9]\)/\1-'"${SHA}"'/' src/version.h || true && \
    python3 -m ensurepip && \
    python3 -m pip install --no-cache-dir gitpython && \
    python3 scripts/update_rules.py -c scripts/rules_config.conf && \
    # 配置 ccache
    export PATH="/usr/lib/ccache/bin:$PATH" && \
    export CCACHE_DIR=/tmp/ccache && \
    export CCACHE_COMPILERCHECK=content && \
    # 使用 Ninja 生成器（比 Make 更快）并启用 ccache
    cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER_LAUNCHER=ccache . && \
    # 并行编译，使用所有可用核心
    ninja -j ${THREADS}

FROM alpine:3.16
RUN apk add --no-cache --virtual subconverter-deps pcre2 libcurl yaml-cpp

COPY --from=builder /src/subconverter /usr/bin/
COPY --from=builder /src/base /base/

ENV TZ=Africa/Abidjan
RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /base
CMD subconverter
EXPOSE 25500/tcp
