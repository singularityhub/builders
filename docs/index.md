---
permalink: docs
title: Docs
---

# Singularity Builder Developer Documentation
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

## 2. Understand the entrypoint
The [sregistry](https://singularityhub.github.io/sregistry-cli/client-google-compute) builder
is going to discover your configuration, the json file, via the manifest served by
the main repository, for example if the user runs:

```
```

He will see a list of options:

```
```

and then can retrieve a particular one (such as your manifest)

```
```
