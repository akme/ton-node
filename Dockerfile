FROM ubuntu:18.04 as builder
RUN apt-get update && \
	apt-get install -y build-essential cmake clang-6.0 openssl libssl-dev zlib1g-dev gperf wget git && \
	rm -rf /var/lib/apt/lists/*
ENV CC clang-6.0
ENV CXX clang++-6.0
WORKDIR /
RUN git clone --recursive https://github.com/ton-blockchain/ton
WORKDIR /ton

RUN mkdir build && \
	cd build && \
	cmake ../ton-node && \
	make -j 8

FROM ubuntu:18.04
RUN apt-get update && \
	apt-get install -y openssl wget&& \
	rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/ton-work/db && \
	mkdir -p /var/ton-work/db/static

COPY --from=builder /ton/build/validator-engine/validator-engine /usr/local/bin/
COPY --from=builder /ton/build/validator-engine-console/validator-engine-console /usr/local/bin/
COPY --from=builder /ton/build/utils/generate-random-id /usr/local/bin/

WORKDIR /var/ton-work/db
COPY init.sh control.template ./
RUN chmod +x init.sh

ENTRYPOINT ["./init.sh"]
