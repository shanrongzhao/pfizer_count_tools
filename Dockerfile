FROM debian:buster-slim
SHELL ["/bin/bash", "-c"]

RUN apt-get -qq update && \
    apt-get -qq -y install --no-install-recommends \
        build-essential \
        cmake \
        gnupg \
        curl \
        bison \
        git \
        cmake \
        wget \
        zlib1g-dev \
        python3 \
        python3-pip

RUN pip3 install numpy==1.18.1 --no-cache-dir && \
    pip3 install pandas==1.0.3 --no-cache-dir

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \ 
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && \
    apt-get update -y && apt-get install -y google-cloud-sdk=290.0.0-0

RUN wget https://github.com/COMBINE-lab/salmon/releases/download/v1.3.0/salmon-1.3.0_linux_x86_64.tar.gz && \
    tar -zxvf salmon-1.3.0_linux_x86_64.tar.gz && \
    rm salmon-1.3.0_linux_x86_64.tar.gz && \
    mkdir -p /software && \
    mv salmon-latest_linux_x86_64/ /software/salmon

RUN wget http://ccb.jhu.edu/software/stringtie/dl/gffread-0.11.4.Linux_x86_64.tar.gz && \
    tar -xzvf gffread-0.11.4.Linux_x86_64.tar.gz && \
    rm -f gffread-0.11.4.Linux_x86_64.tar.gz && \
    mkdir -p /software && \
    mv gffread-0.11.4.Linux_x86_64/ /software/gffread


RUN git clone https://github.com/lh3/bioawk.git /software/bioawk && \
    cd /software/bioawk && make

RUN wget https://github.com/alexdobin/STAR/archive/2.7.5a.tar.gz && \
    tar -xzvf 2.7.5a.tar.gz && \
    rm 2.7.5a.tar.gz && \
    mkdir -p /software && \
    mv STAR-2.7.5a/ /software/STAR

RUN apt-get -qq -y remove curl gnupg wget curl python3-pip && \
    apt-get -qq -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/log/dpkg.log && \
    rm /usr/bin/python && ln -s /usr/bin/python3 /usr/bin/python

ADD https://raw.githubusercontent.com/klarman-cell-observatory/cumulus/master/docker/monitor_script.sh /software
RUN chmod a+rx /software/monitor_script.sh

COPY t2g.py /software
RUN chmod a+rx /software/t2g.py

COPY get-star-summary.pl /software
RUN chmod a+rx /software/get-star-summary.pl

ENV PATH=/software:/software/bioawk:/software/gffread:/software/salmon/bin:/software/STAR/bin/Linux_x86_64:$PATH


