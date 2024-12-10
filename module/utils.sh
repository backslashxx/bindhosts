#!/bin/sh
PATH=$PATH:/data/adb/ap/bin:/data/adb/magisk:/data/adb/ksu/bin
## taken from susfs
## susfs_clone_perm <file/or/dir/perm/to/be/changed> <file/or/dir/to/clone/from>
susfs_clone_perm() {
	TO=$1
	FROM=$2
	if [ -z "${TO}" -o -z "${FROM}" ]; then
		return
	fi
	CLONED_PERM_STRING=$(busybox stat -c "%a %U %G %C" ${FROM})
	set ${CLONED_PERM_STRING}
	busybox chmod $1 ${TO}
	busybox chown $2:$3 ${TO}
	busybox chcon $4 ${TO}
}

