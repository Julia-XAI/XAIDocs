# Explainable AI in Julia

The Julia-XAI ecosystem hosts [Explainable AI (XAI)](https://en.wikipedia.org/wiki/Explainable_artificial_intelligence) 
methods written in the [Julia programming language](https://julialang.org),
with a focus on post-hoc, local input-space explanations of black-box models.
In simpler terms, methods that try to answer the question 
*"Which part of the input is responsible for the model's output?"*.

![Julia-XAI organization](https://julia-xai.github.io/XAIDocs/docs/src/assets/org.png)

The ecosystem is organized into several packages.
As a user, you only need to install the packages that implement the methods you want to use.

As a developer, you can make use of the [XAIBase.jl interface](https://julia-xai.github.io/XAIDocs/XAIBase/dev/interface/)
to quickly implement or prototype new methods without having to write boilerplate code.

## Where to start
##### New users:
Our recommended starting point into the Julia-XAI ecosystem is the 
[Getting started](@ref docs-getting-started) guide.

##### New developers:
If you want to implement a method, take a look at the [common interface
defined in XAIBase.jl](https://julia-xai.github.io/XAIDocs/XAIBase/dev/interface/).

## Contributing
We welcome all contributions to the Julia-XAI ecosystem!
Please contact us if you want your package to be included in this organization.
