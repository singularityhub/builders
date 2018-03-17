# The Builders

Hi friends! This is the future home of the Singularity Builders, served 
faithfully by the [Singularity Global Client](https://singularityhub.github.io/sregistry-cli)
so you can run your own remote builds on different clouds of your choosing. This
code base is under development, so expect to see more soon. It works as follows:

 1. This is the library of build configurations, organized in [_cloud](_cloud) by environment, and operating system. 
 2. When you launch a builder with the `sregistry` client, you have different ways to select build configurations from here.
 3. When your build launches, it uses the configuration settings and entry point running script you have selected!
 4. The build is run, and the result uploaded to Storage, again per the builder bundle.


## General Overview

>> Wait, what is a builder bundle?

Generally, a **builder bundle** is a folder that has a particular build configuration. 
Specifically, it is a folder path in this repository that has 
only two requirements - 1) a `run.sh` script that should install Singularity, 
grab metadata for the build, run the build, and finish it up, 
and 2) a configuration file that is provided for the user to customize and launch the
build. This means that any file that ends in `json` that you find in the tree under
[_cloud](_cloud) is a configuration that a user can select and customize to build a
container. For example, here is how we might organize the bundle for an ubuntu base on Google
Compute.

```
├── google
│   └── compute
│       └── ubuntu
│           ├── securebuild-2.4.3.json
│           └── run.sh
```

The configuration file [securebuild-2.4.3.json](_cloud/google/compute/ubuntu/securebuild-2.4.3.json) itself has a header with variables, and both are served programatically:

 - [the builder library](https://singularityhub.github.io/builders/configs.json) of configurations is a starting entrypoint for the `sregistry` tool to search, and return custom configurations.
 - Each [specific config file](https://singularityhub.github.io/builders/cloud/google/compute/ubuntu/securebuild-2.4.3.json) can then be discovered and used by the `sregistry` client.

The client knows how to select reasonable defaults for builders, so for most users, they won't need to
think about these builder bundles. For the more advanced user that wants to find tune his build, however,
he will finally be able to do so!

>> How are the builder bundles organized?

The bundles are organized logically for the user based on build environment, operating systems, 
and then any more detail that is necessary. For example, the bundle linked above is logically for an ubuntu
host, and builds a "secure build" environment container with Singularity 2.4.3. 
The folder hierarchy can look however is logical, with no limit on the number of different configurations that
might even share some of the same running dependencies (files in the folder).

>> How is a builder bundle registered?

To appear in the API to be available for `sregistry`, the config file simply needs to be physically in the folder
hierarchy. We will also be adding tests (checks) to run for the config files to ensure that formatting and other 
details are OK.

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
[static API](https://singularityhub.github.io/builders/configs.json) that serves the 
config.json that is "default" for each builder bundle. This means that
the client `sregistry` can query this static endpoint to always get a set of templates that are intended
for each bundle.

>> What's in a bundle?

Each bundle (as of now in development) should have the following:

 - *.json: a configuration file (typically json) with front end (yaml) matter that is used to register the builder bundle with the API, and define custom variables. When the API renders the registered builders for the `sregistry` client, the client uses this information to ensure that the build is set up correctly. The user chooses from these configurations, and then can further customize them for his needs.
 - run.sh: The primary (default) runscript for the build. This is actually a variable, and doesn't necessarily need to be called run.sh, or even have the requirement of one script.

**under development** and everything subject to change!  - @vsoch
