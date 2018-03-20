---
layout: default
title: Contribute A Builder
pdf: true
permalink: /environment
toc: false
---

# Environment
While each builder might have specific environment needs (for example, Google Cloud
might require a variable for a Google Storage bucket) there are a set of variables that
support the general flow of the builders, namely:

 1. We have to know the **builder bundle** and repository the user wants to use
 2. We must know the **Singularity** version and repository to install
 3. We must know the **user's repository** that is being cloned to build from
 4. We must know the **container** URI being requested for build

The fifth item (unlisted) would include any custom environment variables for a builder, 
not documented here on the global level. To support this, we use three environment namespace
that generally map to each category above:

 1. `SREGISTRY_BUILDER_*` refers to variables for the builder
 2. `SINGULARITY_*` refers to Singularity variables
 3. `SREGISTRY_USER_*` refers to the user's repository, and 
 4. `SREGISTRY_CONTAINER_*` to the container being built.

Each are shown in the tables below. For any variable, a user can customize it by adding it
to their build configuration metadata. The way that the metadata is passed from the configuration
to the build environment depends on the builder bundle (for example, Google Compute uses their
metadata APIs) and this is handled for the user by the developer of the builder bundle. 

##  Singularity Builder Namespace

| Variable | Description | Default |
|----------|---------|-------------|
| SREGISTRY_BUILDER_REPO | `[required]` The builder bundle repository | https://www.github.com/singularityhub/builders |
| SREGISTRY_BUILDER_BUNDLE | `[required]` The configuration id to drive the build | `google/compute/ubuntu/securebuild-2.4.3`  |
| SREGISTRY_BUILDER_COMMIT | `[optional]` A commit to checkout | Not set |
| SREGISTRY_BUILDER_BRANCH | `[optional]` A branch to clone from | master |
| SREGISTRY_BUILDER_RUNSCRIPT | `[optional]` After clone and cd into `SREGISTRY_BUILDER_BUNDLE`, what script do we execute? | run.sh |
| SREGISTRY_BUILDER_ID | `[required]` The id for the builder bundle | automatically generated from the API |
| SREGISTRY_BUILDER_DEBUGHOURS | `[optional]` The number of hours to let the builder run if nonzero exit | 4 |
| SREGISTRY_BUILDER_KILLHOURS | `[optional]` Kill the build script process if goes over this number of hours | 10 |
| SREGISTRY_BUILDER_MANAGER | The base startup-script version to use | `apt` |

For the manager, we currently have support for debian/ubuntu flavors with `apt`. For additional
support (e.g., yum) please file an issue / contribute!


##  Singularity Namespace

| Variable | Description | Default |
|----------|---------|-------------|
| SINGULARITY_REPO | `[required]` The Singularity repository with securebuild | https://www.github.com/singularityware/singularity |
| SINGULARITY_RECIPE | The Singularity recipe to build, relative to the repository base | `Singularity` |
| SINGULARITY_BRANCH | `[optional]` A branch to clone from | Not set |
| SREGISTRY_COMMIT | `[optional]` A commit to checkout | master |


##  Singularity User Namespace

| Variable | Description | Default |
|----------|---------|-------------|
| SREGISTRY_USER_REPO | `[required]` The Github repository to build from. | Not set |
| SREGISTRY_USER_COMMIT | `[optional]` A commit to checkout | Not set |
| SREGISTRY_USER_BRANCH | `[optional]` A branch to clone from | master |
| SREGISTRY_USER_TAG | `[optional]` The tag for the container | latest |
| SREGISTRY_CONTAINER_NAME | The parsed uri for the container (`vsoch/hello-world`) for storage and metadata | Not set |


Now that you've read about the environments, read about [Builder Flow](/builders/builder-flow) or jump into more detail on [Google Compute & Storage](/builders/builder-google-compute).


<div>
    <a href="/builders/environment"><button class="previous-button btn btn-primary"><i class="fa fa-chevron-left"></i> </button></a>
    <a href="/builders"><button class="next-button btn btn-primary"><i class="fa fa-chevron-right"></i> </button></a>
</div><br>
