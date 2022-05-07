# shellcheck shell=bash

if [ -z "$BASALT_PACKAGE_DIR" ]; then
	printf "%s\n" "Fatal: source_packages.sh: \$BASALT_PACKAGE_DIR is empty, but must exist"
	exit 1
fi

if [ -f "$BASALT_PACKAGE_DIR/.basalt/generated/source_packages.sh" ]; then
	source "$BASALT_PACKAGE_DIR/.basalt/generated/source_packages.sh"
fi

if [ -f "$BASALT_PACKAGE_DIR/.basalt/generated/source_setoptions.sh" ]; then
	source "$BASALT_PACKAGE_DIR/.basalt/generated/source_setoptions.sh"
fi

if [ -f "$BASALT_PACKAGE_DIR/.basalt/generated/source_shoptoptions.sh" ]; then
	source "$BASALT_PACKAGE_DIR/.basalt/generated/source_shoptoptions.sh"
fi
