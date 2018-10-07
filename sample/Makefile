artifact = application.zip

.PHONY: build
build:
	cd application &&  zip -r ../${artifact} .

.PHONY: upload_to_s3
upload_to_s3:
	aws s3 cp ${artifact} s3://${S3_BUCKET_NAME}/${artifact}