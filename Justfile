set dotenv-load := true

export AWS_PROFILE := env_var_or_default("AWS_PROFILE", "infra_tools_external")

deploy lang bucket="mr-staging.openclassrooms.tech": (generate lang bucket)
    aws s3 sync public/ s3://{{ bucket }} --delete

generate lang bucket="mr-staging.openclassrooms.tech":
    echo "baseURL: https://{{ bucket }}" > config/production/config.yaml
    echo "defaultContentLanguage: {{ lang }}" >> config/production/config.yaml
    echo "defaultContentLanguageInSubdir: true" >> config/production/config.yaml

    yarn install

    aws s3 sync s3://rapportdemission.openclassrooms.com/library ./static/library
    aws s3 sync s3://rapportdemission.openclassrooms.com/SignatureFR_MissionReport_V4.png ./static/SignatureFR_MissionReport_V4.png
    aws s3 sync s3://rapportdemission.openclassrooms.com/SignatureEN_MissionReport_V4.png ./static/SignatureEN_MissionReport_V4.png
    yarn osuny build

backup bucket="mr-staging.openclassrooms.tech" output="output":
    mkdir -p {{ output }}
    aws s3 sync s3://{{ bucket }} {{ output }}

[private]
update:
    git pull
    git submodule update --init --recursive
