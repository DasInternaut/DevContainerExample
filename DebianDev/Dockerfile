# Since I regard crafting a Dockerfile as mostly grunt work, I got Google's
# latest Gemini Pro model to generate most of this. Then I needed to resolve
# a couple of problems mysefl:
#
#     - Firstly, Debian Bookworm's repositories no longer have OpenJDK 11. No
#       idea why given it is LTS.
#     - So I updated the initial round of installs to bring in Amazon Correcto
#       instead.
#     - It also made sense to prototype the Python stuff inside a running
#       container and then transfer to the Dockerfile.
#
# Why Java 11? I don't currently have time to make changes to my codebase to
# get it to work with 17.
#
# To run in Docker on MX (Arm) based mac, swap out linux64.tar.gz for
# aarch64.tar.gz.
#
# Note: I use svn at work. You can replace that with git easily enough.
#
# I've not yet tested on a Mac, so no idea if Correctto will be problematic. 

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

# Set up environment variables. 
ENV JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto

ENV BASE=/test
ENV SYSTEM=OvernightDirect

ENV PYTHONPATH=${BASE}/pyunit/ocslib
ENV CONFIG=${BASE}/config
ENV VIRTUAL_ENV=/pvenv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install geckodriver (separate RUN instruction), install python3-venv and
# then use pip3 to install various packages into the venv. This is done
# because under Debian Bookworm, the Python people decided that apt is the
# gatekeeper to installing software, and any pip installs must be done inside
# a venv.

RUN apt-get update && apt-get install -y --no-install-recommends wget && \
    GECKODRIVER_VERSION=$(curl -sL "https://api.github.com/repos/mozilla/geckodriver/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/') && \
    wget -q "https://github.com/mozilla/geckodriver/releases/download/v${GECKODRIVER_VERSION}/geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz" && \
    tar -xzf "geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz" -C /usr/local/bin/ && \
    rm "geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz" && \
    chmod +x /usr/local/bin/geckodriver && \
    apt install -y python3-venv && \
    apt-get purge -y wget && apt-get autoremove -y &&  rm -rf /var/lib/apt/lists/* && \
    python3 -m venv $VIRTUAL_ENV && \
    . /pvenv/bin/activate && pip3 install behave && pip3 install requests && pip3 install psycopg2-binary && pip3 install flask && deactivate

# Other things you can do? You can copy a checkout script and run that against
# your repository. Also, if you want more flexibility with environment variables,
# you can copy in a custom .bashrc at build time (but note that some environment
# variables are needed up there as part of the build).

CMD ["bash"]
