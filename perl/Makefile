SHELL := bash

ROOT_PERL := $(shell pwd)

ZILD := \
    cpan \
    cpanshell \
    dist \
    distdir \
    distshell \
    disttest \
    install \
    release \
    update \

test ?= test/
v ?= -v

export RELEASE_BRANCH := main

export PATH := $(ROOT_PERL)/bin:$(PATH)

export LINGY_EXEC := $(ROOT_PERL)/bin/_lingy.pl

CLOJURE_REPO := https://raw.githubusercontent.com/clojure/clojure
CLOJURE_TAG := clojure-1.11.1
CLOJURE_SOURCE_DIR := $(CLOJURE_REPO)/$(CLOJURE_TAG)/src/clj
CLOJURE_CORE := clojure/core.clj
CLOJURE_CORE_SOURCE := $(CLOJURE_SOURCE_DIR)/$(CLOJURE_CORE)
TMP_CLOJURE_CORE := /tmp/$(CLOJURE_CORE)
LINGY_CLOJURE_CORE := lib/Lingy/core.clj

DEPS := \
    $(LINGY_CLOJURE_CORE)

.DELETE_ON_ERROR:

#------------------------------------------------------------------------------
default:

build: $(DEPS)

.PHONY: test
test: $(DEPS)
	prove -l $v $(test)

$(ZILD): $(DEPS)
	zild $@

clean:
	zild $@
	rm -f $(TMP_CLOJURE_CORE)

$(LINGY_CLOJURE_CORE): $(TMP_CLOJURE_CORE)
	perl tool/compile-clojure-core $< $(CLOJURE_CORE_SOURCE) > $@

$(TMP_CLOJURE_CORE):
	mkdir -p $(dir $@)
	curl -s $(CLOJURE_CORE_SOURCE) > $@
