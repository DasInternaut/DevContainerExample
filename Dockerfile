# (31/03/2024 Jason Hindle): I've been using a dev container on my personal windows system for
# for some time now.  This was very much the hand crafted result of some mucking about around
# a Youtube tutorial.  So, I wanted to build something from scratch using a Dockerfile.  This
# is the result of some experimenting. 

# I'm using Alpine.  Anyone familiar with apt or yun will be comfortable understanding the 
# apk add commands, below (and at translating them to produce a Rocky or Debian version of
# this Dockerfile.)

FROM alpine:latest

# RUN is only used at build time and is useful for getting everything required by this
# container.
# ENV sets up environment variables at build time.  These are baked in (i.e. set up 
# before .bashrc or .profile is run).

# Install system-level dependencies
# Why two versions of Java? Because Microsoft's Java language server has started to demand
# Java 17, while I need Java 11!

RUN apk add --no-cache openssh curl build-base vim maven openjdk17 openjdk11 python3 py3-pip firefox subversion && mkdir /test && mkdir /pvenv && mkdir /root/.ssh

# For Debian or RHEL variants, you can probably use apt/yum to get geckodriver.  It appears this
# is not present in the Apline repository, so the hard way it is.

RUN LATEST_GECKODRIVER_URL=$(curl -s https://api.github.com/repos/mozilla/geckodriver/releases/latest | grep 'browser_download_url.*linux64.*tar.gz' | cut -d : -f 2,3 | tr -d \" ) && \
    curl -o /gecko.tar.gz -LOs $(echo $LATEST_GECKODRIVER_URL | sed 's/gz.*/gz/') && tar -xzvf /gecko.tar.gz -C /usr/local/bin && cp /usr/local/bin/geckodriver /

# Set up some environment variables for Java and the default Python virtual environment (venv) 
# we will be using.

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk
ENV JAVA=/usr/lib/jvm/java-11-openjdk/bin/java
ENV VIRTUAL_ENV=/pvenv

# The latest versions of pip insist we must install Python dependencies either using the
# distribution's package manager, or in a venv.  Since I'm a little unfamiliar with
# Alpine's repository, I choose venv.

RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:/usr/lib/jvm/java-11-openjdk/bin:$PATH"
RUN . /pvenv/bin/activate && pip3 install behave && pip3 install requests && pip3 install psycopg2-binary && pip3 install flask && deactivate
ENV BASE=/test
ENV SYSTEM=122NoneSharded
ENV PYTHONPATH=${BASE}/pyunit/ocslib
ENV CONFIG=${BASE}/config
ENV BIN=""

# Extending this to create a test server?  It is simple FROM <this_image_name>:<tag>.

# Set the working directory.  This happened to be the directory where I will pull
# the latest revision of my software from Subversion.

WORKDIR /test

# Copy in the ssh config file and checkout.sh.
# Neither file should be version controlled in a public repo.

COPY ./config /root/.ssh
COPY ./checkout.sh /checkout.sh
RUN cd / && chmod u+x checkout.sh && ./checkout.sh  && cd $CONFIG/Systems/$SYSTEM && cp ocssystemV2.cfg ../..

# From here, get (or copy in at build time, via the COPY command) the script to
# check out the code.
# Give the script execute permissions
# RUN chmod +x svn_checkout_script.sh

# Specify the command to execute when the container starts
# CMD ["run_some_tests.sh"]
