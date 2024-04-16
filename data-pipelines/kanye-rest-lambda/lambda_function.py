import requests
import json


def get_and_print_api_data(url):
    try:
        response = requests.get(url)

        response.raise_for_status()

        data = response.json()

        print(json.dumps(data, indent=4))
    except requests.exceptions.RequestException as e:
        print("Error fetching data:", e)


def lambda_handler(event, context):
    # TODO implement
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }


if __name__ == "__main__":
    api_url = "https://api.kanye.rest/"
    get_and_print_api_data(api_url)
