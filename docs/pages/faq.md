---
layout: default
title: The Builder FAQ
pdf: true
permalink: /faq
toc: false
---

# Frequently Asked Questions

>> Wait, what is a builder bundle?

Generally, a **builder bundle** is a folder that has a particular build configuration. 
Specifically, it is a folder path in this repository that has 
only two requirements :

  1. a `run.sh` script that should install Singularity, grab metadata for the build, run the build, and finish it up, and   
  2. a configuration file that is provided for the user to customize and launch the build. 

What is this configuration file? It is any file that ends in `json` that you find in the tree under
[_cloud](https://github.com/singularityhub/builders/blob/master/_cloud). 
These are the configurations that are served programatically via the [static API](https://github.com/singularityhub/builders/configs.json) served by this repository, and from which a user can select.
For example, here is how we might organize the bundle for an ubuntu base on Google
Compute.

```
├── google
│   └── compute
│       └── ubuntu
│           ├── securebuild-2.4.3.json
│           └── run.sh
```

The configuration file [securebuild-2.4.3.json](https://github.com/singularityhub/builders/blob/master/_cloud/google/compute/ubuntu/securebuild-2.4.3.json) itself has a header with variables, and both are served programatically with
a [main builder library](https://singularityhub.github.io/builders/configs.json) that links to [custom configurations](https://singularityhub.github.io/builders/cloud/google/compute/ubuntu/securebuild-2.4.3.json). It is by way of the library that any configuration (json file) in the repository can be discovered and used by the `sregistry` client. For example,
if a user wants to see google-compute templates, he would do this:

```
export SREGISTRY_CLIENT=google-compute
$ sregistry build templates
1  /cloud/google/compute/ubuntu/securebuild-2.4.3.json
```

and then issue other commands to save a configuration, or use it directly from the API. Even this use
case is considered advanced, because each endpoint (e.g., Google Compute) sets reasonable defaults that
will work for the typical user. These builder bundles, and customizing them, are scoped for the more
advanced users. 

>> What is in the configuration file?

This config.json file has variables that configure the build on the platform selected,
and importantly, point to a builder bundle repository to clone at build time to get 
files that are needed. For example, it might provide the repository address, 
the builder bundle folder, the commit and branch, and other build time settings that you can adjust. There will be reasonable defaults set for most, and so the general user will not need to edit the file.

>> How are the builder bundles organized?

The bundles are organized logically for the user based on build environment, operating systems, 
and then any more detail that is necessary. For example, the bundle linked above is logically for an ubuntu
host, and builds a "secure build" environment container with Singularity 2.4.3. 
The folder hierarchy can look however is logical, with no limit on the number of different configurations that
might even share some of the same running dependencies (files in the folder). When you update or add a new builder
bundle, the organization should be discussed in the pull request.

>> How is a builder bundle registered?

To appear in the API to be available for `sregistry`, the config file simply needs to be physically in the folder
hierarchy. The magic of jekyll and Github pages automatically adds it to the API and thus it is
available for the `sregistry` client. This means that all you need to do is write a text configuration file, and drop
your build files in a folder to contribute a new builder. We would also like to add tests and checks for details
about these files.

>> Why are the builder bundles separate from the Singularity Builder executable?

In short, the builder bundles are community driven. This means that we not only want, but 
we encourge lots of contribution and rapid change! This is a different pace than the core software  
([sregistry](https://singularityhub.github.io/sregistry-cli)) that we would want to be 
slower changing.


>> How do the Singularity Builder executable and the builder bundles work together?

The user (you maybe?) is going to choose an `sregistry` endpoint (e.g., `google-compute`) and 
 launch a build that looks something like the following:

```
$ sregistry build https://www.github.com/vsoch/hello-world
```

If I wanted to customize the default configuration, I would grab it first, and then add it to
my request:

```
$ sregistry build templates /cloud/google/compute/ubuntu/securebuild-2.4.3.json > config.json
$ sregistry build https://www.github.com/vsoch/hello-world --config config.json
```

What might you edit? Maybe the instance type, or the size of the disk. The environment variables exposed
by each builder have a [general core set](/builders/environment) shared by all builders, and then variables
specific to the one you have chosen, which will be dumped into the config.json file for your inspection.

>> How do I select a specific recipe?
You would just provide the relative path, as the second argument, after the Github repository url:

```
$ sregistry build https://www.github.com/singularityhub/hello-registry os/ubuntu/Singularity.14.04
```
While the build doesn't use your local files (it will clone from Github) we find it helpful to request
the build from the same Github repository, that way you can use autocompletion to be sure about the recipe path.

>> Why is there a Github repository there?

We are still hecklers for reproducibility, so the builds aren't done from files on your local machine. 
Akin to Singularity Hub, the builder will start from your **version controlled** Github repository to perform
the build. The builds will capture the repository information (commit, branch, base, etc.) with associated 
object metadata. 


>> Why should I bother saving a configuration file?

Again for reproducibility, in case a builder bundle changes, you would want to keep a record. Having 
this kind of setup was inspired by [runc](https://github.com/opencontainers/runtime-spec/blob/master/config.md),
which was really awesome to use! The other reason is that for any given build repository, you might want to 
build the same container under different conditions. For example, I might have:

```
sregistry build config-debian.json
sregistry build config-gpu.json
...
```

and from this I could build "the same" containers and understand how they might be different.

>> What if I have private builder bundles?

The repository of the builder bundle that is cloned by your builder is in fact a variable!
This means that you can maintain your own builder bundles repository that works
with the software. We do hope you contribte here, but we understand if your institution does
not allow this.


<div>
    <a href="/builders/"><button class="previous-button btn btn-primary"><i class="fa fa-chevron-left"></i> </button></a>
    <a href="/builders/contribute-builder"><button class="next-button btn btn-primary"><i class="fa fa-chevron-right"></i> </button></a>
</div><br>
