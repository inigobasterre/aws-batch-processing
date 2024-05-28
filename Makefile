set-aws-env :
					aws-sso-util login && source .env
lambda-layer :
					python3.9 -m venv create_layer && source create_layer/bin/activate && pip install -r data-pipelines/kanye-rest/requirements.txt && mkdir requests-layer && cp -r create_layer requests-layer/python