# docker-run START

cat >> ~/.shell_aliases <<"EOF"
# AWSDocker -v "$(pwd):/var/foo"
AWSDocker() {
  docker run --rm -it --entrypoint '' \
    -v "$HOME"/.aws/credentials.json:/root/.aws/credentials.json \
    $@ \
    amazon/aws-cli /bin/bash
}
EOF

# docker-run END
