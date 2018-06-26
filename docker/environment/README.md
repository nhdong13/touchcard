# touchcard-environment

Docker image that constitutes our base environment for testing & execution: Ruby, Node, Chrome, Chromedriver

We make an effort to cache our gems here to avoid repeatedly installing them during CI and environment setup.
When a new gem gets added to the project, every run of our CI will also install that gem (unless caching has been fixed).
Instead of caching in the CI, which can be a bit finicky, especially with local execution, we can update this Docker file
whenever a new gem gets added to the project. This isn't a requirement every time, but it should speed things up after
a number of gem changes have been made.


## build

First - be sure to change directory to project root so docker command has access to Gemfile* & package.json / yarn.lock

    docker build -t registry.gitlab.com/touchcard/api/environment -f docker/environment/Dockerfile .
    

## make sure you're logged in

    docker login registry.gitlab.com

## push 

    docker push registry.gitlab.com/touchcard/api/environment
    

## debugging inside of container:

    docker run -it registry.gitlab.com/touchcard/api/environment:latest /bin/bash


## Executing gitlab runner locally

    gitlab-runner exec docker rspec 
    
# May need to include shared memory size option 
 
    gitlab-runner exec docker --docker-shm-size=2000000000 rspec
     