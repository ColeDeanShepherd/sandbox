FROM alpine:edge

RUN apk update \
	&& apk --no-cache add bash build-base make git gmp-dev chez-scheme \
	&& adduser -D -s /bin/bash linuxbrew \
	&& echo 'linuxbrew ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers \
	&& ln -s /bin/touch /usr/bin/touch

USER linuxbrew
WORKDIR /home/linuxbrew
ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/home/linuxbrew/.idris2/bin:$PATH \
	SHELL=/bin/bash \
	USER=linuxbrew \
	IDRIS2_INC_CGS=chez

RUN git clone https://github.com/idris-lang/Idris2.git \
	&& cd Idris2 \
	&& git checkout tags/v0.5.1 -b main-v0.5.1 \
	&& make bootstrap SCHEME=chez \
	&& make install

RUN cd Idris2 \
	&& make install-libdocs \
 	&& make clean \
	&& make all \
	&& make install \
	&& make install-api \
#	&& make test \
#	&& eval "$(idris2 --bash-completion-script idris2)"
	&& make clean

CMD ["/bin/bash"]