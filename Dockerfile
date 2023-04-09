FROM r-base
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libssl-dev \
    libcurl4-openssl-dev
COPY . /usr/local/src/myscripts
WORKDIR /usr/local/src/myscripts
RUN Rscript dependencies.R
CMD ["Rscript", "getsecret.R"]

