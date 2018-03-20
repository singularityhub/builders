---
layout: default
title: Singularity Google Compute Builder
pdf: true
permalink: /builder-google-compute
toc: true
---

# Singularity Google Compute Builder

The Google Compute Builder is the first builder offered by the `sregistry` client! For builder usage, see the 
[sregistry documentation](https://singularityhub.github.io/sregistry-cli/client-google-compute). These notes are relevant to development, meaning customizing or appending the files in this repository.

## Creating a new builder
You should take the following steps:

### 1. Decide on organization
If you are slightly tweaking an already existing configuration, then you can
simply copy the file, give it an appropriate name, and edit the front end
matter for your needs. If you are creating a new builder bundle (typically this
means you want a different runscript logic or see the organization of your
builder as novel) then create a new folder for it. In the picture below, we have a file
`securebuild-2.4.3.json` that has an entrypoint of `run.sh`:

```
├── google
│   └── compute
│       └── ubuntu
│           ├── securebuild-2.4.3.json
│           └── run.sh
```

### 2. Understand the entrypoint
In a nutshell, it looks like this:

```
[ sregistry ] --> [ builder-builder API ] --> [ config.json ] --> [ deployment ]
```

The [sregistry](https://singularityhub.github.io/sregistry-cli/client-google-compute) builder
is going to discover your configuration, the json file, via the manifest served by
the bulider bundle API (this repository) and then produce a configuration template (`config.json`)
that the user can customize for the deployment. The user can also discover the configuration
templates available programatically! For example the user can retrieve a list of templates:

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
            "google-compute",
            "google-storage",
            "singularity"
        ]
    },
    "links": {
        "self": "https://singularityhub.github.io/builders/cloud/google/compute/ubuntu/securebuild-2.4.3.json"
    }
}
```

The user is likely going to save this into a file, in case you change it, or if he wants to customize it:

```
$ sregistry build templates cloud/google/compute/ubuntu/securebuild-2.4.3.json > config.json
```

Notice anything about that template name/id? It's just a path relative to the root
of this repository, pointing directly to the json file! This is generated automatically for you
based on the location, which is why you should think carefully about this choice.

### 3. Understand the Configuration Template

The data structure we dump into `config.json` is served automatically via the repository
restful (static) API, and might [look like this](https://singularityhub.github.io/builders/cloud/google/compute/ubuntu/securebuild-2.4.3.json). Compare that with the [file it renders from](https://github.com/singularityhub/builders/blob/master/_cloud/google/compute/ubuntu/securebuild-2.4.3.json). This file is the one that a developer would write 
or customize. Notice that this example builder bundle is relevant for Google Compute engine, meaning that the `google-compute` builder is the one that knows how to use it. We represent this information in tags.

#### The Front Matter
You might be famiiar with Jekyll [front Matter](https://jekyllrb.com/docs/frontmatter/) that broadly is a section of yaml that serves metadata variables for a page. This is the header chunk at the top of any *.json page in this repository! This section defines the variables that are either different from the [defaults set by sregistry](/builders/environment) for a general builder, or specific to Google Compute or Google Storage. The variables might also include something that you want users to set that is specific to your builder, such as a logging email. These variables that we want to render into the `metadata` field of our config.json, meaning the user is shown them up front, and under the `metadata` front matter in the file you are looking it.

### The Content
The content is everything **below** the front matter. For a Jekyll blog this might be paragraphs, but for a statically rendered API this is json content! So the json data structure at the bottom in our examples above has the [Google Compute configuration start](https://cloud.google.com/compute/docs/tutorials/python-guide#adding-an-instance) for a good set of variables that are not likely to change. The user **can** change any and everything when the template is created. 


### 4. Understand Translation
How does this yaml front matter turn into a configuration file? The user will generate the file
using the builder bundle API (the call we showed above), customize the variables, and then they will be send to the
builder as metadata when creating the instance. This process will vary based on the compute environment, and for Google Compute we use the metadata API. Let's take a look at this journey!

Here is a variable in the json front end matter in the Github repository:

```
metadata:
 - key: SINGULARITY_REPO
   value: "https://github.com/cclerget/singularity.git"
```

This will be rendered via the [builder bundle API](https://singularityhub.github.io/builders/cloud/google/compute/ubuntu/securebuild-2.4.3.json) in the "metadata" section:

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

and then the metadata is retrieved by the instance:

```
METADATA="http://metadata/computeMetadata/v1/instance/attributes"
SINGULARITY_REPO=$(curl ${METADATA}/SINGULARITY_REPO -H "Metadata-Flavor: Google")
```

You also might notice variables that have keys but not values, this suggests that these are optional (and
have no defaults).

```
 - key: SINGULARITY_COMMIT
```

For the above, the user **could** define the `SINGULARITY_COMMIT` in the config.json file
if he wanted a particular commit of the software, but it's not required. We put it there so when he
dumps the config.json into his folder, he sees it as an option.

And there we have it! Any variables that you add as metadata will be sent to your instance, so for 
example, you would retrieve them as above in your `run.sh` (the main entrypoint for your builder) script.


### 5. Understand the Variables
The configuration file can overwrite any of the [global builder environment](/builders/environment) 
variables as needed. In the example linked above, we change the default Singularity repository and
branch to use a secure build. For Google Storage, other than [runtime variables needed by the 
user](https://singularityhub.github.io/sregistry-cli/client-google-compute) we also require the following. 
Remember that by the time the builder is running, we already have chosen a Google Cloud Project, zone, etc.


##  Google Compute Namespace

| Variable | Description | Default |
|----------|---------|-------------|
| SREGISTRY_COMPUTE_CONFIG | The default builder bundle to use for `google-compute` | `google/compute/ubuntu/securebuild-2.4.3` |
| SREGISTRY_BUILDER_STORAGE_BUCKET | The bucket to get or create. | If not set, defaults to `sregistry-$USER` |
| SREGISTRY_BUILDER_machine_type | The Google Compute instance type | `n1-standard-1` |
| SREGISTRY_BUILDER_disk_size | The Google Compute disk size, in GB | `100` |
| GOOGLE_COMPUTE_PROJECT | The project with the base image | `debian-cloud` |
| GOOGLE_COMPUTE_IMAGE_FAMILY | The image family to use for the disk | `debian-8` |
| SREGISTRY_GOOGLE_STORAGE_PRIVATE | Should images uploaded to storage be private? | false | 


### 6. Understand how to customize
You will do well to start off with one of the already 
existing builder bundles, and possibly tweak the defaults. For example, you could
 start off with a different instance family and type entirely by changing these variables:

```
metadata:
 - key: GOOGLE_COMPUTE_PROJECT
   value: "debian-cloud"
 - key: SREGISTRY_BUILDER_machine_type
   value: "n1-standard-1"
 - key: GOOGLE_COMPUTE_IMAGE_FAMILY
   value: "debian-8"
```

In the example that we showed, we changed the branch and repository to build Singularity from, so we 
wrote this:

```
 - key: SINGULARITY_BRANCH
   value: "feature-squashbuild-secbuild-2.4.3"
 - key: SINGULARITY_REPO
   value: "https://github.com/cclerget/singularity.git"
```

There are other really easy ways to customize! 

 - You can decide that installing Singularity every time is slow, and preconfigure an image with dependencies, remove the variables for the `SINGULARITY_*` namespace, and just start with an instance ready to go! This is what Singularity Hub does, so we don't need to install Singularity and prepare an instance each time.
 - You could write a different entrypoint that also does custom logging or notification to my platform of choice, and ask the user to add a `MYNAMESPACE_*`
 - You could decide running `run.sh` isn't what you want to do, and change the `SREGISTRY_BUILDER_RUNSCRIPT` variable:

```
- key: SREGISTRY_BUILDER_RUNSCRIPT
  value do-this-instead.sh
```

Remember that when you are designing your builder bundle, the build is executed relative to the bundle folder with your configuration file in it.

### 6. Understand Storage

#### Organization
The files in storage are organized based on the Github repository uri and file hash, however the images themselves are found via a metadata value in the object, `type:container`. This technically means you can upload them to whatever hierarchy fits your needs, and we recommend the following:

```
gs://[storage-bucket]/github.com/[github-namespace]/[sha256sum]:[tag].simg
```
These components can be broken into these parts, and we provide an example:

```
Upload with format: 
[storage-bucket]     : sregistry-vanessa 
[github-namespace]   : github.com/[container]/[branch]/[commit]
  [container]        : eilon-s/sherlock_vep
  [commit]           : c76f5591cb09e7d24b485872c5983e1208cec509
  [branch]           : master
[sha256sum]          : 591c0bd8879547909a98966ef43b17ce8d1a50712121d547b0e823f7452443fe
[tag]                : latest
gs://[storage-bucket]/github.com/[github-namespace]/[sha256sum]:[tag].simg
```
Meaning that the final container object would look like this:

```
gs://sregistry-vanessa/github.com/eilon-s/sherlock_vep/master/c76f5591cb09e7d24b485872c5983e1208cec509/591c0bd8879547909a98966ef43b17ce8d1a50712121d547b0e823f7452443fe:latest.simg
```

#### Metadata
The following metadata is recommended. This metadata is stored with the object, and makes your container better 
searchable. The `type:container` is **required** if you want it to be found by `sregistry search`.

```
type:container
client:sregistry
tag:[tag]
commit:[commit]
hash:[sha256sum]
uri:[container-namespace]:[tag]@[commit]
```

### 7. Understand what you are responsible for
Looking at the existing builders is a good start, generally. To be more specific, your build entry point should handle the following:

 1. The builder bundle will be obtained via the [startup-scripts](https://github.com/singularityhub/sregistry-cli/tree/master/sregistry/templates) served with the `sregistry client`, so look here to understand how setup is done before cloning your builder bundle.
 2. Look at the [environment variables](/builders/environment) involved in this process. Do you want to change any of them? 
 3. Does your `run.sh` (or other specific `SREGISTRY_BUILDER_RUNSCRIPT` perform the build, handle logging if desired, and upload to storage? Did you decide on a metadata and organization format?
 4. Any kind of logging or display of outputs is up to you! For these default templates, I am going to have web accessible logs (for checking during build) and also some kind of notification (TBA). Right now they are... [green and black awesome](https://vsoch.github.io/sherlock_vep/), ha.
 5. You are responsible for dealing with kill times and timeouts, or generally deciding how to deal with things when they go wrong! For these first templates, I am using a runtime limit of 10 hours, at which point the job is killed. The debugging time is then 4 hours, meaning when there is a non zero exit status, we hang around for 4 more hours to give the user a chance to shell inand debug. Actually, you are responsible for cleaning up (or not) the instance. For these first templates, I have a function that will allow the instance to... destroy itself. Yes, it's a little dark.
 6. You are responsible for writing good notes and documentation for your configurations! If you need help, please [reach out](https://www.github.com/singularityhub/builders/issues)
 7. Generally, for all custom variables, along with listing them in your front end yaml matter you should write a clear README.md to give another head's up to the user.

<div>
    <a href="/builders"><button class="previous-button btn btn-primary"><i class="fa fa-chevron-left"></i> </button></a>
    <a href="/builders/environment"><button class="next-button btn btn-primary"><i class="fa fa-chevron-right"></i> </button></a>
</div><br>
