SRC_DIR			= $(shell dirname `pwd`)
EXTENSION		= $(shell cat ../Makefile|egrep '^EXTENSION'|awk '{print $$3}')


image:
	docker build --tag=postgis_dev:9.6 .

run:
	docker run \
		--name postgis_$(EXTENSION) \
		--volume=${SRC_DIR}:/usr/src/ \
		--workdir=/usr/src/ \
		-d postgis_dev:9.6

test:
	docker exec \
		postgis_$(EXTENSION) \
		bash -c "make install;\
			psql -U postgres -c 'create extension if not exists pgtap';\
			pg_prove -U postgres -ovf ./test/*.sql"

test_update:
	docker exec \
		postgis_$(EXTENSION) \
		bash -c "\
			make pack; \
			make uninstall; \
			psql -U postgres -c \"drop extension lostgis\";\
			pgxn install 'lostgis=1.0.0'; \
			psql -U postgres -c 'create extension if not exists lostgis';\
			pgxn install ./lostgis-1.0.1.zip; \
			psql -U postgres -c 'alter extension lostgis update';"

shell:
	docker exec -ti \
		postgis_$(EXTENSION) \
		bash
