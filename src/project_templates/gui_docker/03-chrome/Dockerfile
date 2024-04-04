FROM ubuntu:24.04
RUN apt update && apt install -y wget
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN dpkg -i google-chrome-stable_current_amd64.deb || true
RUN apt -f -y install

RUN usermod -md /home/igncp -l igncp ubuntu

USER igncp
WORKDIR /home/igncp

CMD ["bash", "-c", "google-chrome-stable --no-sandbox"]
