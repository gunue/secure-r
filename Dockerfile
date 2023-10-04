# Use the official R base image
FROM r-base:latest

# Install dependencies for httr and RCurl
RUN apt-get update && \
    apt-get install -y \
        libcurl4-openssl-dev \
        libssl-dev \
        libxml2-dev

# Install the httr and RCurl packages

RUN mkdir /app
COPY app.R /app/app.R
#COPY dependencies.R /app/dependencies.R
WORKDIR /app
#RUN Rscript dependencies.R
RUN R -e "install.packages(c('httr', 'RCurl'), dependencies=TRUE)"

# The command that will run when the container starts
CMD ["Rscript", "app.R"]