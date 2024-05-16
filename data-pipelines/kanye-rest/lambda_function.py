import json
import requests
import logging
logger = logging.getLogger()


def get_and_print_api_data(url):
    try:
        response = requests.get(url)

        response.raise_for_status()

        logger.info(f"Request successful")

        return response.json()

    except requests.exceptions.RequestException as e:
        logger.exception("Error fetching the data:", e)


def lambda_handler(event, context):
    logger.info("Inside the handler function")
    logger.info(event)
    api_url = "https://api.kanye.rest/"
    data = get_and_print_api_data(api_url)
    return {"statusCode": 200, "body": json.dumps(data, indent=4)}


if __name__ == "__main__":
    api_url = "https://api.kanye.rest/"
    print(get_and_print_api_data(api_url))
