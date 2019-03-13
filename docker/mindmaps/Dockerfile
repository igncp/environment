FROM node:10.15.3-alpine

RUN apk add git \
  && git clone https://github.com/drichard/mindmaps.git --depth 1 \
  && cd mindmaps \
  && npm i \
  && npm run build

WORKDIR /mindmaps

CMD ["./node_modules/.bin/http-server", "-s", "-p", "5000", "dist"]
