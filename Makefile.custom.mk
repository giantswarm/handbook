# This command enables you to quickly check which links to the intranet are dead. \
Cookie has to be valid to get access through our oauth proxy.
check-intranet:
	find . -name \*.md -print0 | xargs -0 -n1 grep -Po "\(\Khttps?://intranet[^\s\)]+" | xargs -I@ -n1 sh -c 'echo @; curl -L -s -o /dev/null -w "%{http_code}\n" -H "Cookie: $(COOKIE)" -X HEAD @'
