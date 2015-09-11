GITCOMMIT := $(shell git rev-parse --short HEAD 2> /dev/null)
MAIN_PACKAGE=github.com/davidkbainbridge/bp2-consumer
ALL_PACKAGES=\
	github.com/davidkbainbridge/bp2-consumer \
	github.com/davidkbainbridge/bp2-consumer/consumer \
	github.com/davidkbainbridge/bp2-consumer/hooks
SERVICE=bp2-consumer
DOCKER_REPO=davidkbainbridge
TD := $(shell mktemp -d /tmp/build.XXXXX)

coverage:
	@echo "Not Yet Implemented"
	@echo "This rule produces the test coverage information for the app."

test:
	GOPATH=$(abspath $(dir $(lastword $(MAKEFILE_LIST)))) \
	go vet $(ALL_PACKAGES)
	GOPATH=$(abspath $(dir $(lastword $(MAKEFILE_LIST)))) \
	go test -v -cover $(ALL_PACKAGES)

prepare: prepare-venv

prepare-venv:
	rm -rf src pkg bin
	mkdir -p src/$(dir $(MAIN_PACKAGE))
	(cd src/$(dir $(MAIN_PACKAGE)); ln -s ../../.. $(notdir $(MAIN_PACKAGE)))
	GOPATH=$(abspath $(dir $(lastword $(MAKEFILE_LIST))))	\
	go get -d .

build:
	GOPATH=$(abspath $(dir $(lastword $(MAKEFILE_LIST)))) \
	go build -v -o $(SERVICE) $(MAIN_PACKAGE)

cross-build-hook-exe:
	-mkdir -p $(TD)
	(\
		cd $(TD); \
		git clone http://github.com/davidkbainbridge/bp2-hook-to-rest; \
		cd bp2-hook-to-rest; \
		make linux; \
	)
	mkdir -p bp2/hooks
	cp $(TD)/bp2-hook-to-rest/hook-to-rest bp2/hooks
	-rm -rf $(TD)

cross-build:
	GOPATH=$(abspath $(dir $(lastword $(MAKEFILE_LIST))))	\
	CGO_ENABLED=0 \
	GOOS=linux \
	GOARCH=amd64 \
	go build -v -o $(SERVICE)-docker $(MAIN_PACKAGE)

clean:
	rm -rf src pkg bin $(SERVICE) $(SERVICE)-docker bp2/hooks

enter:
	@echo "Unable to access container shell, please use 'docker exec' command."

image: cross-build cross-build-hook-exe
	docker build -t $(DOCKER_REPO)/$(SERVICE):$(GITCOMMIT) .

start:
	docker run -tid --name=$(SERVICE) $(DOCKER_REPO)/$(SERVICE):$(GITCOMMIT)

logs:
	docker logs $(SERVICE)

stop:
	docker stop $(SERVICE)
	docker rm $(SERVICE)

dconfigure:
	@echo "Not Yet Implemented"
	@echo "This rule is called by TeamCity to setup the docker image required for the tests."

dutest:
	@echo "Not Yet Implemented"
	@echo "This rule is called by TeamCity to execute the unit-test."

ditest:
	@echo "Not Yet Implemented"
	@echo "This rule is called by TeamCity to execute the integration-test."
