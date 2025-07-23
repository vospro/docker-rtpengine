from_tag=mr13.3.1.4

build:
	docker build -t rtpengine:$(from_tag) --progress=plain \
	--build-arg FROM_TAG=$(from_tag) \
	.
