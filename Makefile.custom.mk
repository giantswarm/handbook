# By default, RFCs are read from your computer, assuming the repo (https://github.com/giantswarm/rfc)
# is cloned on the same directory level as the handbook.
RFCS_DIR ?= ../rfc

# This command enables you to quickly check which links to the intranet are dead. \
Cookie has to be valid to get access through our oauth proxy.
check-intranet:
	find . -name \*.md -print0 | xargs -0 -n1 grep -Po "\(\Khttps?://intranet[^\s\)]+" | xargs -I@ -n1 sh -c 'echo @; curl -L -s -o /dev/null -w "%{http_code}\n" -H "Cookie: $(COOKIE)" @'

# Aggregate RFCs from other repos
rfcs:
	docker run --rm \
		--volume="$$(realpath "$(RFCS_DIR)"):/rfc:ro" \
		--volume="${PWD}/scripts:/scripts:ro" \
		--volume="${PWD}/content/docs/rfcs:/content/docs/rfcs:rw" \
		quay.io/giantswarm/docs-scriptrunner:latest \
		/scripts/aggregate-rfcs.py /rfc /content/docs/rfcs
