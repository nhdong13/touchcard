# touchcard-environment

Docker image that constitutes our base environment for testing & execution: Ruby, Node, Chrome, Chromedriver

##  build

    docker build -t registry.gitlab.com/touchcard/environment .

## push 

    docker push registry.gitlab.com/touchcard/environment
    

Derived from nbulaj/ruby-chromedriver:
https://github.com/nbulaj/ruby-chromedriver
https://hub.docker.com/r/nbulai/ruby-chromedriver/


