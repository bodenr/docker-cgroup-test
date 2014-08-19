Docker cgroup tests
===============

A set of test utilities for validating cgroup aspects of docker LXC
with the ```lxc``` execution engine with docker.

Current utils support for testing of:

* BLKIO - async / sync using container bind mount
* CPUSET - validate CPU pinning
* MEM - limit memory usage

