SRC_DIR			= $(shell pwd)
BRANCH			= $(shell git rev-parse --abbrev-ref HEAD)
EXTENSION		= lostgis
EXTVERSION		= $(shell \
					grep default_version $(EXTENSION).control | \
					sed -e "s/default_version[[:space:]]*=[[:space:]]*'\([^']*\)'/\1/")
DATA 			= $(wildcard updates/*--*.sql) _build/$(EXTENSION)--$(EXTVERSION).sql
EXTRA_CLEAN 	= $(wildcard updates/*--*.sql) _build/$(EXTENSION)--$(EXTVERSION).sql
DOCS			= $(wildcard doc/*.md)

PG_CONFIG		= pg_config
PGXS 			= $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

all: _build/$(EXTENSION)--$(EXTVERSION).sql

_build/$(EXTENSION)--$(EXTVERSION).sql: $(sort $(wildcard sql/types/*.sql)) $(sort $(wildcard sql/functions/*.sql))
	mkdir -p _build
	cat $^ > $@

pack:
	git archive --format zip \
		--prefix=$(EXTENSION)-$(EXTVERSION)/ \
		--output $(EXTENSION)-$(EXTVERSION).zip \
		$(BRANCH)

checkzip:
	pgxn check ./$(EXTENSION)-$(EXTVERSION).zip
