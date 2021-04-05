#!/bin/bash

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)

# Get volumeId
VOLUME_ID=$(aws ec2 describe-volumes \
  --region "$REGION" \
  --filters "Name=tag:HandlerId,Values=${VOLUME_HANDLER_ID}" \
  --query Volumes[].VolumeId \
  --output text)

# attach volume to instance
if [[ $VOLUME_ID == vol-* ]]; then
  echo "Volume Handler ID detected. Trying to attach the volume"
  aws ec2 attach-volume \
    --region "$REGION" \
    --device "${DEVICE_ID}" \
    --instance-id "$INSTANCE_ID" \
    --volume-id "$VOLUME_ID"
else
  echo "VolumeId not found"
fi

DATA_STATE="unknown"
until [ "$DATA_STATE" == "attached" ]; do
  DATA_STATE=$(aws ec2 describe-volumes \
    --region "$REGION" \
    --filters \
    Name=attachment.instance-id,Values="$INSTANCE_ID" \
    Name=attachment.device,Values="${DEVICE_ID}" \
    --query Volumes[].Attachments[].State \
    --output text)

  sleep 5
done

# Format ${DEVICE_ID} if it does not contain a partition yet
if [ "$(file -b -s ${DEVICE_ID})" == "data" ]; then
  echo "No partition. Device will be formatted in ext4."
  mkfs -t ext4 "${DEVICE_ID}"
fi

mkdir -p "${MOUNT_POINT}"
mount "${DEVICE_ID}" "${MOUNT_POINT}"

# Persist the volume in /etc/fstab so it gets mounted again
echo '${DEVICE_ID} ${MOUNT_POINT} ext4 defaults,nofail 0 2' | tee -a /etc/fstab
