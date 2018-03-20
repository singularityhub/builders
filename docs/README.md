---
layout: default
title: Singularity Registry Builders
pdf: true
permalink: /
---

<div style="float:right; margin-bottom:50px; color:#666">
</div>

<div>
    <img src="assets/img/logo.png" style="float:left">
</div><br><br>


# The Builders
Welcome to the Builders documentation! <a href="https://vsoch.github.io/builders/configs.json" target='_blank'>[builder-manifest]</a><a href="https://vsoch.github.io/sherlock_vep/" target='_blank'>[static-demo]</a>.


## What are the Builders?
Hi friends! Welcome to the builders documentation! The Builder robots are served 
faithfully by the [Singularity Global Client](https://singularityhub.github.io/sregistry-cli)
so you can run your own builds on different clouds of your choosing. This documentation is intended for
**developers** of builders, and not using the builders. For using the builders, see the [Singularity Global Client](https://singularityhub.github.io/sregistry-cli/clients). The builder that you use (e.g., Google Compute) will logically map to the client there!

## Why was it created?
<a href="https://www.singularity-hub.org" target="_blank">Singularity Hub</a> can support building of scientific containers that fall within a specific set of build environment and institutional needs. Specifically, the Singularity Hub Builders will perform a secure build and serve public containers that take 2 hours or less to build. If you belong to an institution that needs to build privately, needs to build at scale, or needs to build with a different environment entirely, it would be almost impossible for Singularity Hub to handle your use case. 

For this reason in 2016 we developed <a href="https://singularityhub.github.io/sregistry" target="_blank">Singularity Registry</a>, allowing an institution to deploy their own registry and push containers to it. The idea behind this open source initiative is that while it would be hard to provide a central solution that works for all the different kinds of use cases, a modular and distributed framework that allows the single user or institution to select some set of builders and authorization plugins would go very far. Some registries will want to build, and others may not. Some might want to serve private containers, and others not. Some might want to use cloud resources, and others not. To meet the goals of flexibility and user needs, these builders will work with a Singularity Registry to provide not only storage but also building.

## Builder Development
Read here if you are interested in adding a new builder. These sections will explain how this site serves a static builder API, and the contents of the metadata files included within.
 - [Frequently Asked Questions](/builders/faq): What is a builder bundle? How is this repository organized? This is a good place to start if you haven't looked here before.
 - [Contribute A Builder](/builders/contribute-builder): a helpful guide to general steps to develop a new builder bundle for this repository.

## Available Builders
Read here if you want to learn about how to contribute to a particular builder. If you are adding a new builder, you will want to add your notes and documentation under a section here.
 - [Google Compute & Storage](/builders/builder-google-compute): The set of Google Compute builders are optimized to build on Google Compute, and upload results to Google Storage.


Thanks for your patience as we develop the software and documentation! Please <a href="https://github.com/singularityhub/builders" target="_blank">reach out</a> if you have a question or want to contribute.

## Getting Help
This is an open source project. Please contribute to the package, or post feedback and questions as <a href="https://github.com/singularityhub/builders" target="_blank">issues</a>. You'll notice a little eliipsis (<i class="fa fa-ellipsis-h"></i>) next to each header section. If you click this, you can open an issue relevant to the section, grab a permalink, or suggest a change. You can also talk to us directly on Gitter.

[![Gitter chat](https://badges.gitter.im/gitterHQ/gitter.png)](https://gitter.im/singularityhub/lobby)

## License

This code is licensed under the Affero GPL, version 3.0 or later [LICENSE](https://github.com/singularityhub/builders/blob/master/LICENSE).


<div>
    <a href="/builders/faq"><button class="next-button btn btn-primary"><i class="fa fa-chevron-right"></i> </button></a>
</div><br>
