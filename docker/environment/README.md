# touchcard-environment

Docker image that constitutes our base environment for testing & execution: Ruby, Node, Chrome, Chromedriver

## build

    docker build -t registry.gitlab.com/touchcard/api/environment .

## make sure you're logged in

    docker login registry.gitlab.com

## push 

    docker push registry.gitlab.com/touchcard/api/environment
    

