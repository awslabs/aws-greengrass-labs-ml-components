import requests
from pathlib import Path


def download(url, destination: Path):
    print("Downloading the content from URL %s to the file %s", url, destination.name)
    download_response = _get_download_response(url)
    with open(destination, "wb") as file:
        file.write(download_response.content)


def _get_download_response(url) -> requests.Response:
    try:
        download_response = requests.get(url, stream=True, timeout=30)
        if download_response.status_code != 200:
            download_response.raise_for_status()
    except Exception:
        print("Failed to download the file from %s", url)
        raise
    return download_response


model_zip_name = "TensorFlowLite-Mobilenet.zip"
component_name = "variant.TensorFlowLite.ImageClassification.ModelStore"
download_url = f"https://github.com/awslabs/aws-greengrass-labs-ml-components/releases/download/1.0.0/{model_zip_name}"
gg_artifacts_dir = Path("").joinpath("greengrass-build", "artifacts", component_name)
gg_artifact_version_dir = list(gg_artifacts_dir.iterdir())[0]
destination = gg_artifact_version_dir.joinpath(model_zip_name)
download(download_url, destination)
