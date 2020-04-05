# builder definition
FROM rust:latest as builder

RUN apt-get update \
    && apt-get install -y libfontconfig1-dev libgraphite2-dev libharfbuzz-dev libicu-dev zlib1g-dev fonts-font-awesome fonts-texgyre
RUN cargo install tectonic --force --vers 0.1.12

WORKDIR /usr/src/tex
RUN wget 'https://sourceforge.net/projects/biblatex-biber/files/biblatex-biber/2.11/binaries/Linux/biber-linux_x86_64.tar.gz'
RUN tar -xvzf biber-linux_x86_64.tar.gz
RUN chmod +x biber
RUN cp biber /usr/bin/biber

COPY tex/ ./
# first run - keep files for biber
RUN tectonic --keep-intermediates --reruns 0 main.tex
RUN biber main
# one last tectonic run over all files
RUN for f in *.tex; do tectonic $f; done

# use a lightweight debian - no need for the whole rust environment
FROM debian:stretch-slim 
RUN apt-get update \
    && apt-get install -y --no-install-recommends libfontconfig1 libgraphite2-3 libharfbuzz0b zlib1g libharfbuzz-icu0 libssl1.1 ca-certificates curl jq fonts-font-awesome fonts-texgyre 

# reuse tectonic binary, cache and biber
COPY --from=builder /usr/lib/x86_64-linux-gnu/libicu* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/local/cargo/bin/tectonic /usr/bin/
COPY --from=builder /root/.cache/Tectonic/ /root/.cache/Tectonic/
COPY --from=builder /usr/bin/biber /usr/bin/ 

WORKDIR /data
