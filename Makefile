.PHONY: check
check:
	pre-commit run --all-files

.PHONY: checkupdate
checkupdate:
	pre-commit autoupdate
