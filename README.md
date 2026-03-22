<div align="center">
	<h1>GoodPool</h1>
	<p>A simple, flexible, and lightweight <code>object pooling module</code> for Roblox that works with any type of object, not just Instances.</p>
	<a href="https://thecogumeta.github.io/goodpool/"><strong>View docs</strong></a>
</div>

<!--moonwave-hide-before-this-line-->

## Why GoodPool?

In many Roblox projects, repeatedly creating and destroying objects can cause unnecessary allocations and performance overhead. Object pooling solves this by **reusing objects instead of constantly creating new ones**.

**GoodPool** provides a minimal and generic pooling system where you define:

- how objects are **created**
- how objects are **initialized when acquired**

The module then handles the pooling logic for you.

## Features

- **Generic Pooling**: Works with any object type.
- **Lightweight**: Minimal overhead and simple API.
- **Flexible**: Define custom creation and initialization logic.
- **Reusable**: Helps reduce allocations and improve performance.
