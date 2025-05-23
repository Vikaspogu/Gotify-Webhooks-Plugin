BUILDDIR=./build
GOTIFY_VERSION=master
PLUGIN_NAME=gotify-webhooks
GO_VERSION=`cat $(BUILDDIR)/gotify-server-go-version`
DOCKER_BUILD_IMAGE=gotify/build
DOCKER_WORKDIR=/proj
DOCKER_RUN=podman run --rm -v "$$PWD/.:${DOCKER_WORKDIR}" -v "`go env GOPATH`/pkg/mod/.:/go/pkg/mod" -w ${DOCKER_WORKDIR}
DOCKER_GO_BUILD=go build -mod=readonly -a -installsuffix cgo -ldflags "$$LD_FLAGS" -buildmode=plugin 

download-tools:
	go get -u github.com/gotify/plugin-api/cmd/gomod-cap

create-build-dir:
	mkdir -p ${BUILDDIR} || true

update-go-mod: create-build-dir
	wget -O ${BUILDDIR}/gotify-server.mod https://raw.githubusercontent.com/gotify/server/${GOTIFY_VERSION}/go.mod
	go run github.com/gotify/plugin-api/cmd/gomod-cap -from ${BUILDDIR}/gotify-server.mod -to go.mod
	rm ${BUILDDIR}/gotify-server.mod || true
	go mod tidy

get-gotify-server-go-version: create-build-dir
	rm ${BUILDDIR}/gotify-server-go-version || true
	wget -O ${BUILDDIR}/gotify-server-go-version https://raw.githubusercontent.com/gotify/server/${GOTIFY_VERSION}/GO_VERSION

build-linux-amd64: get-gotify-server-go-version update-go-mod
	${DOCKER_RUN} ${DOCKER_BUILD_IMAGE}:$(GO_VERSION)-linux-amd64 ${DOCKER_GO_BUILD} -o ${BUILDDIR}/${PLUGIN_NAME}.so ${DOCKER_WORKDIR}

build: build-linux-amd64

.PHONY: build