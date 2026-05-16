FROM golang:alpine AS builder
WORKDIR /work
COPY . .
RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build \
  -tags netgo \
  -ldflags="-extldflags=-static" \
  -o {{project-name}} \
  && chmod +x {{project-name}}

FROM scratch
WORKDIR /work
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /work/{{project-name}} /bin/{{project-name}}
CMD [ "{{project-name}}" ]
