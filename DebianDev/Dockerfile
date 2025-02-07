FROM debian:stable-slim

# Install packages, create directories, and install Amazon Corretto 11
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openssh-client \
    curl \
    vim \
    maven \
    wget \
    openjdk-17-jdk \
    python3 \
    python3-pip \
    firefox-esr \
    gnupg \
    subversion && \
    wget -O- https://apt.corretto.aws/corretto.key | apt-key add - && \
    echo "deb https://apt.corretto.aws stable main" > /etc/apt/sources.list.d/corretto.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends java-11-amazon-corretto-jdk && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /test /pvenv /root/.ssh

# Set JAVA_HOME to Corretto 11.  Crucially, use update-alternatives to find the correct path.
ENV JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto

ENV BASE=/test
ENV SYSTEM=OvernightDirect

ENV PYTHONPATH=${BASE}/pyunit/ocslib
ENV CONFIG=${BASE}/config
ENV VIRTUAL_ENV=/pvenv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install geckodriver (separate RUN instruction)
RUN apt-get update && apt-get install -y --no-install-recommends wget && \
    GECKODRIVER_VERSION=$(curl -sL "https://api.github.com/repos/mozilla/geckodriver/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/') && \
    wget -q "https://github.com/mozilla/geckodriver/releases/download/v${GECKODRIVER_VERSION}/geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz" && \
    tar -xzf "geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz" -C /usr/local/bin/ && \
    rm "geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz" && \
    chmod +x /usr/local/bin/geckodriver && \
    apt-get purge -y wget && apt-get autoremove -y &&  rm -rf /var/lib/apt/lists/* && \
    python3 -m venv $VIRTUAL_ENV && \
    . /pvenv/bin/activate && pip3 install behave && pip3 install requests && pip3 install psycopg2-binary && pip3 install flask && deactivate
    

CMD ["bash"]
