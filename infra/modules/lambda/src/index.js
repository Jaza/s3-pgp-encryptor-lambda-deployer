import { config, logger, pgpEncryptS3Object } from "s3-pgp-encryptor-lib";

export const handler = async (event) => {
  if (!event.Records) {
    throw new Error("Missing event.Records");
  }

  const records = event.Records;

  if (!records[0]) {
    throw new Error("Missing event.Records[0]");
  }

  const firstRecord = event.Records[0];

  if (!firstRecord.s3) {
    throw new Error("Missing event.Records[0].s3");
  }

  const s3 = firstRecord.s3;

  if (!s3.bucket) {
    throw new Error("Missing event.Records[0].s3.bucket");
  }

  const bucket = s3.bucket;

  if (!s3.object) {
    throw new Error("Missing event.Records[0].s3.object");
  }

  const obj = s3.object;

  await pgpEncryptS3Object(firstRecord.awsRegion, bucket.name, obj.key, config, logger);
};
