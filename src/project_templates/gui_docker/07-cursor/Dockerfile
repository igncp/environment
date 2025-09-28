FROM ubuntu:24.04

RUN apt update
RUN apt install -y wget gedit
RUN cd /root
RUN wget https://downloads.cursor.com/production/b753cece5c67c47cb5637199a5a5de2b7100c18f/linux/x64/deb/amd64/deb/cursor_1.6.35_amd64.deb
RUN apt install -y ./cursor_1.6.35_amd64.deb
