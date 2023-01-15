# About Camunda Platforms

This playground focuses on orchestrating [Robot Framework](https://robotframework.org/rpa/) automation packages with [Camunda Zeebe](https://camunda.com/platform/zeebe/) process engine. Yet, the same approach works as well with also [Camunda Platform 7 Community Edition](https://camunda.com/download/).

So, what are the differences...?

## Zeebe

```{figure} zeebe-architecture.svg
```

### Thoughts on Zeebe

* Future is supported by Camunda
* Simple, event based, distributed
* Most of "Camunda Platform" closed source
* Platfrom 8 is Zeebe with applications
* Custom "source available" license
* Multi-instance is simple, trivial
* No file variable, only JSON and FEEL
* RCC integration with [parrot-rcc](https://github.com/datakurre/parrot-rcc)

## Platform 7


```{figure} camunda-architecture.svg
```

### Thoughts on Platform 7

* Future may depend on the community
* Complete, transactional, monolith
* "Embedded Java engine with External Task Pattern"
* Most of "Camunda Platform" open source
* Never 100 % feature parity with Zeebe
* Apache License 2.0, "open core model"
* Multi-instance may not be trivial
* Files, Java variable types
* Expressions and scripts with any language
* RCC integration with [carrot-rcc](https://github.com/datakurre/carrot-rcc)

