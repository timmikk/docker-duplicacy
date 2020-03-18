# Copyright (c) 2019-2020 Eric D. Hough <eric@tubepress.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

FROM alpine:latest

RUN ARCHITECTURE=linux_x64                                                                    && \
    SHA256_DUPLICACY=162ecb3ea14ee28b2dccb3342f0446eab3bb0154cc7cadfb794551e81eb56cda         && \
    SHA256_DUPLICACY_WEB=9381581171503788a9c31c60ea672bf0a0f3fc7d7537f83c24b318fef009b87f     && \
    VERSION_DUPLICACY=2.4.0                                                                   && \
    VERSION_DUPLICACY_WEB=1.2.1                                                               && \
                                                                                                 \
    # ------------------------------------------------------------------------------------------
                                                                                                 \
    _URL_DUPLICACY="$(                                                                           \
      printf https://github.com/gilbertchen/duplicacy/releases/download/v%s/duplicacy_%s_%s      \
      $VERSION_DUPLICACY $ARCHITECTURE $VERSION_DUPLICACY                                        \
    )"                                                                                        && \
    _URL_DUPLICACY_WEB="$(                                                                       \
      printf https://acrosync.com/duplicacy-web/duplicacy_web_%s_%s                              \
      $ARCHITECTURE $VERSION_DUPLICACY_WEB                                                       \
    )"                                                                                        && \
    _BIN_DUPLICACY=/usr/local/bin/duplicacy                                                   && \
    _BIN_DUPLICACY_WEB=/usr/local/bin/duplicacy_web                                           && \
    _DIR_WEB=~/.duplicacy-web                                                                 && \
    _DIR_CONF=/config                                                                         && \
    _DIR_CACHE=/var/cache/duplicacy                                                           && \
                                                                                                 
    # add a few packages:
    #  * ca-certificates - so Duplicacy doesn't complain about HTTPS
    #  * tzdata          - so users can set timezone via TZ environment variable
    apk update                                                                                && \
    apk add --no-cache ca-certificates tzdata                                                 && \
                                                                                                 
    # download, check, and install duplicacy
    wget -O $_BIN_DUPLICACY "$_URL_DUPLICACY"                                                 && \
    echo "${SHA256_DUPLICACY}  ${_BIN_DUPLICACY}" | sha256sum -s -c -                         && \
    chmod +x $_BIN_DUPLICACY                                                                  && \
                                                                                                 
    # downlooad, check, and install the web UI
    wget -O $_BIN_DUPLICACY_WEB "$_URL_DUPLICACY_WEB"                                         && \
    echo "${SHA256_DUPLICACY_WEB}  ${_BIN_DUPLICACY_WEB}" | sha256sum -s -c -                 && \
    chmod +x $_BIN_DUPLICACY_WEB                                                              && \
                                                                                                 
    ln -s ${_DIR_CONF}  ${_DIR_WEB}                                                           && \

    # create some dirs
    mkdir -p                                                                                     \
      ${_DIR_CACHE}/repositories                                                                 \
      ${_DIR_CACHE}/stats                                                                        \
      ${_DIR_CONF}/bin                                                                           \
      /var/lib/dbus                                                                           && \
                                                                                                 
    # duplicacy_web expects to find the CLI binary in a certain location
    # https://forum.duplicacy.com/t/run-web-ui-in-a-docker-container/1505/2
    cp $_BIN_DUPLICACY ${_DIR_WEB}/bin/duplicacy_${ARCHITECTURE}_${VERSION_DUPLICACY}      && \
                                                                                                 
    # redirect the log to stdout
    ln -s /dev/stdout /var/log/duplicacy_web.log                                              && \
                                                                                                 
    # stage the rest of the web directory
    ln -s ${_DIR_CONF}/filters        ${_DIR_WEB}/filters                                     && \
    ln -s ${_DIR_CACHE}/stats         ${_DIR_WEB}/stats

EXPOSE 3875
CMD [ "/usr/local/bin/entrypoint.sh" ]

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

VOLUME ["/var/cache/duplicacy", "/config"]
