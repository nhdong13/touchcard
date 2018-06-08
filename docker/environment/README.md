# touchcard-environment

Docker image that constitutes our base environment for testing & execution: Ruby, Node, Chrome, Chromedriver

## build

First - be sure to change directory to project root so docker command has access to Gemfile* & package.json / yarn.lock

    docker build -t registry.gitlab.com/touchcard/api/environment -f docker/environment/Dockerfile .
    

## make sure you're logged in

    docker login registry.gitlab.com

## push 

    docker push registry.gitlab.com/touchcard/api/environment
    

## debugging inside of container:

    docker run -it registry.gitlab.com/touchcard/api/environment:latest /bin/bash
