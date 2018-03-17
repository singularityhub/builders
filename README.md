# The Builders

Hi friends! This is the future home of the Singularity Builders, served 
faithfully by the [Singularity Global Client](https://singularityhub.github.io/sregistry-cli)
so you can run your own remote builds on different clouds of your choosing. This
code base is under development, so expect to see more soon. It works as follows:

 1. When you launch a builder with the client, this repository is the default base
 2. The builder start script clones this repository with a builder bundle of choice. 
 3. The build is run, and the result uploaded to Storage


## General Overview

>> Wait, what is a builder bundle?

Generally, it's a folder that has a particular build configuration. 
Specifically, a **builder bundle** is a folder path in this repository that has 
only three requirements - a `run.sh` script that should install Singularity, 
grab metadata for the build, run the build, and finish it up, 
a configuration file that is provided for the user to customize and launch the
build, and a yaml file to register any custom variables and defaults that are needed
(TODO: this might be possible to capture in the config.json, but we need this
arguably to render the static API and register custom config.json files). 
The bundles are organized logically for the user based on build environment, operating systems, 
and then any more detail that is necessary. The folder hierarchy can look however is logical, with no limit on
organization, as any folder with a .yaml file will be found and registered. 
For example, here is how we might organize the bundle for an ubuntu base on Google
Compute.

```
├── google
│   └── compute
│       └── ubuntu
│           ├── ubuntu.yaml
│           ├── config.json
│           └── run.sh
```

More detail will be written about these files soon! For most users, they won't need
to interact when them other than choosing a default for their platform.

>> Why are the builder bundles separate from the Singularity Builder executable?

In short, the builder bundles are community driven. This repository is going to rapidly change,
and have many contributions! This is a different pace than the core software  
([sregistry](https://singularityhub.github.io/sregistry-cli)) that should be
slow changing and reliable.


>> How do the Singularity Builder executable and the builder bundles work together?

The user (you maybe?) is going to be launching 
a build that looks something like the following:

```
sregistry build https://www.github.com/vsoch/hello-world config.json
```

Where the `config.json` is going to be a template generated automatically by 
[sregistry build](https://singularityhub.github.io/sregistry-cli), and then edited
by you to specify the parameters of your build. If you issue the command sitting inside your Github
repository local folder (in this case, in a folder called `hello-world`) then you don't need to include
the github URL, and can just include the configuration file. Then you can imagine keeping several configuration
files with your repository for building under different conditions:

```
sregistry build config-debian.json
sregistry build config-gpu.json
...
```

And yes! This also means that you can maintain your own builder bundles repository that works
with the software. We do hope you contribte here, but we understand if your institution does
not allow this.

>> What is in the configuration file?

This config.json file is going to have variables that point to this repository! Specifically,
it will provide the repository address, the builder bundle folder, the commit and branch, 
and other build time settings that you can adjust. There will be reasonable defaults set for most,
and so the general user will not need to edit the file. We will be discussing this workflow more
in detail.

## What is in each folder?
In the base here you will notice a file, [configs.json](configs.json). This renders into a
static API that serves the config.json that is "default" for each builder bundle. This means that
the client `sregistry` can query this static endpoint to always get a set of templates that are intended
for each bundle.

>> What's in a bundle?

Each bundle (as of now in development) should have the following:

 - *.yaml: the yaml files register the different config.json files, and define custom variables. When the API renders the registered builders for the `sregistry` client, the client uses this information to ensure that the build is set up correctly.
 - config.json: One or more configuration files registered in the config.json for the user to choose from. 
 - run.sh: The primary (default) runscript for the build. This is actually a variable, and doesn't necessarily need to be called run.sh, or even have the requirement of one script.

**under development** and everything subject to change!  - @vsoch


