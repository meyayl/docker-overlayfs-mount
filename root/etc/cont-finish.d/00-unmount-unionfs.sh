#!/usr/bin/with-contenv sh
echo "$( date +'%Y/%m/%d %H:%M:%S' ) Unmounting ${WORK_DIR} and ${MERGE_DIR}"

for fuse_mount in "$MERGE_DIR $WORK_DIR"; do
  fusermount3 -uz ${fuse_mount}
if [[ $? -eq 0 ]]; then
  echo "$( date +'%Y/%m/%d %H:%M:%S' ) INFO: ${fuse_mount} unmounted wihout error."
else
  echo "$( date +'%Y/%m/%d %H:%M:%S' ) ERROR: ${fuse_mount} unmounted with errors, Please check your host path for 'Transport endpoint is not connected' errors."
fi

