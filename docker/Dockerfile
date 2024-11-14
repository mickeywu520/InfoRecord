# Download base image ubuntu 20.04
FROM ubuntu:20.04
MAINTAINER Mickey

#USER root

#ARG userid
#ARG groupid
#ARG username
ARG DEBIAN_FRONTEND=noninteractive
#ENV username px30

ENV MYNAME px30
ENV MYPASS px30
ENV HOME /home/$MYNAME

# install source list
RUN apt-get update && apt-get install -y sudo git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache libgl1-mesa-dev libxml2-utils xsltproc unzip python bc liblz4-tool libncurses5

RUN curl -o jdk8.tgz https://android.googlesource.com/platform/prebuilts/jdk/jdk8/+archive/master.tar.gz \
 && tar -zxf jdk8.tgz linux-x86 \
 && mkdir /usr/lib/jvm \
 && mv linux-x86 /usr/lib/jvm/java-8-openjdk-amd64 \
 && rm -rf jdk8.tgz
 
RUN curl -o /usr/local/bin/repo https://storage.googleapis.com/git-repo-downloads/repo \
# && echo "d06f33115aea44e583c8669375b35aad397176a411de3461897444d247b6c220  /usr/local/bin/repo" | sha256sum --strict -c - \
 && chmod a+x /usr/local/bin/repo
 
#RUN groupadd -g $groupid $username \
# && useradd -m -u $userid -g $groupid $username \
# && echo $username >/root/username \
# && echo "export USER="$username >>/home/$username/.gitconfig
 
#COPY gitconfig /home/$username/.gitconfig
#RUN chown $userid:$groupid /home/$username/.gitconfig
#ENV HOME=/home/$username
#ENV USER=$username

#
# user account
#

RUN echo "User: android Pass: $MYPASS" && \
 useradd --create-home -d $HOME --shell /bin/bash --user-group --groups adm,sudo $MYNAME && \
 echo "$MYNAME:$MYPASS" | chpasswd && \
 echo "${MYNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${MYNAME} && \
 chmod 0440 /etc/sudoers.d/${USER}


USER $MYNAME

#ENTRYPOINT chroot --userspec=$(cat /root/username):$(cat /root/username) / /bin/bash -i
