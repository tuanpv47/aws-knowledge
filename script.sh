region=
aws_account_id=
ecr_repo=
app_name=
env=
PORT=80
CONTAINER_NAMES=`docker ps -aqf "name=<app_name>$" --format "{{.Names}}"`
echo $CONTAINER_NAMES
# aws configure set aws_access_key_id $aws_access_key_id
# aws configure set aws_secret_access_key $aws_secret_access_key
# aws configure set default.region $region
aws ecr get-login-password --region $region | docker login --username AWS --password-stdin $aws_account_id.dkr.ecr.$region.amazonaws.com
ECR_IMAGE="$aws_account_id.dkr.ecr.$region.amazonaws.com/$ecr_repo"
docker pull $ECR_IMAGE:latest
if [ -n "${CONTAINER_NAMES}" ]
then
    if [ $CONTAINER_NAMES == $app_name ]; then
        echo "Remove and start container - [START]";
        DOCKER_STOP=`docker stop $app_name`
        DOCKER_RM=`docker rm $app_name`
        DOCKER_RUN=`docker run -it -d --name $app_name -e PORT=$PORT -e NODE_ENV=$env --restart=always -p $PORT:$PORT $ECR_IMAGE:latest`
        DOCKER_PRUNE=`docker image prune -a --force`
        echo "Remove and start container - [END]";
    fi
else
    echo "Start container - [START]";
    DOCKER_RUN=`docker run -it -d --name $app_name -e PORT=$PORT -e NODE_ENV=$env --restart=always -p $PORT:$PORT $ECR_IMAGE:latest`
    DOCKER_PRUNE=`docker image prune -a --force`
    echo "Start container - [END]";
fi
