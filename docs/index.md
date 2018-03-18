---
permalink: docs
title: Docs
---

This is a brief set of documentation to help the developer contribute a new
or update Singularity Builder. 

## Creating a new builder
You should take the following steps:

### 1. Decide on organization
If you are slightly tweaking an already existing configuration, then you can
simply copy the file, give it an appropriate name, and edit the front end
matter for your needs. If you are creating a new builder bundle (typically this
means you want a different runscript logic or see the organization of your
builder as novel) then create a new folder for it.  As is described in the
[README.md](../README.md), you will need to create an entrypoint `run.sh` and
one or more configuration files (e.g., `securebuild-2.4.3.json`).

```
├── google
│   └── compute
│       └── ubuntu
│           ├── securebuild-2.4.3.json
│           └── run.sh
```

### 2. Understand the entrypoint
The [sregistry](https://singularityhub.github.io/sregistry-cli/client-google-compute) builder
is going to discover your configuration, the json file, via the manifest served by
the main repository, for example the user can retrieve a list of templates:

```
$ sregistry build templates
1  /cloud/google/compute/ubuntu/securebuild-2.4.3.json
```

and then can retrieve a particular one (such as your manifest)

```
$ sregistry build templates cloud/google/compute/ubuntu/securebuild-2.4.3.json
...
            "SINGULARITY_RUNSCRIPT": "run.sh",
            "SREGISTRY_BUILDER_machine_type": "n1-standard-1"
        },
        "tags": [
            "ubuntu",
            "singularity"
        ]
    },
    "links": {
        "self": "https://singularityhub.github.io/builders/cloud/google/compute/ubuntu/securebuild-2.4.3.json"
    }
}
```

The user is likely going to parse this into a file:

```
$ sregistry build templates cloud/google/compute/ubuntu/securebuild-2.4.3.json >> config.json
```
Notice anything about that template name/id? It's just a path relative to the root
of this repository, pointing directly to the json file! This means that the variables that you define
in the file, along with the configuration data structure (the content of the file) are parsed on Github pages 
into what you see when you issue that command. To see the complete output of the above,
go to the [selfLink](https://singularityhub.github.io/builders/cloud/google/compute/ubuntu/securebuild-2.4.3.json) 
and then compare that with the [file it renders from](https://github.com/singularityhub/builders/blob/master/_cloud/google/compute/ubuntu/securebuild-2.4.3.json). 

### 3. Understand the variables
The content of the file is important! The json data structure at the bottom, the content
of the file, has the [Google Compute configuration start](https://cloud.google.com/compute/docs/tutorials/python-guide#adding-an-instance) for all variables that we probably aren't going to change. Keep in mind that the user
**can** change any and everything when the template is created, but these aren't exposed nicely in the documentation because they are unlikely to change. The header chunk at the top (the part in yaml) defines the variables that need to be defined,
and likely will change, under the `metadata` field. How does it work? The user will generate a json configuration file
using the builder bundle API (the call we showed above), customize the variables, and then they will be send to the
builder as metadata when creating the instance. The header also defines a main 
entry point (`runscript`) meaning that once the builder instance is created, the repository cloned, and we are sitting in
the directory with our builder bundle, this is the script that is called. This is important for the developer to know
because...

>> If you develop a new builder that deviates or requires special variables, you **must** write a clear README.md to give this instruction to the user's of your template!

This means that you need to generate a *.json file akin to this in order to add a builder bundle. We will talk about this next. For complete (userland usage), see the [sregistry docs](https://singularityhub.github.io/sregistry-cli/client-google-compute). To be explicitly clear, this variable in the json file in the Github repository:

```
metadata:
 - key: SINGULARITY_REPO
   value: "https://github.com/cclerget/singularity.git"
```

will be rendered via the [builder bundle API](https://singularityhub.github.io/builders/cloud/google/compute/ubuntu/securebuild-2.4.3.json) in the "metadata" section:

```
"metadata": { 
          "GOOGLE_COMPUTE_PROJECT": "debian-cloud",
          "SINGULARITY_REPO": "https://github.com/cclerget/singularity.git",
...
           }
},
```

and when parsed into a [configuration for the builder](https://cloud.google.com/compute/docs/tutorials/python-guide#adding-an-instance), it is sent as metadata:

```
"metadata": {
            "items": [{
                "key": "SINGULARITY_REPO",
                "value": "https://github.com/cclerget/singularity.git"
                ...
            }]
        }
```

and then the metadata is retrieved by the instance, either in the [base templates](https://github.com/singularityhub/sregistry-cli/tree/master/sregistry/templates) to get things 
started under the sregistry client (environment variables that start with `SREGISTRY_BUILDER_*`) or 
by the run entrypoint (`run.sh`, environment variables that start with `SINGULARITY_*` or other)  

```
METADATA="http://metadata/computeMetadata/v1/instance/attributes"
SINGULARITY_REPO=$(curl ${METADATA}/SINGULARITY_REPO -H "Metadata-Flavor: Google")
```

Finally, if you see variables that have keys but not values, this suggests that these are optional (and
have no defaults).

```
 - key: SINGULARITY_COMMIT
```

For the above, the user **could** define the `SINGULARITY_COMMIT` in the config.json file
if he wanted a particular commit of the software, but it's not required.

And there we have it! 

### 4. Understand how to customize
This means that you will be good to start off with one of the already 
existing builder bundles, and possibly tweak the defaults to start off with a different instance
family and type entirely:

```
metadata:
 - key: GOOGLE_COMPUTE_PROJECT
   value: "debian-cloud"
 - key: SREGISTRY_BUILDER_machine_type
   value: "n1-standard-1"
 - key: GOOGLE_COMPUTE_IMAGE_FAMILY
   value: "debian-8"
```

Yes, the variables that start with `GOOGLE_COMPUTE_*` are for that namespace! You can get
a different base image by changing them. You will likely want to keep the core variables 
shown above to get the builder bundle and Singularity version, but you are totally free to
change defaults, or even add your own to do different things! For example:

 - You can decide that installing Singularity every time is slow, and preconfigure an image with dependencies, remove the variables for the `SINGULARITY_*` namespace, and just start with an instance ready to go! This is what Singularity Hub does, so we don't need to install Singularity and prepare an instance each time.
 - You could write a different entrypoint that also does custom logging or notification to my platform of choice, and ask the user to add a `MYNAMESPACE_*`

### 5. Understand what you are responsible for
Looking at the existing builders is a good start, generally. To be more specific, your build entry point should handle the following:

 - The builder bundle will be obtained via the [scripts](https://github.com/singularityhub/sregistry-cli/tree/master/sregistry/templates) served with the `sregistry client` and the `SREGISTRY_BUILDER_*` namespace. You should include these in your header.
 - You should also include the `SINGULARITY_*` namespace to determine the version of Singularity to install, unless you preconfigure an instance with it already installed (and then could remove this step all together). 
 - You are then responsible for running the build with whatever settings are desired.
 - Any kind of logging or display of outputs is up to you! For these default templates, I am going to have web accessible logs (for checking during build) and also some kind of notification (TBA).
 - You are responsible for dealing with kill times and timeouts, or generally deciding how to deal with things when they go wrong! For these first templates, I am using a runtime limit of 10 hours, at which point the job is killed.
 - You are responsible for cleaning up (or not) the instance. For these first templates, I have a function that will allow the instance to... destroy itself. Yes, it's a little dark.
 - You are responsible for writing good notes and documentation for your configurations! If you need help, please [reach out](https://www.github.com/singularityhub/builders/issues)
