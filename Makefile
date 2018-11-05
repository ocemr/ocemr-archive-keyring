GPG_OPTIONS := --no-options --no-default-keyring --no-auto-check-trustdb --trustdb-name ./trustdb.gpg

build: verify-indices verify-results

verify-indices: keyrings/team-members.gpg
	gpg ${GPG_OPTIONS} \
		--keyring keyrings/team-members.gpg \
		--verify team-members/index.gpg team-members/index

verify-results: keyrings/team-members.gpg
	gpg ${GPG_OPTIONS} \
		--keyring keyrings/team-members.gpg --verify \
		keyrings/team-members.gpg.asc \
		keyrings/team-members.gpg

keyrings/team-members.gpg: team-members/index
	jetring-build -I $@ team-members
	gpg ${GPG_OPTIONS} --no-keyring --import-options import-export --import < $@ > $@.tmp
	mv -f $@.tmp $@

clean:
	rm -f keyrings/team-members.gpg \
		keyrings/team-members.gpg~ \
		keyrings/team-members.gpg.lastchangeset
	rm -rf trustdb.gpg
	rm -f keyrings/*.cache

install: build
	install -d $(DESTDIR)/usr/share/keyrings/
	cp keyrings/team-members.gpg $(DESTDIR)/usr/share/keyrings/ocemr-archive-keyring.gpg
	install -d $(DESTDIR)/etc/apt/trusted.gpg.d/
	ln  -s /usr/share/keyrings/ocemr-archive-keyring.gpg $(DESTDIR)/etc/apt/trusted.gpg.d/

.PHONY: verify-indices verify-results clean build install
